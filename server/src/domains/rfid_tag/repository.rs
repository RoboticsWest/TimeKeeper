use async_trait::async_trait;
use diesel::prelude::*;
use diesel_async::RunQueryDsl;
use uuid::Uuid;

use database::{DbPool, schema::rfid_tags};

use super::model::RfidTag;

#[async_trait]
pub trait RfidTagRepository: Send + Sync {
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

pub struct PgRfidTagRepository {
  pool: DbPool,
}

impl PgRfidTagRepository {
  pub fn new(pool: DbPool) -> Self {
    Self { pool }
  }
}

#[async_trait]
impl RfidTagRepository for PgRfidTagRepository {
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<RfidTag>> {
    let mut conn = self.pool.get().await?;
    Ok(rfid_tags::table.filter(rfid_tags::id.eq(id)).select(RfidTag::as_select()).first(&mut conn).await.optional()?)
  }

  async fn get_all(&self) -> anyhow::Result<Vec<RfidTag>> {
    let mut conn = self.pool.get().await?;
    Ok(rfid_tags::table.select(RfidTag::as_select()).load(&mut conn).await?)
  }

  async fn add(&self, team_member_id: Uuid, tag: &str) -> anyhow::Result<RfidTag> {
    let mut conn = self.pool.get().await?;
    let id = Uuid::now_v7();
    Ok(
      diesel::insert_into(rfid_tags::table)
        .values((rfid_tags::id.eq(id), rfid_tags::team_member_id.eq(team_member_id), rfid_tags::tag.eq(tag)))
        .returning(RfidTag::as_select())
        .get_result(&mut conn)
        .await?,
    )
  }

  async fn remove(&self, id: Uuid) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::delete(rfid_tags::table.filter(rfid_tags::id.eq(id))).execute(&mut conn).await?;
    Ok(())
  }

  async fn clear(&self) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::delete(rfid_tags::table).execute(&mut conn).await?;
    Ok(())
  }

  async fn get_by_team_member_id(&self, team_member_id: Uuid) -> anyhow::Result<Vec<RfidTag>> {
    let mut conn = self.pool.get().await?;
    Ok(
      rfid_tags::table
        .filter(rfid_tags::team_member_id.eq(team_member_id))
        .select(RfidTag::as_select())
        .load(&mut conn)
        .await?,
    )
  }

  async fn get_by_tag(&self, tag: &str) -> anyhow::Result<Option<RfidTag>> {
    let mut conn = self.pool.get().await?;
    Ok(rfid_tags::table.filter(rfid_tags::tag.eq(tag)).select(RfidTag::as_select()).first(&mut conn).await.optional()?)
  }

  async fn remove_by_team_member_id(&self, team_member_id: Uuid) -> anyhow::Result<()> {
    let mut conn = self.pool.get().await?;
    diesel::delete(rfid_tags::table.filter(rfid_tags::team_member_id.eq(team_member_id))).execute(&mut conn).await?;
    Ok(())
  }
}
