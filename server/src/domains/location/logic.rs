use async_trait::async_trait;
use uuid::Uuid;

use super::model::Location;
use super::repository::LocationRepository;

#[async_trait]
pub trait LocationLogic: Send + Sync {
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<Location>>;
  async fn get_all(&self) -> anyhow::Result<Vec<Location>>;
  async fn add(&self, location: &str) -> anyhow::Result<Location>;
  async fn update(&self, id: Uuid, location: &str) -> anyhow::Result<Option<Location>>;
  async fn remove(&self, id: Uuid) -> anyhow::Result<()>;
  async fn clear(&self) -> anyhow::Result<()>;
}

pub struct DefaultLocationLogic<R: LocationRepository> {
  repo: R,
}

impl<R: LocationRepository> DefaultLocationLogic<R> {
  pub fn new(repo: R) -> Self {
    Self { repo }
  }
}

#[async_trait]
impl<R: LocationRepository> LocationLogic for DefaultLocationLogic<R> {
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<Location>> {
    self.repo.get(id).await
  }

  async fn get_all(&self) -> anyhow::Result<Vec<Location>> {
    self.repo.get_all().await
  }

  async fn add(&self, location: &str) -> anyhow::Result<Location> {
    self.repo.add(location).await
  }

  async fn update(&self, id: Uuid, location: &str) -> anyhow::Result<Option<Location>> {
    self.repo.update(id, location).await
  }

  async fn remove(&self, id: Uuid) -> anyhow::Result<()> {
    self.repo.remove(id).await
  }

  async fn clear(&self) -> anyhow::Result<()> {
    self.repo.clear().await
  }
}
