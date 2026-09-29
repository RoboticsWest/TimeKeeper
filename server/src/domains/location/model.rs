use async_graphql::dataloader::DataLoader;
use async_graphql::{ComplexObject, Context, Result, SimpleObject};
use diesel::prelude::*;
use uuid::Uuid;

use database::schema::locations;

use crate::auth::auth_helpers::require_permission;
use crate::auth::permissions::PermissionLevel;
use crate::domains::session::Session;
use crate::gql_common::capped;
use crate::loaders::LocationSessionsLoader;

#[derive(Debug, Clone, Queryable, Selectable, SimpleObject)]
#[graphql(complex)]
#[diesel(table_name = locations)]
#[diesel(check_for_backend(diesel::pg::Pg))]
pub struct Location {
  pub id: Uuid,
  pub location: String,
}

#[ComplexObject]
impl Location {
  /// The sessions held here, newest start first.
  async fn sessions(&self, ctx: &Context<'_>, limit: Option<usize>) -> Result<Vec<Session>> {
    require_permission(ctx, "sessions", PermissionLevel::Read)?;
    let loader = ctx.data::<DataLoader<LocationSessionsLoader>>()?;
    let mut rows = loader.load_one(self.id).await?.unwrap_or_default();
    rows.sort_by(|a, b| b.start_time.cmp(&a.start_time).then_with(|| b.id.cmp(&a.id)));
    Ok(capped(rows, limit))
  }
}
