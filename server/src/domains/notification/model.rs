use async_graphql::SimpleObject;
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use uuid::Uuid;

use database::schema::notifications;

/// Notification kinds. Mirrors the `notification_type` CHECK constraint in `0001_init`.
pub const TYPE_SESSION_START_REMINDER: &str = "session_start_reminder";
pub const TYPE_SESSION_END_REMINDER: &str = "session_end_reminder";
pub const TYPE_OVERTIME: &str = "overtime";
pub const TYPE_AUTO_CHECKOUT: &str = "auto_checkout";

pub const VALID_TYPES: &[&str] =
  &[TYPE_SESSION_START_REMINDER, TYPE_SESSION_END_REMINDER, TYPE_OVERTIME, TYPE_AUTO_CHECKOUT];

/// Lifecycle states. Mirrors the `notifications_status_check` constraint in `0008`.
///
/// The point of having these at all is that "should this be sent?" used to be answered by the
/// *absence* of a row, so deleting one re-armed it. A row now always exists and always says
/// what happened to it; only `Pending` is ever sent, and nothing returns to `Pending`.
pub const STATUS_PENDING: &str = "pending";
pub const STATUS_SENT: &str = "sent";
/// The reminder's window had already elapsed when the session was created, and the operator
/// chose not to fire it late.
pub const STATUS_SKIPPED: &str = "skipped";
/// A user switched this reminder off. Distinct from `Skipped` so the UI can say which.
pub const STATUS_CANCELLED: &str = "cancelled";
pub const STATUS_FAILED: &str = "failed";

pub const VALID_STATUSES: &[&str] = &[STATUS_PENDING, STATUS_SENT, STATUS_SKIPPED, STATUS_CANCELLED, STATUS_FAILED];

/// A single scheduled message, bound to the session it is about.
///
/// Created up front when the session is created (for the session-wide reminders) or when the
/// condition arises (for the per-member ones), rather than at the moment of sending. That makes
/// the send loop a query - "what is due and still pending for this session" - instead of an
/// inference from what is missing, and it means deleting a session takes its notifications with
/// it via `ON DELETE CASCADE`.
#[derive(Debug, Clone, Queryable, Selectable, SimpleObject)]
#[diesel(table_name = notifications)]
#[diesel(check_for_backend(diesel::pg::Pg))]
pub struct Notification {
  pub id: Uuid,
  pub notification_type: String,
  pub session_id: Uuid,
  /// Set for the per-member kinds (`overtime`, `auto_checkout`), null for session-wide ones.
  pub team_member_id: Option<Uuid>,
  pub discord_message_id: Option<String>,
  /// When this is due. Null for kinds that fire on a condition rather than a clock.
  pub scheduled_for: Option<DateTime<Utc>>,
  pub sent_at: Option<DateTime<Utc>>,
  pub status: String,
}

impl Notification {
  /// Whether this is still eligible to be sent.
  pub fn is_pending(&self) -> bool {
    self.status == STATUS_PENDING
  }

  /// Whether this is due at `now`. A null `scheduled_for` means "as soon as noticed".
  pub fn is_due(&self, now: DateTime<Utc>) -> bool {
    self.is_pending() && self.scheduled_for.is_none_or(|due| due <= now)
  }
}
