use anyhow::Result;
use server::server::Server;

#[tokio::main]
async fn main() -> Result<()> {
  server::logging::init_logging()?;
  Server::new(None).run().await
}
