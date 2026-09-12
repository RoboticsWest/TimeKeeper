use std::sync::Arc;

use async_graphql::{ComplexObject, Context, Result, SimpleObject};
use diesel::prelude::*;
use uuid::Uuid;

use database::schema::users;

use crate::auth::permissions::Role;
use crate::auth::permissions_repository::PermissionsRepository;

#[derive(Debug, Clone, Queryable, Selectable, SimpleObject)]
#[diesel(table_name = users)]
#[diesel(check_for_backend(diesel::pg::Pg))]
#[graphql(complex)]
pub struct User {
  pub id: Uuid,
  pub username: String,
  #[graphql(skip)]
  pub password: String,
}

#[ComplexObject]
impl User {
  /// The roles this user holds. A user with none can sign in but has no permissions.
  async fn roles(&self, ctx: &Context<'_>) -> Result<Vec<Role>> {
    let repo = ctx.data::<Arc<dyn PermissionsRepository>>()?;
    Ok(repo.roles_for_user(self.id).await?)
  }
}
