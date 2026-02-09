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
      GetSessionsRequest, GetSessionsResponse, SessionResponse, StreamSessionsRequest, StreamSessionsResponse,
      session_service_server::SessionService,
    },
    db::Session,
  },
  modules::session::SessionRepository,
};

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
        ChangeEvent::Record { id, data, .. } => data
          .map(|session| Ok(StreamSessionsResponse { sessions: vec![SessionResponse { id, session: Some(session) }] })),
        ChangeEvent::Table => match get_all_sessions() {
          Ok(sessions) => Some(Ok(StreamSessionsResponse { sessions })),
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

    let full_stream = tokio_stream::once(Ok(StreamSessionsResponse { sessions: initial })).chain(stream);
    let full_stream = with_shutdown(full_stream);

    Ok(Response::new(Box::pin(full_stream)))
  }
}
