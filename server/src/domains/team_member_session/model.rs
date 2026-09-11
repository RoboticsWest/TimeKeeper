use async_graphql::SimpleObject;
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use uuid::Uuid;

use database::schema::team_member_sessions;

#[derive(Debug, Clone, Queryable, Selectable, SimpleObject)]
#[diesel(table_name = team_member_sessions)]
#[diesel(check_for_backend(diesel::pg::Pg))]
pub struct TeamMemberSession {
  pub id: Uuid,
  pub team_member_id: Uuid,
  pub session_id: Uuid,
  pub check_in_time: DateTime<Utc>,
  pub check_out_time: Option<DateTime<Utc>>,
}
