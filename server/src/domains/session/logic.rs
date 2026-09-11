use std::sync::Arc;

use async_trait::async_trait;
use chrono::{DateTime, Utc};
use uuid::Uuid;

use crate::domains::notification::NotificationRepository;
use crate::domains::settings::SettingsRepository;
use crate::domains::team_member_session::{TeamMemberSession, TeamMemberSessionRepository};

use super::model::Session;
use super::repository::SessionRepository;

fn is_member_checked_in(ms: &TeamMemberSession) -> bool {
  ms.check_out_time.is_none()
}

/// A session that is past its end time, with precomputed state for both `SessionService`
/// (auto-checkout) and the Discord notification service (overtime/auto-checkout DM warnings).
pub struct PastEndSession {
  pub session_id: Uuid,
  pub session: Session,
  pub start_secs: i64,
  pub end_secs: i64,
  pub checked_in: Vec<TeamMemberSession>,
  pub next_start_secs: Option<i64>,
}

#[async_trait]
pub trait SessionLogic: Send + Sync {
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<Session>>;
  async fn get_all(&self) -> anyhow::Result<Vec<Session>>;
  async fn create(
    &self,
    start_time: DateTime<Utc>,
    end_time: DateTime<Utc>,
    location_id: Uuid,
  ) -> anyhow::Result<Session>;
  #[allow(clippy::too_many_arguments)]
  async fn update(
    &self,
    id: Uuid,
    start_time: DateTime<Utc>,
    end_time: DateTime<Utc>,
    location_id: Uuid,
    finished: bool,
  ) -> anyhow::Result<Session>;
  async fn remove(&self, id: Uuid) -> anyhow::Result<()>;
  /// Checks a team member in to the eligible session at `location_id`, or checks them out if
  /// they're already checked in to any session. Returns `true` if now checked in, `false` if
  /// checked out.
  async fn check_in_out(&self, team_member_id: Uuid, location_id: Uuid) -> anyhow::Result<bool>;
  /// Finishes sessions past their end time: marks them finished once every member has checked
  /// out, or force-checks-out lingering members (enqueuing auto-checkout notifications) once the
  /// next session at that location is about to start. Called on a schedule by `SessionService`.
  async fn process_past_end_sessions(&self) -> anyhow::Result<()>;
  /// Read-only view of unfinished sessions past their end time, with checked-in members and the
  /// next session's start time precomputed. Used by the Discord notification service to decide
  /// overtime/auto-checkout DM timing, independent of `process_past_end_sessions`'s mutations.
  async fn get_past_end_sessions(&self) -> anyhow::Result<Vec<PastEndSession>>;
}

pub struct DefaultSessionLogic<R: SessionRepository> {
  repo: R,
  team_member_sessions: Arc<dyn TeamMemberSessionRepository>,
  notifications: Arc<dyn NotificationRepository>,
  settings: Arc<dyn SettingsRepository>,
}

impl<R: SessionRepository> DefaultSessionLogic<R> {
  pub fn new(
    repo: R,
    team_member_sessions: Arc<dyn TeamMemberSessionRepository>,
    notifications: Arc<dyn NotificationRepository>,
    settings: Arc<dyn SettingsRepository>,
  ) -> Self {
    Self { repo, team_member_sessions, notifications, settings }
  }

  async fn threshold_secs(&self) -> i64 {
    self.settings.get().await.map_or(4 * 60 * 60, |s| s.next_session_threshold_secs)
  }

  /// Unfinished sessions with a start time, sorted ascending.
  async fn unfinished_sorted(&self) -> anyhow::Result<Vec<Session>> {
    let mut sessions: Vec<Session> = self.repo.get_all().await?.into_iter().filter(|s| !s.finished).collect();
    sessions.sort_by_key(|s| s.start_time);
    Ok(sessions)
  }

  async fn past_end_sessions(&self) -> anyhow::Result<Vec<PastEndSession>> {
    let now = Utc::now();
    let unfinished = self.unfinished_sorted().await?;
    let mut results = Vec::new();

    for (i, session) in unfinished.iter().enumerate() {
      if now <= session.end_time {
        continue;
      }

      let checked_in: Vec<TeamMemberSession> = self
        .team_member_sessions
        .get_by_session_id(session.id)
        .await?
        .into_iter()
        .filter(is_member_checked_in)
        .collect();

      let next_start_secs = unfinished.get(i + 1).map(|next| next.start_time.timestamp());

      results.push(PastEndSession {
        session_id: session.id,
        session: session.clone(),
        start_secs: session.start_time.timestamp(),
        end_secs: session.end_time.timestamp(),
        checked_in,
        next_start_secs,
      });
    }

    Ok(results)
  }
}

#[async_trait]
impl<R: SessionRepository> SessionLogic for DefaultSessionLogic<R> {
  async fn get(&self, id: Uuid) -> anyhow::Result<Option<Session>> {
    self.repo.get(id).await
  }

  async fn get_all(&self) -> anyhow::Result<Vec<Session>> {
    self.repo.get_all().await
  }

  async fn create(
    &self,
    start_time: DateTime<Utc>,
    end_time: DateTime<Utc>,
    location_id: Uuid,
  ) -> anyhow::Result<Session> {
    self.repo.add(start_time, end_time, location_id, false).await
  }

  async fn update(
    &self,
    id: Uuid,
    start_time: DateTime<Utc>,
    end_time: DateTime<Utc>,
    location_id: Uuid,
    finished: bool,
  ) -> anyhow::Result<Session> {
    self
      .repo
      .update(id, start_time, end_time, location_id, finished)
      .await?
      .ok_or_else(|| anyhow::anyhow!("Session not found"))
  }

  async fn remove(&self, id: Uuid) -> anyhow::Result<()> {
    self.repo.remove(id).await
  }

  async fn check_in_out(&self, team_member_id: Uuid, location_id: Uuid) -> anyhow::Result<bool> {
    let now = Utc::now();

    let member_sessions = self.team_member_sessions.get_by_member_id(team_member_id).await?;
    for ms in member_sessions {
      if is_member_checked_in(&ms) {
        self
          .team_member_sessions
          .update(ms.id, ms.team_member_id, ms.session_id, ms.check_in_time, Some(now))
          .await?
          .ok_or_else(|| anyhow::anyhow!("Team member session not found"))?;
        return Ok(false);
      }
    }

    let threshold = self.threshold_secs().await;
    let unfinished = self.unfinished_sorted().await?;

    let mut best: Option<(Session, i64)> = None;
    for session in unfinished {
      if session.location_id != location_id {
        continue;
      }
      let start_secs = session.start_time.timestamp();
      let end_secs = session.end_time.timestamp();
      let now_secs = now.timestamp();

      if now_secs < start_secs - threshold || now_secs > end_secs + threshold {
        continue;
      }

      let distance = if now_secs >= start_secs && now_secs <= end_secs {
        0
      } else if now_secs < start_secs {
        start_secs - now_secs
      } else {
        now_secs - end_secs
      };

      if best.as_ref().is_none_or(|(_, d)| distance < *d) {
        best = Some((session, distance));
      }
    }

    let Some((session, _)) = best else {
      return Err(anyhow::anyhow!("No active session at this location"));
    };

    self.team_member_sessions.add(team_member_id, session.id, now, None).await?;

    Ok(true)
  }

  async fn process_past_end_sessions(&self) -> anyhow::Result<()> {
    let now_secs = Utc::now().timestamp();
    let threshold = self.threshold_secs().await;
    let past_end = self.past_end_sessions().await?;

    for pes in past_end {
      let session = &pes.session;
      let checked_in = &pes.checked_in;
      let auto_checkout_imminent = pes.next_start_secs.is_some_and(|next| (next - now_secs) <= threshold);

      if checked_in.is_empty() {
        self
          .repo
          .update(session.id, session.start_time, session.end_time, session.location_id, true)
          .await?
          .ok_or_else(|| anyhow::anyhow!("Session not found"))?;
        log::info!("[SessionService] Marked session {} as finished (no lingering members)", session.id);
      } else if auto_checkout_imminent {
        for ms in checked_in {
          self
            .team_member_sessions
            .update(ms.id, ms.team_member_id, ms.session_id, ms.check_in_time, Some(session.end_time))
            .await?
            .ok_or_else(|| anyhow::anyhow!("Team member session not found"))?;

          if let Err(e) =
            self.notifications.add("auto_checkout", session.id, Some(ms.team_member_id), false, None).await
          {
            log::error!(
              "[SessionService] Failed to enqueue auto-checkout notification for member {}: {e}",
              ms.team_member_id
            );
          }
        }

        self
          .repo
          .update(session.id, session.start_time, session.end_time, session.location_id, true)
          .await?
          .ok_or_else(|| anyhow::anyhow!("Session not found"))?;
        log::info!(
          "[SessionService] Force-finished session {} (checked out {} members, next session approaching)",
          session.id,
          checked_in.len()
        );
      }
    }

    Ok(())
  }

  async fn get_past_end_sessions(&self) -> anyhow::Result<Vec<PastEndSession>> {
    self.past_end_sessions().await
  }
}
