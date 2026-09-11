use async_graphql::SimpleObject;
use diesel::prelude::*;
use uuid::Uuid;

use database::schema::rfid_tags;

#[derive(Debug, Clone, Queryable, Selectable, SimpleObject)]
#[diesel(table_name = rfid_tags)]
#[diesel(check_for_backend(diesel::pg::Pg))]
pub struct RfidTag {
  pub id: Uuid,
  pub team_member_id: Uuid,
  pub tag: String,
}
