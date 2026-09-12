use std::net::SocketAddr;

use anyhow::Result;
use axum::{
  Router,
  body::Body,
  http::{HeaderValue, Request, header},
  middleware::{self, Next},
  response::Response,
  routing::get,
};
use tokio_util::sync::CancellationToken;
use tower::ServiceBuilder;
use tower_http::{
  cors::{Any, CorsLayer},
  services::{ServeDir, ServeFile},
};

async fn set_wasm_headers(req: Request<Body>, next: Next) -> Response {
  let is_wasm = std::path::Path::new(req.uri().path()).extension().is_some_and(|ext| ext.eq_ignore_ascii_case("wasm"));
  let mut response = next.run(req).await;

  // Set WASM MIME type
  if is_wasm {
    response.headers_mut().insert(header::CONTENT_TYPE, HeaderValue::from_static("application/wasm"));
  }

  // Enable cross-origin isolation for WASM threading (required for skwasm)
  response
    .headers_mut()
    .insert(header::HeaderName::from_static("cross-origin-opener-policy"), HeaderValue::from_static("same-origin"));
  response
    .headers_mut()
    .insert(header::HeaderName::from_static("cross-origin-embedder-policy"), HeaderValue::from_static("require-corp"));

  response
}

pub struct Web {
  addr: SocketAddr,
  static_dir: String,
}

impl Web {
  pub fn new(addr: SocketAddr, static_dir: String) -> Self {
    Self { addr, static_dir }
  }

  pub async fn serve(&self, cancel: CancellationToken) -> Result<()> {
    let cors = CorsLayer::new().allow_origin(Any).allow_headers(Any).allow_methods(Any).expose_headers(Any);

    // Create router with static file serving
    let app = Router::new()
      .route("/health", get(|| async { "OK" }))
      // Static file serving as fallback
      .fallback_service(
        ServiceBuilder::new().layer(cors).service(
          ServeDir::new(&self.static_dir)
            .fallback(ServeFile::new(std::path::Path::new(&self.static_dir).join("index.html"))),
        ),
      )
      // Add WASM headers middleware
      .layer(middleware::from_fn(set_wasm_headers))
      // fallback to error 404
      .layer(CorsLayer::permissive());

    // Create TCP listener
    let listener = tokio::net::TcpListener::bind(self.addr).await?;

    log::info!("Web server listening on http://{}", self.addr);
    log::info!("Serving static files from: {}", self.static_dir);

    // Serve with graceful shutdown
    match axum::serve(listener, app).with_graceful_shutdown(async move { cancel.cancelled().await }).await {
      Ok(()) => Ok(()),
      Err(e) => {
        log::error!("Web server error: {:?}", e);
        Err(anyhow::Error::msg("Failed to serve web"))
      }
    }
  }
}
