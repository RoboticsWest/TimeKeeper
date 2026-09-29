use std::sync::Arc;

use async_graphql::{Context, Error, ID, Object, Result, Subscription};
use futures_util::{Stream, StreamExt};
use tokio_stream::wrappers::BroadcastStream;

use crate::events::{ChangeOperation, EVENT_BUS, resolve_once};
use crate::gql_common::Change;

use super::logic::SessionRsvpLogic;
use super::model::SessionRsvp;

const TABLE: &str = "session_rsvps";

fn logic(ctx: &Context<'_>) -> Result<Arc<dyn SessionRsvpLogic>> {
  Ok(ctx.data::<Arc<dyn SessionRsvpLogic>>()?.clone())
}

#[derive(Default)]
pub struct SessionRsvpQuery;

#[Object]
impl SessionRsvpQuery {
  async fn session_rsvps(&self, ctx: &Context<'_>) -> Result<Vec<SessionRsvp>> {
    Ok(logic(ctx)?.get_all().await?)
  }
}

#[derive(Default)]
pub struct SessionRsvpSubscription;

#[Subscription]
impl SessionRsvpSubscription {
  async fn session_rsvp_changes(&self, ctx: &Context<'_>) -> Result<impl Stream<Item = Change<SessionRsvp>>> {
    let logic = logic(ctx)?;
    let Some(bus) = EVENT_BUS.get() else {
      return Err(Error::new("Event bus not initialized"));
    };
    let rx = bus.subscribe(TABLE);

    Ok(BroadcastStream::new(rx).filter_map(move |change| {
      let logic = logic.clone();
      async move {
        let change = change.ok()?;
        // No get-by-id on this repository, so finding the row means reading the table. Sharing the
        // result across subscribers at least makes that once per event rather than once per
        // connected client.
        let data = if change.operation == ChangeOperation::Delete {
          None
        } else {
          let id = change.id.clone();
          resolve_once(
            &change,
            || async move { logic.get_all().await.ok()?.into_iter().find(|r| r.id.to_string() == id) },
          )
          .await
        };
        Some(Change { operation: change.operation, id: ID(change.id), data })
      }
    }))
  }
}
