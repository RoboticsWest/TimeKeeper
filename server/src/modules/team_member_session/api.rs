use std::pin::Pin;

use tokio_stream::{
  Stream, StreamExt,
  wrappers::{BroadcastStream, errors::BroadcastStreamRecvError},
};
use tonic::{Request, Response, Result, Status};

use crate::{
  core::{
    events::{ChangeEvent, EVENT_BUS},
    shutdown::with_shutdown,
  },
  generated::{
    api::{
      GetTeamMemberSessionsRequest, GetTeamMemberSessionsResponse, StreamTeamMemberSessionsRequest,
      StreamTeamMemberSessionsResponse, TeamMemberSessionResponse,
      team_member_session_service_server::TeamMemberSessionService,
    },
    common::SyncType,
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
}
