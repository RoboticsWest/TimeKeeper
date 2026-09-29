use std::net::SocketAddr;
use std::sync::Arc;

use anyhow::Result;
use async_graphql::dataloader::DataLoader;
use async_graphql::http::{ALL_WEBSOCKET_PROTOCOLS, GraphiQLSource};
use async_graphql::{Data, Schema};
use async_graphql_axum::{GraphQLProtocol, GraphQLRequest, GraphQLResponse, GraphQLWebSocket};
use axum::Router;
use axum::extract::State;
use axum::extract::ws::WebSocketUpgrade;
use axum::http::HeaderMap;
use axum::response::{Html, IntoResponse};
use axum::routing::get;
use tokio_util::sync::CancellationToken;
use tower_http::cors::{Any, CorsLayer};

use crate::auth::jwt::{Auth, Claims};
use crate::auth::permissions_repository::PermissionsRepository;
use crate::domains::location::{LocationLogic, LocationRepository};
use crate::domains::notification::{NotificationLogic, NotificationRepository};
use crate::domains::rfid_tag::{RfidTagLogic, RfidTagRepository};
use crate::domains::schedule::ScheduleLogic;
use crate::domains::session::{SessionLogic, SessionRepository};
use crate::domains::session_rsvp::{SessionRsvpLogic, SessionRsvpRepository};
use crate::domains::settings::SettingsLogic;
use crate::domains::statistics::{AccoladesLogic, MemberStatsLogic, MemberStatsRepository, StatisticsLogic};
use crate::domains::team_member::{TeamMemberLogic, TeamMemberRepository};
use crate::domains::team_member_session::{TeamMemberSessionLogic, TeamMemberSessionRepository};
use crate::domains::user::UserLogic;
use crate::loaders::{
  AttendanceLoader, AttendanceStatsLoader, LocationLoader, LocationSessionsLoader, MemberAttendanceLoader,
  MemberNotificationsLoader, MemberRfidTagsLoader, MemberRsvpsLoader, MemberStatsLoader, SessionAttendanceLoader,
  SessionLoader, SessionNotificationsLoader, SessionRsvpsLoader, TeamMemberLoader,
};
use crate::schema::{AppSchema, MutationRoot, QueryRoot, SubscriptionRoot};

/// Merges every domain's Query/Mutation/Subscription (see `schema.rs`) into one `AppSchema` and
/// injects the `Arc<dyn XLogic>` each domain's resolvers pull out of the GraphQL `Context` via
/// `ctx.data::<Arc<dyn XLogic>>()`.
#[allow(clippy::too_many_arguments)]
pub fn build_schema(
  location_logic: Arc<dyn LocationLogic>,
  user_logic: Arc<dyn UserLogic>,
  rfid_tag_logic: Arc<dyn RfidTagLogic>,
  notification_logic: Arc<dyn NotificationLogic>,
  team_member_logic: Arc<dyn TeamMemberLogic>,
  team_member_session_logic: Arc<dyn TeamMemberSessionLogic>,
  session_logic: Arc<dyn SessionLogic>,
  session_rsvp_logic: Arc<dyn SessionRsvpLogic>,
  statistics_logic: Arc<dyn StatisticsLogic>,
  member_stats_logic: Arc<dyn MemberStatsLogic>,
  accolades_logic: Arc<dyn AccoladesLogic>,
  schedule_logic: Arc<dyn ScheduleLogic>,
  settings_logic: Arc<dyn SettingsLogic>,
  permissions_repo: Arc<dyn PermissionsRepository>,
) -> AppSchema {
  Schema::build(QueryRoot::default(), MutationRoot::default(), SubscriptionRoot::default())
    .data(location_logic)
    .data(user_logic)
    .data(rfid_tag_logic)
    .data(notification_logic)
    .data(team_member_logic)
    .data(team_member_session_logic)
    .data(session_logic)
    .data(session_rsvp_logic)
    .data(statistics_logic)
    .data(member_stats_logic)
    .data(accolades_logic)
    .data(schedule_logic)
    .data(settings_logic)
    .data(permissions_repo)
    // Nested relationships are resolved server-side (`TeamMemberSession.teamMember`,
    // `Session.location`, ...), so a client can ask for the exact shape it renders. That also means
    // a query's depth is chosen by the caller, and a deeply self-referential one is a way to make
    // the server do unbounded work. Twenty levels is far more than any screen needs and still
    // bounded.
    .limit_depth(MAX_QUERY_DEPTH)
    .finish()
}

/// How deeply a query may nest. See the note in [`build_schema`].
const MAX_QUERY_DEPTH: usize = 20;

/// The per-request data loaders that batch nested relationship lookups.
///
/// Built per request rather than once for the schema on purpose: a loader caches what it has
/// already fetched, which is what makes the same id free twice within one query — and exactly what
/// would hand out stale rows if the cache outlived the request.
fn insert_loaders(data: &mut Data, repos: &Repositories) {
  // belongs-to
  data.insert(DataLoader::new(TeamMemberLoader(repos.team_members.clone()), tokio::spawn));
  data.insert(DataLoader::new(SessionLoader(repos.sessions.clone()), tokio::spawn));
  data.insert(DataLoader::new(LocationLoader(repos.locations.clone()), tokio::spawn));
  data.insert(DataLoader::new(AttendanceLoader(repos.attendance.clone()), tokio::spawn));

  // has-many
  data.insert(DataLoader::new(MemberAttendanceLoader(repos.attendance.clone()), tokio::spawn));
  data.insert(DataLoader::new(SessionAttendanceLoader(repos.attendance.clone()), tokio::spawn));
  data.insert(DataLoader::new(MemberRfidTagsLoader(repos.rfid_tags.clone()), tokio::spawn));
  data.insert(DataLoader::new(SessionRsvpsLoader(repos.rsvps.clone()), tokio::spawn));
  data.insert(DataLoader::new(MemberRsvpsLoader(repos.rsvps.clone()), tokio::spawn));
  data.insert(DataLoader::new(SessionNotificationsLoader(repos.notifications.clone()), tokio::spawn));
  data.insert(DataLoader::new(MemberNotificationsLoader(repos.notifications.clone()), tokio::spawn));
  data.insert(DataLoader::new(LocationSessionsLoader(repos.sessions.clone()), tokio::spawn));

  // recorded statistics
  data.insert(DataLoader::new(MemberStatsLoader(repos.member_stats.clone()), tokio::spawn));
  data.insert(DataLoader::new(AttendanceStatsLoader(repos.member_stats.clone()), tokio::spawn));
}

/// The repositories the data loaders read through.
#[derive(Clone)]
pub struct Repositories {
  pub team_members: Arc<dyn TeamMemberRepository>,
  pub sessions: Arc<dyn SessionRepository>,
  pub locations: Arc<dyn LocationRepository>,
  pub attendance: Arc<dyn TeamMemberSessionRepository>,
  pub rfid_tags: Arc<dyn RfidTagRepository>,
  pub rsvps: Arc<dyn SessionRsvpRepository>,
  pub notifications: Arc<dyn NotificationRepository>,
  pub member_stats: Arc<dyn MemberStatsRepository>,
}

/// GraphQL API server - `/graphql` (queries/mutations over HTTP) and `/graphql/ws` (subscriptions
/// over the graphql-transport-ws protocol). The final injector for every domain's `gql.rs`
/// resolvers, analogous to how `web.rs`'s `Web` is the final injector for static file serving.
pub struct Api {
  addr: SocketAddr,
  schema: AppSchema,
  repos: Repositories,
}

impl Api {
  pub fn new(addr: SocketAddr, schema: AppSchema, repos: Repositories) -> Self {
    Self { addr, schema, repos }
  }

  pub async fn serve(&self, cancel: CancellationToken) -> Result<()> {
    let app = routes(self.schema.clone(), self.repos.clone());

    let listener = tokio::net::TcpListener::bind(self.addr).await?;
    log::info!("API server listening on http://{}", self.addr);

    axum::serve(listener, app).with_graceful_shutdown(async move { cancel.cancelled().await }).await?;
    Ok(())
  }
}

/// The API's routes: `/graphql`, `/graphql/ws` and `/health`.
///
/// Shared with the built-in web server (`web.rs`), which mounts these alongside the static
/// Flutter build so the all-in-one binary answers API calls on its web port too. That keeps
/// the web client same-origin in every deployment, which is what lets it derive the API
/// address from the page it was served from instead of being configured.
/// Everything a handler needs: the schema, plus the repositories that per-request data loaders are
/// built from.
#[derive(Clone)]
pub struct ApiState {
  schema: AppSchema,
  repos: Repositories,
}

pub fn routes(schema: AppSchema, repos: Repositories) -> Router {
  let cors = CorsLayer::new().allow_origin(Any).allow_headers(Any).allow_methods(Any).expose_headers(Any);

  Router::new()
    .route("/graphql", get(graphiql).post(graphql_handler))
    .route("/graphql/ws", get(graphql_ws_handler))
    .route("/health", get(|| async { "OK" }))
    .layer(cors)
    .with_state(ApiState { schema, repos })
}

async fn graphiql() -> impl IntoResponse {
  Html(GraphiQLSource::build().endpoint("/graphql").subscription_endpoint("/graphql/ws").finish())
}

/// Reads the JWT from the `Authorization: Bearer <token>` header, if present, and validates it.
fn extract_claims(headers: &HeaderMap) -> Option<Claims> {
  let value = headers.get("authorization")?.to_str().ok()?;
  let token = value.strip_prefix("Bearer ")?;
  Auth::validate_token(token).ok()
}

async fn graphql_handler(State(state): State<ApiState>, headers: HeaderMap, req: GraphQLRequest) -> GraphQLResponse {
  let mut request = req.into_inner();
  if let Some(claims) = extract_claims(&headers) {
    request = request.data(claims);
  }
  // Fresh loaders for this request only.
  insert_loaders(&mut request.data, &state.repos);
  state.schema.execute(request).await.into()
}

async fn graphql_ws_handler(
  State(state): State<ApiState>,
  protocol: GraphQLProtocol,
  ws: WebSocketUpgrade,
) -> impl IntoResponse {
  ws.protocols(ALL_WEBSOCKET_PROTOCOLS).on_upgrade(move |socket| {
    // A socket outlives any one operation, so its loaders are per-connection rather than
    // per-request. Subscription payloads are single rows, so there is nothing to batch and nothing
    // meaningful to go stale — the loaders are here so the nested fields resolve at all.
    let repos = state.repos.clone();
    GraphQLWebSocket::new(socket, state.schema, protocol)
      .on_connection_init(move |value| on_connection_init(value, repos))
      .serve()
  })
}

/// Browsers can't set custom headers on a WebSocket handshake, so the graphql-ws protocol's
/// `connection_init` message payload carries the token instead (client sends
/// `{"Authorization": "Bearer <token>"}` as the payload).
async fn on_connection_init(value: serde_json::Value, repos: Repositories) -> async_graphql::Result<Data> {
  let mut data = Data::default();
  insert_loaders(&mut data, &repos);
  if let Some(token) = value.get("Authorization").and_then(|v| v.as_str()) {
    let token = token.strip_prefix("Bearer ").unwrap_or(token);
    if let Ok(claims) = Auth::validate_token(token) {
      data.insert(claims);
    }
  }
  Ok(data)
}
