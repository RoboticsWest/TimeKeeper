use std::sync::Arc;
use std::sync::Mutex;
use std::time::{Duration, Instant};

use async_graphql::{Context, Error, ID, InputObject, Object, Result, SimpleObject, Subscription};
use chrono::{DateTime, Utc};
use futures_util::{Stream, StreamExt};
use tokio_stream::wrappers::BroadcastStream;
use uuid::Uuid;

use crate::auth::auth_helpers::require_permission;
use crate::auth::permissions::PermissionLevel;
use crate::events::{ChangeOperation, EVENT_BUS};
use crate::gql_common::{Change, Page, page_bounds};

use crate::domains::notification::{LateReminderPolicy, plan_session_reminders};
use crate::domains::settings::SettingsLogic;
use crate::domains::team_member::TeamMemberLogic;

use super::logic::SessionLogic;
use super::model::Session;
use super::repository::SessionFilter;

const RESOURCE: &str = "sessions";
const TABLE: &str = "sessions";

fn logic(ctx: &Context<'_>) -> Result<Arc<dyn SessionLogic>> {
  Ok(ctx.data::<Arc<dyn SessionLogic>>()?.clone())
}

/// Outcome of a PIN sign-in.
///
/// Carries the resolved member back to the caller so the kiosk can name them in
/// its confirmation toast. The kiosk already replicates team members (minus
/// their PINs), so an ID is enough to render a name and leaks nothing the
/// caller could not already read.
#[derive(SimpleObject)]
pub struct PinCheckInOut {
  /// True for checked in, false for checked out.
  pub checked_in: bool,
  pub team_member_id: Uuid,
}

/// Short PINs stored in plaintext are guessable, so PIN sign-in is rate
/// limited. This is a per-process counter rather than a per-caller one: kiosks
/// share a token, so there is no useful identity to key on, and the goal is
/// only to make bulk guessing slow rather than to authenticate the caller.
const PIN_ATTEMPT_WINDOW: Duration = Duration::from_secs(60);
const PIN_MAX_FAILURES_PER_WINDOW: u32 = 10;

static PIN_THROTTLE: Mutex<Option<(Instant, u32)>> = Mutex::new(None);

/// Returns false when the caller has burned through the failure budget.
fn pin_attempt_allowed() -> bool {
  let mut guard = PIN_THROTTLE.lock().unwrap_or_else(std::sync::PoisonError::into_inner);
  match *guard {
    Some((started, failures)) if started.elapsed() < PIN_ATTEMPT_WINDOW => failures < PIN_MAX_FAILURES_PER_WINDOW,
    // First attempt, or the previous window has expired.
    _ => {
      *guard = Some((Instant::now(), 0));
      true
    }
  }
}

/// Only *failures* count toward the budget - a busy kiosk with members typing
/// correct PINs is never throttled.
fn record_pin_failure() {
  let mut guard = PIN_THROTTLE.lock().unwrap_or_else(std::sync::PoisonError::into_inner);
  match *guard {
    Some((started, ref mut failures)) if started.elapsed() < PIN_ATTEMPT_WINDOW => *failures += 1,
    _ => *guard = Some((Instant::now(), 1)),
  }
}

/// Narrows `sessionPage`. Every field is optional; an empty list means "no constraint".
#[derive(InputObject, Default)]
pub struct SessionFilterInput {
  /// Sessions starting at or after this instant.
  pub from: Option<DateTime<Utc>>,
  /// Sessions starting strictly before this instant.
  pub to: Option<DateTime<Utc>>,
  pub location_ids: Option<Vec<Uuid>>,
  /// True for finished sessions only, false for unfinished, omitted for both.
  pub finished: Option<bool>,
}

impl From<SessionFilterInput> for SessionFilter {
  fn from(input: SessionFilterInput) -> Self {
    Self {
      from: input.from,
      to: input.to,
      location_ids: input.location_ids.unwrap_or_default(),
      finished: input.finished,
    }
  }
}

/// What creating a session at these times would do to its Discord reminders.
///
/// The Sessions dialog queries this before creating, so an admin scheduling a session two hours
/// out is told that the 24-hour reminder is already overdue and asked whether to send it - rather
/// than discovering it by seeing "@here Session tomorrow" appear seconds later for a session
/// starting the same afternoon.
#[derive(SimpleObject)]
pub struct SessionReminderPreview {
  /// True when at least one reminder's lead time has already elapsed.
  pub has_late_reminder: bool,
  /// Human-readable names of the reminders that would fire immediately.
  pub late_reminders: Vec<String>,
  /// How the session's day would render in a message right now ("today", "tomorrow", ...).
  pub relative_day: String,
}

#[derive(Default)]
pub struct SessionQuery;

#[Object]
impl SessionQuery {
  /// Every session.
  ///
  /// Kept for the kiosk and the calendar, which need the whole set. History views should use
  /// `sessionPage` — this grows by a few hundred rows a season.
  async fn sessions(&self, ctx: &Context<'_>) -> Result<Vec<Session>> {
    Ok(logic(ctx)?.get_all().await?)
  }

  /// One filtered, paged slice of sessions, newest start first.
  async fn session_page(
    &self,
    ctx: &Context<'_>,
    filter: Option<SessionFilterInput>,
    offset: Option<i32>,
    limit: Option<i32>,
  ) -> Result<Page<Session>> {
    require_permission(ctx, RESOURCE, PermissionLevel::Read)?;
    let (limit, offset) = page_bounds(offset, limit);
    let filter: SessionFilter = filter.unwrap_or_default().into();
    let (items, total) = logic(ctx)?.query_page(&filter, offset, limit).await?;
    Ok(Page::new(items, total, offset, limit))
  }

  /// Dry-run of the reminder scheduling for a session that does not exist yet.
  async fn session_reminder_preview(
    &self,
    ctx: &Context<'_>,
    start_time: DateTime<Utc>,
    end_time: DateTime<Utc>,
    location_id: Uuid,
  ) -> Result<SessionReminderPreview> {
    require_permission(ctx, RESOURCE, PermissionLevel::Read)?;
    let settings = ctx.data::<Arc<dyn SettingsLogic>>()?.get().await?;
    let now = Utc::now();

    // A throwaway session standing in for the one about to be created.
    let candidate = Session {
      id: Uuid::nil(),
      start_time,
      end_time,
      location_id,
      finished: false,
      actual_start_time: None,
      actual_end_time: None,
    };

    let planned = plan_session_reminders(&candidate, &settings, now, LateReminderPolicy::SendNow);
    let late_reminders: Vec<String> = planned
      .iter()
      .filter(|p| p.is_late)
      .map(|p| match p.notification_type {
        crate::domains::notification::TYPE_SESSION_START_REMINDER => "Session start reminder".to_string(),
        crate::domains::notification::TYPE_SESSION_END_REMINDER => "Session end reminder".to_string(),
        other => other.to_string(),
      })
      .collect();

    Ok(SessionReminderPreview {
      has_late_reminder: !late_reminders.is_empty(),
      late_reminders,
      relative_day: crate::time::format_relative_day(
        start_time.timestamp(),
        crate::time::parse_tz(&settings.timezone),
        now.timestamp(),
      ),
    })
  }
}

#[derive(Default)]
pub struct SessionMutation;

#[Object]
impl SessionMutation {
  /// Creates a session.
  ///
  /// `send_late_reminder` decides what happens to a reminder whose lead time has already
  /// elapsed: `true` sends it on the next tick, `false` records it as skipped. Defaults to
  /// `false` so a caller that does not ask the question never fires a surprise announcement;
  /// the UI asks and passes the operator's answer through.
  async fn create_session(
    &self,
    ctx: &Context<'_>,
    start_time: DateTime<Utc>,
    end_time: DateTime<Utc>,
    location_id: Uuid,
    send_late_reminder: Option<bool>,
  ) -> Result<Session> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    let policy =
      if send_late_reminder.unwrap_or(false) { LateReminderPolicy::SendNow } else { LateReminderPolicy::Skip };
    Ok(logic(ctx)?.create(start_time, end_time, location_id, policy).await?)
  }

  #[allow(clippy::too_many_arguments)]
  async fn update_session(
    &self,
    ctx: &Context<'_>,
    id: Uuid,
    start_time: DateTime<Utc>,
    end_time: DateTime<Utc>,
    location_id: Uuid,
    finished: bool,
  ) -> Result<Session> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    Ok(logic(ctx)?.update(id, start_time, end_time, location_id, finished).await?)
  }

  async fn delete_session(&self, ctx: &Context<'_>, id: Uuid) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Delete)?;
    logic(ctx)?.remove(id).await?;
    Ok(true)
  }

  /// Kiosk check-in/out by RFID scan - creates or closes a `team_member_sessions` row.
  async fn check_in_out(&self, ctx: &Context<'_>, team_member_id: Uuid, location_id: Uuid) -> Result<bool> {
    require_permission(ctx, "team_member_sessions", PermissionLevel::Write)?;
    Ok(logic(ctx)?.check_in_out(team_member_id, location_id).await?)
  }

  /// Kiosk check-in/out by quick PIN. Returns true for checked in, false for checked out.
  ///
  /// Resolution happens here rather than on the client on purpose: RFID tags
  /// are resolved client-side against fully replicated tables, but shipping
  /// every member's PIN to every kiosk would defeat the point of having one.
  async fn check_in_out_by_pin(&self, ctx: &Context<'_>, pin: String, location_id: Uuid) -> Result<PinCheckInOut> {
    // Same gate the kiosk already holds for RFID check-in.
    require_permission(ctx, "team_member_sessions", PermissionLevel::Write)?;

    let settings = ctx.data::<Arc<dyn crate::domains::settings::SettingsLogic>>()?.get().await?;
    if !settings.quick_pin_enabled {
      return Err(Error::new("PIN sign-in is not enabled."));
    }

    if !pin_attempt_allowed() {
      return Err(Error::new("Too many incorrect PINs. Please wait a moment and try again."));
    }

    let pin = pin.trim();
    let team_members = ctx.data::<Arc<dyn TeamMemberLogic>>()?;
    let Some(member) = team_members.get_by_quick_pin(pin).await? else {
      record_pin_failure();
      return Err(Error::new("PIN not recognised."));
    };

    let checked_in = logic(ctx)?.check_in_out(member.id, location_id).await?;
    Ok(PinCheckInOut { checked_in, team_member_id: member.id })
  }
}

#[derive(Default)]
pub struct SessionSubscription;

#[Subscription]
impl SessionSubscription {
  async fn session_changes(&self, ctx: &Context<'_>) -> Result<impl Stream<Item = Change<Session>>> {
    let logic = logic(ctx)?;
    let Some(bus) = EVENT_BUS.get() else {
      return Err(Error::new("Event bus not initialized"));
    };
    let rx = bus.subscribe(TABLE);

    Ok(BroadcastStream::new(rx).filter_map(move |change| {
      let logic = logic.clone();
      async move {
        let change = change.ok()?;
        let data = match change.operation {
          ChangeOperation::Delete => None,
          _ => logic.get(change.id.parse().ok()?).await.ok().flatten(),
        };
        Some(Change { operation: change.operation, id: ID(change.id), data })
      }
    }))
  }
}
