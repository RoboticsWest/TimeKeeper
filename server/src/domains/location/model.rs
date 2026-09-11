use async_graphql::SimpleObject;
use diesel::prelude::*;
use uuid::Uuid;

use database::schema::locations;

#[derive(Debug, Clone, Queryable, Selectable, SimpleObject)]
#[diesel(table_name = locations)]
#[diesel(check_for_backend(diesel::pg::Pg))]
pub struct Location {
  pub id: Uuid,
  pub location: String,
}
