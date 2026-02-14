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
      GetTeamMemberSessionsResponse, StreamTeamMemberSessionsRequest, StreamTeamMemberSessionsResponse,
      TeamMemberSessionResponse, UpdateTeamMemberSessionRequest, UpdateTeamMemberSessionResponse,
      team_member_session_service_server::TeamMemberSessionService,
    },
    common::{Role, SyncType},
    db::TeamMemberSession,
  },
  modules::team_member_session::TeamMemberSessionRepository,
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
}
