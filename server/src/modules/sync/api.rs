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
      LocationResponse, NotificationResponse, RfidTagResponse, SessionResponse, StreamEntitiesRequest,
      StreamEntitiesResponse, StreamLocationsResponse, StreamNotificationsResponse, StreamRfidTagsResponse,
      StreamSessionsResponse, StreamTeamMemberSessionsResponse, StreamTeamMembersResponse, TeamMemberResponse,
      TeamMemberSessionResponse, stream_entities_response::Payload, sync_service_server::SyncService,
    },
    common::SyncType,
    db::{Location, Notification, RfidTag, Session, TeamMember, TeamMemberSession},
  },
  modules::{
    location::LocationRepository, notification::NotificationRepository, rfid_tag::RfidTagRepository,
    session::SessionRepository, team_member::TeamMemberRepository, team_member_session::TeamMemberSessionRepository,
  },
};

pub struct SyncApi;

// ── Helper functions to get all entities ──────────────────────────────

fn get_all_sessions() -> std::result::Result<Vec<SessionResponse>, Status> {
  Session::get_all()
    .map_err(|e| Status::internal(format!("Failed to get sessions: {e}")))?
    .into_iter()
    .map(|(id, session)| Ok(SessionResponse { id, session: Some(session) }))
    .collect()
}

fn get_all_locations() -> std::result::Result<Vec<LocationResponse>, Status> {
  Location::get_all()
    .map_err(|e| Status::internal(format!("Failed to get locations: {e}")))?
    .into_iter()
    .map(|(id, location)| Ok(LocationResponse { id, location: Some(location) }))
    .collect()
}

fn get_all_members() -> std::result::Result<Vec<TeamMemberResponse>, Status> {
  TeamMember::get_all()
    .map_err(|e| Status::internal(format!("Failed to get team members: {e}")))?
    .into_iter()
    .map(|(id, team_member)| Ok(TeamMemberResponse { id, team_member: Some(team_member) }))
    .collect()
}

fn get_all_rfid_tags() -> std::result::Result<Vec<RfidTagResponse>, Status> {
  RfidTag::get_all()
    .map_err(|e| Status::internal(format!("Failed to get RFID tags: {e}")))?
    .into_iter()
    .map(|(id, rfid_tag)| Ok(RfidTagResponse { id, rfid_tag: Some(rfid_tag) }))
    .collect()
}

fn get_all_notifications() -> std::result::Result<Vec<NotificationResponse>, Status> {
  Notification::get_all()
    .map_err(|e| Status::internal(format!("Failed to get notifications: {e}")))?
    .into_iter()
    .map(|(id, notification)| Ok(NotificationResponse { id, notification: Some(notification) }))
    .collect()
}

fn get_all_team_member_sessions() -> std::result::Result<Vec<TeamMemberSessionResponse>, Status> {
  TeamMemberSession::get_all()
    .map_err(|e| Status::internal(format!("Failed to get team member sessions: {e}")))?
    .into_iter()
    .map(|(id, team_member_session)| {
      Ok(TeamMemberSessionResponse { id, team_member_session: Some(team_member_session) })
    })
    .collect()
}

// ── Wrapper to tag a stream item with its entity type ─────────────────

enum EntityEvent {
  Sessions(StreamSessionsResponse),
  Locations(StreamLocationsResponse),
  TeamMembers(StreamTeamMembersResponse),
  TeamMemberSessions(StreamTeamMemberSessionsResponse),
  RfidTags(StreamRfidTagsResponse),
  Notifications(StreamNotificationsResponse),
}

impl EntityEvent {
  fn into_response(self, sync_type: SyncType) -> StreamEntitiesResponse {
    let st = sync_type as i32;
    match self {
      Self::Sessions(s) => StreamEntitiesResponse { sync_type: st, payload: Some(Payload::Sessions(s)) },
      Self::Locations(l) => StreamEntitiesResponse { sync_type: st, payload: Some(Payload::Locations(l)) },
      Self::TeamMembers(t) => StreamEntitiesResponse { sync_type: st, payload: Some(Payload::TeamMembers(t)) },
      Self::TeamMemberSessions(t) => {
        StreamEntitiesResponse { sync_type: st, payload: Some(Payload::TeamMemberSessions(t)) }
      }
      Self::RfidTags(r) => StreamEntitiesResponse { sync_type: st, payload: Some(Payload::RfidTags(r)) },
      Self::Notifications(n) => StreamEntitiesResponse { sync_type: st, payload: Some(Payload::Notifications(n)) },
    }
  }
}

#[tonic::async_trait]
impl SyncService for SyncApi {
  type StreamEntitiesStream = Pin<Box<dyn Stream<Item = Result<StreamEntitiesResponse, Status>> + Send>>;

  async fn stream_entities(
    &self,
    _request: Request<StreamEntitiesRequest>,
  ) -> Result<Response<Self::StreamEntitiesStream>, Status> {
    let Some(event_bus) = EVENT_BUS.get() else {
      return Err(Status::internal("Event bus not initialized"));
    };

    // ── Initial snapshots ──────────────────────────────────────────

    let initial_sessions = get_all_sessions()?;
    let initial_locations = get_all_locations()?;
    let initial_members = get_all_members()?;
    let initial_member_sessions = get_all_team_member_sessions()?;
    let initial_rfid_tags = get_all_rfid_tags()?;
    let initial_notifications = get_all_notifications()?;

    let initial = vec![
      Ok(
        EntityEvent::Sessions(StreamSessionsResponse { sessions: initial_sessions, sync_type: SyncType::Full as i32 })
          .into_response(SyncType::Full),
      ),
      Ok(
        EntityEvent::Locations(StreamLocationsResponse {
          locations: initial_locations,
          sync_type: SyncType::Full as i32,
        })
        .into_response(SyncType::Full),
      ),
      Ok(
        EntityEvent::TeamMembers(StreamTeamMembersResponse {
          team_members: initial_members,
          sync_type: SyncType::Full as i32,
        })
        .into_response(SyncType::Full),
      ),
      Ok(
        EntityEvent::TeamMemberSessions(StreamTeamMemberSessionsResponse {
          team_member_sessions: initial_member_sessions,
          sync_type: SyncType::Full as i32,
        })
        .into_response(SyncType::Full),
      ),
      Ok(
        EntityEvent::RfidTags(StreamRfidTagsResponse {
          rfid_tags: initial_rfid_tags,
          sync_type: SyncType::Full as i32,
        })
        .into_response(SyncType::Full),
      ),
      Ok(
        EntityEvent::Notifications(StreamNotificationsResponse {
          notifications: initial_notifications,
          sync_type: SyncType::Full as i32,
        })
        .into_response(SyncType::Full),
      ),
    ];

    // ── Subscribe to all entity event bus channels ──────────────────

    let session_rx = event_bus
      .subscribe::<Session>()
      .map_err(|e| Status::internal(format!("Failed to subscribe to session events: {e}")))?;

    let location_rx = event_bus
      .subscribe::<Location>()
      .map_err(|e| Status::internal(format!("Failed to subscribe to location events: {e}")))?;

    let member_rx = event_bus
      .subscribe::<TeamMember>()
      .map_err(|e| Status::internal(format!("Failed to subscribe to team member events: {e}")))?;

    let member_session_rx = event_bus
      .subscribe::<TeamMemberSession>()
      .map_err(|e| Status::internal(format!("Failed to subscribe to team member session events: {e}")))?;

    let rfid_tag_rx = event_bus
      .subscribe::<RfidTag>()
      .map_err(|e| Status::internal(format!("Failed to subscribe to RFID tag events: {e}")))?;

    let notification_rx = event_bus
      .subscribe::<Notification>()
      .map_err(|e| Status::internal(format!("Failed to subscribe to notification events: {e}")))?;

    // ── Map each broadcast stream to EntityEvent ────────────────────

    let session_stream = BroadcastStream::new(session_rx).filter_map(|result| match result {
      Ok(event) => match event {
        ChangeEvent::Record { id, data, .. } => Some(Ok(
          EntityEvent::Sessions(StreamSessionsResponse {
            sessions: vec![SessionResponse { id, session: data }],
            sync_type: SyncType::Partial as i32,
          })
          .into_response(SyncType::Partial),
        )),
        ChangeEvent::Table => match get_all_sessions() {
          Ok(sessions) => Some(Ok(
            EntityEvent::Sessions(StreamSessionsResponse { sessions, sync_type: SyncType::Full as i32 })
              .into_response(SyncType::Full),
          )),
          Err(e) => {
            log::error!("Failed to get sessions after table change: {e}");
            None
          }
        },
        _ => None,
      },
      Err(BroadcastStreamRecvError::Lagged(n)) => {
        log::warn!("Entity session stream lagged by {n} messages");
        None
      }
    });

    let location_stream = BroadcastStream::new(location_rx).filter_map(|result| match result {
      Ok(event) => match event {
        ChangeEvent::Record { id, data, .. } => Some(Ok(
          EntityEvent::Locations(StreamLocationsResponse {
            locations: vec![LocationResponse { id, location: data }],
            sync_type: SyncType::Partial as i32,
          })
          .into_response(SyncType::Partial),
        )),
        ChangeEvent::Table => match get_all_locations() {
          Ok(locations) => Some(Ok(
            EntityEvent::Locations(StreamLocationsResponse { locations, sync_type: SyncType::Full as i32 })
              .into_response(SyncType::Full),
          )),
          Err(e) => {
            log::error!("Failed to get locations after table change: {e}");
            None
          }
        },
        _ => None,
      },
      Err(BroadcastStreamRecvError::Lagged(n)) => {
        log::warn!("Entity location stream lagged by {n} messages");
        None
      }
    });

    let member_stream = BroadcastStream::new(member_rx).filter_map(|result| match result {
      Ok(event) => match event {
        ChangeEvent::Record { id, data, .. } => Some(Ok(
          EntityEvent::TeamMembers(StreamTeamMembersResponse {
            team_members: vec![TeamMemberResponse { id, team_member: data }],
            sync_type: SyncType::Partial as i32,
          })
          .into_response(SyncType::Partial),
        )),
        ChangeEvent::Table => match get_all_members() {
          Ok(team_members) => Some(Ok(
            EntityEvent::TeamMembers(StreamTeamMembersResponse { team_members, sync_type: SyncType::Full as i32 })
              .into_response(SyncType::Full),
          )),
          Err(e) => {
            log::error!("Failed to get team members after table change: {e}");
            None
          }
        },
        _ => None,
      },
      Err(BroadcastStreamRecvError::Lagged(n)) => {
        log::warn!("Entity member stream lagged by {n} messages");
        None
      }
    });

    let member_session_stream = BroadcastStream::new(member_session_rx).filter_map(|result| match result {
      Ok(event) => match event {
        ChangeEvent::Record { id, data, .. } => Some(Ok(
          EntityEvent::TeamMemberSessions(StreamTeamMemberSessionsResponse {
            team_member_sessions: vec![TeamMemberSessionResponse { id, team_member_session: data }],
            sync_type: SyncType::Partial as i32,
          })
          .into_response(SyncType::Partial),
        )),
        ChangeEvent::Table => match get_all_team_member_sessions() {
          Ok(team_member_sessions) => Some(Ok(
            EntityEvent::TeamMemberSessions(StreamTeamMemberSessionsResponse {
              team_member_sessions,
              sync_type: SyncType::Full as i32,
            })
            .into_response(SyncType::Full),
          )),
          Err(e) => {
            log::error!("Failed to get team member sessions after table change: {e}");
            None
          }
        },
        _ => None,
      },
      Err(BroadcastStreamRecvError::Lagged(n)) => {
        log::warn!("Entity member session stream lagged by {n} messages");
        None
      }
    });

    let rfid_tag_stream = BroadcastStream::new(rfid_tag_rx).filter_map(|result| match result {
      Ok(event) => match event {
        ChangeEvent::Record { id, data, .. } => Some(Ok(
          EntityEvent::RfidTags(StreamRfidTagsResponse {
            rfid_tags: vec![RfidTagResponse { id, rfid_tag: data }],
            sync_type: SyncType::Partial as i32,
          })
          .into_response(SyncType::Partial),
        )),
        ChangeEvent::Table => match get_all_rfid_tags() {
          Ok(rfid_tags) => Some(Ok(
            EntityEvent::RfidTags(StreamRfidTagsResponse { rfid_tags, sync_type: SyncType::Full as i32 })
              .into_response(SyncType::Full),
          )),
          Err(e) => {
            log::error!("Failed to get RFID tags after table change: {e}");
            None
          }
        },
        _ => None,
      },
      Err(BroadcastStreamRecvError::Lagged(n)) => {
        log::warn!("Entity RFID tag stream lagged by {n} messages");
        None
      }
    });

    let notification_stream = BroadcastStream::new(notification_rx).filter_map(|result| match result {
      Ok(event) => match event {
        ChangeEvent::Record { id, data, .. } => Some(Ok(
          EntityEvent::Notifications(StreamNotificationsResponse {
            notifications: vec![NotificationResponse { id, notification: data }],
            sync_type: SyncType::Partial as i32,
          })
          .into_response(SyncType::Partial),
        )),
        ChangeEvent::Table => match get_all_notifications() {
          Ok(notifications) => Some(Ok(
            EntityEvent::Notifications(StreamNotificationsResponse { notifications, sync_type: SyncType::Full as i32 })
              .into_response(SyncType::Full),
          )),
          Err(e) => {
            log::error!("Failed to get notifications after table change: {e}");
            None
          }
        },
        _ => None,
      },
      Err(BroadcastStreamRecvError::Lagged(n)) => {
        log::warn!("Entity notification stream lagged by {n} messages");
        None
      }
    });

    // ── Merge all streams ───────────────────────────────────────────

    let merged = session_stream
      .merge(location_stream)
      .merge(member_stream)
      .merge(member_session_stream)
      .merge(rfid_tag_stream)
      .merge(notification_stream);

    // Prepend initial snapshots, then chain live updates
    let full_stream = tokio_stream::iter(initial).chain(merged);
    let full_stream = with_shutdown(full_stream);

    Ok(Response::new(Box::pin(full_stream)))
  }
}
