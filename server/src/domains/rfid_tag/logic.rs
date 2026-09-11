use async_trait::async_trait;
use uuid::Uuid;

use super::model::RfidTag;
use super::repository::RfidTagRepository;

#[async_trait]
pub trait RfidTagLogic: Send + Sync {
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<RfidTag>>;
  async fn get_all(&self) -> anyhow::Result<Vec<RfidTag>>;
  async fn add(&self, team_member_id: Uuid, tag: &str) -> anyhow::Result<RfidTag>;
  async fn remove(&self, id: Uuid) -> anyhow::Result<()>;
  async fn clear(&self) -> anyhow::Result<()>;

  /// All tags assigned to a given team member.
  async fn get_by_team_member_id(&self, team_member_id: Uuid) -> anyhow::Result<Vec<RfidTag>>;
  /// Look up the tag record by its scanned tag string (used to resolve which team member scanned in).
  async fn get_by_tag(&self, tag: &str) -> anyhow::Result<Option<RfidTag>>;
  /// Delete every tag belonging to a team member (e.g. when the member is removed).
  async fn remove_by_team_member_id(&self, team_member_id: Uuid) -> anyhow::Result<()>;
}

pub struct DefaultRfidTagLogic<R: RfidTagRepository> {
  repo: R,
}

impl<R: RfidTagRepository> DefaultRfidTagLogic<R> {
  pub fn new(repo: R) -> Self {
    Self { repo }
  }
}

#[async_trait]
impl<R: RfidTagRepository> RfidTagLogic for DefaultRfidTagLogic<R> {
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<RfidTag>> {
    self.repo.get(id).await
  }

  async fn get_all(&self) -> anyhow::Result<Vec<RfidTag>> {
    self.repo.get_all().await
  }

  async fn add(&self, team_member_id: Uuid, tag: &str) -> anyhow::Result<RfidTag> {
    let record = self.repo.add(team_member_id, tag).await?;

    Ok(record)
  }

  async fn remove(&self, id: Uuid) -> anyhow::Result<()> {
    self.repo.remove(id).await?;

    Ok(())
  }

  async fn clear(&self) -> anyhow::Result<()> {
    self.repo.clear().await?;

    Ok(())
  }

  async fn get_by_team_member_id(&self, team_member_id: Uuid) -> anyhow::Result<Vec<RfidTag>> {
    self.repo.get_by_team_member_id(team_member_id).await
  }

  async fn get_by_tag(&self, tag: &str) -> anyhow::Result<Option<RfidTag>> {
    self.repo.get_by_tag(tag).await
  }

  async fn remove_by_team_member_id(&self, team_member_id: Uuid) -> anyhow::Result<()> {
    self.repo.remove_by_team_member_id(team_member_id).await
  }
}
