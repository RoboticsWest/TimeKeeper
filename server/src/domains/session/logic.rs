use std::sync::Arc;

use async_trait::async_trait;
use chrono::{DateTime, Utc};
use uuid::Uuid;

use crate::domains::notification::{
  LateReminderPolicy, NewNotification, NotificationRepository, STATUS_PENDING, TYPE_AUTO_CHECKOUT,
  TYPE_SESSION_END_REMINDER, TYPE_SESSION_START_REMINDER, ensure_session_reminders,
};
use crate::domains::settings::{DEFAULT_AUTO_CHECKOUT_AFTER_SECS, DEFAULT_CHECK_IN_WINDOW_SECS, SettingsRepository};
use crate::domains::team_member_session::{TeamMemberSession, TeamMemberSessionRepository};

use super::model::Session;
use super::repository::{SessionFilter, SessionRepository};

fn is_member_checked_in(ms: &TeamMemberSession) -> bool {
  ms.check_out_time.is_none()
}

/// A session that is past its end time, with precomputed state for both `SessionService`
/// (auto-checkout) and the Discord notification service (overtime/auto-checkout DM warnings).
pub struct PastEndSession {
  pub session_id: Uuid,
  pub session: Session,
  pub start_secs: i64,
  pub end_secs: i64,
  pub checked_in: Vec<TeamMemberSession>,
  pub next_start_secs: Option<i64>,
}

#[async_trait]
pub trait SessionLogic: Send + Sync {
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<Session>>;
  async fn get_all(&self) -> anyhow::Result<Vec<Session>>;
  /// Creates a session and schedules its Discord reminders.
  ///
  /// `late_policy` decides what happens to a reminder whose lead time has already elapsed -
  /// the common case of an admin creating a session a couple of hours out when the start
  /// reminder is set to 24 hours. The caller asks the operator; see `sessionReminderPreview`.
  async fn create(
    &self,
    start_time: DateTime<Utc>,
    end_time: DateTime<Utc>,
    location_id: Uuid,
    late_policy: LateReminderPolicy,
  ) -> anyhow::Result<Session>;
  #[allow(clippy::too_many_arguments)]
  async fn update(
    &self,
    id: Uuid,
    start_time: DateTime<Utc>,
    end_time: DateTime<Utc>,
    location_id: Uuid,
    finished: bool,
  ) -> anyhow::Result<Session>;
  async fn remove(&self, id: Uuid) -> anyhow::Result<()>;
  /// Checks a team member in to the eligible session at `location_id`, or checks them out if
  /// they're already checked in to any session. Returns `true` if now checked in, `false` if
  /// checked out.
  async fn check_in_out(&self, team_member_id: Uuid, location_id: Uuid) -> anyhow::Result<bool>;
  /// Finishes sessions past their end time: marks them finished once every member has checked
  /// out, or force-checks-out lingering members (enqueuing auto-checkout notifications) once
  /// either the configured grace period has elapsed or the next session at that location has
  /// started. Called on a schedule by `SessionService`.
  async fn process_past_end_sessions(&self) -> anyhow::Result<()>;
  /// One page of sessions matching `filter`, with the total number of matching rows.
  async fn query_page(&self, filter: &SessionFilter, offset: i64, limit: i64) -> anyhow::Result<(Vec<Session>, i64)>;
  /// Read-only view of unfinished sessions past their end time, with checked-in members and the
  /// next session's start time precomputed. Used by the Discord notification service to decide
  /// overtime/auto-checkout DM timing, independent of `process_past_end_sessions`'s mutations.
  async fn get_past_end_sessions(&self) -> anyhow::Result<Vec<PastEndSession>>;
}

pub struct DefaultSessionLogic<R: SessionRepository> {
  repo: R,
  team_member_sessions: Arc<dyn TeamMemberSessionRepository>,
  notifications: Arc<dyn NotificationRepository>,
  settings: Arc<dyn SettingsRepository>,
}

impl<R: SessionRepository> DefaultSessionLogic<R> {
  pub fn new(
    repo: R,
    team_member_sessions: Arc<dyn TeamMemberSessionRepository>,
    notifications: Arc<dyn NotificationRepository>,
    settings: Arc<dyn SettingsRepository>,
  ) -> Self {
    Self { repo, team_member_sessions, notifications, settings }
  }

  /// How far either side of a session a kiosk scan still counts as checking in to it.
  async fn check_in_window_secs(&self) -> i64 {
    self.settings.get().await.map_or(DEFAULT_CHECK_IN_WINDOW_SECS, |s| s.check_in_window_secs)
  }

  /// Grace period after a session's scheduled end before lingering members are checked out.
  async fn auto_checkout_after_secs(&self) -> i64 {
    self.settings.get().await.map_or(DEFAULT_AUTO_CHECKOUT_AFTER_SECS, |s| s.auto_checkout_after_secs)
  }

  /// Unfinished sessions with a start time, sorted ascending.
  async fn unfinished_sorted(&self) -> anyhow::Result<Vec<Session>> {
    let mut sessions: Vec<Session> = self.repo.get_all().await?.into_iter().filter(|s| !s.finished).collect();
    sessions.sort_by_key(|s| s.start_time);
    Ok(sessions)
  }

  async fn past_end_sessions(&self) -> anyhow::Result<Vec<PastEndSession>> {
    let now = Utc::now();
    let unfinished = self.unfinished_sorted().await?;
    let mut results = Vec::new();

    for (i, session) in unfinished.iter().enumerate() {
      if now <= session.end_time {
        continue;
      }

      let checked_in: Vec<TeamMemberSession> = self
        .team_member_sessions
        .get_by_session_id(session.id)
        .await?
        .into_iter()
        .filter(is_member_checked_in)
        .collect();

      // The next session *at this location*, not simply the next one anywhere. Check-in is
      // location-scoped, so a session starting in another room says nothing about whether
      // these members should have been signed out.
      let next_start_secs = unfinished
        .iter()
        .skip(i + 1)
        .find(|next| next.location_id == session.location_id)
        .map(|next| next.start_time.timestamp());

      results.push(PastEndSession {
        session_id: session.id,
        session: session.clone(),
        start_secs: session.start_time.timestamp(),
        end_secs: session.end_time.timestamp(),
        checked_in,
        next_start_secs,
      });
    }

    Ok(results)
  }
}

#[async_trait]
impl<R: SessionRepository> SessionLogic for DefaultSessionLogic<R> {
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<Session>> {
    self.repo.get(id).await
  }

  async fn get_all(&self) -> anyhow::Result<Vec<Session>> {
    self.repo.get_all().await
  }

  async fn create(
    &self,
    start_time: DateTime<Utc>,
    end_time: DateTime<Utc>,
    location_id: Uuid,
    late_policy: LateReminderPolicy,
  ) -> anyhow::Result<Session> {
    let session = self.repo.add(start_time, end_time, location_id, false).await?;

    // Reminders are created with the session rather than at send time, so they can be listed,
    // cancelled, and cascade-deleted with it.
    let settings = self.settings.get().await?;
    if let Err(e) =
      ensure_session_reminders(self.notifications.as_ref(), &session, &settings, Utc::now(), late_policy).await
    {
      // A session that exists without its reminders is recoverable (the notification service
      // backfills schedules); failing the create would not be.
      log::error!("[SessionLogic] Failed to schedule reminders for new session {}: {e}", session.id);
    }

    Ok(session)
  }

  async fn update(
    &self,
    id: Uuid,
    start_time: DateTime<Utc>,
    end_time: DateTime<Utc>,
    location_id: Uuid,
    finished: bool,
  ) -> anyhow::Result<Session> {
    let previous = self.repo.get(id).await?;
    let session = self
      .repo
      .update(id, start_time, end_time, location_id, finished)
      .await?
      .ok_or_else(|| anyhow::anyhow!("Session not found"))?;

    // Moving a session invalidates the lead times of any reminder not yet sent. Drop the
    // pending ones and re-derive them; anything already sent, cancelled or skipped is left
    // alone, so rescheduling never re-announces a session or revives an opt-out.
    let times_changed = previous.is_none_or(|p| p.start_time != session.start_time || p.end_time != session.end_time);
    if times_changed {
      for notification in self.notifications.get_by_session_id(session.id).await? {
        let is_session_wide = notification.notification_type == TYPE_SESSION_START_REMINDER
          || notification.notification_type == TYPE_SESSION_END_REMINDER;
        if is_session_wide && notification.is_pending() {
          self.notifications.remove(notification.id).await?;
        }
      }

      let settings = self.settings.get().await?;
      // Not the operator's decision this time: a reschedule that lands inside the lead time
      // should not fire a burst of "starting soon" messages for a session being edited.
      if let Err(e) =
        ensure_session_reminders(self.notifications.as_ref(), &session, &settings, Utc::now(), LateReminderPolicy::Skip)
          .await
      {
        log::error!("[SessionLogic] Failed to reschedule reminders for session {}: {e}", session.id);
      }
    }

    Ok(session)
  }

  async fn remove(&self, id: Uuid) -> anyhow::Result<()> {
    self.repo.remove(id).await
  }

  async fn check_in_out(&self, team_member_id: Uuid, location_id: Uuid) -> anyhow::Result<bool> {
    let now = Utc::now();

    let member_sessions = self.team_member_sessions.get_by_member_id(team_member_id).await?;
    for ms in member_sessions {
      if is_member_checked_in(&ms) {
        self
          .team_member_sessions
          .update(ms.id, ms.team_member_id, ms.session_id, ms.check_in_time, Some(now))
          .await?
          .ok_or_else(|| anyhow::anyhow!("Team member session not found"))?;
        // This may have been the last member out, which is what actually ends the session.
        self.repo.refresh_actual_times(ms.session_id).await?;
        return Ok(false);
      }
    }

    let window = self.check_in_window_secs().await;
    let unfinished = self.unfinished_sorted().await?;

    let mut best: Option<(Session, i64)> = None;
    for session in unfinished {
      if session.location_id != location_id {
        continue;
      }
      let start_secs = session.start_time.timestamp();
      let end_secs = session.end_time.timestamp();
      let now_secs = now.timestamp();

      if now_secs < start_secs - window || now_secs > end_secs + window {
        continue;
      }

      let distance = if now_secs >= start_secs && now_secs <= end_secs {
        0
      } else if now_secs < start_secs {
        start_secs - now_secs
      } else {
        now_secs - end_secs
      };

      if best.as_ref().is_none_or(|(_, d)| distance < *d) {
        best = Some((session, distance));
      }
    }

    let Some((session, _)) = best else {
      return Err(anyhow::anyhow!("No active session at this location"));
    };

    self.team_member_sessions.add(team_member_id, session.id, now, None).await?;
    // First person in sets the session's real start; a later arrival leaves it unchanged.
    self.repo.refresh_actual_times(session.id).await?;

    Ok(true)
  }

  async fn process_past_end_sessions(&self) -> anyhow::Result<()> {
    let now_secs = Utc::now().timestamp();
    let grace_secs = self.auto_checkout_after_secs().await;
    let past_end = self.past_end_sessions().await?;

    for pes in past_end {
      let session = &pes.session;
      let checked_in = &pes.checked_in;

      // Two independent triggers, whichever comes first:
      //   * the configurable grace period after this session's scheduled end has elapsed, or
      //   * the next session at this location has actually started - at which point anyone
      //     still signed in to the old one is unambiguously stale.
      //
      // The grace period used to be borrowed from the check-in window and measured *backwards
      // from the next session's start*, so a location with no next session scheduled never
      // auto-checked-out at all, and one with a session the following morning checked people
      // out hours before anybody had agreed to.
      let grace_elapsed = now_secs >= pes.end_secs + grace_secs;
      let next_session_started = pes.next_start_secs.is_some_and(|next| now_secs >= next);
      let auto_checkout_due = grace_elapsed || next_session_started;

      if checked_in.is_empty() {
        self
          .repo
          .update(session.id, session.start_time, session.end_time, session.location_id, true)
          .await?
          .ok_or_else(|| anyhow::anyhow!("Session not found"))?;
        self.repo.refresh_actual_times(session.id).await?;
        log::info!("[SessionService] Marked session {} as finished (no lingering members)", session.id);
      } else if auto_checkout_due {
        for ms in checked_in {
          self
            .team_member_sessions
            .update(ms.id, ms.team_member_id, ms.session_id, ms.check_in_time, Some(session.end_time))
            .await?
            .ok_or_else(|| anyhow::anyhow!("Team member session not found"))?;

          if let Err(e) = self
            .notifications
            .schedule(NewNotification {
              notification_type: TYPE_AUTO_CHECKOUT,
              session_id: session.id,
              team_member_id: Some(ms.team_member_id),
              // No lead time: it is due the moment the checkout happens.
              scheduled_for: None,
              status: STATUS_PENDING,
            })
            .await
          {
            log::error!(
              "[SessionService] Failed to enqueue auto-checkout notification for member {}: {e}",
              ms.team_member_id
            );
          }
        }

        self
          .repo
          .update(session.id, session.start_time, session.end_time, session.location_id, true)
          .await?
          .ok_or_else(|| anyhow::anyhow!("Session not found"))?;
        // Everyone is out now, so the session finally has a real end time.
        self.repo.refresh_actual_times(session.id).await?;
        log::info!(
          "[SessionService] Force-finished session {} (checked out {} members; reason: {})",
          session.id,
          checked_in.len(),
          if next_session_started { "next session at this location started" } else { "grace period elapsed" }
        );
      }
    }

    Ok(())
  }

  async fn query_page(&self, filter: &SessionFilter, offset: i64, limit: i64) -> anyhow::Result<(Vec<Session>, i64)> {
    self.repo.query_page(filter, offset, limit).await
  }

  async fn get_past_end_sessions(&self) -> anyhow::Result<Vec<PastEndSession>> {
    self.past_end_sessions().await
  }
}
