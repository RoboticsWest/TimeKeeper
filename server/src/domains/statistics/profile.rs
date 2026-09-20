//! A single member's derived attendance figures.
//!
//! Everything `!mystats`, the titles and the achievements read comes from here, so there is one
//! definition of "overtime", "forgot to check out" and "attendance streak" rather than one per
//! caller. The struct is plain numbers with no database handle and no `async`, which is what lets
//! [`crate::domains::statistics::achievements`] be a list of pure predicates that unit-test
//! against a hand-built profile.

use std::collections::{HashMap, HashSet};

use chrono::{DateTime, Datelike, FixedOffset, Timelike, Utc, Weekday};
use uuid::Uuid;

use crate::domains::session::Session;
use crate::domains::team_member_session::TeamMemberSession;

/// A checkout at or before this local hour counts as "after midnight" rather than "late".
const SMALL_HOURS_END: u32 = 4;

#[derive(Debug, Clone, Default)]
pub struct MemberProfile {
  /// The stored member type (`student`, `mentor`, ...), lowercase as the database holds it.
  pub member_type: String,
  /// Sessions this member checked in to.
  pub sessions_attended: usize,
  /// Sessions that had already ended, and so were there to be attended.
  pub sessions_possible: usize,
  /// All-time seconds, as the leaderboard counts them.
  pub total_secs: f64,
  /// Seconds outside the scheduled session window, in either direction.
  pub overtime_secs: f64,
  pub this_week_secs: f64,
  /// Seconds accrued in a session that is still running.
  pub active_secs: f64,
  /// Attendances closed by the auto-checkout at the session's scheduled end — a forgotten
  /// sign-out rather than a deliberate one.
  pub forgot_checkout: usize,
  /// Forgotten sign-outs in an unbroken run ending at the most recent completed attendance.
  pub forgot_checkout_streak: usize,
  /// Finished sessions attended in an unbroken run ending at the most recently finished session.
  pub attendance_streak: usize,
  pub longest_stint_secs: Option<i64>,
  pub shortest_stint_secs: Option<i64>,
  /// Times of day, as minutes since local midnight.
  pub avg_check_in_minutes: Option<i64>,
  pub avg_check_out_minutes: Option<i64>,
  pub earliest_check_in_minutes: Option<i64>,
  pub latest_check_out_minutes: Option<i64>,
  /// Minutes between the earliest and latest check-in time of day — how predictable they are.
  pub check_in_spread_minutes: Option<i64>,
  /// Attendances started before the session was scheduled to begin.
  pub early_arrivals: usize,
  /// Attendances that ran past the scheduled end under their own steam (not auto-closed).
  pub late_stays: usize,
  /// Checkouts landing between local midnight and [`SMALL_HOURS_END`].
  pub after_midnight_checkouts: usize,
  /// Attendances whose check-in fell on a local Saturday or Sunday.
  pub weekend_sessions: usize,
  pub distinct_locations: usize,
  /// Days since the first check-in on record.
  pub days_since_first: Option<i64>,
  /// Position and field size on the unfiltered leaderboard.
  pub global_rank: Option<(usize, usize)>,
  /// Position and field size among members of the same type.
  pub group_rank: Option<(usize, usize)>,
  pub currently_checked_in: bool,
}

impl MemberProfile {
  /// Share of all-time hours spent outside session windows, 0-100.
  #[must_use]
  pub fn overtime_pct(&self) -> i64 {
    if self.total_secs <= 0.0 {
      return 0;
    }
    #[allow(clippy::cast_possible_truncation)]
    let pct = (self.overtime_secs * 100.0 / self.total_secs).round() as i64;
    pct.clamp(0, 100)
  }

  /// Share of finished sessions attended, 0-100. Zero when there were none to attend.
  #[must_use]
  pub fn attendance_pct(&self) -> i64 {
    if self.sessions_possible == 0 {
      return 0;
    }
    let attended = i64::try_from(self.sessions_attended.min(self.sessions_possible)).unwrap_or(i64::MAX);
    let possible = i64::try_from(self.sessions_possible).unwrap_or(1);
    (attended * 100) / possible
  }

  /// Share of attendances that ended in a forgotten sign-out, 0-100.
  #[must_use]
  pub fn forgot_pct(&self) -> i64 {
    if self.sessions_attended == 0 {
      return 0;
    }
    let forgot = i64::try_from(self.forgot_checkout).unwrap_or(i64::MAX);
    let attended = i64::try_from(self.sessions_attended).unwrap_or(1);
    (forgot * 100) / attended
  }

  #[must_use]
  pub fn total_hours(&self) -> f64 {
    self.total_secs / 3600.0
  }

  #[must_use]
  pub fn this_week_hours(&self) -> f64 {
    self.this_week_secs / 3600.0
  }

  /// Longest single stint in hours, or 0 when nothing is on record.
  #[must_use]
  pub fn longest_stint_hours(&self) -> f64 {
    #[allow(clippy::cast_precision_loss)]
    let secs = self.longest_stint_secs.unwrap_or(0) as f64;
    secs / 3600.0
  }
}

/// Everything needed to derive a profile. The two totals and the two ranks come from the
/// leaderboard so the numbers on a stat card always match the numbers on the board; the rest is
/// derived here from the member's own attendance rows.
pub struct ProfileInput<'a> {
  pub member_type: String,
  pub member_sessions: &'a [TeamMemberSession],
  pub sessions: &'a [Session],
  pub tz: FixedOffset,
  pub now: DateTime<Utc>,
  pub total_secs: f64,
  pub this_week_secs: f64,
  pub active_secs: f64,
  pub global_rank: Option<(usize, usize)>,
  pub group_rank: Option<(usize, usize)>,
}

/// Minutes since local midnight.
fn minutes_of_day(at: DateTime<Utc>, tz: FixedOffset) -> i64 {
  let local = at.with_timezone(&tz);
  i64::from(local.hour() * 60 + local.minute())
}

/// Forgotten sign-outs in an unbroken run ending at the most recent completed attendance.
///
/// Only completed attendances count: an open one is still in progress and has not yet had the
/// chance to be forgotten, so it neither extends nor breaks the run.
fn trailing_forgot_streak(completed: &[(DateTime<Utc>, bool)]) -> usize {
  let mut ordered: Vec<&(DateTime<Utc>, bool)> = completed.iter().collect();
  ordered.sort_by_key(|(check_in, _)| std::cmp::Reverse(*check_in));
  ordered.iter().take_while(|(_, forgot)| *forgot).count()
}

/// Finished sessions attended in an unbroken run ending at the most recently finished session.
fn trailing_attendance_streak(sessions: &[Session], attended: &HashSet<Uuid>, now: DateTime<Utc>) -> usize {
  let mut finished: Vec<&Session> = sessions.iter().filter(|s| s.end_time <= now).collect();
  finished.sort_by_key(|s| std::cmp::Reverse(s.end_time));
  finished.iter().take_while(|s| attended.contains(&s.id)).count()
}

#[must_use]
pub fn build(input: &ProfileInput) -> MemberProfile {
  let (tz, now) = (input.tz, input.now);
  let session_by_id: HashMap<Uuid, &Session> = input.sessions.iter().map(|s| (s.id, s)).collect();
  let now_secs = now.timestamp();

  let mut overtime_secs = 0.0;
  let mut check_in_total = 0i64;
  let mut check_out_total = 0i64;
  let mut check_out_count = 0usize;
  let mut forgot_checkout = 0usize;
  let mut earliest_check_in: Option<i64> = None;
  let mut latest_check_out: Option<i64> = None;
  let mut longest_stint: Option<i64> = None;
  let mut shortest_stint: Option<i64> = None;
  let mut early_arrivals = 0usize;
  let mut late_stays = 0usize;
  let mut after_midnight = 0usize;
  let mut weekend_sessions = 0usize;
  let mut currently_checked_in = false;
  let mut locations: HashSet<Uuid> = HashSet::new();
  let mut attended: HashSet<Uuid> = HashSet::new();
  let mut completed: Vec<(DateTime<Utc>, bool)> = Vec::new();
  let mut first_check_in: Option<DateTime<Utc>> = None;

  for ms in input.member_sessions {
    attended.insert(ms.session_id);
    first_check_in = Some(first_check_in.map_or(ms.check_in_time, |cur| cur.min(ms.check_in_time)));

    let in_minutes = minutes_of_day(ms.check_in_time, tz);
    check_in_total += in_minutes;
    earliest_check_in = Some(earliest_check_in.map_or(in_minutes, |cur: i64| cur.min(in_minutes)));

    if ms.check_in_time.with_timezone(&tz).weekday() == Weekday::Sat
      || ms.check_in_time.with_timezone(&tz).weekday() == Weekday::Sun
    {
      weekend_sessions += 1;
    }

    if let Some(check_out) = ms.check_out_time {
      let out_minutes = minutes_of_day(check_out, tz);
      check_out_total += out_minutes;
      check_out_count += 1;
      latest_check_out = Some(latest_check_out.map_or(out_minutes, |cur: i64| cur.max(out_minutes)));
      if check_out.with_timezone(&tz).hour() < SMALL_HOURS_END {
        after_midnight += 1;
      }
      let stint = (check_out - ms.check_in_time).num_seconds().max(0);
      longest_stint = Some(longest_stint.map_or(stint, |cur: i64| cur.max(stint)));
      if stint > 0 {
        shortest_stint = Some(shortest_stint.map_or(stint, |cur: i64| cur.min(stint)));
      }
    } else {
      currently_checked_in = true;
    }

    let Some(session) = session_by_id.get(&ms.session_id) else { continue };
    locations.insert(session.location_id);

    // The auto-checkout process records the checkout as exactly the scheduled end
    // (`session/logic.rs`), so a checkout landing on the end instant is one the member never
    // signed out from themselves.
    let forgot = ms.check_out_time.is_some_and(|co| co == session.end_time);
    if forgot {
      forgot_checkout += 1;
    }
    if ms.check_out_time.is_some() {
      completed.push((ms.check_in_time, forgot));
    }

    if ms.check_in_time < session.start_time {
      early_arrivals += 1;
    }
    if ms.check_out_time.is_some_and(|co| co > session.end_time) {
      late_stays += 1;
    }

    let start = session.start_time.timestamp();
    let end = session.end_time.timestamp();
    let check_in = ms.check_in_time.timestamp();
    let check_out = ms.check_out_time.map_or(now_secs, |t| t.timestamp());
    if check_out <= check_in {
      continue;
    }
    // Same window math as the leaderboard: overtime is anything outside [start, end].
    #[allow(clippy::cast_precision_loss)]
    let raw = (check_out - check_in) as f64;
    #[allow(clippy::cast_precision_loss)]
    let regular = (check_out.min(end) - check_in.max(start)).max(0) as f64;
    overtime_secs += raw - regular;
  }

  let sessions_attended = input.member_sessions.len();
  let latest_check_in = input.member_sessions.iter().map(|ms| minutes_of_day(ms.check_in_time, tz)).max();

  MemberProfile {
    member_type: input.member_type.clone(),
    sessions_attended,
    sessions_possible: input.sessions.iter().filter(|s| s.end_time <= now).count(),
    total_secs: input.total_secs,
    overtime_secs,
    this_week_secs: input.this_week_secs,
    active_secs: input.active_secs,
    forgot_checkout,
    forgot_checkout_streak: trailing_forgot_streak(&completed),
    attendance_streak: trailing_attendance_streak(input.sessions, &attended, now),
    longest_stint_secs: longest_stint,
    shortest_stint_secs: shortest_stint,
    avg_check_in_minutes: average(check_in_total, sessions_attended),
    avg_check_out_minutes: average(check_out_total, check_out_count),
    earliest_check_in_minutes: earliest_check_in,
    latest_check_out_minutes: latest_check_out,
    check_in_spread_minutes: earliest_check_in.zip(latest_check_in).map(|(first, last)| last - first),
    early_arrivals,
    late_stays,
    after_midnight_checkouts: after_midnight,
    weekend_sessions,
    distinct_locations: locations.len(),
    days_since_first: first_check_in.map(|first| (now - first).num_days()),
    global_rank: input.global_rank,
    group_rank: input.group_rank,
    currently_checked_in,
  }
}

/// Rounded mean of `total` over `count`, or `None` when `count` is zero.
fn average(total: i64, count: usize) -> Option<i64> {
  if count == 0 {
    return None;
  }
  #[allow(clippy::cast_precision_loss, clippy::cast_possible_truncation)]
  let avg = (total as f64 / count as f64).round() as i64;
  Some(avg)
}
