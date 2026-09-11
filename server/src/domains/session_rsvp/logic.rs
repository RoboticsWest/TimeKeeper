use async_trait::async_trait;
use uuid::Uuid;

use super::model::{SessionRsvp, SessionRsvpMessage};
use super::repository::{SessionRsvpMessageRepository, SessionRsvpRepository};

#[async_trait]
pub trait SessionRsvpLogic: Send + Sync {
  async fn get_all(&self) -> anyhow::Result<Vec<SessionRsvp>>;
  async fn get_by_session_id(&self, session_id: Uuid) -> anyhow::Result<Vec<SessionRsvp>>;
  /// Creates or replaces a member's RSVP for a session. Emits `Create` if this member had no RSVP
  /// for the session yet, `Update` otherwise - mirrors the old sled-era repository's behavior.
  async fn upsert(&self, session_id: Uuid, team_member_id: Uuid, status: &str) -> anyhow::Result<SessionRsvp>;
  async fn remove(&self, id: Uuid) -> anyhow::Result<()>;
  async fn remove_by_session_and_member(&self, session_id: Uuid, team_member_id: Uuid) -> anyhow::Result<()>;
  async fn clear(&self) -> anyhow::Result<()>;
}

pub struct DefaultSessionRsvpLogic<R: SessionRsvpRepository> {
  repo: R,
}

impl<R: SessionRsvpRepository> DefaultSessionRsvpLogic<R> {
  pub fn new(repo: R) -> Self {
    Self { repo }
  }
}

#[async_trait]
impl<R: SessionRsvpRepository> SessionRsvpLogic for DefaultSessionRsvpLogic<R> {
  async fn get_all(&self) -> anyhow::Result<Vec<SessionRsvp>> {
    self.repo.get_all().await
  }

  async fn get_by_session_id(&self, session_id: Uuid) -> anyhow::Result<Vec<SessionRsvp>> {
    self.repo.get_by_session_id(session_id).await
  }

  async fn upsert(&self, session_id: Uuid, team_member_id: Uuid, status: &str) -> anyhow::Result<SessionRsvp> {
    self.repo.upsert(session_id, team_member_id, status).await
  }

  async fn remove(&self, id: Uuid) -> anyhow::Result<()> {
    self.repo.remove(id).await
  }

  async fn remove_by_session_and_member(&self, session_id: Uuid, team_member_id: Uuid) -> anyhow::Result<()> {
    self.repo.remove_by_session_and_member(session_id, team_member_id).await
  }

  async fn clear(&self) -> anyhow::Result<()> {
    self.repo.clear().await?;

    Ok(())
  }
}

/// Tracks which Discord message is showing RSVPs for which session. Unlike `SessionRsvpLogic`,
/// the old sled-era repository never published events for these mutations, so neither does this.
#[async_trait]
pub trait SessionRsvpMessageLogic: Send + Sync {
  async fn set(&self, discord_message_id: &str, session_id: Uuid) -> anyhow::Result<SessionRsvpMessage>;
  async fn get_by_message_id(&self, discord_message_id: &str) -> anyhow::Result<Option<SessionRsvpMessage>>;
  async fn clear(&self) -> anyhow::Result<()>;
}

pub struct DefaultSessionRsvpMessageLogic<R: SessionRsvpMessageRepository> {
  repo: R,
}

impl<R: SessionRsvpMessageRepository> DefaultSessionRsvpMessageLogic<R> {
  pub fn new(repo: R) -> Self {
    Self { repo }
  }
}

#[async_trait]
impl<R: SessionRsvpMessageRepository> SessionRsvpMessageLogic for DefaultSessionRsvpMessageLogic<R> {
  async fn set(&self, discord_message_id: &str, session_id: Uuid) -> anyhow::Result<SessionRsvpMessage> {
    self.repo.set(discord_message_id, session_id).await
  }

  async fn get_by_message_id(&self, discord_message_id: &str) -> anyhow::Result<Option<SessionRsvpMessage>> {
    self.repo.get_by_message_id(discord_message_id).await
  }

  async fn clear(&self) -> anyhow::Result<()> {
    self.repo.clear().await
  }
}
