use tonic::{Request, Response, Result, Status};

use crate::{
  auth::auth_helpers::require_permission,
  generated::{
    api::{
      UploadScheduleCsvRequest, UploadScheduleCsvResponse, UploadScheduleIcsRequest, UploadScheduleIcsResponse,
      schedule_service_server::ScheduleService,
    },
    common::Role,
    db::{Location, Session},
  },
  modules::{location::LocationRepository, schedule::Schedule, session::SessionRepository},
};

pub struct ScheduleApi;

#[tonic::async_trait]
impl ScheduleService for ScheduleApi {
  async fn upload_schedule_csv(
    &self,
    request: Request<UploadScheduleCsvRequest>,
  ) -> Result<Response<UploadScheduleCsvResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let bytes = request.into_inner().csv_data;
    let csv_string = String::from_utf8_lossy(&bytes);
    let schedule = match Schedule::from_csv(&csv_string) {
      Ok(schedule) => schedule,
      Err(err) => return Err(Status::invalid_argument(err.to_string())),
    };

    // setup locations
    for location in schedule.locations {
      let existing_loc = match Location::get_by_name(&location) {
        Ok(existing_loc) => existing_loc,
        Err(err) => {
          log::error!("Database error getting data {}: {}", location, err);
          return Err(Status::not_found(err.to_string()));
        }
      };

      // check if map is empty
      if existing_loc.is_empty() {
        // Add new location();
        match Location::add(&Location { location: location.clone() }) {
          Ok(_) => {}
          Err(err) => {
            log::error!("Database error adding location {}: {}", location, err);
            return Err(Status::internal(err.to_string()));
          }
        }
      }
    }

    // Setup sessions
    for session in schedule.sessions {
      let locations = match Location::get_by_name(&session.location_name) {
        Ok(locations) => locations,
        Err(err) => {
          log::error!("Database error getting location {}: {}", session.location_name, err);
          return Err(Status::internal(err.to_string()));
        }
      };

      let Some((location_id, _)) = locations.into_iter().next() else {
        log::error!("Location not found: {}", session.location_name);
        return Err(Status::not_found(format!("Location not found: {}", session.location_name)));
      };

      let new_session = Session {
        start_time: Some(session.start_time),
        end_time: Some(session.end_time),
        location_id,
        member_sessions: vec![],
        finished: false,
      };

      match Session::add(&new_session) {
        Ok(_) => {}
        Err(err) => {
          log::error!("Database error adding session: {}", err);
          return Err(Status::internal(err.to_string()));
        }
      }
    }

    Ok(Response::new(UploadScheduleCsvResponse {}))
  }

  async fn upload_schedule_ics(
    &self,
    request: Request<UploadScheduleIcsRequest>,
  ) -> Result<Response<UploadScheduleIcsResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    Ok(Response::new(UploadScheduleIcsResponse {}))
  }
}
