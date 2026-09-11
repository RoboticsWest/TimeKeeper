use async_graphql::SimpleObject;
use diesel::prelude::*;
use uuid::Uuid;

use database::schema::team_members;

#[derive(Debug, Clone, Queryable, Selectable, SimpleObject)]
#[diesel(table_name = team_members)]
#[diesel(check_for_backend(diesel::pg::Pg))]
pub struct TeamMember {
  pub id: Uuid,
  pub first_name: String,
  pub last_name: String,
  /// Plain string holding one of the lowercase values enforced by the DB CHECK constraint:
  /// `'student'` | `'mentor'`. Proto enum <-> string conversion happens in a later grpc.rs layer.
  pub member_type: String,
  pub display_name: Option<String>,
  pub mobile_number: Option<String>,
  pub discord_username: Option<String>,
}
