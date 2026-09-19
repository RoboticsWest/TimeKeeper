use async_graphql::SimpleObject;
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use uuid::Uuid;

use database::schema::sessions;

#[derive(Debug, Clone, Queryable, Selectable, SimpleObject)]
#[diesel(table_name = sessions)]
#[diesel(check_for_backend(diesel::pg::Pg))]
pub struct Session {
  pub id: Uuid,
  pub start_time: DateTime<Utc>,
  pub end_time: DateTime<Utc>,
  pub location_id: Uuid,
  pub finished: bool,
  /// When the session really began: the earliest check-in. `None` until somebody checks in.
  ///
  /// Kept beside the scheduled `start_time`/`end_time` rather than replacing it, because the
  /// gap between the two *is* the overtime. Session-level statistics read these; deriving them
  /// by summing per-member attendance answers a different question (man-hours, not hours).
  pub actual_start_time: Option<DateTime<Utc>>,
  /// When the session really ended: the latest check-out, and only once nobody is still
  /// checked in. `None` while anyone remains signed in - the session has no real end yet.
  pub actual_end_time: Option<DateTime<Utc>>,
}
