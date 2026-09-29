use std::sync::Arc;

use async_graphql::{Context, Error, ID, InputObject, Object, Result, Subscription};
use chrono::{DateTime, Utc};
use futures_util::{Stream, StreamExt};
use tokio_stream::wrappers::BroadcastStream;
use uuid::Uuid;

use crate::auth::auth_helpers::require_permission;
use crate::auth::permissions::PermissionLevel;
use crate::domains::session::SessionLogic;
use crate::domains::statistics::{MemberStatsLogic, SOURCE_ADMIN};
use crate::events::{ChangeOperation, EVENT_BUS, resolve_once};
use crate::gql_common::{Change, Page, page_bounds};

use super::logic::TeamMemberSessionLogic;
use super::model::{AttendanceSummary, SessionAttendanceCount, TeamMemberSession};
use super::repository::AttendanceFilter;

const RESOURCE: &str = "team_member_sessions";
const TABLE: &str = "team_member_sessions";

/// The session an attendance belongs to — needed to tell a late checkout from a punctual one.
fn sessions(ctx: &Context<'_>) -> Result<Arc<dyn SessionLogic>> {
  Ok(ctx.data::<Arc<dyn SessionLogic>>()?.clone())
}

fn logic(ctx: &Context<'_>) -> Result<Arc<dyn TeamMemberSessionLogic>> {
  Ok(ctx.data::<Arc<dyn TeamMemberSessionLogic>>()?.clone())
}

/// Narrows `attendance`. Every field is optional and an empty list means "no constraint",
/// matching a filter UI with nothing selected.
#[derive(InputObject, Default)]
pub struct AttendanceFilterInput {
  /// Check-ins at or after this instant.
  pub from: Option<DateTime<Utc>>,
  /// Check-ins strictly before this instant.
  pub to: Option<DateTime<Utc>>,
  pub team_member_ids: Option<Vec<Uuid>>,
  pub session_ids: Option<Vec<Uuid>>,
  pub location_ids: Option<Vec<Uuid>>,
  /// "student" / "mentor".
  pub member_types: Option<Vec<String>>,
  /// True for people still checked in, false for completed visits, omitted for both.
  pub checked_in_only: Option<bool>,
  /// Case-insensitive substring over the member's first, last and display name.
  pub search: Option<String>,
}

impl From<AttendanceFilterInput> for AttendanceFilter {
  fn from(input: AttendanceFilterInput) -> Self {
    Self {
      from: input.from,
      to: input.to,
      team_member_ids: input.team_member_ids.unwrap_or_default(),
      session_ids: input.session_ids.unwrap_or_default(),
      location_ids: input.location_ids.unwrap_or_default(),
      member_types: input.member_types.unwrap_or_default(),
      checked_in_only: input.checked_in_only,
      search: input.search,
    }
  }
}

#[derive(Default)]
pub struct TeamMemberSessionQuery;

#[Object]
impl TeamMemberSessionQuery {
  /// Every attendance row.
  ///
  /// Kept for the kiosk and the live check-in list, which genuinely need the current set and
  /// stay small. Anything that renders history should use `attendance` instead — this table
  /// grows without bound and will not stay loadable in one request.
  async fn team_member_sessions(&self, ctx: &Context<'_>) -> Result<Vec<TeamMemberSession>> {
    Ok(logic(ctx)?.get_all().await?)
  }

  /// Every visit nobody has checked out of yet — who is in the building right now.
  ///
  /// This exists so a client does not have to hold the entire attendance table to answer "is this
  /// member checked in?". That is all the kiosk board, the roster's check-in button and the RFID
  /// scan path ever asked of it, and the whole table grows without bound while this is bounded by
  /// the size of the team. Clients used to download every row at login to compute it.
  async fn open_attendance(&self, ctx: &Context<'_>) -> Result<Vec<TeamMemberSession>> {
    require_permission(ctx, RESOURCE, PermissionLevel::Read)?;
    Ok(logic(ctx)?.get_open().await?)
  }

  /// Attendance counters for the given sessions: people seen, and people still in.
  ///
  /// Asked for a page of sessions at a time. The Sessions table used to count these in Dart over a
  /// client-side copy of every attendance row ever recorded.
  async fn session_attendance_counts(
    &self,
    ctx: &Context<'_>,
    session_ids: Vec<Uuid>,
  ) -> Result<Vec<SessionAttendanceCount>> {
    require_permission(ctx, RESOURCE, PermissionLevel::Read)?;
    Ok(logic(ctx)?.counts_by_session(&session_ids).await?)
  }

  /// Table-wide attendance totals, for the KPI tiles that only ever showed a count.
  async fn attendance_summary(&self, ctx: &Context<'_>) -> Result<AttendanceSummary> {
    require_permission(ctx, RESOURCE, PermissionLevel::Read)?;
    Ok(logic(ctx)?.summary().await?)
  }

  /// When a member last checked in or out — what the kiosk's scan debounce compares against.
  async fn last_attendance_activity(&self, ctx: &Context<'_>, team_member_id: Uuid) -> Result<Option<DateTime<Utc>>> {
    require_permission(ctx, RESOURCE, PermissionLevel::Read)?;
    Ok(logic(ctx)?.last_activity_for_member(team_member_id).await?)
  }

  /// One filtered, paged slice of attendance, newest check-in first.
  ///
  /// Filtering and paging both happen in SQL, so the cost is proportional to the page rather
  /// than to the table.
  async fn attendance(
    &self,
    ctx: &Context<'_>,
    filter: Option<AttendanceFilterInput>,
    offset: Option<i32>,
    limit: Option<i32>,
  ) -> Result<Page<TeamMemberSession>> {
    require_permission(ctx, RESOURCE, PermissionLevel::Read)?;
    let (limit, offset) = page_bounds(offset, limit);
    let filter: AttendanceFilter = filter.unwrap_or_default().into();
    let (items, total) = logic(ctx)?.query_page(&filter, offset, limit).await?;
    Ok(Page::new(items, total, offset, limit))
  }
}

#[derive(Default)]
pub struct TeamMemberSessionMutation;

#[Object]
impl TeamMemberSessionMutation {
  async fn update_team_member_session(
    &self,
    ctx: &Context<'_>,
    id: Uuid,
    check_in_time: DateTime<Utc>,
    check_out_time: Option<DateTime<Utc>>,
  ) -> Result<TeamMemberSession> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    let logic = logic(ctx)?;
    let existing = logic.get(id).await?.ok_or_else(|| Error::new("Team member session not found"))?;
    let updated = logic.update(id, existing.team_member_id, existing.session_id, check_in_time, check_out_time).await?;

    // An admin filling in a checkout by hand is a real checkout, made by a real route, and is
    // recorded as such. Without this the row would keep whatever the check-in opened it with and
    // read as still open forever.
    let stats = ctx.data::<Arc<dyn MemberStatsLogic>>()?;
    match check_out_time {
      Some(at) => {
        let late = sessions(ctx)?.get(existing.session_id).await?.is_some_and(|session| at > session.end_time);
        stats.record_manual_checkout(id, SOURCE_ADMIN, late).await;
      }
      // The edit reopened the attendance, so the recorded checkout no longer describes anything.
      None => stats.record_reopened(id).await,
    }

    Ok(updated)
  }

  async fn delete_team_member_session(&self, ctx: &Context<'_>, id: Uuid) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Delete)?;
    let logic = logic(ctx)?;
    if logic.get(id).await?.is_none() {
      return Err(Error::new("Team member session not found"));
    }
    logic.remove(id).await?;
    Ok(true)
  }

  /// Deletes every attendance record, returning how many there were.
  ///
  /// One statement rather than the client looping a delete per row: that loop was one HTTP round
  /// trip *and* one change event per row, which over a link with any latency turned clearing a
  /// season's worth of data into minutes of sequential requests.
  async fn clear_attendance(&self, ctx: &Context<'_>) -> Result<i32> {
    require_permission(ctx, RESOURCE, PermissionLevel::Delete)?;
    let deleted = logic(ctx)?.clear().await?;
    Ok(i32::try_from(deleted).unwrap_or(i32::MAX))
  }

  async fn import_attendance_csv(&self, ctx: &Context<'_>, csv_data: String) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    logic(ctx)?.import_attendance_csv(&csv_data).await.map_err(|e| Error::new(e.to_string()))?;
    Ok(true)
  }
}

#[derive(Default)]
pub struct TeamMemberSessionSubscription;

#[Subscription]
impl TeamMemberSessionSubscription {
  async fn team_member_session_changes(
    &self,
    ctx: &Context<'_>,
  ) -> Result<impl Stream<Item = Change<TeamMemberSession>>> {
    let logic = logic(ctx)?;
    let Some(bus) = EVENT_BUS.get() else {
      return Err(Error::new("Event bus not initialized"));
    };
    let rx = bus.subscribe(TABLE);

    Ok(BroadcastStream::new(rx).filter_map(move |change| {
      let logic = logic.clone();
      async move {
        let change = change.ok()?;
        // A delete carries no row. Anything else is fetched once per event rather than once per
        // subscriber - see `resolve_once`.
        let data = if change.operation == ChangeOperation::Delete {
          None
        } else {
          let id = change.id.parse().ok()?;
          resolve_once(&change, || async move { logic.get(id).await.ok().flatten() }).await
        };
        Some(Change { operation: change.operation, id: ID(change.id), data })
      }
    }))
  }
}
