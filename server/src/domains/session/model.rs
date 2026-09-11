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
}
