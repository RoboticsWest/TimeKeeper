use std::collections::HashMap;
use std::sync::Arc;

use async_graphql::SimpleObject;
use async_trait::async_trait;
use chrono::{Datelike, Utc};
use uuid::Uuid;

use crate::domains::session::SessionRepository;
use crate::domains::settings::SettingsRepository;
use crate::domains::team_member::{TeamMember, TeamMemberRepository};
use crate::domains::team_member_session::{TeamMemberSession, TeamMemberSessionRepository};

#[derive(SimpleObject)]
pub struct HoursBucket {
  pub regular_secs: f64,
  pub overtime_secs: f64,
}

#[derive(SimpleObject)]
pub struct LeaderboardEntry {
  pub team_member_id: Uuid,
  pub team_member: TeamMember,
  pub active_session: HoursBucket,
  pub this_week: HoursBucket,
  pub all_time: HoursBucket,
  pub total_secs: f64,
}

/// Compute regular and overtime seconds for a single member session.
///
/// Regular = time within [session_start, session_end].
/// Overtime = time outside that window (before start or after end).
fn compute_hours(ms: &TeamMemberSession, session_start: i64, session_end: i64, now_secs: i64) -> (f64, f64) {
  let check_in = ms.check_in_time.timestamp();
  let check_out = ms.check_out_time.map_or(now_secs, |t| t.timestamp());

  if check_out <= check_in {
    return (0.0, 0.0);
  }

  let overlap_start = check_in.max(session_start);
  let overlap_end = check_out.min(session_end);

  #[allow(clippy::cast_precision_loss)]
  let regular_secs = (overlap_end - overlap_start).max(0) as f64;

  #[allow(clippy::cast_precision_loss)]
  let total_secs = (check_out - check_in) as f64;
  let overtime_secs = total_secs - regular_secs;

  (regular_secs, overtime_secs)
}

/// Unix timestamp (seconds) for Monday 00:00 UTC of the current week.
fn week_start_secs() -> i64 {
  let now = Utc::now();
  let days_since_monday = i64::from(now.weekday().num_days_from_monday());
  let monday = now.date_naive() - chrono::Duration::days(days_since_monday);
  monday.and_hms_opt(0, 0, 0).map_or(0, |dt| dt.and_utc().timestamp())
}

struct MemberAccumulator {
  active_session: HoursBucket,
  this_week: HoursBucket,
  all_time: HoursBucket,
}

impl MemberAccumulator {
  fn new() -> Self {
    Self {
      active_session: HoursBucket { regular_secs: 0.0, overtime_secs: 0.0 },
      this_week: HoursBucket { regular_secs: 0.0, overtime_secs: 0.0 },
      all_time: HoursBucket { regular_secs: 0.0, overtime_secs: 0.0 },
    }
  }

  fn add(&mut self, regular: f64, overtime: f64, is_active: bool, is_this_week: bool) {
    self.all_time.regular_secs += regular;
    self.all_time.overtime_secs += overtime;
    if is_this_week {
      self.this_week.regular_secs += regular;
      self.this_week.overtime_secs += overtime;
    }
    if is_active {
      self.active_session.regular_secs += regular;
      self.active_session.overtime_secs += overtime;
    }
  }
}

fn combine_overtime(bucket: &mut HoursBucket) {
  bucket.regular_secs += bucket.overtime_secs;
  bucket.overtime_secs = 0.0;
}

#[async_trait]
pub trait StatisticsLogic: Send + Sync {
  async fn get_leaderboard(&self) -> anyhow::Result<Vec<LeaderboardEntry>>;
}

pub struct DefaultStatisticsLogic {
  sessions: Arc<dyn SessionRepository>,
  team_members: Arc<dyn TeamMemberRepository>,
  team_member_sessions: Arc<dyn TeamMemberSessionRepository>,
  settings: Arc<dyn SettingsRepository>,
}

impl DefaultStatisticsLogic {
  pub fn new(
    sessions: Arc<dyn SessionRepository>,
    team_members: Arc<dyn TeamMemberRepository>,
    team_member_sessions: Arc<dyn TeamMemberSessionRepository>,
    settings: Arc<dyn SettingsRepository>,
  ) -> Self {
    Self { sessions, team_members, team_member_sessions, settings }
  }
}

#[async_trait]
impl StatisticsLogic for DefaultStatisticsLogic {
  async fn get_leaderboard(&self) -> anyhow::Result<Vec<LeaderboardEntry>> {
    let settings = self.settings.get().await?;
    let show_overtime = settings.leaderboard_show_overtime;
    let member_types: Vec<String> = settings.leaderboard_member_types.into_iter().flatten().collect();

    let sessions: HashMap<Uuid, _> = self.sessions.get_all().await?.into_iter().map(|s| (s.id, s)).collect();
    let team_members: HashMap<Uuid, TeamMember> =
      self.team_members.get_all().await?.into_iter().map(|m| (m.id, m)).collect();
    let member_sessions = self.team_member_sessions.get_all().await?;

    let now_secs = Utc::now().timestamp();
    let week_start = week_start_secs();
    let week_end = week_start + 7 * 24 * 60 * 60;

    let mut accumulators: HashMap<Uuid, MemberAccumulator> = HashMap::new();

    for ms in &member_sessions {
      let Some(session) = sessions.get(&ms.session_id) else { continue };

      let session_start_secs = session.start_time.timestamp();
      let session_end_secs = session.end_time.timestamp();
      let is_active = !session.finished;
      let is_this_week = session_start_secs >= week_start && session_start_secs < week_end;

      let (regular, overtime) = compute_hours(ms, session_start_secs, session_end_secs, now_secs);

      accumulators.entry(ms.team_member_id).or_insert_with(MemberAccumulator::new).add(
        regular,
        overtime,
        is_active,
        is_this_week,
      );
    }

    let mut entries: Vec<LeaderboardEntry> = accumulators
      .into_iter()
      .filter_map(|(member_id, mut acc)| {
        let member = team_members.get(&member_id)?.clone();

        if !member_types.is_empty() && !member_types.contains(&member.member_type) {
          return None;
        }

        if !show_overtime {
          combine_overtime(&mut acc.active_session);
          combine_overtime(&mut acc.this_week);
          combine_overtime(&mut acc.all_time);
        }

        let total_secs = acc.all_time.regular_secs + acc.all_time.overtime_secs;

        Some(LeaderboardEntry {
          team_member_id: member_id,
          team_member: member,
          active_session: acc.active_session,
          this_week: acc.this_week,
          all_time: acc.all_time,
          total_secs,
        })
      })
      .collect();

    entries.sort_by(|a, b| b.total_secs.partial_cmp(&a.total_secs).unwrap_or(std::cmp::Ordering::Equal));

    Ok(entries)
  }
}
