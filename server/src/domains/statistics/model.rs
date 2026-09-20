//! Recorded statistics — facts written when they happen, rather than inferred later.
//!
//! Both rows live in tables that reference the business schema without extending it (migration
//! 0013). Nothing in here is needed to run a session; it exists so the stat card and the
//! achievements have something durable and unambiguous to read.

use async_graphql::SimpleObject;
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use uuid::Uuid;

use database::schema::{attendance_stats, team_member_stats};

/// Nobody has checked out of this attendance yet.
pub const CHECKOUT_NONE: &str = "none";
/// The member ended the attendance themselves, by any route.
pub const CHECKOUT_MANUAL: &str = "manual";
/// The auto-checkout ended it for them — they forgot.
pub const CHECKOUT_AUTO: &str = "auto";

/// Checkout routes. `Unknown` is what pre-0013 history backfills to: the fact was never recorded,
/// and guessing would be inventing data.
pub const SOURCE_KIOSK: &str = "kiosk";
pub const SOURCE_RFID: &str = "rfid";
pub const SOURCE_DISCORD: &str = "discord";
pub const SOURCE_ADMIN: &str = "admin";
pub const SOURCE_AUTO: &str = "auto";
pub const SOURCE_UNKNOWN: &str = "unknown";

/// What happened to one specific attendance, recorded at the moment it happened.
#[derive(Debug, Clone, Queryable, Selectable, SimpleObject)]
#[diesel(table_name = attendance_stats)]
#[diesel(check_for_backend(diesel::pg::Pg))]
pub struct AttendanceStats {
  pub team_member_session_id: Uuid,
  /// One of [`CHECKOUT_NONE`], [`CHECKOUT_MANUAL`], [`CHECKOUT_AUTO`].
  pub checkout_kind: String,
  /// One of the `SOURCE_*` constants.
  pub checkout_source: String,
  /// Whether the checkout landed after the session's scheduled end. Stored rather than compared
  /// on read, so editing the session afterwards cannot rewrite history.
  pub checked_out_late: bool,
  pub recorded_at: DateTime<Utc>,
}

impl AttendanceStats {
  /// Whether this attendance was ended by the auto-checkout — the member forgot to sign out.
  #[must_use]
  pub fn forgot_checkout(&self) -> bool {
    self.checkout_kind == CHECKOUT_AUTO
  }

  /// Whether the member signed out themselves, but after the session had already ended. The case
  /// the old heuristic could not tell apart from forgetting.
  #[must_use]
  pub fn late_manual_checkout(&self) -> bool {
    self.checkout_kind == CHECKOUT_MANUAL && self.checked_out_late
  }
}

/// Lifetime counters for one member. Monotonic by design: deleting an old session must not cost
/// somebody an achievement they already earned.
#[derive(Debug, Clone, Queryable, Selectable, SimpleObject)]
#[diesel(table_name = team_member_stats)]
#[diesel(check_for_backend(diesel::pg::Pg))]
pub struct TeamMemberStats {
  pub team_member_id: Uuid,
  /// Every check-in ever, including ones whose session has since been deleted.
  pub check_ins: i64,
  /// Overtime DMs actually delivered to this member.
  pub overtime_warnings: i64,
  pub updated_at: DateTime<Utc>,
}

impl TeamMemberStats {
  /// A member with no counter row yet behaves as a member at zero, so callers never branch on
  /// absence. The database creates the row on insert of the member (migration 0013), so this is
  /// only reached for a member created before that trigger existed.
  #[must_use]
  pub fn zeroed(team_member_id: Uuid) -> Self {
    Self { team_member_id, check_ins: 0, overtime_warnings: 0, updated_at: Utc::now() }
  }
}
