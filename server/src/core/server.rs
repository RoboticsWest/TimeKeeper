use std::time::Duration;

use anyhow::Result;

use crate::{
  auth::jwt::init_jwt_secret,
  config::ServerConfig,
  core::{
    api::Api, db::init_db, events::init_event_bus, scheduler::SchedulerPool, shutdown::ShutdownNotifier, web::Web,
  },
  modules::session::SessionService,
};

pub struct Server {
  config: ServerConfig,
  scheduler: SchedulerPool,
}

impl Server {
  pub fn new(config: Option<ServerConfig>) -> Self {
    let config = match config {
      Some(cfg) => cfg,
      None => ServerConfig::parse_from_cli(),
    };

    Self { config, scheduler: SchedulerPool::new() }
  }

  pub async fn run(mut self) -> Result<()> {
    log::info!("Running server with config: {:?}", self.config);

    let shutdown_notifier = ShutdownNotifier::get();

    // Middleware Setups
    init_event_bus(1024)?;
    init_db(&self.config)?;
    init_jwt_secret()?;

    // Schedule background services
    self.scheduler.schedule(SessionService, shutdown_notifier);

    log::info!("Scheduled {} background service(s)", self.scheduler.count());

    // Start API server
    let api_socket_addr =
      format!("{}:{}", self.config.addr, self.config.api_port).parse().expect("Error parsing API address");
    let api_server = Api::new(api_socket_addr);
    let mut api_handle = tokio::spawn(async move {
      if let Err(e) = api_server.serve().await {
        log::error!("API Server Error: {:?}", e);
      }
    });

    // Start Web Server
    let web_socket_addr =
      format!("{}:{}", self.config.addr, self.config.web_port).parse().expect("Error parsing API address");
    let web_server = Web::new(web_socket_addr, "client/build/web".to_string());
    let mut web_handle = tokio::spawn(async move {
      if let Err(e) = web_server.serve().await {
        log::error!("Web Server Error: {:?}", e);
      }
    });

    // Wait for shutdown signal
    tokio::signal::ctrl_c().await.expect("Failed to listen for shutdown signal");
    log::warn!("Received shutdown signal, beginning graceful shutdown...");

    // Notify all services to begin graceful shutdown
    shutdown_notifier.notify();

    // Wait for services to shutdown gracefully with timeout
    let timeout_future = async {
      let (api_result, web_result) = tokio::join!(&mut api_handle, &mut web_handle);
      let combined_result = api_result.and(web_result);

      // Wait for scheduled services
      if let Err(e) = self.scheduler.wait_all().await {
        log::error!("Scheduled services error: {:?}", e);
        return combined_result;
      }

      combined_result
    };

    match tokio::time::timeout(Duration::from_secs(5), timeout_future).await {
      Ok(Ok(())) => log::info!("All services shut down gracefully"),
      Ok(Err(e)) => log::error!("Service task panicked: {:?}", e),
      Err(_) => {
        log::warn!("Shutdown timeout - force aborting...");
        api_handle.abort();
        web_handle.abort();
        self.scheduler.abort_all();
      }
    }

    log::info!("Server exited gracefully");
    Ok(())
  }
}
