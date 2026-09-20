use async_trait::async_trait;
use uuid::Uuid;

use super::model::User;
use super::repository::{UserFilter, UserRepository};

/// Reserved username for the built-in admin account. Never returned by user listing/streaming and
/// never modifiable/deletable through the CRUD RPCs - mirrors the old sled-era behavior.
pub const DEFAULT_ADMIN_USERNAME: &str = "admin";

#[async_trait]
pub trait UserLogic: Send + Sync {
  /// One page of users matching `filter`, ordered by username, with the total match count.
  ///
  /// Never includes the built-in admin account, matching the unpaged `get_all` listing.
  async fn query_page(&self, filter: &UserFilter, offset: i64, limit: i64) -> anyhow::Result<(Vec<User>, i64)>;
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<User>>;
  async fn get_all(&self) -> anyhow::Result<Vec<User>>;
  async fn get_by_username(&self, username: &str) -> anyhow::Result<Option<User>>;
  async fn add(&self, username: &str, password: &str) -> anyhow::Result<User>;
  async fn update(&self, id: Uuid, username: &str, password: &str) -> anyhow::Result<Option<User>>;
  async fn remove(&self, id: Uuid) -> anyhow::Result<()>;
  /// Overwrites the built-in admin account's password directly, no old-password check - mirrors
  /// the old sled-era `UserRepository::set_admin_password`.
  async fn set_admin_password(&self, password: &str) -> anyhow::Result<()>;
  async fn clear(&self) -> anyhow::Result<()>;
}

pub struct DefaultUserLogic<R: UserRepository> {
  repo: R,
}

impl<R: UserRepository> DefaultUserLogic<R> {
  pub fn new(repo: R) -> Self {
    Self { repo }
  }
}

#[async_trait]
impl<R: UserRepository> UserLogic for DefaultUserLogic<R> {
  async fn query_page(&self, filter: &UserFilter, offset: i64, limit: i64) -> anyhow::Result<(Vec<User>, i64)> {
    self.repo.query_page(filter, offset, limit).await
  }

  async fn get(&self, id: Uuid) -> anyhow::Result<Option<User>> {
    self.repo.get(id).await
  }

  async fn get_all(&self) -> anyhow::Result<Vec<User>> {
    self.repo.get_all().await
  }

  async fn get_by_username(&self, username: &str) -> anyhow::Result<Option<User>> {
    self.repo.get_by_username(username).await
  }

  async fn add(&self, username: &str, password: &str) -> anyhow::Result<User> {
    self.repo.add(username, password).await
  }

  async fn update(&self, id: Uuid, username: &str, password: &str) -> anyhow::Result<Option<User>> {
    self.repo.update(id, username, password).await
  }

  async fn remove(&self, id: Uuid) -> anyhow::Result<()> {
    self.repo.remove(id).await
  }

  async fn set_admin_password(&self, password: &str) -> anyhow::Result<()> {
    let admin = self
      .repo
      .get_by_username(DEFAULT_ADMIN_USERNAME)
      .await?
      .ok_or_else(|| anyhow::anyhow!("Admin user not found"))?;

    self.repo.update(admin.id, &admin.username, password).await?;

    Ok(())
  }

  async fn clear(&self) -> anyhow::Result<()> {
    self.repo.clear().await
  }
}
