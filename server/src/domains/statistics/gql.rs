use std::sync::Arc;

use async_graphql::{Context, Object, Result};

use super::logic::{LeaderboardEntry, StatisticsLogic};

#[derive(Default)]
pub struct StatisticsQuery;

#[Object]
impl StatisticsQuery {
  async fn leaderboard(&self, ctx: &Context<'_>) -> Result<Vec<LeaderboardEntry>> {
    let logic = ctx.data::<Arc<dyn StatisticsLogic>>()?.clone();
    Ok(logic.get_leaderboard().await?)
  }
}
