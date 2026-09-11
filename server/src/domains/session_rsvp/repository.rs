use async_trait::async_trait;
use diesel::prelude::*;
use diesel_async::RunQueryDsl;
use uuid::Uuid;

use database::{
  DbPool,
  schema::{session_rsvp_messages, session_rsvps},
};

use super::model::{SessionRsvp, SessionRsvpMessage};

#[async_trait]
pub trait SessionRsvpRepository: Send + Sync {
  async fn get_all(&self) -> anyhow::Result<Vec<SessionRsvp>>;
  async fn get_by_session_id(&self, session_id: Uuid) -> anyhow::Result<Vec<SessionRsvp>>;
  async fn upsert(&self, session_id: Uuid, team_member_id: Uuid, status: &str) -> anyhow::Result<SessionRsvp>;
  async fn remove(&self, id: Uuid) -> anyhow::Result<()>;
  async fn remove_by_session_and_member(&self, session_id: Uuid, team_member_id: Uuid) -> anyhow::Result<()>;
  async fn clear(&self) -> anyhow::Result<()>;
}

pub struct PgSessionRsvpRepository {
  pool: DbPool,
}

impl PgSessionRsvpRepository {
  pub fn new(pool: DbPool) -> Self {
    Self { pool }
  }
}

#[async_trait]
impl SessionRsvpRepository for PgSessionRsvpRepository {
  async fn get_all(&self) -> anyhow::Result<Vec<SessionRsvp>> {
    let mut conn = self.pool.get().await?;
    Ok(session_rsvps::table.select(SessionRsvp::as_select()).load(&mut conn).await?)
  }

  async fn get_by_session_id(&self, session_id: Uuid) -> anyhow::Result<Vec<SessionRsvp>> {
    let mut conn = self.pool.get().await?;
    Ok(
      session_rsvps::table
        .filter(session_rsvps::session_id.eq(session_id))
        .select(SessionRsvp::as_select())
        .load(&mut conn)
        .await?,
    )
  }

  async fn upsert(&self, session_id: Uuid, team_member_id: Uuid, status: &str) -> anyhow::Result<SessionRsvp> {
    let mut conn = self.pool.get().await?;
    let id = Uuid::now_v7();
    Ok(
      diesel::insert_into(session_rsvps::table)
        .values((
          session_rsvps::id.eq(id),
          session_rsvps::session_id.eq(session_id),
          session_rsvps::team_member_id.eq(team_member_id),
          session_rsvps::status.eq(status),
        ))
        .on_conflict((session_rsvps::session_id, session_rsvps::team_member_id))
        .do_update()
        .set(session_rsvps::status.eq(status))
        .returning(SessionRsvp::as_select())
        .get_result(&mut conn)
        .await?,
    )
  }

  async fn remove(&self, id: Uuid) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::delete(session_rsvps::table.filter(session_rsvps::id.eq(id))).execute(&mut conn).await?;
    Ok(())
  }

  async fn remove_by_session_and_member(&self, session_id: Uuid, team_member_id: Uuid) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::delete(
      session_rsvps::table
        .filter(session_rsvps::session_id.eq(session_id))
        .filter(session_rsvps::team_member_id.eq(team_member_id)),
    )
    .execute(&mut conn)
    .await?;
    Ok(())
  }

  async fn clear(&self) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::delete(session_rsvps::table).execute(&mut conn).await?;
    Ok(())
  }
}

#[async_trait]
pub trait SessionRsvpMessageRepository: Send + Sync {
  async fn set(&self, discord_message_id: &str, session_id: Uuid) -> anyhow::Result<SessionRsvpMessage>;
  async fn get_by_message_id(&self, discord_message_id: &str) -> anyhow::Result<Option<SessionRsvpMessage>>;
  async fn clear(&self) -> anyhow::Result<()>;
}

pub struct PgSessionRsvpMessageRepository {
  pool: DbPool,
}

impl PgSessionRsvpMessageRepository {
  pub fn new(pool: DbPool) -> Self {
    Self { pool }
  }
}

#[async_trait]
impl SessionRsvpMessageRepository for PgSessionRsvpMessageRepository {
  async fn set(&self, discord_message_id: &str, session_id: Uuid) -> anyhow::Result<SessionRsvpMessage> {
    let mut conn = self.pool.get().await?;
    Ok(
      diesel::insert_into(session_rsvp_messages::table)
        .values((
          session_rsvp_messages::discord_message_id.eq(discord_message_id),
          session_rsvp_messages::session_id.eq(session_id),
        ))
        .on_conflict(session_rsvp_messages::discord_message_id)
        .do_update()
        .set(session_rsvp_messages::session_id.eq(session_id))
        .returning(SessionRsvpMessage::as_select())
        .get_result(&mut conn)
        .await?,
    )
  }

  async fn get_by_message_id(&self, discord_message_id: &str) -> anyhow::Result<Option<SessionRsvpMessage>> {
    let mut conn = self.pool.get().await?;
    Ok(
      session_rsvp_messages::table
        .filter(session_rsvp_messages::discord_message_id.eq(discord_message_id))
        .select(SessionRsvpMessage::as_select())
        .first(&mut conn)
        .await
        .optional()?,
    )
  }

  async fn clear(&self) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::delete(session_rsvp_messages::table).execute(&mut conn).await?;
    Ok(())
  }
}
