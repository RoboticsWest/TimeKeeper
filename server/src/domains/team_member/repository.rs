use async_trait::async_trait;
use diesel::prelude::*;
use diesel_async::RunQueryDsl;
use uuid::Uuid;

use database::{DbPool, schema::team_members};

use super::model::TeamMember;

#[async_trait]
pub trait TeamMemberRepository: Send + Sync {
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<TeamMember>>;
  async fn get_all(&self) -> anyhow::Result<Vec<TeamMember>>;
  /// Filters by the `member_type` column (`"student"` or `"mentor"`).
  async fn get_by_member_type(&self, member_type: &str) -> anyhow::Result<Vec<TeamMember>>;
  /// Used to link Discord reactions/roles to a team member by their Discord username.
  async fn get_by_discord_id(&self, discord_id: &str) -> anyhow::Result<Option<TeamMember>>;
  /// Used by CSV import (dedup) and attendance import (name -> member lookup).
  async fn get_by_name(&self, first_name: &str, last_name: &str) -> anyhow::Result<Vec<TeamMember>>;
  #[allow(clippy::too_many_arguments)]
  async fn add(
    &self,
    first_name: &str,
    last_name: &str,
    member_type: &str,
    display_name: Option<&str>,
    mobile_number: Option<&str>,
    discord_id: Option<&str>,
  ) -> anyhow::Result<TeamMember>;
  #[allow(clippy::too_many_arguments)]
  async fn update(
    &self,
    id: Uuid,
    first_name: &str,
    last_name: &str,
    member_type: &str,
    display_name: Option<&str>,
    mobile_number: Option<&str>,
    discord_id: Option<&str>,
  ) -> anyhow::Result<Option<TeamMember>>;
  async fn remove(&self, id: Uuid) -> anyhow::Result<()>;
  async fn clear(&self) -> anyhow::Result<()>;
}

pub struct PgTeamMemberRepository {
  pool: DbPool,
}

impl PgTeamMemberRepository {
  pub fn new(pool: DbPool) -> Self {
    Self { pool }
  }
}

#[async_trait]
impl TeamMemberRepository for PgTeamMemberRepository {
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<TeamMember>> {
    let mut conn = self.pool.get().await?;
    Ok(
      team_members::table
        .filter(team_members::id.eq(id))
        .select(TeamMember::as_select())
        .first(&mut conn)
        .await
        .optional()?,
    )
  }

  async fn get_all(&self) -> anyhow::Result<Vec<TeamMember>> {
    let mut conn = self.pool.get().await?;
    Ok(team_members::table.select(TeamMember::as_select()).load(&mut conn).await?)
  }

  async fn get_by_member_type(&self, member_type: &str) -> anyhow::Result<Vec<TeamMember>> {
    let mut conn = self.pool.get().await?;
    Ok(
      team_members::table
        .filter(team_members::member_type.eq(member_type))
        .select(TeamMember::as_select())
        .load(&mut conn)
        .await?,
    )
  }

  async fn get_by_discord_id(&self, discord_id: &str) -> anyhow::Result<Option<TeamMember>> {
    let mut conn = self.pool.get().await?;
    Ok(
      team_members::table
        .filter(team_members::discord_id.eq(discord_id))
        .select(TeamMember::as_select())
        .first(&mut conn)
        .await
        .optional()?,
    )
  }

  async fn get_by_name(&self, first_name: &str, last_name: &str) -> anyhow::Result<Vec<TeamMember>> {
    let mut conn = self.pool.get().await?;
    Ok(
      team_members::table
        .filter(team_members::first_name.eq(first_name))
        .filter(team_members::last_name.eq(last_name))
        .select(TeamMember::as_select())
        .load(&mut conn)
        .await?,
    )
  }

  async fn add(
    &self,
    first_name: &str,
    last_name: &str,
    member_type: &str,
    display_name: Option<&str>,
    mobile_number: Option<&str>,
    discord_id: Option<&str>,
  ) -> anyhow::Result<TeamMember> {
    let mut conn = self.pool.get().await?;
    let id = Uuid::now_v7();
    Ok(
      diesel::insert_into(team_members::table)
        .values((
          team_members::id.eq(id),
          team_members::first_name.eq(first_name),
          team_members::last_name.eq(last_name),
          team_members::member_type.eq(member_type),
          team_members::display_name.eq(display_name),
          team_members::mobile_number.eq(mobile_number),
          team_members::discord_id.eq(discord_id),
        ))
        .returning(TeamMember::as_select())
        .get_result(&mut conn)
        .await?,
    )
  }

  async fn update(
    &self,
    id: Uuid,
    first_name: &str,
    last_name: &str,
    member_type: &str,
    display_name: Option<&str>,
    mobile_number: Option<&str>,
    discord_id: Option<&str>,
  ) -> anyhow::Result<Option<TeamMember>> {
    let mut conn = self.pool.get().await?;
    Ok(
      diesel::update(team_members::table.filter(team_members::id.eq(id)))
        .set((
          team_members::first_name.eq(first_name),
          team_members::last_name.eq(last_name),
          team_members::member_type.eq(member_type),
          team_members::display_name.eq(display_name),
          team_members::mobile_number.eq(mobile_number),
          team_members::discord_id.eq(discord_id),
        ))
        .returning(TeamMember::as_select())
        .get_result(&mut conn)
        .await
        .optional()?,
    )
  }

  async fn remove(&self, id: Uuid) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::delete(team_members::table.filter(team_members::id.eq(id))).execute(&mut conn).await?;
    Ok(())
  }

  async fn clear(&self) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::delete(team_members::table).execute(&mut conn).await?;
    Ok(())
  }
}
