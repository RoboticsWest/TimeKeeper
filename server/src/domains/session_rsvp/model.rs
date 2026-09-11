use async_graphql::SimpleObject;
use diesel::prelude::*;
use uuid::Uuid;

use database::schema::{session_rsvp_messages, session_rsvps};

#[derive(Debug, Clone, Queryable, Selectable, SimpleObject)]
#[diesel(table_name = session_rsvps)]
#[diesel(check_for_backend(diesel::pg::Pg))]
pub struct SessionRsvp {
  pub id: Uuid,
  pub session_id: Uuid,
  pub team_member_id: Uuid,
  pub status: String,
}

#[derive(Debug, Clone, Queryable, Selectable, SimpleObject)]
#[diesel(table_name = session_rsvp_messages)]
#[diesel(check_for_backend(diesel::pg::Pg))]
pub struct SessionRsvpMessage {
  pub discord_message_id: String,
  pub session_id: Uuid,
}
