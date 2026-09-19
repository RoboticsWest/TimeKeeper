use std::collections::HashMap;
use std::sync::Arc;

use async_trait::async_trait;
use chrono::{DateTime, Utc};
use uuid::Uuid;

use crate::domains::location::LocationRepository;
use crate::domains::session::SessionRepository;
use crate::domains::team_member::TeamMemberRepository;

use super::csv_parser::AttendanceCsvParser;
use super::model::TeamMemberSession;
use super::repository::{AttendanceFilter, TeamMemberSessionRepository};

#[async_trait]
pub trait TeamMemberSessionLogic: Send + Sync {
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<TeamMemberSession>>;
  async fn get_all(&self) -> anyhow::Result<Vec<TeamMemberSession>>;
  async fn get_by_member_id(&self, team_member_id: Uuid) -> anyhow::Result<Vec<TeamMemberSession>>;
  async fn get_by_session_id(&self, session_id: Uuid) -> anyhow::Result<Vec<TeamMemberSession>>;
  async fn add(
    &self,
    team_member_id: Uuid,
    session_id: Uuid,
    check_in_time: DateTime<Utc>,
    check_out_time: Option<DateTime<Utc>>,
  ) -> anyhow::Result<TeamMemberSession>;
  async fn update(
    &self,
    id: Uuid,
    team_member_id: Uuid,
    session_id: Uuid,
    check_in_time: DateTime<Utc>,
    check_out_time: Option<DateTime<Utc>>,
  ) -> anyhow::Result<TeamMemberSession>;
  async fn remove(&self, id: Uuid) -> anyhow::Result<()>;
  async fn clear(&self) -> anyhow::Result<()>;
  /// Parses an attendance CSV (`FIRST_NAME,LAST_NAME,LOCATION,CHECK_IN_TIME,CHECK_OUT_TIME`),
  /// resolves each row's team member (by name) and session (by location + a generous time
  /// window around check-in), and adds a check-in record for it - skipping rows it can't resolve
  /// or that already have a record for that session. Used by `ImportAttendanceCsv`. Returns
  /// `(imported, skipped)` counts.
  async fn import_attendance_csv(&self, csv: &str) -> anyhow::Result<(usize, usize)>;

  /// One page of attendance matching `filter`, with the total number of matching rows.
  async fn query_page(
    &self,
    filter: &AttendanceFilter,
    offset: i64,
    limit: i64,
  ) -> anyhow::Result<(Vec<TeamMemberSession>, i64)>;
}

pub struct DefaultTeamMemberSessionLogic<R: TeamMemberSessionRepository> {
  repo: R,
  team_members: Arc<dyn TeamMemberRepository>,
  sessions: Arc<dyn SessionRepository>,
  locations: Arc<dyn LocationRepository>,
}

impl<R: TeamMemberSessionRepository> DefaultTeamMemberSessionLogic<R> {
  pub fn new(
    repo: R,
    team_members: Arc<dyn TeamMemberRepository>,
    sessions: Arc<dyn SessionRepository>,
    locations: Arc<dyn LocationRepository>,
  ) -> Self {
    Self { repo, team_members, sessions, locations }
  }
}

#[async_trait]
impl<R: TeamMemberSessionRepository> TeamMemberSessionLogic for DefaultTeamMemberSessionLogic<R> {
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<TeamMemberSession>> {
    self.repo.get(id).await
  }

  async fn get_all(&self) -> anyhow::Result<Vec<TeamMemberSession>> {
    self.repo.get_all().await
  }

  async fn get_by_member_id(&self, team_member_id: Uuid) -> anyhow::Result<Vec<TeamMemberSession>> {
    self.repo.get_by_member_id(team_member_id).await
  }

  async fn get_by_session_id(&self, session_id: Uuid) -> anyhow::Result<Vec<TeamMemberSession>> {
    self.repo.get_by_session_id(session_id).await
  }

  async fn add(
    &self,
    team_member_id: Uuid,
    session_id: Uuid,
    check_in_time: DateTime<Utc>,
    check_out_time: Option<DateTime<Utc>>,
  ) -> anyhow::Result<TeamMemberSession> {
    let record = self.repo.add(team_member_id, session_id, check_in_time, check_out_time).await?;
    self.sessions.refresh_actual_times(session_id).await?;
    Ok(record)
  }

  async fn update(
    &self,
    id: Uuid,
    team_member_id: Uuid,
    session_id: Uuid,
    check_in_time: DateTime<Utc>,
    check_out_time: Option<DateTime<Utc>>,
  ) -> anyhow::Result<TeamMemberSession> {
    // An edit can move the session's first check-in or last check-out, and can move the row to
    // a different session entirely - in which case both sessions need recomputing.
    let previous_session_id = self.repo.get(id).await?.map(|ms| ms.session_id);

    let record = self
      .repo
      .update(id, team_member_id, session_id, check_in_time, check_out_time)
      .await?
      .ok_or_else(|| anyhow::anyhow!("Team member session not found"))?;

    self.sessions.refresh_actual_times(session_id).await?;
    if let Some(previous) = previous_session_id
      && previous != session_id
    {
      self.sessions.refresh_actual_times(previous).await?;
    }

    Ok(record)
  }

  async fn remove(&self, id: Uuid) -> anyhow::Result<()> {
    // Read the owning session before the row is gone, so its actual times can be recomputed.
    let session_id = self.repo.get(id).await?.map(|ms| ms.session_id);
    self.repo.remove(id).await?;
    if let Some(session_id) = session_id {
      self.sessions.refresh_actual_times(session_id).await?;
    }
    Ok(())
  }

  async fn clear(&self) -> anyhow::Result<()> {
    let session_ids: Vec<Uuid> = self.repo.get_all().await?.into_iter().map(|ms| ms.session_id).collect();
    self.repo.clear().await?;
    // Every session just lost all its attendance, so all of them revert to "never started".
    for session_id in session_ids.into_iter().collect::<std::collections::HashSet<_>>() {
      self.sessions.refresh_actual_times(session_id).await?;
    }
    Ok(())
  }

  async fn query_page(
    &self,
    filter: &AttendanceFilter,
    offset: i64,
    limit: i64,
  ) -> anyhow::Result<(Vec<TeamMemberSession>, i64)> {
    self.repo.query_page(filter, offset, limit).await
  }

  async fn import_attendance_csv(&self, csv: &str) -> anyhow::Result<(usize, usize)> {
    let records = AttendanceCsvParser::parse(csv)?;

    // Pre-load all sessions and locations for lookup.
    let all_sessions = self.sessions.get_all().await?;
    let all_locations = self.locations.get_all().await?;
    let location_name_to_id: HashMap<String, Uuid> =
      all_locations.iter().map(|loc| (loc.location.clone(), loc.id)).collect();

    let mut imported = 0;
    let mut skipped = 0;

    for record in records {
      // Look up team member by name.
      let members = self.team_members.get_by_name(&record.first_name, &record.last_name).await?;
      let Some(member) = members.into_iter().next() else {
        log::warn!("[ImportAttendance] Skipping: team member not found: {} {}", record.first_name, record.last_name);
        skipped += 1;
        continue;
      };

      // Look up location by name.
      let Some(location_id) = location_name_to_id.get(&record.location) else {
        log::warn!("[ImportAttendance] Skipping: location not found: {}", record.location);
        skipped += 1;
        continue;
      };

      // Find the session at this location that contains the check-in time.
      let check_in_secs = record.check_in_time.timestamp();
      let matching_session = all_sessions.iter().find(|s| {
        s.location_id == *location_id
          && s.start_time.timestamp() <= check_in_secs
          && check_in_secs <= s.end_time.timestamp() + 4 * 3600 // generous window
      });

      let Some(session) = matching_session else {
        log::warn!(
          "[ImportAttendance] Skipping: no matching session for {} {} at {} (check-in: {})",
          record.first_name,
          record.last_name,
          record.location,
          check_in_secs
        );
        skipped += 1;
        continue;
      };

      // Check for existing record (same member + session).
      let existing = self.get_by_session_id(session.id).await?;
      if existing.iter().any(|ms| ms.team_member_id == member.id) {
        log::debug!(
          "[ImportAttendance] Skipping duplicate: {} {} already has a record for session {}",
          record.first_name,
          record.last_name,
          session.id
        );
        skipped += 1;
        continue;
      }

      if let Err(err) = self.add(member.id, session.id, record.check_in_time, record.check_out_time).await {
        log::error!("[ImportAttendance] Failed to add record for {} {}: {err}", record.first_name, record.last_name);
        skipped += 1;
        continue;
      }

      imported += 1;
    }

    log::info!("[ImportAttendance] Imported {imported} records, skipped {skipped}");
    Ok((imported, skipped))
  }
}
