use std::sync::Arc;

use async_graphql::{Context, Error, ID, Object, Result, Subscription};
use futures_util::{Stream, StreamExt};
use tokio_stream::wrappers::BroadcastStream;
use uuid::Uuid;

use crate::auth::auth_helpers::require_permission;
use crate::auth::permissions::PermissionLevel;
use crate::events::{ChangeOperation, EVENT_BUS};
use crate::gql_common::Change;

use super::logic::TeamMemberLogic;
use super::model::TeamMember;

const RESOURCE: &str = "team_members";
const TABLE: &str = "team_members";
const VALID_MEMBER_TYPES: &[&str] = &["student", "mentor"];

fn validate_member_type(value: &str) -> Result<()> {
  if VALID_MEMBER_TYPES.contains(&value) {
    Ok(())
  } else {
    Err(Error::new("Invalid member_type, expected 'student' or 'mentor'"))
  }
}

fn logic(ctx: &Context<'_>) -> Result<Arc<dyn TeamMemberLogic>> {
  Ok(ctx.data::<Arc<dyn TeamMemberLogic>>()?.clone())
}

#[derive(Default)]
pub struct TeamMemberQuery;

#[Object]
impl TeamMemberQuery {
  /// Pass `memberType` ("student"/"mentor") to filter, or omit for everyone.
  async fn team_members(&self, ctx: &Context<'_>, member_type: Option<String>) -> Result<Vec<TeamMember>> {
    let logic = logic(ctx)?;
    match member_type {
      Some(t) => {
        validate_member_type(&t)?;
        Ok(logic.get_by_member_type(&t).await?)
      }
      None => Ok(logic.get_all().await?),
    }
  }
}

#[derive(Default)]
pub struct TeamMemberMutation;

#[Object]
impl TeamMemberMutation {
  async fn upload_student_csv(&self, ctx: &Context<'_>, csv_data: String) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    logic(ctx)?.import_csv(&csv_data, "student").await.map_err(|e| Error::new(e.to_string()))?;
    Ok(true)
  }

  async fn upload_mentor_csv(&self, ctx: &Context<'_>, csv_data: String) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    logic(ctx)?.import_csv(&csv_data, "mentor").await.map_err(|e| Error::new(e.to_string()))?;
    Ok(true)
  }

  #[allow(clippy::too_many_arguments)]
  async fn create_team_member(
    &self,
    ctx: &Context<'_>,
    first_name: String,
    last_name: String,
    member_type: String,
    display_name: Option<String>,
    discord_id: Option<String>,
  ) -> Result<TeamMember> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    validate_member_type(&member_type)?;
    Ok(
      logic(ctx)?
        .add(&first_name, &last_name, &member_type, display_name.as_deref(), None, discord_id.as_deref())
        .await?,
    )
  }

  #[allow(clippy::too_many_arguments)]
  async fn update_team_member(
    &self,
    ctx: &Context<'_>,
    id: Uuid,
    first_name: String,
    last_name: String,
    member_type: String,
    display_name: Option<String>,
    discord_id: Option<String>,
  ) -> Result<TeamMember> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    validate_member_type(&member_type)?;
    let logic = logic(ctx)?;
    if logic.get(id).await?.is_none() {
      return Err(Error::new("Team member not found"));
    }
    Ok(
      logic
        .update(id, &first_name, &last_name, &member_type, display_name.as_deref(), None, discord_id.as_deref())
        .await?,
    )
  }

  async fn delete_team_member(&self, ctx: &Context<'_>, id: Uuid) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Delete)?;
    let logic = logic(ctx)?;
    if logic.get(id).await?.is_none() {
      return Err(Error::new("Team member not found"));
    }
    // RFID tags belonging to this member cascade-delete at the DB level (ON DELETE CASCADE).
    logic.remove(id).await?;
    Ok(true)
  }
}

#[derive(Default)]
pub struct TeamMemberSubscription;

#[Subscription]
impl TeamMemberSubscription {
  async fn team_member_changes(&self, ctx: &Context<'_>) -> Result<impl Stream<Item = Change<TeamMember>>> {
    let logic = logic(ctx)?;
    let Some(bus) = EVENT_BUS.get() else {
      return Err(Error::new("Event bus not initialized"));
    };
    let rx = bus.subscribe(TABLE);

    Ok(BroadcastStream::new(rx).filter_map(move |change| {
      let logic = logic.clone();
      async move {
        let change = change.ok()?;
        let data = match change.operation {
          ChangeOperation::Delete => None,
          _ => logic.get(change.id.parse().ok()?).await.ok().flatten(),
        };
        Some(Change { operation: change.operation, id: ID(change.id), data })
      }
    }))
  }
}
