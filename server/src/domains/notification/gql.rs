use std::sync::Arc;

use async_graphql::{Context, Error, ID, Object, Result, Subscription};
use futures_util::{Stream, StreamExt};
use tokio_stream::wrappers::BroadcastStream;
use uuid::Uuid;

use crate::auth::auth_helpers::require_permission;
use crate::auth::permissions::PermissionLevel;
use crate::events::{ChangeOperation, EVENT_BUS};
use crate::gql_common::Change;

use super::logic::NotificationLogic;
use super::model::Notification;

const RESOURCE: &str = "notifications";
const TABLE: &str = "notifications";

/// Matches the `notifications.notification_type` CHECK constraint in the migration.
const VALID_TYPES: &[&str] = &["session_start_reminder", "session_end_reminder", "overtime", "auto_checkout"];

fn validate_type(value: &str) -> Result<()> {
  if VALID_TYPES.contains(&value) {
    Ok(())
  } else {
    Err(Error::new(format!("Invalid notification type, expected one of: {}", VALID_TYPES.join(", "))))
  }
}

fn logic(ctx: &Context<'_>) -> Result<Arc<dyn NotificationLogic>> {
  Ok(ctx.data::<Arc<dyn NotificationLogic>>()?.clone())
}

#[derive(Default)]
pub struct NotificationQuery;

#[Object]
impl NotificationQuery {
  async fn notifications(&self, ctx: &Context<'_>) -> Result<Vec<Notification>> {
    Ok(logic(ctx)?.get_all().await?)
  }
}

#[derive(Default)]
pub struct NotificationMutation;

#[Object]
impl NotificationMutation {
  #[allow(clippy::too_many_arguments)]
  async fn create_notification(
    &self,
    ctx: &Context<'_>,
    notification_type: String,
    session_id: Uuid,
    team_member_id: Option<Uuid>,
    sent: bool,
  ) -> Result<Notification> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    validate_type(&notification_type)?;
    Ok(logic(ctx)?.add(&notification_type, session_id, team_member_id, sent, None).await?)
  }

  #[allow(clippy::too_many_arguments)]
  async fn update_notification(
    &self,
    ctx: &Context<'_>,
    id: Uuid,
    notification_type: String,
    session_id: Uuid,
    team_member_id: Option<Uuid>,
    sent: bool,
  ) -> Result<Notification> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    validate_type(&notification_type)?;
    logic(ctx)?
      .update(id, &notification_type, session_id, team_member_id, sent, None)
      .await?
      .ok_or_else(|| Error::new("Notification not found"))
  }

  async fn delete_notification(&self, ctx: &Context<'_>, id: Uuid) -> Result<bool> {
    require_permission(ctx, RESOURCE, PermissionLevel::Delete)?;
    let logic = logic(ctx)?;
    if logic.get(id).await?.is_none() {
      return Err(Error::new("Notification not found"));
    }
    logic.remove(id).await?;
    Ok(true)
  }
}

#[derive(Default)]
pub struct NotificationSubscription;

#[Subscription]
impl NotificationSubscription {
  async fn notification_changes(&self, ctx: &Context<'_>) -> Result<impl Stream<Item = Change<Notification>>> {
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
