use async_trait::async_trait;
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use diesel_async::RunQueryDsl;
use uuid::Uuid;

use database::{DbPool, schema::team_member_sessions};

use super::model::TeamMemberSession;

#[async_trait]
pub trait TeamMemberSessionRepository: Send + Sync {
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<TeamMemberSession>>;
  async fn get_all(&self) -> anyhow::Result<Vec<TeamMemberSession>>;
  /// All session check-in records for a given team member (e.g. to check if they're already
  /// checked into any session).
  async fn get_by_member_id(&self, team_member_id: Uuid) -> anyhow::Result<Vec<TeamMemberSession>>;
  /// All team members checked into a given session.
  async fn get_by_session_id(&self, session_id: Uuid) -> anyhow::Result<Vec<TeamMemberSession>>;
  async fn add(
    &self,
    team_member_id: Uuid,
    session_id: Uuid,
    check_in_time: DateTime<Utc>,
    check_out_time: Option<DateTime<Utc>>,
  ) -> anyhow::Result<TeamMemberSession>;
  async fn update(
    &self,
    id: Uuid,
    team_member_id: Uuid,
    session_id: Uuid,
    check_in_time: DateTime<Utc>,
    check_out_time: Option<DateTime<Utc>>,
  ) -> anyhow::Result<Option<TeamMemberSession>>;
  async fn remove(&self, id: Uuid) -> anyhow::Result<()>;
  async fn clear(&self) -> anyhow::Result<()>;
}

pub struct PgTeamMemberSessionRepository {
  pool: DbPool,
}

impl PgTeamMemberSessionRepository {
  pub fn new(pool: DbPool) -> Self {
    Self { pool }
  }
}

#[async_trait]
impl TeamMemberSessionRepository for PgTeamMemberSessionRepository {
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<TeamMemberSession>> {
    let mut conn = self.pool.get().await?;
    Ok(
      team_member_sessions::table
        .filter(team_member_sessions::id.eq(id))
        .select(TeamMemberSession::as_select())
        .first(&mut conn)
        .await
        .optional()?,
    )
  }

  async fn get_all(&self) -> anyhow::Result<Vec<TeamMemberSession>> {
    let mut conn = self.pool.get().await?;
    Ok(team_member_sessions::table.select(TeamMemberSession::as_select()).load(&mut conn).await?)
  }

  async fn get_by_member_id(&self, team_member_id: Uuid) -> anyhow::Result<Vec<TeamMemberSession>> {
    let mut conn = self.pool.get().await?;
    Ok(
      team_member_sessions::table
        .filter(team_member_sessions::team_member_id.eq(team_member_id))
        .select(TeamMemberSession::as_select())
        .load(&mut conn)
        .await?,
    )
  }

  async fn get_by_session_id(&self, session_id: Uuid) -> anyhow::Result<Vec<TeamMemberSession>> {
    let mut conn = self.pool.get().await?;
    Ok(
      team_member_sessions::table
        .filter(team_member_sessions::session_id.eq(session_id))
        .select(TeamMemberSession::as_select())
        .load(&mut conn)
        .await?,
    )
  }

  async fn add(
    &self,
    team_member_id: Uuid,
    session_id: Uuid,
    check_in_time: DateTime<Utc>,
    check_out_time: Option<DateTime<Utc>>,
  ) -> anyhow::Result<TeamMemberSession> {
    let mut conn = self.pool.get().await?;
    let id = Uuid::now_v7();
    Ok(
      diesel::insert_into(team_member_sessions::table)
        .values((
          team_member_sessions::id.eq(id),
          team_member_sessions::team_member_id.eq(team_member_id),
          team_member_sessions::session_id.eq(session_id),
          team_member_sessions::check_in_time.eq(check_in_time),
          team_member_sessions::check_out_time.eq(check_out_time),
        ))
        .returning(TeamMemberSession::as_select())
        .get_result(&mut conn)
        .await?,
    )
  }

  async fn update(
    &self,
    id: Uuid,
    team_member_id: Uuid,
    session_id: Uuid,
    check_in_time: DateTime<Utc>,
    check_out_time: Option<DateTime<Utc>>,
  ) -> anyhow::Result<Option<TeamMemberSession>> {
    let mut conn = self.pool.get().await?;
    Ok(
      diesel::update(team_member_sessions::table.filter(team_member_sessions::id.eq(id)))
        .set((
          team_member_sessions::team_member_id.eq(team_member_id),
          team_member_sessions::session_id.eq(session_id),
          team_member_sessions::check_in_time.eq(check_in_time),
          team_member_sessions::check_out_time.eq(check_out_time),
        ))
        .returning(TeamMemberSession::as_select())
        .get_result(&mut conn)
        .await
        .optional()?,
    )
  }

  async fn remove(&self, id: Uuid) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::delete(team_member_sessions::table.filter(team_member_sessions::id.eq(id))).execute(&mut conn).await?;
    Ok(())
  }

  async fn clear(&self) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::delete(team_member_sessions::table).execute(&mut conn).await?;
    Ok(())
  }
}
