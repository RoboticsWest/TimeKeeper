use std::sync::Arc;

use async_graphql::{Context, Error, ID, Object, Result, Subscription};
use futures_util::{Stream, StreamExt};
use tokio_stream::wrappers::BroadcastStream;
use uuid::Uuid;

use crate::auth::auth_helpers::require_permission;
use crate::auth::permissions::PermissionLevel;
use crate::events::{ChangeOperation, EVENT_BUS};
use crate::gql_common::Change;

use super::logic::LocationLogic;
use super::model::Location;

const RESOURCE: &str = "locations";
const TABLE: &str = "locations";

fn logic(ctx: &Context<'_>) -> Result<Arc<dyn LocationLogic>> {
  Ok(ctx.data::<Arc<dyn LocationLogic>>()?.clone())
}

#[derive(Default)]
pub struct LocationQuery;

#[Object]
impl LocationQuery {
  async fn locations(&self, ctx: &Context<'_>) -> Result<Vec<Location>> {
    Ok(logic(ctx)?.get_all().await?)
  }
}

#[derive(Default)]
pub struct LocationMutation;

#[Object]
impl LocationMutation {
  async fn create_location(&self, ctx: &Context<'_>, location: String) -> Result<Location> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    if location.is_empty() {
      return Err(Error::new("Location name is required"));
    }
    Ok(logic(ctx)?.add(&location).await?)
  }

  async fn update_location(&self, ctx: &Context<'_>, id: Uuid, location: String) -> Result<Location> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    logic(ctx)?.update(id, &location).await?.ok_or_else(|| Error::new("Location not found"))
  }

  async fn delete_location(&self, ctx: &Context<'_>, id: Uuid) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Delete)?;
    let logic = logic(ctx)?;
    if logic.get(id).await?.is_none() {
      return Err(Error::new("Location not found"));
    }
    logic.remove(id).await?;
    Ok(true)
  }
}

#[derive(Default)]
pub struct LocationSubscription;

#[Subscription]
impl LocationSubscription {
  /// Emits one event per row change on `locations`, re-fetched fresh from the DB - `data` is
  /// `None` for deletes. Clients should query `locations` once for initial state, then subscribe
  /// here for incremental updates.
  async fn location_changes(&self, ctx: &Context<'_>) -> Result<impl Stream<Item = Change<Location>>> {
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
