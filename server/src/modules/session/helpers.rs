use anyhow::Result;
use chrono::Utc;

use crate::{
  generated::{
    common::Timestamp,
    db::{Session, Settings, TeamMemberSession},
  },
  modules::{session::SessionRepository, settings::SettingsRepository},
};

/// Get the current time as a protobuf Timestamp.
pub fn now_timestamp() -> Timestamp {
  let now = Utc::now();
  Timestamp { seconds: now.timestamp(), nanos: 0 }
}

/// Load the next session threshold from DB settings, falling back to 4 hours.
pub fn get_next_session_threshold_secs() -> i64 {
  Settings::get().map(|s| s.next_session_threshold_secs).unwrap_or(4 * 60 * 60)
}

/// Get all unfinished sessions with a start time, sorted by start_time ascending.
pub fn get_unfinished_sessions_sorted() -> Result<Vec<(String, Session)>> {
  let all_sessions = Session::get_all()?;
  let mut unfinished: Vec<(String, Session)> =
    all_sessions.into_iter().filter(|(_, s)| !s.finished && s.start_time.is_some()).collect();
  unfinished.sort_by_key(|(_, s)| s.start_time.as_ref().map_or(0, |t| t.seconds));
  Ok(unfinished)
}

/// Check if a single member session is currently checked in (has check_in but no check_out).
pub fn is_member_checked_in(ms: &TeamMemberSession) -> bool {
  ms.check_in_time.is_some() && ms.check_out_time.is_none()
}

/// Check if a session has any members still checked in.
pub fn has_checked_in_members(session: &Session) -> bool {
  session.member_sessions.iter().any(is_member_checked_in)
}

/// Check out all lingering members in a session with the given timestamp.
pub fn check_out_all_members(session: &mut Session, now: &Timestamp) {
  for ms in &mut session.member_sessions {
    if is_member_checked_in(ms) {
      ms.check_out_time = Some(*now);
    }
  }
}

/// Find the index of the session a member should check into.
/// If the next session's start time is within `threshold_secs` of now, prefer it over the current one.
pub fn find_check_in_target_index(unfinished: &[(String, Session)], now: &Timestamp, threshold_secs: i64) -> usize {
  match unfinished.get(1) {
    Some((_, next_session)) => match &next_session.start_time {
      Some(next_start) => {
        let time_until_next = next_start.seconds - now.seconds;
        usize::from(time_until_next > 0 && time_until_next <= threshold_secs)
      }
      None => 0,
    },
    None => 0,
  }
}
