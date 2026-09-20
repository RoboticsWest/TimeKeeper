use std::sync::Arc;

use async_graphql::{Context, Object, Result};
use uuid::Uuid;

use crate::auth::auth_helpers::require_permission;
use crate::auth::permissions::PermissionLevel;

use super::accolades::{AccoladesLogic, AchievementView, MemberAccolades};
use super::logic::{LeaderboardEntry, MemberStatsLogic, StatisticsLogic};
use super::model::{AttendanceStats, TeamMemberStats};

#[derive(Default)]
pub struct StatisticsQuery;

#[Object]
impl StatisticsQuery {
  /// The hours leaderboard.
  ///
  /// `memberTypes` overrides the configured default filter for this call. Omit it to get
  /// whatever `leaderboardMemberTypes` is set to; pass an explicit list (e.g. `["mentor"]`) to
  /// ask for those types regardless of the default; pass `[]` for everyone.
  async fn leaderboard(&self, ctx: &Context<'_>, member_types: Option<Vec<String>>) -> Result<Vec<LeaderboardEntry>> {
    let logic = ctx.data::<Arc<dyn StatisticsLogic>>()?.clone();
    Ok(logic.get_leaderboard(member_types).await?)
  }

  /// A member's lifetime counters — the statistics recorded as events happened rather than
  /// derived from attendance rows.
  ///
  /// Gated on `team_members` rather than a resource of its own: these are facts about a member,
  /// and anybody allowed to read the member is allowed to read them.
  async fn team_member_stats(&self, ctx: &Context<'_>, team_member_id: Uuid) -> Result<TeamMemberStats> {
    require_permission(ctx, "team_members", PermissionLevel::Read)?;
    let logic = ctx.data::<Arc<dyn MemberStatsLogic>>()?.clone();
    Ok(logic.get_member(team_member_id).await?)
  }

  /// Every achievement there is to collect, rated for rarity against the members actually in use.
  ///
  /// Gated despite being the same list for everybody: the rarity figures are aggregates over
  /// the roster, and the team's size is not public information.
  async fn achievement_catalogue(&self, ctx: &Context<'_>) -> Result<Vec<AchievementView>> {
    require_permission(ctx, "team_members", PermissionLevel::Read)?;
    let logic = ctx.data::<Arc<dyn AccoladesLogic>>()?.clone();
    Ok(logic.catalogue().await?)
  }

  /// Every member's title and collection, most decorated first.
  async fn member_accolades(&self, ctx: &Context<'_>) -> Result<Vec<MemberAccolades>> {
    require_permission(ctx, "team_members", PermissionLevel::Read)?;
    let logic = ctx.data::<Arc<dyn AccoladesLogic>>()?.clone();
    Ok(logic.for_all().await?)
  }

  /// One member's title and collection.
  async fn member_accolades_for(&self, ctx: &Context<'_>, team_member_id: Uuid) -> Result<Option<MemberAccolades>> {
    require_permission(ctx, "team_members", PermissionLevel::Read)?;
    let logic = ctx.data::<Arc<dyn AccoladesLogic>>()?.clone();
    Ok(logic.for_member(team_member_id).await?)
  }

  /// What was recorded about each of a member's attendances: who ended it, by which route, and
  /// whether it ran past the session's scheduled end.
  async fn attendance_stats(&self, ctx: &Context<'_>, team_member_id: Uuid) -> Result<Vec<AttendanceStats>> {
    require_permission(ctx, "team_member_sessions", PermissionLevel::Read)?;
    let logic = ctx.data::<Arc<dyn MemberStatsLogic>>()?.clone();
    Ok(logic.get_attendance_for_member(team_member_id).await?)
  }
}
