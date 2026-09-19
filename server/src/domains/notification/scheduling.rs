use async_trait::async_trait;
use chrono::{DateTime, Duration, Utc};

use crate::domains::session::Session;
use crate::domains::settings::Settings;

use super::logic::NotificationLogic;
use super::model::{
  Notification, STATUS_PENDING, STATUS_SKIPPED, TYPE_SESSION_END_REMINDER, TYPE_SESSION_START_REMINDER,
};
use super::repository::{NewNotification, NotificationRepository};

/// The one capability [ensure_session_reminders] needs.
///
/// Both the repository and the logic layer can schedule, and both call this - session creation
/// holds a repository, the notification service holds a logic. Naming the capability avoids
/// duplicating the function for each.
#[async_trait]
pub trait ReminderScheduler: Send + Sync {
  async fn schedule_reminder(&self, new: NewNotification<'_>) -> anyhow::Result<Notification>;
}

#[async_trait]
impl ReminderScheduler for dyn NotificationRepository {
  async fn schedule_reminder(&self, new: NewNotification<'_>) -> anyhow::Result<Notification> {
    NotificationRepository::schedule(self, new).await
  }
}

#[async_trait]
impl ReminderScheduler for dyn NotificationLogic {
  async fn schedule_reminder(&self, new: NewNotification<'_>) -> anyhow::Result<Notification> {
    NotificationLogic::schedule(self, new).await
  }
}

/// What to do with a reminder whose lead time had already elapsed by the time the session was
/// created - an admin scheduling a session two hours out when the reminder is set to 24 hours.
///
/// Firing it regardless is what the old code did implicitly, and it produced the confusing
/// "Session on tomorrow ..." message seconds after the session was created. Neither choice is
/// right in general, so the caller decides and the operator is asked.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum LateReminderPolicy {
  /// Send it on the next scheduler tick.
  SendNow,
  /// Record it as deliberately skipped, so nothing ever fires it.
  Skip,
}

/// A reminder that should exist for a session.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct PlannedReminder {
  pub notification_type: &'static str,
  pub scheduled_for: DateTime<Utc>,
  pub status: &'static str,
  /// True when the lead time had already passed at planning time.
  pub is_late: bool,
}

/// Works out which session-wide reminders a session should have, and when.
///
/// Pure so the timing rules can be tested without a database or a Discord token.
///
/// A reminder is planned only when its lead time is configured (> 0). A lead time that has
/// already elapsed yields `is_late`, and [LateReminderPolicy] decides whether that becomes a
/// pending reminder due immediately or a skipped one.
pub fn plan_session_reminders(
  session: &Session,
  settings: &Settings,
  now: DateTime<Utc>,
  late_policy: LateReminderPolicy,
) -> Vec<PlannedReminder> {
  let mut planned = Vec::new();

  let late_status = match late_policy {
    LateReminderPolicy::SendNow => STATUS_PENDING,
    LateReminderPolicy::Skip => STATUS_SKIPPED,
  };

  if settings.discord_start_reminder_mins > 0 {
    let due = session.start_time - Duration::minutes(settings.discord_start_reminder_mins);
    // A session already under way has no "starting soon" to announce, late policy or not.
    if session.start_time > now {
      let is_late = due <= now;
      planned.push(PlannedReminder {
        notification_type: TYPE_SESSION_START_REMINDER,
        scheduled_for: if is_late { now } else { due },
        status: if is_late { late_status } else { STATUS_PENDING },
        is_late,
      });
    }
  }

  if settings.discord_end_reminder_mins > 0 {
    let due = session.end_time - Duration::minutes(settings.discord_end_reminder_mins);
    // The end reminder is only meaningful once the session has started and before it ends.
    if session.end_time > now {
      let is_late = due <= now;
      // Never earlier than the session start: "ending in 15 minutes" sent before anyone has
      // even arrived is noise. This clamp applies to the on-time path too - an end-reminder
      // lead longer than the session itself reaches back past the start without being "late".
      let raw_due = if is_late { now } else { due };
      planned.push(PlannedReminder {
        notification_type: TYPE_SESSION_END_REMINDER,
        scheduled_for: raw_due.max(session.start_time),
        status: if is_late { late_status } else { STATUS_PENDING },
        is_late,
      });
    }
  }

  planned
}

/// Persists [plan_session_reminders]'s output.
///
/// Insert conflicts are ignored by the repository, so this is safe to call repeatedly - it will
/// not resurrect a reminder that was already sent, skipped or cancelled.
pub async fn ensure_session_reminders<S: ReminderScheduler + ?Sized>(
  scheduler: &S,
  session: &Session,
  settings: &Settings,
  now: DateTime<Utc>,
  late_policy: LateReminderPolicy,
) -> anyhow::Result<()> {
  for reminder in plan_session_reminders(session, settings, now, late_policy) {
    scheduler
      .schedule_reminder(NewNotification {
        notification_type: reminder.notification_type,
        session_id: session.id,
        team_member_id: None,
        scheduled_for: Some(reminder.scheduled_for),
        status: reminder.status,
      })
      .await?;
  }
  Ok(())
}

#[cfg(test)]
mod tests {
  use super::*;
  use uuid::Uuid;

  fn session(start: DateTime<Utc>, end: DateTime<Utc>) -> Session {
    Session {
      id: Uuid::now_v7(),
      start_time: start,
      end_time: end,
      location_id: Uuid::now_v7(),
      finished: false,
      actual_start_time: None,
      actual_end_time: None,
    }
  }

  fn settings(start_mins: i64, end_mins: i64) -> Settings {
    Settings {
      id: true,
      check_in_window_secs: 4 * 3600,
      auto_checkout_after_secs: 24 * 3600,
      discord_bot_token: String::new(),
      discord_guild_id: String::new(),
      discord_announcement_channel_id: String::new(),
      discord_notification_channel_id: String::new(),
      discord_self_link_enabled: false,
      discord_name_sync_enabled: false,
      discord_start_reminder_mins: start_mins,
      discord_end_reminder_mins: end_mins,
      discord_start_reminder_message: String::new(),
      discord_end_reminder_message: String::new(),
      discord_overtime_dm_enabled: false,
      discord_overtime_dm_mins: 10,
      discord_overtime_dm_message: String::new(),
      discord_auto_checkout_dm_enabled: false,
      discord_auto_checkout_dm_message: String::new(),
      discord_checkout_enabled: false,
      discord_enabled: true,
      timezone: "UTC".to_string(),
      leaderboard_show_overtime: true,
      leaderboard_member_types: Vec::new(),
      discord_rsvp_reactions_enabled: false,
      discord_auto_delete_start_reminder: false,
      discord_auto_delete_end_reminder: false,
      quick_pin_enabled: false,
    }
  }

  fn at(s: &str) -> DateTime<Utc> {
    DateTime::parse_from_rfc3339(s).unwrap().with_timezone(&Utc)
  }

  #[test]
  fn schedules_reminders_at_their_lead_times() {
    let now = at("2026-09-19T00:00:00Z");
    let s = session(at("2026-09-25T10:00:00Z"), at("2026-09-25T14:00:00Z"));
    let planned = plan_session_reminders(&s, &settings(24 * 60, 15), now, LateReminderPolicy::SendNow);

    assert_eq!(planned.len(), 2);
    assert_eq!(planned[0].notification_type, TYPE_SESSION_START_REMINDER);
    assert_eq!(planned[0].scheduled_for, at("2026-09-24T10:00:00Z"));
    assert!(!planned[0].is_late);
    assert_eq!(planned[1].notification_type, TYPE_SESSION_END_REMINDER);
    assert_eq!(planned[1].scheduled_for, at("2026-09-25T13:45:00Z"));
  }

  #[test]
  fn a_lead_time_already_past_is_flagged_late() {
    // Session created two hours out, with a 24 hour reminder.
    let now = at("2026-09-19T08:00:00Z");
    let s = session(at("2026-09-19T10:00:00Z"), at("2026-09-19T14:00:00Z"));
    let planned = plan_session_reminders(&s, &settings(24 * 60, 15), now, LateReminderPolicy::SendNow);

    let start = planned.iter().find(|p| p.notification_type == TYPE_SESSION_START_REMINDER).unwrap();
    assert!(start.is_late);
    assert_eq!(start.scheduled_for, now, "a late reminder is due immediately");
    assert_eq!(start.status, STATUS_PENDING);
  }

  #[test]
  fn skip_policy_records_a_late_reminder_as_skipped() {
    let now = at("2026-09-19T08:00:00Z");
    let s = session(at("2026-09-19T10:00:00Z"), at("2026-09-19T14:00:00Z"));
    let planned = plan_session_reminders(&s, &settings(24 * 60, 15), now, LateReminderPolicy::Skip);

    let start = planned.iter().find(|p| p.notification_type == TYPE_SESSION_START_REMINDER).unwrap();
    assert_eq!(start.status, STATUS_SKIPPED);
  }

  #[test]
  fn a_zero_lead_time_disables_that_reminder() {
    let now = at("2026-09-19T00:00:00Z");
    let s = session(at("2026-09-25T10:00:00Z"), at("2026-09-25T14:00:00Z"));
    let planned = plan_session_reminders(&s, &settings(0, 0), now, LateReminderPolicy::SendNow);
    assert!(planned.is_empty());
  }

  #[test]
  fn a_session_already_started_gets_no_start_reminder() {
    let now = at("2026-09-19T11:00:00Z");
    let s = session(at("2026-09-19T10:00:00Z"), at("2026-09-19T14:00:00Z"));
    let planned = plan_session_reminders(&s, &settings(24 * 60, 15), now, LateReminderPolicy::SendNow);

    assert!(planned.iter().all(|p| p.notification_type != TYPE_SESSION_START_REMINDER));
    assert!(planned.iter().any(|p| p.notification_type == TYPE_SESSION_END_REMINDER));
  }

  #[test]
  fn a_finished_session_gets_nothing() {
    let now = at("2026-09-20T00:00:00Z");
    let s = session(at("2026-09-19T10:00:00Z"), at("2026-09-19T14:00:00Z"));
    let planned = plan_session_reminders(&s, &settings(24 * 60, 15), now, LateReminderPolicy::SendNow);
    assert!(planned.is_empty());
  }

  #[test]
  fn a_late_end_reminder_never_predates_the_session_start() {
    // 8 hour end-reminder lead on a 4 hour session: the lead time reaches back before the
    // session even begins.
    let now = at("2026-09-19T00:00:00Z");
    let s = session(at("2026-09-19T10:00:00Z"), at("2026-09-19T14:00:00Z"));
    let planned = plan_session_reminders(&s, &settings(0, 8 * 60), now, LateReminderPolicy::SendNow);

    let end = planned.iter().find(|p| p.notification_type == TYPE_SESSION_END_REMINDER).unwrap();
    assert_eq!(end.scheduled_for, s.start_time);
  }
}
