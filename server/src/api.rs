use std::net::SocketAddr;
use std::sync::Arc;

use anyhow::Result;
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
use crate::domains::location::LocationLogic;
use crate::domains::notification::NotificationLogic;
use crate::domains::rfid_tag::RfidTagLogic;
use crate::domains::schedule::ScheduleLogic;
use crate::domains::session::SessionLogic;
use crate::domains::session_rsvp::SessionRsvpLogic;
use crate::domains::settings::SettingsLogic;
use crate::domains::statistics::StatisticsLogic;
use crate::domains::team_member::TeamMemberLogic;
use crate::domains::team_member_session::TeamMemberSessionLogic;
use crate::domains::user::UserLogic;
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
    .data(schedule_logic)
    .data(settings_logic)
    .data(permissions_repo)
    .finish()
}

/// GraphQL API server - `/graphql` (queries/mutations over HTTP) and `/graphql/ws` (subscriptions
/// over the graphql-transport-ws protocol). The final injector for every domain's `gql.rs`
/// resolvers, analogous to how `web.rs`'s `Web` is the final injector for static file serving.
pub struct Api {
  addr: SocketAddr,
  schema: AppSchema,
}

impl Api {
  pub fn new(addr: SocketAddr, schema: AppSchema) -> Self {
    Self { addr, schema }
  }

  pub async fn serve(&self, cancel: CancellationToken) -> Result<()> {
    let cors = CorsLayer::new().allow_origin(Any).allow_headers(Any).allow_methods(Any).expose_headers(Any);

    let app = Router::new()
      .route("/graphql", get(graphiql).post(graphql_handler))
      .route("/graphql/ws", get(graphql_ws_handler))
      .route("/health", get(|| async { "OK" }))
      .layer(cors)
      .with_state(self.schema.clone());

    let listener = tokio::net::TcpListener::bind(self.addr).await?;
    log::info!("API server listening on http://{}", self.addr);

    axum::serve(listener, app).with_graceful_shutdown(async move { cancel.cancelled().await }).await?;
    Ok(())
  }
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

async fn graphql_handler(State(schema): State<AppSchema>, headers: HeaderMap, req: GraphQLRequest) -> GraphQLResponse {
  let mut request = req.into_inner();
  if let Some(claims) = extract_claims(&headers) {
    request = request.data(claims);
  }
  schema.execute(request).await.into()
}

async fn graphql_ws_handler(
  State(schema): State<AppSchema>,
  protocol: GraphQLProtocol,
  ws: WebSocketUpgrade,
) -> impl IntoResponse {
  ws.protocols(ALL_WEBSOCKET_PROTOCOLS).on_upgrade(move |socket| {
    GraphQLWebSocket::new(socket, schema, protocol).on_connection_init(on_connection_init).serve()
  })
}

/// Browsers can't set custom headers on a WebSocket handshake, so the graphql-ws protocol's
/// `connection_init` message payload carries the token instead (client sends
/// `{"Authorization": "Bearer <token>"}` as the payload).
async fn on_connection_init(value: serde_json::Value) -> async_graphql::Result<Data> {
  let mut data = Data::default();
  if let Some(token) = value.get("Authorization").and_then(|v| v.as_str()) {
    let token = token.strip_prefix("Bearer ").unwrap_or(token);
    if let Ok(claims) = Auth::validate_token(token) {
      data.insert(claims);
    }
  }
  Ok(data)
}
