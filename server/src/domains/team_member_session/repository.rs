use async_trait::async_trait;
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use diesel_async::RunQueryDsl;
use uuid::Uuid;

use database::{
  DbPool,
  schema::{sessions, team_member_sessions, team_members},
};

use super::model::TeamMemberSession;

/// Narrows an attendance query. Every field is optional; an empty list means "no constraint"
/// rather than "match nothing", which is what a UI with no chips selected means.
///
/// Applied in SQL rather than after loading. Attendance is the table that grows without bound
/// — tens of thousands of rows in a season — so filtering it in Rust would mean fetching
/// everything first, which is exactly what pagination is here to avoid.
#[derive(Debug, Clone, Default)]
pub struct AttendanceFilter {
  /// Check-ins at or after this instant.
  pub from: Option<DateTime<Utc>>,
  /// Check-ins strictly before this instant.
  pub to: Option<DateTime<Utc>>,
  pub team_member_ids: Vec<Uuid>,
  pub session_ids: Vec<Uuid>,
  pub location_ids: Vec<Uuid>,
  /// "student" / "mentor".
  pub member_types: Vec<String>,
  /// `Some(true)` for people still checked in, `Some(false)` for completed visits.
  pub checked_in_only: Option<bool>,
  /// Matches the member's first, last or display name, case-insensitive.
  pub search: Option<String>,
}

/// Builds the filtered, joined attendance query.
///
/// A macro rather than a function because the boxed query type is named differently in the
/// `select` and `count` positions, and writing it out twice is worse than this.
macro_rules! filtered_attendance {
  ($filter:expr) => {{
    let mut query = team_member_sessions::table
      .inner_join(sessions::table.on(sessions::id.eq(team_member_sessions::session_id)))
      .inner_join(team_members::table.on(team_members::id.eq(team_member_sessions::team_member_id)))
      .into_boxed();

    if let Some(from) = $filter.from {
      query = query.filter(team_member_sessions::check_in_time.ge(from));
    }
    if let Some(to) = $filter.to {
      query = query.filter(team_member_sessions::check_in_time.lt(to));
    }
    if !$filter.team_member_ids.is_empty() {
      query = query.filter(team_member_sessions::team_member_id.eq_any($filter.team_member_ids.clone()));
    }
    if !$filter.session_ids.is_empty() {
      query = query.filter(team_member_sessions::session_id.eq_any($filter.session_ids.clone()));
    }
    if !$filter.location_ids.is_empty() {
      query = query.filter(sessions::location_id.eq_any($filter.location_ids.clone()));
    }
    if !$filter.member_types.is_empty() {
      query = query.filter(team_members::member_type.eq_any($filter.member_types.clone()));
    }
    match $filter.checked_in_only {
      Some(true) => query = query.filter(team_member_sessions::check_out_time.is_null()),
      Some(false) => query = query.filter(team_member_sessions::check_out_time.is_not_null()),
      None => {}
    }
    if let Some(search) = $filter.search.as_deref().map(str::trim).filter(|s| !s.is_empty()) {
      // ILIKE like the team-members filter: keeps the comparison in the database and matches
      // however the admin typed it.
      let pattern = format!("%{search}%");
      query = query.filter(
        team_members::first_name
          .ilike(pattern.clone())
          .or(team_members::last_name.ilike(pattern.clone()))
          .or(team_members::display_name.ilike(pattern)),
      );
    }

    query
  }};
}

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

  /// One page of attendance matching `filter`, newest check-in first, with the total number of
  /// matching rows so a pager can size itself.
  async fn query_page(
    &self,
    filter: &AttendanceFilter,
    offset: i64,
    limit: i64,
  ) -> anyhow::Result<(Vec<TeamMemberSession>, i64)>;
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

  async fn query_page(
    &self,
    filter: &AttendanceFilter,
    offset: i64,
    limit: i64,
  ) -> anyhow::Result<(Vec<TeamMemberSession>, i64)> {
    let mut conn = self.pool.get().await?;

    // Counted with the same filters but without the page bounds, so the pager knows how many
    // rows it is paging through rather than just how many it received.
    let total: i64 = filtered_attendance!(filter).count().get_result(&mut conn).await?;

    // Newest first, with the id as a tiebreaker: two check-ins can share a timestamp to the
    // microsecond after a CSV import, and without a total order the same row can appear on two
    // pages or on neither.
    let items = filtered_attendance!(filter)
      .order((team_member_sessions::check_in_time.desc(), team_member_sessions::id.desc()))
      .limit(limit)
      .offset(offset)
      .select(TeamMemberSession::as_select())
      .load(&mut conn)
      .await?;

    Ok((items, total))
  }
}
