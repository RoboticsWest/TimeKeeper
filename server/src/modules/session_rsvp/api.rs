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
      GetSessionRsvpsRequest, GetSessionRsvpsResponse, SessionRsvpResponse, StreamSessionRsvpsRequest,
      StreamSessionRsvpsResponse, session_rsvp_service_server::SessionRsvpService,
    },
    common::SyncType,
    db::SessionRsvp,
  },
  modules::session_rsvp::SessionRsvpRepository,
};

pub struct SessionRsvpApi;

fn get_all_session_rsvps() -> std::result::Result<Vec<SessionRsvpResponse>, Status> {
  SessionRsvp::get_all()
    .map_err(|e| Status::internal(format!("Failed to get session RSVPs: {e}")))?
    .into_iter()
    .map(|(id, rsvp)| Ok(SessionRsvpResponse { id, rsvp: Some(rsvp) }))
    .collect()
}

#[tonic::async_trait]
impl SessionRsvpService for SessionRsvpApi {
  async fn get_session_rsvps(
    &self,
    _request: Request<GetSessionRsvpsRequest>,
  ) -> Result<Response<GetSessionRsvpsResponse>, Status> {
    let rsvps = get_all_session_rsvps()?;
    Ok(Response::new(GetSessionRsvpsResponse { rsvps }))
  }

  type StreamSessionRsvpsStream = Pin<Box<dyn Stream<Item = Result<StreamSessionRsvpsResponse, Status>> + Send>>;

  async fn stream_session_rsvps(
    &self,
    _request: Request<StreamSessionRsvpsRequest>,
  ) -> Result<Response<Self::StreamSessionRsvpsStream>, Status> {
    let initial = get_all_session_rsvps()?;

    let Some(event_bus) = EVENT_BUS.get() else {
      return Err(Status::internal("Event bus not initialized"));
    };

    let rx = event_bus
      .subscribe::<SessionRsvp>()
      .map_err(|e| Status::internal(format!("Failed to subscribe to session RSVP events: {e}")))?;

    let stream = BroadcastStream::new(rx).filter_map(|result| match result {
      Ok(event) => match event {
        ChangeEvent::Record { id, data, .. } => Some(Ok(StreamSessionRsvpsResponse {
          rsvps: vec![SessionRsvpResponse { id, rsvp: data }],
          sync_type: SyncType::Partial as i32,
        })),
        ChangeEvent::Table => match get_all_session_rsvps() {
          Ok(rsvps) => Some(Ok(StreamSessionRsvpsResponse { rsvps, sync_type: SyncType::Full as i32 })),
          Err(e) => {
            log::error!("Failed to get all session RSVPs after table change: {e}");
            None
          }
        },
        _ => None,
      },
      Err(BroadcastStreamRecvError::Lagged(n)) => {
        log::warn!("Client lagged by {n} messages");
        None
      }
    });

    let full_stream =
      tokio_stream::once(Ok(StreamSessionRsvpsResponse { rsvps: initial, sync_type: SyncType::Full as i32 }))
        .chain(stream);
    let full_stream = with_shutdown(full_stream);

    Ok(Response::new(Box::pin(full_stream)))
  }
}
