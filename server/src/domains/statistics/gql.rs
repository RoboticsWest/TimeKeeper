use std::sync::Arc;

use async_graphql::{Context, Object, Result};

use super::logic::{LeaderboardEntry, StatisticsLogic};

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
}
