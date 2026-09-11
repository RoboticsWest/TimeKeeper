use async_graphql::SimpleObject;
use diesel::prelude::*;
use uuid::Uuid;

use database::schema::users;

#[derive(Debug, Clone, Queryable, Selectable, SimpleObject)]
#[diesel(table_name = users)]
#[diesel(check_for_backend(diesel::pg::Pg))]
pub struct User {
  pub id: Uuid,
  pub username: String,
  #[graphql(skip)]
  pub password: String,
}
