use async_graphql::dataloader::DataLoader;
use async_graphql::{ComplexObject, Context, Result, SimpleObject};
use chrono::{DateTime, Utc};
use diesel::prelude::*;
use uuid::Uuid;

use database::schema::team_member_sessions;

use crate::auth::auth_helpers::require_permission;
use crate::auth::permissions::PermissionLevel;
use crate::domains::session::Session;
use crate::domains::statistics::AttendanceStats;
use crate::domains::team_member::TeamMember;
use crate::loaders::{AttendanceStatsLoader, SessionLoader, TeamMemberLoader};

/// One visit: a member checked into a session, and possibly back out again.
///
/// `team_member_id` and `session_id` are kept as scalars *and* exposed as the `teamMember` and
/// `session` objects below. A client that only needs ids pays nothing for the objects; one that
/// renders a row asks for the names it is going to print and gets them in the same request, rather
/// than holding a local copy of both tables to look them up in.
#[derive(Debug, Clone, Queryable, Selectable, SimpleObject)]
#[graphql(complex)]
#[diesel(table_name = team_member_sessions)]
#[diesel(check_for_backend(diesel::pg::Pg))]
pub struct TeamMemberSession {
  pub id: Uuid,
  pub team_member_id: Uuid,
  pub session_id: Uuid,
  pub check_in_time: DateTime<Utc>,
  pub check_out_time: Option<DateTime<Utc>>,
}

#[ComplexObject]
impl TeamMemberSession {
  /// The member whose visit this is.
  ///
  /// Batched: a page of rows resolves this in one query, not one per row. `None` only if the member
  /// was deleted between this row being read and the relationship being resolved — attendance
  /// cascades with its member, so it is not a state the database keeps.
  async fn team_member(&self, ctx: &Context<'_>) -> Result<Option<TeamMember>> {
    require_permission(ctx, "team_members", PermissionLevel::Read)?;
    let loader = ctx.data::<DataLoader<TeamMemberLoader>>()?;
    Ok(loader.load_one(self.team_member_id).await?)
  }

  /// The session this visit belongs to.
  async fn session(&self, ctx: &Context<'_>) -> Result<Option<Session>> {
    require_permission(ctx, "sessions", PermissionLevel::Read)?;
    let loader = ctx.data::<DataLoader<SessionLoader>>()?;
    Ok(loader.load_one(self.session_id).await?)
  }

  /// What was recorded about how this visit ended — who ended it, by which route, and whether it
  /// ran past the session's scheduled end. `None` for a visit that is still open, or one imported
  /// from a CSV rather than lived through.
  async fn stats(&self, ctx: &Context<'_>) -> Result<Option<AttendanceStats>> {
    require_permission(ctx, "statistics", PermissionLevel::Read)?;
    let loader = ctx.data::<DataLoader<AttendanceStatsLoader>>()?;
    Ok(loader.load_one(self.id).await?)
  }
}

/// How many people one session has seen, and how many of them are still in it.
///
/// Counted in SQL and returned per session so a client can render the Sessions table's member
/// column, and the kiosk its counters, without holding the attendance table.
#[derive(Debug, Clone, SimpleObject)]
pub struct SessionAttendanceCount {
  pub session_id: Uuid,
  /// Distinct members with at least one attendance row for this session.
  pub members: i64,
  /// Of those, how many have not checked out.
  pub checked_in: i64,
}

/// Table-wide attendance totals, for the KPI tiles that only ever showed a count.
#[derive(Debug, Clone, SimpleObject)]
pub struct AttendanceSummary {
  /// Attendance rows in total.
  pub records: i64,
  /// Distinct members who have ever checked in.
  pub members: i64,
}
