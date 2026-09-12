use std::sync::Arc;

use async_trait::async_trait;
use uuid::Uuid;

use crate::domains::rfid_tag::RfidTagRepository;

use super::csv_parser::TeamMemberCsvParser;
use super::model::TeamMember;
use super::repository::TeamMemberRepository;

/// Ensures `display_name` is populated - if empty/missing, falls back to "first last".
fn fill_display_name(first_name: &str, last_name: &str, display_name: Option<&str>) -> Option<String> {
  match display_name {
    Some(name) if !name.is_empty() => Some(name.to_string()),
    _ => {
      let name = format!("{first_name} {last_name}").trim().to_string();
      if name.is_empty() { None } else { Some(name) }
    }
  }
}

#[async_trait]
pub trait TeamMemberLogic: Send + Sync {
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<TeamMember>>;
  async fn get_all(&self) -> anyhow::Result<Vec<TeamMember>>;
  async fn get_by_member_type(&self, member_type: &str) -> anyhow::Result<Vec<TeamMember>>;
  async fn get_by_discord_id(&self, discord_id: &str) -> anyhow::Result<Option<TeamMember>>;
  /// Resolves a PIN typed at a kiosk to the single member that owns it.
  async fn get_by_quick_pin(&self, quick_pin: &str) -> anyhow::Result<Option<TeamMember>>;
  async fn get_by_name(&self, first_name: &str, last_name: &str) -> anyhow::Result<Vec<TeamMember>>;
  #[allow(clippy::too_many_arguments)]
  async fn add(
    &self,
    first_name: &str,
    last_name: &str,
    member_type: &str,
    display_name: Option<&str>,
    mobile_number: Option<&str>,
    discord_id: Option<&str>,
    quick_pin: Option<&str>,
  ) -> anyhow::Result<TeamMember>;
  #[allow(clippy::too_many_arguments)]
  async fn update(
    &self,
    id: Uuid,
    first_name: &str,
    last_name: &str,
    member_type: &str,
    display_name: Option<&str>,
    mobile_number: Option<&str>,
    discord_id: Option<&str>,
    quick_pin: Option<&str>,
  ) -> anyhow::Result<TeamMember>;
  async fn remove(&self, id: Uuid) -> anyhow::Result<()>;
  async fn clear(&self) -> anyhow::Result<()>;
  /// Parses a CSV upload (`FIRST_NAME,LAST_NAME,DISPLAY_NAME,RFID_TAG,DISCORD_ID`) and adds
  /// every row not already present (matched by first + last name) as a team member of
  /// `member_type` ("student"/"mentor"), assigning the RFID tag column if present. Used by
  /// `UploadStudentCsv`/`UploadMentorCsv`.
  async fn import_csv(&self, csv: &str, member_type: &str) -> anyhow::Result<()>;
}

pub struct DefaultTeamMemberLogic<R: TeamMemberRepository> {
  repo: R,
  rfid_tags: Arc<dyn RfidTagRepository>,
}

impl<R: TeamMemberRepository> DefaultTeamMemberLogic<R> {
  pub fn new(repo: R, rfid_tags: Arc<dyn RfidTagRepository>) -> Self {
    Self { repo, rfid_tags }
  }
}

#[async_trait]
impl<R: TeamMemberRepository> TeamMemberLogic for DefaultTeamMemberLogic<R> {
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<TeamMember>> {
    self.repo.get(id).await
  }

  async fn get_all(&self) -> anyhow::Result<Vec<TeamMember>> {
    self.repo.get_all().await
  }

  async fn get_by_member_type(&self, member_type: &str) -> anyhow::Result<Vec<TeamMember>> {
    self.repo.get_by_member_type(member_type).await
  }

  async fn get_by_discord_id(&self, discord_id: &str) -> anyhow::Result<Option<TeamMember>> {
    self.repo.get_by_discord_id(discord_id).await
  }

  async fn get_by_quick_pin(&self, quick_pin: &str) -> anyhow::Result<Option<TeamMember>> {
    self.repo.get_by_quick_pin(quick_pin).await
  }

  async fn get_by_name(&self, first_name: &str, last_name: &str) -> anyhow::Result<Vec<TeamMember>> {
    self.repo.get_by_name(first_name, last_name).await
  }

  async fn add(
    &self,
    first_name: &str,
    last_name: &str,
    member_type: &str,
    display_name: Option<&str>,
    mobile_number: Option<&str>,
    discord_id: Option<&str>,
    quick_pin: Option<&str>,
  ) -> anyhow::Result<TeamMember> {
    let display_name = fill_display_name(first_name, last_name, display_name);
    self
      .repo
      .add(first_name, last_name, member_type, display_name.as_deref(), mobile_number, discord_id, quick_pin)
      .await
  }

  async fn update(
    &self,
    id: Uuid,
    first_name: &str,
    last_name: &str,
    member_type: &str,
    display_name: Option<&str>,
    mobile_number: Option<&str>,
    discord_id: Option<&str>,
    quick_pin: Option<&str>,
  ) -> anyhow::Result<TeamMember> {
    let display_name = fill_display_name(first_name, last_name, display_name);
    self
      .repo
      .update(id, first_name, last_name, member_type, display_name.as_deref(), mobile_number, discord_id, quick_pin)
      .await?
      .ok_or_else(|| anyhow::anyhow!("Team member not found"))
  }

  async fn remove(&self, id: Uuid) -> anyhow::Result<()> {
    self.repo.remove(id).await
  }

  async fn clear(&self) -> anyhow::Result<()> {
    self.repo.clear().await
  }

  async fn import_csv(&self, csv: &str, member_type: &str) -> anyhow::Result<()> {
    let rows = TeamMemberCsvParser::parse(csv)?;

    for row in rows {
      let existing = self.get_by_name(&row.first_name, &row.last_name).await?;
      if !existing.is_empty() {
        continue;
      }

      let member = self
        .add(
          &row.first_name,
          &row.last_name,
          member_type,
          row.display_name.as_deref(),
          None,
          row.discord_id.as_deref(),
          None,
        )
        .await?;

      if let Some(tag) = row.rfid_tag
        && let Err(err) = self.rfid_tags.add(member.id, &tag).await
      {
        log::error!("[TeamMemberCsvImport] adding RFID tag for {} {}: {err}", row.first_name, row.last_name);
      }
    }

    Ok(())
  }
}
