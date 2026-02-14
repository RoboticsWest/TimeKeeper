use anyhow::Result;
use chrono::Utc;

use crate::{
  generated::{
    common::Timestamp,
    db::{Session, Settings, TeamMemberSession},
  },
  modules::{
    session::SessionRepository, settings::SettingsRepository, team_member_session::TeamMemberSessionRepository,
  },
};

/// A session that is past its end time, with precomputed state for both
/// SessionService (auto-checkout) and DiscordNotificationService (DM warnings).
pub struct PastEndSession {
  pub session_id: String,
  pub session: Session,
  pub end_secs: i64,
  pub checked_in: Vec<(String, TeamMemberSession)>,
  pub next_start_secs: Option<i64>,
}

/// A member who was auto-checked-out by the SessionService but hasn't been notified yet.
pub struct AutoCheckedOutMember {
  pub ms_id: String,
  pub member_session: TeamMemberSession,
  pub session: Session,
}

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
pub fn has_checked_in_members(session_id: &str) -> Result<bool> {
  let member_sessions = TeamMemberSession::get_by_session_id(session_id)?;
  Ok(member_sessions.values().any(is_member_checked_in))
}

/// Get all checked-in member sessions for a session (has check_in but no check_out).
pub fn get_checked_in_members(session_id: &str) -> Result<Vec<(String, TeamMemberSession)>> {
  let member_sessions = TeamMemberSession::get_by_session_id(session_id)?;
  Ok(member_sessions.into_iter().filter(|(_, ms)| is_member_checked_in(ms)).collect())
}

/// Check out all lingering members in a session with the given timestamp.
pub fn check_out_all_members(session_id: &str, now: &Timestamp) -> Result<()> {
  let member_sessions = TeamMemberSession::get_by_session_id(session_id)?;
  for (id, mut ms) in member_sessions {
    if is_member_checked_in(&ms) {
      ms.check_out_time = Some(*now);
      TeamMemberSession::update(&id, &ms)?;
    }
  }
  Ok(())
}

/// Find the best session at a given location within the threshold window.
///
/// A session is eligible if `now` falls within `[start_time - threshold, end_time + threshold]`.
/// Among eligible sessions, the one whose time window is closest to `now` is preferred.
pub fn find_session_for_location(
  location_id: &str,
  now: &Timestamp,
  threshold_secs: i64,
) -> Result<Option<(String, Session)>> {
  let unfinished = get_unfinished_sessions_sorted()?;
  let now_secs = now.seconds;

  let mut best: Option<(String, Session, i64)> = None;

  for (id, session) in unfinished {
    if session.location_id != location_id {
      continue;
    }

    let start_secs = session.start_time.as_ref().map_or(0, |t| t.seconds);
    let end_secs = session.end_time.as_ref().map_or(0, |t| t.seconds);

    // Check if now is within the threshold window
    if now_secs < start_secs - threshold_secs || now_secs > end_secs + threshold_secs {
      continue;
    }

    // Distance: 0 if within session window, otherwise distance to nearest edge
    let distance = if now_secs >= start_secs && now_secs <= end_secs {
      0
    } else if now_secs < start_secs {
      start_secs - now_secs
    } else {
      now_secs - end_secs
    };

    if best.as_ref().is_none_or(|(_, _, d)| distance < *d) {
      best = Some((id, session, distance));
    }
  }

  Ok(best.map(|(id, session, _)| (id, session)))
}

/// Get all unfinished sessions that are past their end time, with checked-in members
/// and the next session's start time precomputed.
///
/// This is the single source of truth for overtime/auto-checkout detection,
/// used by both SessionService and DiscordNotificationService.
pub fn get_past_end_sessions() -> Result<Vec<PastEndSession>> {
  let now_secs = Utc::now().timestamp();
  let unfinished = get_unfinished_sessions_sorted()?;

  let mut results = Vec::new();

  for i in 0..unfinished.len() {
    let (ref id, ref session) = unfinished[i];
    let end_secs = match session.end_time.as_ref() {
      Some(t) => t.seconds,
      None => continue,
    };

    if now_secs <= end_secs {
      continue;
    }

    let checked_in = get_checked_in_members(id)?;
    let next_start_secs = unfinished.get(i + 1).and_then(|(_, next)| next.start_time.as_ref().map(|t| t.seconds));

    results.push(PastEndSession {
      session_id: id.clone(),
      session: session.clone(),
      end_secs,
      checked_in,
      next_start_secs,
    });
  }

  Ok(results)
}

/// Check if an auto-checkout is imminent — i.e. the next session starts within the given threshold.
pub fn is_auto_checkout_imminent(next_start_secs: Option<i64>, now_secs: i64, threshold_secs: i64) -> bool {
  match next_start_secs {
    Some(next_start) => (next_start - now_secs) <= threshold_secs,
    None => false,
  }
}

/// Get all members who were auto-checked-out (session finished, has check_out_time)
/// but haven't been notified yet (auto_checkout_notified == false).
pub fn get_auto_checked_out_members() -> Result<Vec<AutoCheckedOutMember>> {
  let all_sessions = Session::get_all()?;
  let mut results = Vec::new();

  for (session_id, session) in &all_sessions {
    if !session.finished {
      continue;
    }

    let member_sessions = TeamMemberSession::get_by_session_id(session_id)?;
    for (ms_id, ms) in member_sessions {
      if ms.check_out_time.is_some() && !ms.auto_checkout_notified {
        results.push(AutoCheckedOutMember { ms_id, member_session: ms, session: session.clone() });
      }
    }
  }

  Ok(results)
}
