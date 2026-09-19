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

use super::logic::NotificationLogic;
use super::model::{Notification, STATUS_CANCELLED, STATUS_PENDING, VALID_STATUSES, VALID_TYPES};
use super::repository::NewNotification;

const RESOURCE: &str = "notifications";
const TABLE: &str = "notifications";

fn validate_type(value: &str) -> Result<()> {
  if VALID_TYPES.contains(&value) {
    Ok(())
  } else {
    Err(Error::new(format!("Invalid notification type, expected one of: {}", VALID_TYPES.join(", "))))
  }
}

fn validate_status(value: &str) -> Result<()> {
  if VALID_STATUSES.contains(&value) {
    Ok(())
  } else {
    Err(Error::new(format!("Invalid notification status, expected one of: {}", VALID_STATUSES.join(", "))))
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

  /// Notifications scheduled for one session. The Sessions UI uses this to show what will be
  /// sent and when, and to let an operator cancel a reminder before it fires.
  async fn session_notifications(&self, ctx: &Context<'_>, session_id: Uuid) -> Result<Vec<Notification>> {
    Ok(logic(ctx)?.get_by_session_id(session_id).await?)
  }
}

#[derive(Default)]
pub struct NotificationMutation;

#[Object]
impl NotificationMutation {
  /// Schedules a notification. Idempotent: scheduling one that already exists returns the
  /// existing row rather than creating a duplicate or resetting its status.
  async fn schedule_notification(
    &self,
    ctx: &Context<'_>,
    notification_type: String,
    session_id: Uuid,
    team_member_id: Option<Uuid>,
    scheduled_for: Option<DateTime<Utc>>,
  ) -> Result<Notification> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    validate_type(&notification_type)?;
    Ok(
      logic(ctx)?
        .schedule(NewNotification {
          notification_type: &notification_type,
          session_id,
          team_member_id,
          scheduled_for,
          status: STATUS_PENDING,
        })
        .await?,
    )
  }

  /// Moves a notification to a different lifecycle status.
  async fn set_notification_status(&self, ctx: &Context<'_>, id: Uuid, status: String) -> Result<Notification> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    validate_status(&status)?;
    logic(ctx)?.set_status(id, &status).await?.ok_or_else(|| Error::new("Notification not found"))
  }

  /// Switches off a scheduled reminder without deleting it.
  ///
  /// Preferred over `deleteNotification`: a cancelled row still records that this reminder was
  /// deliberately suppressed, whereas a deleted one is indistinguishable from one that was
  /// never scheduled.
  async fn cancel_notification(&self, ctx: &Context<'_>, id: Uuid) -> Result<Notification> {
    require_permission(ctx, RESOURCE, PermissionLevel::Write)?;
    logic(ctx)?.set_status(id, STATUS_CANCELLED).await?.ok_or_else(|| Error::new("Notification not found"))
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
