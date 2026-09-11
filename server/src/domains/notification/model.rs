use async_graphql::SimpleObject;
use diesel::prelude::*;
use uuid::Uuid;

use database::schema::notifications;

#[derive(Debug, Clone, Queryable, Selectable, SimpleObject)]
#[diesel(table_name = notifications)]
#[diesel(check_for_backend(diesel::pg::Pg))]
pub struct Notification {
  pub id: Uuid,
  pub notification_type: String,
  pub session_id: Uuid,
  pub team_member_id: Option<Uuid>,
  pub sent: bool,
  pub discord_message_id: Option<String>,
}
