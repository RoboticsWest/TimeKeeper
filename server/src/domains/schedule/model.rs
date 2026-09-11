use async_graphql::SimpleObject;
use chrono::{DateTime, Utc};

#[derive(SimpleObject)]
pub struct ScheduleSession {
  pub start_time: DateTime<Utc>,
  pub end_time: DateTime<Utc>,
  pub location_name: String,
}

#[derive(SimpleObject)]
pub struct Schedule {
  pub sessions: Vec<ScheduleSession>,
  pub locations: Vec<String>,
}
