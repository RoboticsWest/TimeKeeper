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
      GetLocationsRequest, GetLocationsResponse, LocationResponse, StreamLocationsRequest, StreamLocationsResponse,
      location_service_server::LocationService,
    },
    db::Location,
  },
  modules::location::LocationRepository,
};

pub struct LocationApi;

fn get_all_locations() -> std::result::Result<Vec<LocationResponse>, Status> {
  Location::get_all()
    .map_err(|e| Status::internal(format!("Failed to get locations: {}", e)))?
    .into_iter()
    .map(|(id, location)| Ok(LocationResponse { id, location: Some(location) }))
    .collect()
}

#[tonic::async_trait]
impl LocationService for LocationApi {
  async fn get_locations(
    &self,
    _request: Request<GetLocationsRequest>,
  ) -> Result<Response<GetLocationsResponse>, Status> {
    let locations = get_all_locations()?;
    Ok(Response::new(GetLocationsResponse { locations }))
  }

  type StreamLocationsStream = Pin<Box<dyn Stream<Item = Result<StreamLocationsResponse, Status>> + Send>>;

  async fn stream_locations(
    &self,
    _request: Request<StreamLocationsRequest>,
  ) -> Result<Response<Self::StreamLocationsStream>, Status> {
    let initial = get_all_locations()?;

    let Some(event_bus) = EVENT_BUS.get() else {
      return Err(Status::internal("Event bus not initialized"));
    };

    let rx = event_bus
      .subscribe::<Location>()
      .map_err(|e| Status::internal(format!("Failed to subscribe to location events: {}", e)))?;

    let stream = BroadcastStream::new(rx).filter_map(|result| match result {
      Ok(event) => match event {
        ChangeEvent::Record { id, data, .. } => data.map(|location| {
          Ok(StreamLocationsResponse { locations: vec![LocationResponse { id, location: Some(location) }] })
        }),
        ChangeEvent::Table => match get_all_locations() {
          Ok(locations) => Some(Ok(StreamLocationsResponse { locations })),
          Err(e) => {
            log::error!("Failed to get all locations after table change: {}", e);
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

    let full_stream = tokio_stream::once(Ok(StreamLocationsResponse { locations: initial })).chain(stream);
    let full_stream = with_shutdown(full_stream);

    Ok(Response::new(Box::pin(full_stream)))
  }
}
