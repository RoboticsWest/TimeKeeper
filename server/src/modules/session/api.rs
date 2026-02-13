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
      CheckInOutRequest, CheckInOutResponse, CreateSessionRequest, CreateSessionResponse, DeleteSessionRequest,
      DeleteSessionResponse, GetSessionsRequest, GetSessionsResponse, SessionResponse, StreamSessionsRequest,
      StreamSessionsResponse, UpdateSessionRequest, UpdateSessionResponse, session_service_server::SessionService,
    },
    common::{Role, SyncType},
    db::{Session, TeamMemberSession},
  },
  modules::session::{
    SessionRepository,
    helpers::{find_session_for_location, get_next_session_threshold_secs, is_member_checked_in, now_timestamp},
  },
};

use crate::modules::team_member_session::TeamMemberSessionRepository;

pub struct SessionApi;

fn get_all_sessions() -> std::result::Result<Vec<SessionResponse>, Status> {
  Session::get_all()
    .map_err(|e| Status::internal(format!("Failed to get sessions: {}", e)))?
    .into_iter()
    .map(|(id, session)| Ok(SessionResponse { id, session: Some(session) }))
    .collect()
}

#[tonic::async_trait]
impl SessionService for SessionApi {
  // Getter

  async fn get_sessions(&self, _request: Request<GetSessionsRequest>) -> Result<Response<GetSessionsResponse>, Status> {
    let sessions = get_all_sessions()?;
    Ok(Response::new(GetSessionsResponse { sessions }))
  }

  // Stream

  type StreamSessionsStream = Pin<Box<dyn Stream<Item = Result<StreamSessionsResponse, Status>> + Send>>;

  async fn stream_sessions(
    &self,
    _request: Request<StreamSessionsRequest>,
  ) -> Result<Response<Self::StreamSessionsStream>, Status> {
    let initial = get_all_sessions()?;

    let Some(event_bus) = EVENT_BUS.get() else {
      return Err(Status::internal("Event bus not initialized"));
    };

    let rx = event_bus
      .subscribe::<Session>()
      .map_err(|e| Status::internal(format!("Failed to subscribe to session events: {}", e)))?;

    let stream = BroadcastStream::new(rx).filter_map(|result| match result {
      Ok(event) => match event {
        ChangeEvent::Record { id, data, .. } => Some(Ok(StreamSessionsResponse {
          sessions: vec![SessionResponse { id, session: data }],
          sync_type: SyncType::Partial as i32,
        })),
        ChangeEvent::Table => match get_all_sessions() {
          Ok(sessions) => Some(Ok(StreamSessionsResponse { sessions, sync_type: SyncType::Full as i32 })),
          Err(e) => {
            log::error!("Failed to get all sessions after table change: {}", e);
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

    let full_stream =
      tokio_stream::once(Ok(StreamSessionsResponse { sessions: initial, sync_type: SyncType::Full as i32 }))
        .chain(stream);
    let full_stream = with_shutdown(full_stream);

    Ok(Response::new(Box::pin(full_stream)))
  }

  // Create / Update / Delete

  async fn create_session(
    &self,
    request: Request<CreateSessionRequest>,
  ) -> Result<Response<CreateSessionResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let request = request.into_inner();

    let session = Session {
      start_time: request.start_time,
      end_time: request.end_time,
      location_id: request.location_id,
      finished: false,
      start_reminder_sent: false,
      end_reminder_sent: false,
    };

    Session::add(&session).map_err(|e| Status::internal(format!("Failed to create session: {}", e)))?;

    Ok(Response::new(CreateSessionResponse {}))
  }

  async fn update_session(
    &self,
    request: Request<UpdateSessionRequest>,
  ) -> Result<Response<UpdateSessionResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let request = request.into_inner();

    if request.id.is_empty() {
      return Err(Status::invalid_argument("Session ID is required"));
    }

    let existing = Session::get(&request.id).map_err(|e| Status::internal(format!("Failed to get session: {}", e)))?;

    let Some(existing) = existing else {
      return Err(Status::not_found("Session not found"));
    };

    let session = Session {
      start_time: request.start_time,
      end_time: request.end_time,
      location_id: request.location_id,
      finished: request.finished,
      start_reminder_sent: existing.start_reminder_sent,
      end_reminder_sent: existing.end_reminder_sent,
    };

    Session::update(&request.id, &session).map_err(|e| Status::internal(format!("Failed to update session: {}", e)))?;

    Ok(Response::new(UpdateSessionResponse {}))
  }

  async fn delete_session(
    &self,
    request: Request<DeleteSessionRequest>,
  ) -> Result<Response<DeleteSessionResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let request = request.into_inner();

    if request.id.is_empty() {
      return Err(Status::invalid_argument("Session ID is required"));
    }

    let existing = Session::get(&request.id).map_err(|e| Status::internal(format!("Failed to get session: {}", e)))?;

    if existing.is_none() {
      return Err(Status::not_found("Session not found"));
    }

    Session::remove(&request.id).map_err(|e| Status::internal(format!("Failed to delete session: {}", e)))?;

    Ok(Response::new(DeleteSessionResponse {}))
  }

  // Check In / Out

  async fn check_in_out(&self, request: Request<CheckInOutRequest>) -> Result<Response<CheckInOutResponse>, Status> {
    require_permission(&request, Role::Kiosk)?;
    let req = request.into_inner();
    let team_member_id = req.team_member_id;
    let location_id = req.location_id;
    let now = now_timestamp();

    // Check if the member is already checked in to any session — if so, check them out
    let member_sessions = TeamMemberSession::get_by_member_id(&team_member_id)
      .map_err(|e| Status::internal(format!("Failed to get member sessions: {}", e)))?;

    for (id, mut ms) in member_sessions {
      if is_member_checked_in(&ms) {
        ms.check_out_time = Some(now);
        TeamMemberSession::update(&id, &ms)
          .map_err(|e| Status::internal(format!("Failed to update member session: {}", e)))?;
        return Ok(Response::new(CheckInOutResponse { checked_in: false }));
      }
    }

    // Not checked in — find the right session at this location
    let threshold = get_next_session_threshold_secs();
    let target = find_session_for_location(&location_id, &now, threshold)
      .map_err(|e| Status::internal(format!("Failed to find session: {}", e)))?;

    let Some((session_id, _)) = target else {
      return Err(Status::not_found("No active session at this location"));
    };

    let new_ms = TeamMemberSession { team_member_id, session_id, check_in_time: Some(now), check_out_time: None };

    TeamMemberSession::add(&new_ms).map_err(|e| Status::internal(format!("Failed to create member session: {}", e)))?;

    Ok(Response::new(CheckInOutResponse { checked_in: true }))
  }
}
