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

  /// Enable TLS Security (HTTPS)
  #[arg(long, default_value_t = false)]
  pub tls: bool,

  /// The path to the certificate
  #[arg(long, default_value = "cert.pem")]
  pub cert_path: String,

  /// The path to the private key
  #[arg(long, default_value = "key.pem")]
  pub key_path: String,

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
