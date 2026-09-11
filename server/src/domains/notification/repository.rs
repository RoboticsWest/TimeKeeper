use async_trait::async_trait;
use diesel::prelude::*;
use diesel_async::RunQueryDsl;
use uuid::Uuid;

use database::{DbPool, schema::notifications};

use super::model::Notification;

#[async_trait]
pub trait NotificationRepository: Send + Sync {
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

pub struct PgNotificationRepository {
  pool: DbPool,
}

impl PgNotificationRepository {
  pub fn new(pool: DbPool) -> Self {
    Self { pool }
  }
}

#[async_trait]
impl NotificationRepository for PgNotificationRepository {
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<Notification>> {
    let mut conn = self.pool.get().await?;
    Ok(
      notifications::table
        .filter(notifications::id.eq(id))
        .select(Notification::as_select())
        .first(&mut conn)
        .await
        .optional()?,
    )
  }

  async fn get_all(&self) -> anyhow::Result<Vec<Notification>> {
    let mut conn = self.pool.get().await?;
    Ok(notifications::table.select(Notification::as_select()).load(&mut conn).await?)
  }

  async fn add(
    &self,
    notification_type: &str,
    session_id: Uuid,
    team_member_id: Option<Uuid>,
    sent: bool,
    discord_message_id: Option<&str>,
  ) -> anyhow::Result<Notification> {
    let mut conn = self.pool.get().await?;
    let id = Uuid::now_v7();
    Ok(
      diesel::insert_into(notifications::table)
        .values((
          notifications::id.eq(id),
          notifications::notification_type.eq(notification_type),
          notifications::session_id.eq(session_id),
          notifications::team_member_id.eq(team_member_id),
          notifications::sent.eq(sent),
          notifications::discord_message_id.eq(discord_message_id),
        ))
        .returning(Notification::as_select())
        .get_result(&mut conn)
        .await?,
    )
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
    let mut conn = self.pool.get().await?;
    Ok(
      diesel::update(notifications::table.filter(notifications::id.eq(id)))
        .set((
          notifications::notification_type.eq(notification_type),
          notifications::session_id.eq(session_id),
          notifications::team_member_id.eq(team_member_id),
          notifications::sent.eq(sent),
          notifications::discord_message_id.eq(discord_message_id),
        ))
        .returning(Notification::as_select())
        .get_result(&mut conn)
        .await
        .optional()?,
    )
  }

  async fn remove(&self, id: Uuid) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::delete(notifications::table.filter(notifications::id.eq(id))).execute(&mut conn).await?;
    Ok(())
  }

  async fn clear(&self) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::delete(notifications::table).execute(&mut conn).await?;
    Ok(())
  }

  async fn get_by_session_id(&self, session_id: Uuid) -> anyhow::Result<Vec<Notification>> {
    let mut conn = self.pool.get().await?;
    Ok(
      notifications::table
        .filter(notifications::session_id.eq(session_id))
        .select(Notification::as_select())
        .load(&mut conn)
        .await?,
    )
  }

  async fn get_unsent(&self) -> anyhow::Result<Vec<Notification>> {
    let mut conn = self.pool.get().await?;
    Ok(
      notifications::table
        .filter(notifications::sent.eq(false))
        .select(Notification::as_select())
        .load(&mut conn)
        .await?,
    )
  }

  async fn exists(
    &self,
    notification_type: &str,
    session_id: Uuid,
    team_member_id: Option<Uuid>,
  ) -> anyhow::Result<bool> {
    let mut conn = self.pool.get().await?;
    let count: i64 = match team_member_id {
      Some(team_member_id) => {
        notifications::table
          .filter(notifications::notification_type.eq(notification_type))
          .filter(notifications::session_id.eq(session_id))
          .filter(notifications::team_member_id.eq(team_member_id))
          .count()
          .get_result(&mut conn)
          .await?
      }
      None => {
        notifications::table
          .filter(notifications::notification_type.eq(notification_type))
          .filter(notifications::session_id.eq(session_id))
          .filter(notifications::team_member_id.is_null())
          .count()
          .get_result(&mut conn)
          .await?
      }
    };
    Ok(count > 0)
  }
}
