use async_graphql::dataloader::DataLoader;
use async_graphql::{ComplexObject, Context, Result, SimpleObject};
use diesel::prelude::*;
use uuid::Uuid;

use database::schema::{session_rsvp_messages, session_rsvps};

use crate::auth::auth_helpers::require_permission;
use crate::auth::permissions::PermissionLevel;
use crate::domains::session::Session;
use crate::domains::team_member::TeamMember;
use crate::loaders::{SessionLoader, TeamMemberLoader};

#[derive(Debug, Clone, Queryable, Selectable, SimpleObject)]
#[graphql(complex)]
#[diesel(table_name = session_rsvps)]
#[diesel(check_for_backend(diesel::pg::Pg))]
pub struct SessionRsvp {
  pub id: Uuid,
  pub session_id: Uuid,
  pub team_member_id: Uuid,
  pub status: String,
}

#[ComplexObject]
impl SessionRsvp {
  /// The session this belongs to.
  async fn session(&self, ctx: &Context<'_>) -> Result<Option<Session>> {
    require_permission(ctx, "sessions", PermissionLevel::Read)?;
    let loader = ctx.data::<DataLoader<SessionLoader>>()?;
    Ok(loader.load_one(self.session_id).await?)
  }

  /// The member this belongs to.
  async fn team_member(&self, ctx: &Context<'_>) -> Result<Option<TeamMember>> {
    require_permission(ctx, "team_members", PermissionLevel::Read)?;
    let loader = ctx.data::<DataLoader<TeamMemberLoader>>()?;
    Ok(loader.load_one(self.team_member_id).await?)
  }
}

#[derive(Debug, Clone, Queryable, Selectable, SimpleObject)]
#[graphql(complex)]
#[diesel(table_name = session_rsvp_messages)]
#[diesel(check_for_backend(diesel::pg::Pg))]
pub struct SessionRsvpMessage {
  pub discord_message_id: String,
  pub session_id: Uuid,
}

#[ComplexObject]
impl SessionRsvpMessage {
  /// The session this belongs to.
  async fn session(&self, ctx: &Context<'_>) -> Result<Option<Session>> {
    require_permission(ctx, "sessions", PermissionLevel::Read)?;
    let loader = ctx.data::<DataLoader<SessionLoader>>()?;
    Ok(loader.load_one(self.session_id).await?)
  }
}
