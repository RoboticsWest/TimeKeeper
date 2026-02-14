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
      CreateNotificationRequest, CreateNotificationResponse, DeleteNotificationRequest, DeleteNotificationResponse,
      GetNotificationsRequest, GetNotificationsResponse, NotificationResponse, StreamNotificationsRequest,
      StreamNotificationsResponse, UpdateNotificationRequest, UpdateNotificationResponse,
      notification_service_server::NotificationService,
    },
    common::{Role, SyncType},
    db::Notification,
  },
  modules::notification::NotificationRepository,
};

pub struct NotificationApi;

fn get_all_notifications() -> std::result::Result<Vec<NotificationResponse>, Status> {
  Notification::get_all()
    .map_err(|e| Status::internal(format!("Failed to get notifications: {e}")))?
    .into_iter()
    .map(|(id, notification)| Ok(NotificationResponse { id, notification: Some(notification) }))
    .collect()
}

#[tonic::async_trait]
impl NotificationService for NotificationApi {
  async fn get_notifications(
    &self,
    _request: Request<GetNotificationsRequest>,
  ) -> Result<Response<GetNotificationsResponse>, Status> {
    let notifications = get_all_notifications()?;
    Ok(Response::new(GetNotificationsResponse { notifications }))
  }

  type StreamNotificationsStream = Pin<Box<dyn Stream<Item = Result<StreamNotificationsResponse, Status>> + Send>>;

  async fn stream_notifications(
    &self,
    _request: Request<StreamNotificationsRequest>,
  ) -> Result<Response<Self::StreamNotificationsStream>, Status> {
    let initial = get_all_notifications()?;

    let Some(event_bus) = EVENT_BUS.get() else {
      return Err(Status::internal("Event bus not initialized"));
    };

    let rx = event_bus
      .subscribe::<Notification>()
      .map_err(|e| Status::internal(format!("Failed to subscribe to notification events: {e}")))?;

    let stream = BroadcastStream::new(rx).filter_map(|result| match result {
      Ok(event) => match event {
        ChangeEvent::Record { id, data, .. } => Some(Ok(StreamNotificationsResponse {
          notifications: vec![NotificationResponse { id, notification: data }],
          sync_type: SyncType::Partial as i32,
        })),
        ChangeEvent::Table => match get_all_notifications() {
          Ok(notifications) => {
            Some(Ok(StreamNotificationsResponse { notifications, sync_type: SyncType::Full as i32 }))
          }
          Err(e) => {
            log::error!("Failed to get all notifications after table change: {e}");
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
      tokio_stream::once(Ok(StreamNotificationsResponse { notifications: initial, sync_type: SyncType::Full as i32 }))
        .chain(stream);
    let full_stream = with_shutdown(full_stream);

    Ok(Response::new(Box::pin(full_stream)))
  }

  async fn create_notification(
    &self,
    request: Request<CreateNotificationRequest>,
  ) -> Result<Response<CreateNotificationResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let req = request.into_inner();

    if req.session_id.is_empty() {
      return Err(Status::invalid_argument("Session ID is required"));
    }

    let notification = Notification {
      notification_type: req.notification_type,
      session_id: req.session_id,
      team_member_id: req.team_member_id,
      sent: req.sent,
    };
    Notification::add(&notification).map_err(|e| Status::internal(format!("Failed to create notification: {e}")))?;

    Ok(Response::new(CreateNotificationResponse {}))
  }

  async fn update_notification(
    &self,
    request: Request<UpdateNotificationRequest>,
  ) -> Result<Response<UpdateNotificationResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let req = request.into_inner();

    if req.id.is_empty() {
      return Err(Status::invalid_argument("Notification ID is required"));
    }

    let existing =
      Notification::get(&req.id).map_err(|e| Status::internal(format!("Failed to get notification: {e}")))?;

    if existing.is_none() {
      return Err(Status::not_found("Notification not found"));
    }

    let notification = Notification {
      notification_type: req.notification_type,
      session_id: req.session_id,
      team_member_id: req.team_member_id,
      sent: req.sent,
    };
    Notification::update(&req.id, &notification)
      .map_err(|e| Status::internal(format!("Failed to update notification: {e}")))?;

    Ok(Response::new(UpdateNotificationResponse {}))
  }

  async fn delete_notification(
    &self,
    request: Request<DeleteNotificationRequest>,
  ) -> Result<Response<DeleteNotificationResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let req = request.into_inner();

    if req.id.is_empty() {
      return Err(Status::invalid_argument("Notification ID is required"));
    }

    let existing =
      Notification::get(&req.id).map_err(|e| Status::internal(format!("Failed to get notification: {e}")))?;

    if existing.is_none() {
      return Err(Status::not_found("Notification not found"));
    }

    Notification::remove(&req.id).map_err(|e| Status::internal(format!("Failed to delete notification: {e}")))?;

    Ok(Response::new(DeleteNotificationResponse {}))
  }
}
