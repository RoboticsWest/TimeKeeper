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

use super::logic::SessionLogic;
use super::model::Session;

const RESOURCE: &str = "sessions";
const TABLE: &str = "sessions";

fn logic(ctx: &Context<'_>) -> Result<Arc<dyn SessionLogic>> {
  Ok(ctx.data::<Arc<dyn SessionLogic>>()?.clone())
}

#[derive(Default)]
pub struct SessionQuery;

#[Object]
impl SessionQuery {
  async fn sessions(&self, ctx: &Context<'_>) -> Result<Vec<Session>> {
    Ok(logic(ctx)?.get_all().await?)
  }
}

#[derive(Default)]
pub struct SessionMutation;

#[Object]
impl SessionMutation {
  async fn create_session(
    &self,
    ctx: &Context<'_>,
    start_time: DateTime<Utc>,
    end_time: DateTime<Utc>,
    location_id: Uuid,
  ) -> Result<Session> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    Ok(logic(ctx)?.create(start_time, end_time, location_id).await?)
  }

  #[allow(clippy::too_many_arguments)]
  async fn update_session(
    &self,
    ctx: &Context<'_>,
    id: Uuid,
    start_time: DateTime<Utc>,
    end_time: DateTime<Utc>,
    location_id: Uuid,
    finished: bool,
  ) -> Result<Session> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    Ok(logic(ctx)?.update(id, start_time, end_time, location_id, finished).await?)
  }

  async fn delete_session(&self, ctx: &Context<'_>, id: Uuid) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Delete)?;
    logic(ctx)?.remove(id).await?;
    Ok(true)
  }

  /// Kiosk check-in/out by RFID scan - creates or closes a `team_member_sessions` row.
  async fn check_in_out(&self, ctx: &Context<'_>, team_member_id: Uuid, location_id: Uuid) -> Result<bool> {
    require_permission(ctx, "team_member_sessions", PermissionLevel::Write)?;
    Ok(logic(ctx)?.check_in_out(team_member_id, location_id).await?)
  }
}

#[derive(Default)]
pub struct SessionSubscription;

#[Subscription]
impl SessionSubscription {
  async fn session_changes(&self, ctx: &Context<'_>) -> Result<impl Stream<Item = Change<Session>>> {
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
