use std::net::IpAddr;

use clap::Parser;

#[derive(Parser, Debug, Clone)]
#[command(version, about, long_about = None)]
pub struct ServerConfig {
  /// Binding Ip Address
  #[arg(short, long, default_value = "0.0.0.0")]
  pub addr: IpAddr,

  /// Binding Port for the web server
  #[arg(short, long, default_value_t = 8080)]
  pub web_port: u16,

  /// Disable the built-in web server, leaving only the GraphQL API. Use when the Flutter
  /// build is served by something else (e.g. a reverse proxy that serves the static files
  /// and forwards `/graphql`, `/graphql/ws` and `/health` here).
  #[arg(long)]
  pub no_web: bool,

  /// Directory holding the built Flutter web app, served by the built-in web server.
  #[arg(long, default_value = "client/build/web")]
  pub web_dir: String,

  /// Binding Port for the GraphQL API endpoint (HTTP `/graphql` and WebSocket `/graphql/ws`)
  #[arg(long, default_value_t = 4000)]
  pub graphql_port: u16,

  /// Postgres connection URL. If unset, an embedded Postgres instance is started automatically
  /// under `.pgdata/` and used instead.
  #[arg(long, env = "DATABASE_URL")]
  pub database_url: Option<String>,

  /// The path for the backups directory
  #[arg(long, default_value = "backups")]
  pub backups_path: String,

  /// Admin password (if not provided, uses default or existing password in DB)
  #[arg(long, env = "TK_ADMIN_PASSWORD")]
  pub admin_password: Option<String>,
}

impl ServerConfig {
  pub fn parse_from_cli() -> Self {
    // Missing .env is not an error — flags/real env vars still work without one.
    let _ = dotenvy::dotenv();
    Self::parse()
  }
}
