use async_trait::async_trait;
use diesel::prelude::*;
use diesel_async::RunQueryDsl;
use uuid::Uuid;

use database::{DbPool, schema::team_members};

use super::model::TeamMember;

/// Narrows a team member query. An empty list means "no constraint".
#[derive(Debug, Clone, Default)]
pub struct TeamMemberFilter {
  /// Case-insensitive substring over first name, last name and display name.
  pub search: Option<String>,
  /// "student" / "mentor".
  pub member_types: Vec<String>,
  /// `Some(true)` for members with a linked Discord account, `Some(false)` for those without.
  pub has_discord: Option<bool>,
  /// `Some(true)` for members with a quick PIN set.
  pub has_quick_pin: Option<bool>,
}

macro_rules! filtered_team_members {
  ($filter:expr) => {{
    let mut query = team_members::table.into_boxed();

    if let Some(search) = $filter.search.as_deref().map(str::trim).filter(|s| !s.is_empty()) {
      // ILIKE rather than lowercasing both sides: it keeps the comparison in the database and
      // reads the same way the admin typed it.
      let pattern = format!("%{search}%");
      query = query.filter(
        team_members::first_name
          .ilike(pattern.clone())
          .or(team_members::last_name.ilike(pattern.clone()))
          .or(team_members::display_name.ilike(pattern)),
      );
    }
    if !$filter.member_types.is_empty() {
      query = query.filter(team_members::member_type.eq_any($filter.member_types.clone()));
    }
    match $filter.has_discord {
      // An empty string is "not linked" too: the column is nullable but the UI writes "".
      Some(true) => query = query.filter(team_members::discord_id.is_not_null().and(team_members::discord_id.ne(""))),
      Some(false) => query = query.filter(team_members::discord_id.is_null().or(team_members::discord_id.eq(""))),
      None => {}
    }
    match $filter.has_quick_pin {
      Some(true) => query = query.filter(team_members::quick_pin.is_not_null().and(team_members::quick_pin.ne(""))),
      Some(false) => query = query.filter(team_members::quick_pin.is_null().or(team_members::quick_pin.eq(""))),
      None => {}
    }

    query
  }};
}

#[async_trait]
pub trait TeamMemberRepository: Send + Sync {
  /// One page of team members matching `filter`, by name, with the total match count.
  async fn query_page(
    &self,
    filter: &TeamMemberFilter,
    offset: i64,
    limit: i64,
  ) -> anyhow::Result<(Vec<TeamMember>, i64)>;
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<TeamMember>>;
  async fn get_all(&self) -> anyhow::Result<Vec<TeamMember>>;
  /// Filters by the `member_type` column (`"student"` or `"mentor"`).
  async fn get_by_member_type(&self, member_type: &str) -> anyhow::Result<Vec<TeamMember>>;
  /// Used to link Discord reactions/roles to a team member by their Discord ID.
  async fn get_by_discord_id(&self, discord_id: &str) -> anyhow::Result<Option<TeamMember>>;
  /// Resolves a PIN typed at a kiosk. Unique index backed, so at most one match.
  async fn get_by_quick_pin(&self, quick_pin: &str) -> anyhow::Result<Option<TeamMember>>;
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
    quick_pin: Option<&str>,
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
    quick_pin: Option<&str>,
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
  async fn query_page(
    &self,
    filter: &TeamMemberFilter,
    offset: i64,
    limit: i64,
  ) -> anyhow::Result<(Vec<TeamMember>, i64)> {
    let mut conn = self.pool.get().await?;

    let total: i64 = filtered_team_members!(filter).count().get_result(&mut conn).await?;

    let items = filtered_team_members!(filter)
      .order((team_members::last_name.asc(), team_members::first_name.asc(), team_members::id.asc()))
      .limit(limit)
      .offset(offset)
      .select(TeamMember::as_select())
      .load(&mut conn)
      .await?;

    Ok((items, total))
  }

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

  async fn get_by_quick_pin(&self, quick_pin: &str) -> anyhow::Result<Option<TeamMember>> {
    let mut conn = self.pool.get().await?;
    Ok(
      team_members::table
        .filter(team_members::quick_pin.eq(quick_pin))
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
    quick_pin: Option<&str>,
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
          team_members::quick_pin.eq(quick_pin),
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
    quick_pin: Option<&str>,
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
          team_members::quick_pin.eq(quick_pin),
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
