use std::pin::Pin;

use tokio_stream::{
  Stream, StreamExt,
  wrappers::{BroadcastStream, errors::BroadcastStreamRecvError},
};
use tonic::{Request, Response, Result, Status};

use crate::{
  auth::auth_helpers::require_permission,
  core::{
    events::{ChangeEvent, EVENT_BUS},
    shutdown::with_shutdown,
  },
  generated::{
    api::{
      DeleteTeamMemberSessionRequest, DeleteTeamMemberSessionResponse, GetTeamMemberSessionsRequest,
      GetTeamMemberSessionsResponse, ImportAttendanceCsvRequest, ImportAttendanceCsvResponse,
      StreamTeamMemberSessionsRequest, StreamTeamMemberSessionsResponse, TeamMemberSessionResponse,
      UpdateTeamMemberSessionRequest, UpdateTeamMemberSessionResponse,
      team_member_session_service_server::TeamMemberSessionService,
    },
    common::{Role, SyncType},
    db::{Session, TeamMember, TeamMemberSession},
  },
  modules::{
    location::LocationRepository,
    session::SessionRepository,
    team_member::TeamMemberRepository,
    team_member_session::{TeamMemberSessionRepository, csv_parser::AttendanceCsvParser},
  },
};

pub struct TeamMemberSessionApi;

fn get_all_team_member_sessions() -> std::result::Result<Vec<TeamMemberSessionResponse>, Status> {
  TeamMemberSession::get_all()
    .map_err(|e| Status::internal(format!("Failed to get team member sessions: {}", e)))?
    .into_iter()
    .map(|(id, team_member_session)| {
      Ok(TeamMemberSessionResponse { id, team_member_session: Some(team_member_session) })
    })
    .collect()
}

#[tonic::async_trait]
impl TeamMemberSessionService for TeamMemberSessionApi {
  async fn get_team_member_sessions(
    &self,
    _request: Request<GetTeamMemberSessionsRequest>,
  ) -> Result<Response<GetTeamMemberSessionsResponse>, Status> {
    let team_member_sessions = get_all_team_member_sessions()?;
    Ok(Response::new(GetTeamMemberSessionsResponse { team_member_sessions }))
  }

  type StreamTeamMemberSessionsStream =
    Pin<Box<dyn Stream<Item = Result<StreamTeamMemberSessionsResponse, Status>> + Send>>;

  async fn stream_team_member_sessions(
    &self,
    _request: Request<StreamTeamMemberSessionsRequest>,
  ) -> Result<Response<Self::StreamTeamMemberSessionsStream>, Status> {
    let initial = get_all_team_member_sessions()?;

    let Some(event_bus) = EVENT_BUS.get() else {
      return Err(Status::internal("Event bus not initialized"));
    };

    let rx = event_bus
      .subscribe::<TeamMemberSession>()
      .map_err(|e| Status::internal(format!("Failed to subscribe to team member session events: {}", e)))?;

    let stream = BroadcastStream::new(rx).filter_map(|result| match result {
      Ok(event) => match event {
        ChangeEvent::Record { id, data, .. } => Some(Ok(StreamTeamMemberSessionsResponse {
          team_member_sessions: vec![TeamMemberSessionResponse { id, team_member_session: data }],
          sync_type: SyncType::Partial as i32,
        })),
        ChangeEvent::Table => match get_all_team_member_sessions() {
          Ok(team_member_sessions) => {
            Some(Ok(StreamTeamMemberSessionsResponse { team_member_sessions, sync_type: SyncType::Full as i32 }))
          }
          Err(e) => {
            log::error!("Failed to get all team member sessions after table change: {}", e);
            None
          }
        },
        _ => None,
      },
      Err(BroadcastStreamRecvError::Lagged(n)) => {
        log::warn!("Client lagged by {} messages", n);
        None
      }
    });

    let full_stream = tokio_stream::once(Ok(StreamTeamMemberSessionsResponse {
      team_member_sessions: initial,
      sync_type: SyncType::Full as i32,
    }))
    .chain(stream);
    let full_stream = with_shutdown(full_stream);

    Ok(Response::new(Box::pin(full_stream)))
  }

  async fn update_team_member_session(
    &self,
    request: Request<UpdateTeamMemberSessionRequest>,
  ) -> Result<Response<UpdateTeamMemberSessionResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let request = request.into_inner();

    if request.id.is_empty() {
      return Err(Status::invalid_argument("Team member session ID is required"));
    }

    let existing = TeamMemberSession::get(&request.id)
      .map_err(|e| Status::internal(format!("Failed to get team member session: {}", e)))?;

    let Some(existing) = existing else {
      return Err(Status::not_found("Team member session not found"));
    };

    let updated = TeamMemberSession {
      team_member_id: existing.team_member_id,
      session_id: existing.session_id,
      check_in_time: request.check_in_time,
      check_out_time: request.check_out_time,
      overtime_notified: existing.overtime_notified,
      auto_checkout_notified: existing.auto_checkout_notified,
    };

    TeamMemberSession::update(&request.id, &updated)
      .map_err(|e| Status::internal(format!("Failed to update team member session: {}", e)))?;

    Ok(Response::new(UpdateTeamMemberSessionResponse {}))
  }

  async fn delete_team_member_session(
    &self,
    request: Request<DeleteTeamMemberSessionRequest>,
  ) -> Result<Response<DeleteTeamMemberSessionResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let request = request.into_inner();

    if request.id.is_empty() {
      return Err(Status::invalid_argument("Team member session ID is required"));
    }

    let existing = TeamMemberSession::get(&request.id)
      .map_err(|e| Status::internal(format!("Failed to get team member session: {}", e)))?;

    if existing.is_none() {
      return Err(Status::not_found("Team member session not found"));
    }

    TeamMemberSession::remove(&request.id)
      .map_err(|e| Status::internal(format!("Failed to delete team member session: {}", e)))?;

    Ok(Response::new(DeleteTeamMemberSessionResponse {}))
  }

  async fn import_attendance_csv(
    &self,
    request: Request<ImportAttendanceCsvRequest>,
  ) -> Result<Response<ImportAttendanceCsvResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let bytes = request.into_inner().csv_data;
    let csv_string = String::from_utf8_lossy(&bytes);

    let records = match AttendanceCsvParser::parse(&csv_string) {
      Ok(records) => records,
      Err(err) => return Err(Status::invalid_argument(err.to_string())),
    };

    // Pre-load all sessions and locations for lookup
    let all_sessions = Session::get_all().map_err(|e| Status::internal(format!("Failed to get sessions: {e}")))?;
    let all_locations = crate::generated::db::Location::get_all()
      .map_err(|e| Status::internal(format!("Failed to get locations: {e}")))?;

    // Build location name -> id map
    let location_name_to_id: std::collections::HashMap<String, String> =
      all_locations.iter().map(|(id, loc)| (loc.location.clone(), id.clone())).collect();

    let mut imported = 0;
    let mut skipped = 0;

    for record in records {
      // Look up team member by name
      let members = TeamMember::get_by_name(&record.first_name, &record.last_name)
        .map_err(|e| Status::internal(format!("Failed to look up team member: {e}")))?;

      let Some((member_id, _)) = members.into_iter().next() else {
        log::warn!("[ImportAttendance] Skipping: team member not found: {} {}", record.first_name, record.last_name);
        skipped += 1;
        continue;
      };

      // Look up location by name
      let Some(location_id) = location_name_to_id.get(&record.location) else {
        log::warn!("[ImportAttendance] Skipping: location not found: {}", record.location);
        skipped += 1;
        continue;
      };

      // Find the session at this location that contains the check-in time
      let check_in_secs = record.check_in_time.seconds;
      let matching_session = all_sessions.iter().find(|(_, s)| {
        s.location_id == *location_id
          && s.start_time.as_ref().is_some_and(|t| t.seconds <= check_in_secs)
          && s.end_time.as_ref().is_some_and(|t| check_in_secs <= t.seconds + 4 * 3600) // generous window
      });

      let Some((session_id, _)) = matching_session else {
        log::warn!(
          "[ImportAttendance] Skipping: no matching session for {} {} at {} (check-in: {})",
          record.first_name,
          record.last_name,
          record.location,
          check_in_secs
        );
        skipped += 1;
        continue;
      };

      // Check for existing record (same member + session)
      let existing = TeamMemberSession::get_by_session_id(session_id)
        .map_err(|e| Status::internal(format!("Failed to check existing records: {e}")))?;

      if existing.values().any(|ms| ms.team_member_id == member_id) {
        log::debug!(
          "[ImportAttendance] Skipping duplicate: {} {} already has a record for session {}",
          record.first_name,
          record.last_name,
          session_id
        );
        skipped += 1;
        continue;
      }

      let new_record = TeamMemberSession {
        team_member_id: member_id,
        session_id: session_id.clone(),
        check_in_time: Some(record.check_in_time),
        check_out_time: record.check_out_time,
        overtime_notified: false,
        auto_checkout_notified: false,
      };

      if let Err(e) = TeamMemberSession::add(&new_record) {
        log::error!("[ImportAttendance] Failed to add record for {} {}: {e}", record.first_name, record.last_name);
        skipped += 1;
        continue;
      }

      imported += 1;
    }

    log::info!("[ImportAttendance] Imported {imported} records, skipped {skipped}");
    Ok(Response::new(ImportAttendanceCsvResponse {}))
  }
}
