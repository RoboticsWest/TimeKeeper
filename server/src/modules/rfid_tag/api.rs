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
      CreateRfidTagRequest, CreateRfidTagResponse, DeleteRfidTagRequest, DeleteRfidTagResponse,
      DeleteRfidTagsByMemberRequest, DeleteRfidTagsByMemberResponse, GetRfidTagsRequest, GetRfidTagsResponse,
      RfidTagResponse, StreamRfidTagsRequest, StreamRfidTagsResponse, rfid_tag_service_server::RfidTagService,
    },
    common::{Role, SyncType},
    db::RfidTag,
  },
  modules::rfid_tag::RfidTagRepository,
};

pub struct RfidTagApi;

fn get_all_rfid_tags() -> std::result::Result<Vec<RfidTagResponse>, Status> {
  RfidTag::get_all()
    .map_err(|e| Status::internal(format!("Failed to get RFID tags: {}", e)))?
    .into_iter()
    .map(|(id, rfid_tag)| Ok(RfidTagResponse { id, rfid_tag: Some(rfid_tag) }))
    .collect()
}

#[tonic::async_trait]
impl RfidTagService for RfidTagApi {
  async fn get_rfid_tags(
    &self,
    _request: Request<GetRfidTagsRequest>,
  ) -> Result<Response<GetRfidTagsResponse>, Status> {
    let rfid_tags = get_all_rfid_tags()?;
    Ok(Response::new(GetRfidTagsResponse { rfid_tags }))
  }

  type StreamRfidTagsStream = Pin<Box<dyn Stream<Item = Result<StreamRfidTagsResponse, Status>> + Send>>;

  async fn stream_rfid_tags(
    &self,
    _request: Request<StreamRfidTagsRequest>,
  ) -> Result<Response<Self::StreamRfidTagsStream>, Status> {
    let initial = get_all_rfid_tags()?;

    let Some(event_bus) = EVENT_BUS.get() else {
      return Err(Status::internal("Event bus not initialized"));
    };

    let rx = event_bus
      .subscribe::<RfidTag>()
      .map_err(|e| Status::internal(format!("Failed to subscribe to RFID tag events: {}", e)))?;

    let stream = BroadcastStream::new(rx).filter_map(|result| match result {
      Ok(event) => match event {
        ChangeEvent::Record { id, data, .. } => Some(Ok(StreamRfidTagsResponse {
          rfid_tags: vec![RfidTagResponse { id, rfid_tag: data }],
          sync_type: SyncType::Partial as i32,
        })),
        ChangeEvent::Table => match get_all_rfid_tags() {
          Ok(rfid_tags) => Some(Ok(StreamRfidTagsResponse { rfid_tags, sync_type: SyncType::Full as i32 })),
          Err(e) => {
            log::error!("Failed to get all RFID tags after table change: {}", e);
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
      tokio_stream::once(Ok(StreamRfidTagsResponse { rfid_tags: initial, sync_type: SyncType::Full as i32 }))
        .chain(stream);
    let full_stream = with_shutdown(full_stream);

    Ok(Response::new(Box::pin(full_stream)))
  }

  async fn create_rfid_tag(
    &self,
    request: Request<CreateRfidTagRequest>,
  ) -> Result<Response<CreateRfidTagResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let request = request.into_inner();

    if request.team_member_id.is_empty() {
      return Err(Status::invalid_argument("Team member ID is required"));
    }
    if request.tag.is_empty() {
      return Err(Status::invalid_argument("RFID tag is required"));
    }

    let rfid_tag = RfidTag { team_member_id: request.team_member_id, tag: request.tag };

    RfidTag::add(&rfid_tag).map_err(|e| Status::internal(format!("Failed to create RFID tag: {}", e)))?;

    Ok(Response::new(CreateRfidTagResponse {}))
  }

  async fn delete_rfid_tag(
    &self,
    request: Request<DeleteRfidTagRequest>,
  ) -> Result<Response<DeleteRfidTagResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let request = request.into_inner();

    if request.id.is_empty() {
      return Err(Status::invalid_argument("RFID tag ID is required"));
    }

    let existing = RfidTag::get(&request.id).map_err(|e| Status::internal(format!("Failed to get RFID tag: {}", e)))?;

    if existing.is_none() {
      return Err(Status::not_found("RFID tag not found"));
    }

    RfidTag::remove(&request.id).map_err(|e| Status::internal(format!("Failed to delete RFID tag: {}", e)))?;

    Ok(Response::new(DeleteRfidTagResponse {}))
  }

  async fn delete_rfid_tags_by_member(
    &self,
    request: Request<DeleteRfidTagsByMemberRequest>,
  ) -> Result<Response<DeleteRfidTagsByMemberResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let request = request.into_inner();

    if request.team_member_id.is_empty() {
      return Err(Status::invalid_argument("Team member ID is required"));
    }

    let tags = RfidTag::get_by_member_id(&request.team_member_id)
      .map_err(|e| Status::internal(format!("Failed to get RFID tags: {}", e)))?;

    for (id, _) in tags {
      RfidTag::remove(&id).map_err(|e| Status::internal(format!("Failed to delete RFID tag: {}", e)))?;
    }

    Ok(Response::new(DeleteRfidTagsByMemberResponse {}))
  }
}
