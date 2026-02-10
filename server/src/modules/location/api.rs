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
      CreateLocationRequest, CreateLocationResponse, DeleteLocationRequest, DeleteLocationResponse,
      GetLocationsRequest, GetLocationsResponse, LocationResponse, StreamLocationsRequest, StreamLocationsResponse,
      UpdateLocationRequest, UpdateLocationResponse, location_service_server::LocationService,
    },
    common::{Role, SyncType},
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
        ChangeEvent::Record { id, data, .. } => Some(Ok(StreamLocationsResponse {
          locations: vec![LocationResponse { id, location: data }],
          sync_type: SyncType::Partial as i32,
        })),
        ChangeEvent::Table => match get_all_locations() {
          Ok(locations) => Some(Ok(StreamLocationsResponse { locations, sync_type: SyncType::Full as i32 })),
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

    let full_stream =
      tokio_stream::once(Ok(StreamLocationsResponse { locations: initial, sync_type: SyncType::Full as i32 }))
        .chain(stream);
    let full_stream = with_shutdown(full_stream);

    Ok(Response::new(Box::pin(full_stream)))
  }

  async fn create_location(
    &self,
    request: Request<CreateLocationRequest>,
  ) -> Result<Response<CreateLocationResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let request = request.into_inner();

    if request.location.is_empty() {
      return Err(Status::invalid_argument("Location name is required"));
    }

    let location = Location { location: request.location };
    Location::add(&location).map_err(|e| Status::internal(format!("Failed to create location: {}", e)))?;

    Ok(Response::new(CreateLocationResponse {}))
  }

  async fn update_location(
    &self,
    request: Request<UpdateLocationRequest>,
  ) -> Result<Response<UpdateLocationResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let request = request.into_inner();

    if request.id.is_empty() {
      return Err(Status::invalid_argument("Location ID is required"));
    }

    let existing =
      Location::get(&request.id).map_err(|e| Status::internal(format!("Failed to get location: {}", e)))?;

    if existing.is_none() {
      return Err(Status::not_found("Location not found"));
    }

    let location = Location { location: request.location };
    Location::update(&request.id, &location)
      .map_err(|e| Status::internal(format!("Failed to update location: {}", e)))?;

    Ok(Response::new(UpdateLocationResponse {}))
  }

  async fn delete_location(
    &self,
    request: Request<DeleteLocationRequest>,
  ) -> Result<Response<DeleteLocationResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let request = request.into_inner();

    if request.id.is_empty() {
      return Err(Status::invalid_argument("Location ID is required"));
    }

    let existing =
      Location::get(&request.id).map_err(|e| Status::internal(format!("Failed to get location: {}", e)))?;

    if existing.is_none() {
      return Err(Status::not_found("Location not found"));
    }

    Location::remove(&request.id).map_err(|e| Status::internal(format!("Failed to delete location: {}", e)))?;

    Ok(Response::new(DeleteLocationResponse {}))
  }
}
