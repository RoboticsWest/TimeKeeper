use tonic::{Request, Response, Result, Status};

use crate::{
  auth::auth_helpers::require_permission,
  core::db::{get_db, recreate_default_admin},
  generated::{
    api::{
      GetSettingsRequest, GetSettingsResponse, PurgeDatabaseRequest, PurgeDatabaseResponse, UpdateSettingsRequest,
      UpdateSettingsResponse, settings_service_server::SettingsService,
    },
    common::Role,
    db::Settings,
  },
  modules::settings::SettingsRepository,
};

pub struct SettingsApi;

#[tonic::async_trait]
impl SettingsService for SettingsApi {
  async fn get_settings(&self, _request: Request<GetSettingsRequest>) -> Result<Response<GetSettingsResponse>, Status> {
    let settings = Settings::get().map_err(|e| Status::internal(format!("Failed to get settings: {}", e)))?;
    Ok(Response::new(GetSettingsResponse { settings: Some(settings) }))
  }

  async fn update_settings(
    &self,
    request: Request<UpdateSettingsRequest>,
  ) -> Result<Response<UpdateSettingsResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let req = request.into_inner();

    let settings = Settings { next_session_threshold_secs: req.next_session_threshold_secs };
    Settings::set(&settings).map_err(|e| Status::internal(format!("Failed to update settings: {}", e)))?;

    Ok(Response::new(UpdateSettingsResponse {}))
  }

  async fn purge_database(
    &self,
    request: Request<PurgeDatabaseRequest>,
  ) -> Result<Response<PurgeDatabaseResponse>, Status> {
    require_permission(&request, Role::Admin)?;

    let db = get_db().map_err(|e| Status::internal(format!("Failed to get database: {}", e)))?;
    db.clear().map_err(|e| Status::internal(format!("Failed to purge database: {}", e)))?;

    log::warn!("Database purged by admin");

    recreate_default_admin().map_err(|e| Status::internal(format!("Failed to recreate admin user: {}", e)))?;

    Ok(Response::new(PurgeDatabaseResponse {}))
  }
}
