use tonic::{Request, Response, Result, Status};

use crate::{
  generated::{
    api::{GetLeaderboardRequest, GetLeaderboardResponse, statistics_service_server::StatisticsService},
    db::Settings,
  },
  modules::settings::SettingsRepository,
};

use super::leaderboard::{LeaderboardConfig, compute_leaderboard};

pub struct StatisticsApi;

#[tonic::async_trait]
impl StatisticsService for StatisticsApi {
  async fn get_leaderboard(
    &self,
    _request: Request<GetLeaderboardRequest>,
  ) -> Result<Response<GetLeaderboardResponse>, Status> {
    let settings = Settings::get().map_err(|e| Status::internal(format!("Failed to get settings: {}", e)))?;

    let config = LeaderboardConfig {
      show_overtime: settings.leaderboard_show_overtime,
      member_types: settings.leaderboard_member_types,
    };

    let entries =
      compute_leaderboard(&config).map_err(|e| Status::internal(format!("Failed to compute leaderboard: {}", e)))?;

    Ok(Response::new(GetLeaderboardResponse { entries }))
  }
}
