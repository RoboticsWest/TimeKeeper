use std::sync::Arc;

use async_graphql::{Context, Error, ID, Object, Result, Subscription};
use futures_util::{Stream, StreamExt};
use tokio_stream::wrappers::BroadcastStream;
use uuid::Uuid;

use crate::auth::auth_helpers::require_permission;
use crate::auth::permissions::PermissionLevel;
use crate::events::{ChangeOperation, EVENT_BUS};
use crate::gql_common::Change;

use super::logic::RfidTagLogic;
use super::model::RfidTag;

const RESOURCE: &str = "rfid_tags";
const TABLE: &str = "rfid_tags";

fn logic(ctx: &Context<'_>) -> Result<Arc<dyn RfidTagLogic>> {
  Ok(ctx.data::<Arc<dyn RfidTagLogic>>()?.clone())
}

#[derive(Default)]
pub struct RfidTagQuery;

#[Object]
impl RfidTagQuery {
  async fn rfid_tags(&self, ctx: &Context<'_>) -> Result<Vec<RfidTag>> {
    Ok(logic(ctx)?.get_all().await?)
  }
}

#[derive(Default)]
pub struct RfidTagMutation;

#[Object]
impl RfidTagMutation {
  async fn create_rfid_tag(&self, ctx: &Context<'_>, team_member_id: Uuid, tag: String) -> Result<RfidTag> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    if tag.is_empty() {
      return Err(Error::new("RFID tag is required"));
    }
    Ok(logic(ctx)?.add(team_member_id, &tag).await?)
  }

  async fn delete_rfid_tag(&self, ctx: &Context<'_>, id: Uuid) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Delete)?;
    let logic = logic(ctx)?;
    if logic.get(id).await?.is_none() {
      return Err(Error::new("RFID tag not found"));
    }
    logic.remove(id).await?;
    Ok(true)
  }

  async fn delete_rfid_tags_by_member(&self, ctx: &Context<'_>, team_member_id: Uuid) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Delete)?;
    logic(ctx)?.remove_by_team_member_id(team_member_id).await?;
    Ok(true)
  }
}

#[derive(Default)]
pub struct RfidTagSubscription;

#[Subscription]
impl RfidTagSubscription {
  async fn rfid_tag_changes(&self, ctx: &Context<'_>) -> Result<impl Stream<Item = Change<RfidTag>>> {
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
