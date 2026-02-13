use std::{net::SocketAddr, time::Duration};

use anyhow::Result;
use tonic::transport::Server;
use tonic_web::GrpcWebLayer;
use tower_http::cors::{Any, CorsLayer};

use crate::{
  auth::auth_interceptors::auth_interceptor,
  core::shutdown::ShutdownNotifier,
  generated::api::{
    health_service_server::HealthServiceServer, location_service_server::LocationServiceServer,
    schedule_service_server::ScheduleServiceServer, session_service_server::SessionServiceServer,
    settings_service_server::SettingsServiceServer, statistics_service_server::StatisticsServiceServer,
    team_member_service_server::TeamMemberServiceServer,
    team_member_session_service_server::TeamMemberSessionServiceServer, user_service_server::UserServiceServer,
  },
  modules::{
    health::HealthApi, location::LocationApi, schedule::ScheduleApi, session::SessionApi, settings::SettingsApi,
    statistics::StatisticsApi, team_member::TeamMemberApi, team_member_session::TeamMemberSessionApi, user::UserApi,
  },
};

pub struct Api {
  addr: SocketAddr,
}

impl Api {
  pub fn new(addr: SocketAddr) -> Self {
    Self { addr }
  }

  pub async fn serve(&self) -> Result<()> {
    let mut shutdown_rx = ShutdownNotifier::get().subscribe();

    let cors = CorsLayer::new().allow_origin(Any).allow_headers(Any).allow_methods(Any).expose_headers(Any);

    let router = Server::builder()
      // Enable HTTP/1.1 for gRPC-Web (browsers)
      .accept_http1(true)
      // TCP Keepalive (detect broken connections at OS level)
      .tcp_keepalive(Some(Duration::from_secs(60)))
      // HTTP/2 keepalive (detect unresponsive clients)
      .http2_keepalive_interval(Some(Duration::from_secs(30)))
      .http2_keepalive_timeout(Some(Duration::from_secs(10)))
      // Max concurrent streams per connection
      .initial_stream_window_size(Some(1024 * 1024)) // 1MB
      .initial_connection_window_size(Some(1024 * 1024 * 2)) // 2MB
      // Add CORS layer for web clients
      .layer(cors)
      // Add gRPC-Web layer support
      .layer(GrpcWebLayer::new())
      // Add services
      .add_service(HealthServiceServer::new(HealthApi {}))
      .add_service(UserServiceServer::with_interceptor(UserApi {}, auth_interceptor))
      .add_service(ScheduleServiceServer::with_interceptor(ScheduleApi {}, auth_interceptor))
      .add_service(TeamMemberServiceServer::with_interceptor(TeamMemberApi {}, auth_interceptor))
      .add_service(SessionServiceServer::with_interceptor(SessionApi {}, auth_interceptor))
      .add_service(SettingsServiceServer::with_interceptor(SettingsApi {}, auth_interceptor))
      .add_service(LocationServiceServer::with_interceptor(LocationApi {}, auth_interceptor))
      .add_service(StatisticsServiceServer::with_interceptor(StatisticsApi {}, auth_interceptor))
      .add_service(TeamMemberSessionServiceServer::with_interceptor(TeamMemberSessionApi {}, auth_interceptor));

    match router
      .serve_with_shutdown(self.addr, async move {
        shutdown_rx.recv().await.ok();
      })
      .await
    {
      Ok(()) => Ok(()),
      Err(e) => {
        log::error!("Error: {:?}", e);
        Err(anyhow::Error::msg("Failed to serve API"))
      }
    }
  }
}
