use async_graphql::dataloader::DataLoader;
use async_graphql::{ComplexObject, Context, Result, SimpleObject};
use diesel::prelude::*;
use uuid::Uuid;

use database::schema::rfid_tags;

use crate::auth::auth_helpers::require_permission;
use crate::auth::permissions::PermissionLevel;
use crate::domains::team_member::TeamMember;
use crate::loaders::TeamMemberLoader;

#[derive(Debug, Clone, Queryable, Selectable, SimpleObject)]
#[graphql(complex)]
#[diesel(table_name = rfid_tags)]
#[diesel(check_for_backend(diesel::pg::Pg))]
pub struct RfidTag {
  pub id: Uuid,
  pub team_member_id: Uuid,
  pub tag: String,
}

#[ComplexObject]
impl RfidTag {
  /// The member this belongs to.
  async fn team_member(&self, ctx: &Context<'_>) -> Result<Option<TeamMember>> {
    require_permission(ctx, "team_members", PermissionLevel::Read)?;
    let loader = ctx.data::<DataLoader<TeamMemberLoader>>()?;
    Ok(loader.load_one(self.team_member_id).await?)
  }
}
