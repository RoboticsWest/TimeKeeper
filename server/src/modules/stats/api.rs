use std::collections::HashMap;

use chrono::{Datelike, Utc};
use tonic::{Request, Response, Result, Status};

use crate::{
  generated::{
    api::{
      GetLeaderboardRequest, GetLeaderboardResponse, HoursBucket, LeaderboardEntry, stats_service_server::StatsService,
    },
    db::{Session, TeamMember, TeamMemberSession},
  },
  modules::{session::SessionRepository, team_member::TeamMemberRepository},
};

pub struct StatsApi;

/// Compute regular and overtime seconds for a single member session.
///
/// Regular = time within [session_start, session_end].
/// Overtime = time outside that window (before start or after end).
fn compute_hours(ms: &TeamMemberSession, session: &Session, now_secs: i64) -> (f64, f64) {
  let check_in = match &ms.check_in_time {
    Some(t) => t.seconds,
    None => return (0.0, 0.0),
  };

  let check_out = match &ms.check_out_time {
    Some(t) => t.seconds,
    None => now_secs,
  };

  if check_out <= check_in {
    return (0.0, 0.0);
  }

  let session_start = session.start_time.as_ref().map_or(0, |t| t.seconds);
  let session_end = session.end_time.as_ref().map_or(0, |t| t.seconds);

  // Regular = overlap of [check_in, check_out] with [session_start, session_end]
  let overlap_start = check_in.max(session_start);
  let overlap_end = check_out.min(session_end);

  #[allow(clippy::cast_precision_loss)]
  let regular_secs = (overlap_end - overlap_start).max(0) as f64;

  #[allow(clippy::cast_precision_loss)]
  let total_secs = (check_out - check_in) as f64;
  let overtime_secs = total_secs - regular_secs;

  (regular_secs, overtime_secs)
}

/// Get the Unix timestamp (seconds) for Monday 00:00 UTC of the current week.
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

#[tonic::async_trait]
impl StatsService for StatsApi {
  async fn get_leaderboard(
    &self,
    _request: Request<GetLeaderboardRequest>,
  ) -> Result<Response<GetLeaderboardResponse>, Status> {
    let sessions = Session::get_all().map_err(|e| Status::internal(format!("Failed to get sessions: {}", e)))?;
    let team_members =
      TeamMember::get_all().map_err(|e| Status::internal(format!("Failed to get team members: {}", e)))?;

    let now_secs = Utc::now().timestamp();
    let week_start = week_start_secs();
    let week_end = week_start + 7 * 24 * 60 * 60;

    let mut accumulators: HashMap<String, MemberAccumulator> = HashMap::new();

    for session in sessions.values() {
      if session.start_time.is_none() || session.end_time.is_none() {
        continue;
      }

      let session_start_secs = session.start_time.as_ref().map_or(0, |t| t.seconds);
      let is_active = !session.finished;
      let is_this_week = session_start_secs >= week_start && session_start_secs < week_end;

      for ms in &session.member_sessions {
        if ms.check_in_time.is_none() {
          continue;
        }

        let (regular, overtime) = compute_hours(ms, session, now_secs);

        accumulators.entry(ms.team_member_id.clone()).or_insert_with(MemberAccumulator::new).add(
          regular,
          overtime,
          is_active,
          is_this_week,
        );
      }
    }

    let mut entries: Vec<LeaderboardEntry> = accumulators
      .into_iter()
      .filter_map(|(member_id, acc)| {
        let member = team_members.get(&member_id)?;
        let total_secs = acc.all_time.regular_secs + acc.all_time.overtime_secs;

        Some(LeaderboardEntry {
          team_member_id: member_id,
          team_member: Some(member.clone()),
          active_session: Some(acc.active_session),
          this_week: Some(acc.this_week),
          all_time: Some(acc.all_time),
          total_secs,
        })
      })
      .collect();

    entries.sort_by(|a, b| b.total_secs.partial_cmp(&a.total_secs).unwrap_or(std::cmp::Ordering::Equal));

    Ok(Response::new(GetLeaderboardResponse { entries }))
  }
}
