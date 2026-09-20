use async_trait::async_trait;
use chrono::{DateTime, Utc};
use uuid::Uuid;

use super::model::Notification;
use super::repository::{NewNotification, NotificationFilter, NotificationRepository};

#[async_trait]
pub trait NotificationLogic: Send + Sync {
  /// One page of notifications matching `filter`, newest-scheduled first, with the total match
  /// count.
  async fn query_page(
    &self,
    filter: &NotificationFilter,
    offset: i64,
    limit: i64,
  ) -> anyhow::Result<(Vec<Notification>, i64)>;
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<Notification>>;
  async fn get_all(&self) -> anyhow::Result<Vec<Notification>>;
  async fn schedule(&self, new: NewNotification<'_>) -> anyhow::Result<Notification>;
  async fn set_status(&self, id: Uuid, status: &str) -> anyhow::Result<Option<Notification>>;
  async fn mark_sent(&self, id: Uuid, discord_message_id: Option<&str>) -> anyhow::Result<Option<Notification>>;
  async fn clear_message_id(&self, id: Uuid) -> anyhow::Result<()>;
  async fn remove(&self, id: Uuid) -> anyhow::Result<()>;
  async fn clear(&self) -> anyhow::Result<()>;

  /// All notifications belonging to a given session.
  async fn get_by_session_id(&self, session_id: Uuid) -> anyhow::Result<Vec<Notification>>;
  /// Everything still pending whose scheduled time has arrived.
  async fn get_due(&self, now: DateTime<Utc>) -> anyhow::Result<Vec<Notification>>;
  /// Whether a notification of this type/session/team-member combination already exists, in any
  /// status.
  async fn exists(
    &self,
    notification_type: &str,
    session_id: Uuid,
    team_member_id: Option<Uuid>,
  ) -> anyhow::Result<bool>;
}

pub struct DefaultNotificationLogic<R: NotificationRepository> {
  repo: R,
}

impl<R: NotificationRepository> DefaultNotificationLogic<R> {
  pub fn new(repo: R) -> Self {
    Self { repo }
  }
}

#[async_trait]
impl<R: NotificationRepository> NotificationLogic for DefaultNotificationLogic<R> {
  async fn query_page(
    &self,
    filter: &NotificationFilter,
    offset: i64,
    limit: i64,
  ) -> anyhow::Result<(Vec<Notification>, i64)> {
    self.repo.query_page(filter, offset, limit).await
  }

  async fn get(&self, id: Uuid) -> anyhow::Result<Option<Notification>> {
    self.repo.get(id).await
  }

  async fn get_all(&self) -> anyhow::Result<Vec<Notification>> {
    self.repo.get_all().await
  }

  async fn schedule(&self, new: NewNotification<'_>) -> anyhow::Result<Notification> {
    self.repo.schedule(new).await
  }

  async fn set_status(&self, id: Uuid, status: &str) -> anyhow::Result<Option<Notification>> {
    self.repo.set_status(id, status).await
  }

  async fn mark_sent(&self, id: Uuid, discord_message_id: Option<&str>) -> anyhow::Result<Option<Notification>> {
    self.repo.mark_sent(id, discord_message_id).await
  }

  async fn clear_message_id(&self, id: Uuid) -> anyhow::Result<()> {
    self.repo.clear_message_id(id).await
  }

  async fn remove(&self, id: Uuid) -> anyhow::Result<()> {
    self.repo.remove(id).await
  }

  async fn clear(&self) -> anyhow::Result<()> {
    self.repo.clear().await
  }

  async fn get_by_session_id(&self, session_id: Uuid) -> anyhow::Result<Vec<Notification>> {
    self.repo.get_by_session_id(session_id).await
  }

  async fn get_due(&self, now: DateTime<Utc>) -> anyhow::Result<Vec<Notification>> {
    self.repo.get_due(now).await
  }

  async fn exists(
    &self,
    notification_type: &str,
    session_id: Uuid,
    team_member_id: Option<Uuid>,
  ) -> anyhow::Result<bool> {
    self.repo.exists(notification_type, session_id, team_member_id).await
  }
}
