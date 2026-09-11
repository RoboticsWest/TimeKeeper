use diesel::prelude::*;

use database::schema::secrets;

#[derive(Debug, Clone, Queryable, Selectable)]
#[diesel(table_name = secrets)]
#[diesel(check_for_backend(diesel::pg::Pg))]
pub struct Secret {
  pub key: String,
  pub secret_bytes: Vec<u8>,
}
