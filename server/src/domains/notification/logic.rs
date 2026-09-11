use async_trait::async_trait;
use uuid::Uuid;

use super::model::Notification;
use super::repository::NotificationRepository;

#[async_trait]
pub trait NotificationLogic: Send + Sync {
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<Notification>>;
  async fn get_all(&self) -> anyhow::Result<Vec<Notification>>;
  #[allow(clippy::too_many_arguments)]
  async fn add(
    &self,
    notification_type: &str,
    session_id: Uuid,
    team_member_id: Option<Uuid>,
    sent: bool,
    discord_message_id: Option<&str>,
  ) -> anyhow::Result<Notification>;
  #[allow(clippy::too_many_arguments)]
  async fn update(
    &self,
    id: Uuid,
    notification_type: &str,
    session_id: Uuid,
    team_member_id: Option<Uuid>,
    sent: bool,
    discord_message_id: Option<&str>,
  ) -> anyhow::Result<Option<Notification>>;
  async fn remove(&self, id: Uuid) -> anyhow::Result<()>;
  async fn clear(&self) -> anyhow::Result<()>;

  /// All notifications belonging to a given session.
  async fn get_by_session_id(&self, session_id: Uuid) -> anyhow::Result<Vec<Notification>>;
  /// All notifications that have not yet been sent.
  async fn get_unsent(&self) -> anyhow::Result<Vec<Notification>>;
  /// Whether a notification of this type/session/team-member combination already exists.
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
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<Notification>> {
    self.repo.get(id).await
  }

  async fn get_all(&self) -> anyhow::Result<Vec<Notification>> {
    self.repo.get_all().await
  }

  async fn add(
    &self,
    notification_type: &str,
    session_id: Uuid,
    team_member_id: Option<Uuid>,
    sent: bool,
    discord_message_id: Option<&str>,
  ) -> anyhow::Result<Notification> {
    let record = self.repo.add(notification_type, session_id, team_member_id, sent, discord_message_id).await?;

    Ok(record)
  }

  async fn update(
    &self,
    id: Uuid,
    notification_type: &str,
    session_id: Uuid,
    team_member_id: Option<Uuid>,
    sent: bool,
    discord_message_id: Option<&str>,
  ) -> anyhow::Result<Option<Notification>> {
    let record = self.repo.update(id, notification_type, session_id, team_member_id, sent, discord_message_id).await?;

    Ok(record)
  }

  async fn remove(&self, id: Uuid) -> anyhow::Result<()> {
    self.repo.remove(id).await?;

    Ok(())
  }

  async fn clear(&self) -> anyhow::Result<()> {
    self.repo.clear().await?;

    Ok(())
  }

  async fn get_by_session_id(&self, session_id: Uuid) -> anyhow::Result<Vec<Notification>> {
    self.repo.get_by_session_id(session_id).await
  }

  async fn get_unsent(&self) -> anyhow::Result<Vec<Notification>> {
    self.repo.get_unsent().await
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
