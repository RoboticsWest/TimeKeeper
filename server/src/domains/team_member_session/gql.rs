use std::sync::Arc;

use async_graphql::{Context, Error, ID, Object, Result, Subscription};
use chrono::{DateTime, Utc};
use futures_util::{Stream, StreamExt};
use tokio_stream::wrappers::BroadcastStream;
use uuid::Uuid;

use crate::auth::auth_helpers::require_permission;
use crate::auth::permissions::PermissionLevel;
use crate::events::{ChangeOperation, EVENT_BUS};
use crate::gql_common::Change;

use super::logic::TeamMemberSessionLogic;
use super::model::TeamMemberSession;

const RESOURCE: &str = "team_member_sessions";
const TABLE: &str = "team_member_sessions";

fn logic(ctx: &Context<'_>) -> Result<Arc<dyn TeamMemberSessionLogic>> {
  Ok(ctx.data::<Arc<dyn TeamMemberSessionLogic>>()?.clone())
}

#[derive(Default)]
pub struct TeamMemberSessionQuery;

#[Object]
impl TeamMemberSessionQuery {
  async fn team_member_sessions(&self, ctx: &Context<'_>) -> Result<Vec<TeamMemberSession>> {
    Ok(logic(ctx)?.get_all().await?)
  }
}

#[derive(Default)]
pub struct TeamMemberSessionMutation;

#[Object]
impl TeamMemberSessionMutation {
  async fn update_team_member_session(
    &self,
    ctx: &Context<'_>,
    id: Uuid,
    check_in_time: DateTime<Utc>,
    check_out_time: Option<DateTime<Utc>>,
  ) -> Result<TeamMemberSession> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    let logic = logic(ctx)?;
    let existing = logic.get(id).await?.ok_or_else(|| Error::new("Team member session not found"))?;
    Ok(logic.update(id, existing.team_member_id, existing.session_id, check_in_time, check_out_time).await?)
  }

  async fn delete_team_member_session(&self, ctx: &Context<'_>, id: Uuid) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Delete)?;
    let logic = logic(ctx)?;
    if logic.get(id).await?.is_none() {
      return Err(Error::new("Team member session not found"));
    }
    logic.remove(id).await?;
    Ok(true)
  }

  async fn import_attendance_csv(&self, ctx: &Context<'_>, csv_data: String) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    logic(ctx)?.import_attendance_csv(&csv_data).await.map_err(|e| Error::new(e.to_string()))?;
    Ok(true)
  }
}

#[derive(Default)]
pub struct TeamMemberSessionSubscription;

#[Subscription]
impl TeamMemberSessionSubscription {
  async fn team_member_session_changes(
    &self,
    ctx: &Context<'_>,
  ) -> Result<impl Stream<Item = Change<TeamMemberSession>>> {
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
