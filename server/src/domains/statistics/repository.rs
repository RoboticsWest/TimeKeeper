//! Persistence for the recorded statistics tables.
//!
//! Every write here is idempotent-ish by construction: the per-attendance row is an upsert keyed
//! on the attendance it describes, and the counters are `+= 1` rather than a recomputed total.
//! Nothing recomputes a counter from a scan, because that would defeat the point of recording it.

use async_trait::async_trait;
use diesel::prelude::*;
use diesel_async::RunQueryDsl;
use uuid::Uuid;

use database::{
  DbPool,
  schema::{attendance_stats, team_member_sessions, team_member_stats},
};

use super::model::{AttendanceStats, CHECKOUT_NONE, SOURCE_UNKNOWN, TeamMemberStats};

#[async_trait]
pub trait MemberStatsRepository: Send + Sync {
  /// Records how an attendance ended. Upserts, so a corrected checkout overwrites rather than
  /// duplicating.
  async fn record_checkout(
    &self,
    team_member_session_id: Uuid,
    kind: &str,
    source: &str,
    late: bool,
  ) -> anyhow::Result<()>;

  /// Returns an attendance's stats row to "still checked in", after an edit removed its checkout.
  async fn reopen(&self, team_member_session_id: Uuid) -> anyhow::Result<()>;

  async fn record_overtime_warning(&self, team_member_id: Uuid) -> anyhow::Result<()>;

  /// Every attendance stats row belonging to one member, via the attendance rows themselves.
  async fn get_attendance_for_member(&self, team_member_id: Uuid) -> anyhow::Result<Vec<AttendanceStats>>;

  /// A member's counters, zeroed when no row exists yet.
  async fn get_member(&self, team_member_id: Uuid) -> anyhow::Result<TeamMemberStats>;

  /// Every attendance stats row. For building the whole team's accolades in one pass.
  async fn get_all_attendance(&self) -> anyhow::Result<Vec<AttendanceStats>>;

  /// Every member's counters.
  async fn get_all_members(&self) -> anyhow::Result<Vec<TeamMemberStats>>;
}

pub struct PgMemberStatsRepository {
  pool: DbPool,
}

impl PgMemberStatsRepository {
  pub fn new(pool: DbPool) -> Self {
    Self { pool }
  }
}

#[async_trait]
impl MemberStatsRepository for PgMemberStatsRepository {
  async fn record_checkout(
    &self,
    team_member_session_id: Uuid,
    kind: &str,
    source: &str,
    late: bool,
  ) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::insert_into(attendance_stats::table)
      .values((
        attendance_stats::team_member_session_id.eq(team_member_session_id),
        attendance_stats::checkout_kind.eq(kind),
        attendance_stats::checkout_source.eq(source),
        attendance_stats::checked_out_late.eq(late),
      ))
      .on_conflict(attendance_stats::team_member_session_id)
      .do_update()
      .set((
        attendance_stats::checkout_kind.eq(kind),
        attendance_stats::checkout_source.eq(source),
        attendance_stats::checked_out_late.eq(late),
      ))
      .execute(&mut conn)
      .await?;
    Ok(())
  }

  async fn reopen(&self, team_member_session_id: Uuid) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    // All three together: the CHECK constraint requires an open row to carry no source and no
    // late flag, so clearing the kind alone would be rejected.
    diesel::update(attendance_stats::table.filter(attendance_stats::team_member_session_id.eq(team_member_session_id)))
      .set((
        attendance_stats::checkout_kind.eq(CHECKOUT_NONE),
        attendance_stats::checkout_source.eq(SOURCE_UNKNOWN),
        attendance_stats::checked_out_late.eq(false),
      ))
      .execute(&mut conn)
      .await?;
    Ok(())
  }

  async fn record_overtime_warning(&self, team_member_id: Uuid) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::insert_into(team_member_stats::table)
      .values((team_member_stats::team_member_id.eq(team_member_id), team_member_stats::overtime_warnings.eq(1)))
      .on_conflict(team_member_stats::team_member_id)
      .do_update()
      .set((
        team_member_stats::overtime_warnings.eq(team_member_stats::overtime_warnings + 1),
        team_member_stats::updated_at.eq(diesel::dsl::now),
      ))
      .execute(&mut conn)
      .await?;
    Ok(())
  }

  async fn get_attendance_for_member(&self, team_member_id: Uuid) -> anyhow::Result<Vec<AttendanceStats>> {
    let mut conn = self.pool.get().await?;
    Ok(
      attendance_stats::table
        .inner_join(team_member_sessions::table)
        .filter(team_member_sessions::team_member_id.eq(team_member_id))
        .select(AttendanceStats::as_select())
        .load(&mut conn)
        .await?,
    )
  }

  async fn get_member(&self, team_member_id: Uuid) -> anyhow::Result<TeamMemberStats> {
    let mut conn = self.pool.get().await?;
    let found = team_member_stats::table
      .filter(team_member_stats::team_member_id.eq(team_member_id))
      .select(TeamMemberStats::as_select())
      .first(&mut conn)
      .await
      .optional()?;
    Ok(found.unwrap_or_else(|| TeamMemberStats::zeroed(team_member_id)))
  }

  async fn get_all_attendance(&self) -> anyhow::Result<Vec<AttendanceStats>> {
    let mut conn = self.pool.get().await?;
    Ok(attendance_stats::table.select(AttendanceStats::as_select()).load(&mut conn).await?)
  }

  async fn get_all_members(&self) -> anyhow::Result<Vec<TeamMemberStats>> {
    let mut conn = self.pool.get().await?;
    Ok(team_member_stats::table.select(TeamMemberStats::as_select()).load(&mut conn).await?)
  }
}
