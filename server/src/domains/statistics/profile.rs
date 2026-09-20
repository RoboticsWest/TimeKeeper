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

use super::model::{AttendanceStats, SOURCE_DISCORD, SOURCE_KIOSK, SOURCE_RFID, TeamMemberStats};

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
  /// Attendances the member signed out of themselves, after the scheduled end. Recorded, not
  /// inferred: on the row alone this is indistinguishable from having forgotten.
  pub late_stays: usize,
  /// Checkouts made from Discord with `!checkout`.
  pub discord_checkouts: usize,
  /// Checkouts made at a kiosk, by PIN or by RFID scan.
  pub kiosk_checkouts: usize,
  /// Overtime DMs this member has actually been sent.
  pub overtime_warnings: usize,
  /// Every check-in ever recorded for them, including ones whose session has since been deleted.
  /// Unlike `sessions_attended`, this only ever goes up.
  pub lifetime_check_ins: usize,
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
  /// Recorded facts for those attendances, keyed by attendance id (migration 0013).
  pub attendance_stats: &'a [AttendanceStats],
  pub member_stats: &'a TeamMemberStats,
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
  let stats_by_attendance: HashMap<Uuid, &AttendanceStats> =
    input.attendance_stats.iter().map(|a| (a.team_member_session_id, a)).collect();
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
  let mut discord_checkouts = 0usize;
  let mut kiosk_checkouts = 0usize;
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

    // Who ended this attendance, as recorded at the time (migration 0013). The old heuristic -
    // "a checkout landing exactly on the session's scheduled end was the auto-checkout" - is
    // kept only as a fallback for a row whose stats write failed, because it is the best guess
    // available for such a row and reporting nothing would be worse. It is a guess, though: a
    // deliberate `!checkout` run after the session ended writes exactly the same instant.
    let recorded = stats_by_attendance.get(&ms.id);
    let forgot = recorded
      .map_or_else(|| ms.check_out_time.is_some_and(|co| co == session.end_time), |stats| stats.forgot_checkout());
    if forgot {
      forgot_checkout += 1;
    }
    if ms.check_out_time.is_some() {
      completed.push((ms.check_in_time, forgot));
    }

    if let Some(stats) = recorded {
      if stats.late_manual_checkout() {
        late_stays += 1;
      }
      match stats.checkout_source.as_str() {
        SOURCE_DISCORD => discord_checkouts += 1,
        SOURCE_KIOSK | SOURCE_RFID => kiosk_checkouts += 1,
        _ => {}
      }
    } else if ms.check_out_time.is_some_and(|co| co > session.end_time) {
      // Strictly after the end, so never the auto-checkout: a late stay even without a record.
      late_stays += 1;
    }

    if ms.check_in_time < session.start_time {
      early_arrivals += 1;
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
    discord_checkouts,
    kiosk_checkouts,
    overtime_warnings: usize::try_from(input.member_stats.overtime_warnings).unwrap_or(usize::MAX),
    lifetime_check_ins: usize::try_from(input.member_stats.check_ins).unwrap_or(usize::MAX),
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

#[cfg(test)]
mod tests {
  use chrono::TimeZone;

  use super::*;
  use crate::domains::statistics::model::{CHECKOUT_AUTO, CHECKOUT_MANUAL, CHECKOUT_NONE, SOURCE_AUTO, SOURCE_DISCORD};

  fn utc(hour: u32) -> DateTime<Utc> {
    Utc.with_ymd_and_hms(2026, 3, 10, hour, 0, 0).single().expect("valid instant")
  }

  fn session(start: u32, end: u32) -> Session {
    Session {
      id: Uuid::now_v7(),
      start_time: utc(start),
      end_time: utc(end),
      location_id: Uuid::now_v7(),
      finished: true,
      actual_start_time: None,
      actual_end_time: None,
    }
  }

  fn attendance(session: &Session, check_in: u32, check_out: Option<DateTime<Utc>>) -> TeamMemberSession {
    TeamMemberSession {
      id: Uuid::now_v7(),
      team_member_id: Uuid::now_v7(),
      session_id: session.id,
      check_in_time: utc(check_in),
      check_out_time: check_out,
    }
  }

  fn stats(attendance: &TeamMemberSession, kind: &str, source: &str, late: bool) -> AttendanceStats {
    AttendanceStats {
      team_member_session_id: attendance.id,
      checkout_kind: kind.to_string(),
      checkout_source: source.to_string(),
      checked_out_late: late,
      recorded_at: utc(12),
    }
  }

  fn build_for(
    sessions: &[Session],
    member_sessions: &[TeamMemberSession],
    attendance_stats: &[AttendanceStats],
  ) -> MemberProfile {
    let member_stats = TeamMemberStats::zeroed(Uuid::now_v7());
    build(&ProfileInput {
      member_type: "student".to_string(),
      member_sessions,
      sessions,
      attendance_stats,
      member_stats: &member_stats,
      tz: FixedOffset::east_opt(0).expect("utc"),
      now: utc(23),
      total_secs: 7200.0,
      this_week_secs: 7200.0,
      active_secs: 0.0,
      global_rank: None,
      group_rank: None,
    })
  }

  #[test]
  fn a_deliberate_late_checkout_is_not_a_forgotten_one() {
    // The bug this whole table exists for. `!checkout` run after the session has ended records
    // the checkout as *exactly* the scheduled end - byte-identical to what the auto-checkout
    // writes - so on the attendance row alone these two are the same event. The recorded kind
    // is the only thing that tells them apart.
    let session = session(9, 17);
    let late_sign_out = attendance(&session, 10, Some(session.end_time));
    let recorded = stats(&late_sign_out, CHECKOUT_MANUAL, SOURCE_DISCORD, true);

    let profile = build_for(&[session], &[late_sign_out], &[recorded]);

    assert_eq!(profile.forgot_checkout, 0, "they signed out themselves");
    assert_eq!(profile.late_stays, 1, "and they did it after the session had ended");
    assert_eq!(profile.discord_checkouts, 1);
  }

  #[test]
  fn an_auto_checkout_is_a_forgotten_one() {
    let session = session(9, 17);
    let forgotten = attendance(&session, 10, Some(session.end_time));
    let recorded = stats(&forgotten, CHECKOUT_AUTO, SOURCE_AUTO, false);

    let profile = build_for(&[session], &[forgotten], &[recorded]);

    assert_eq!(profile.forgot_checkout, 1);
    assert_eq!(profile.late_stays, 0, "the auto-checkout lands on the end, it does not run past it");
    assert_eq!(profile.forgot_checkout_streak, 1);
  }

  #[test]
  fn a_row_with_no_recorded_stats_falls_back_to_the_old_heuristic() {
    // History from before migration 0013 is backfilled, so this only happens when a stats write
    // failed. Guessing is better than reporting nothing for such a row - but it is a guess, and
    // it is the guess that cannot tell the two cases above apart.
    let session = session(9, 17);
    let ambiguous = attendance(&session, 10, Some(session.end_time));

    let profile = build_for(&[session], &[ambiguous], &[]);

    assert_eq!(profile.forgot_checkout, 1, "checkout exactly on the end reads as forgotten");
  }

  #[test]
  fn an_open_attendance_counts_as_neither() {
    let session = session(9, 17);
    let still_in = attendance(&session, 10, None);
    let recorded = stats(&still_in, CHECKOUT_NONE, "unknown", false);

    let profile = build_for(&[session], &[still_in], &[recorded]);

    assert!(profile.currently_checked_in);
    assert_eq!(profile.forgot_checkout, 0);
    assert_eq!(profile.late_stays, 0);
    assert_eq!(profile.forgot_checkout_streak, 0, "an open attendance cannot yet have been forgotten");
  }

  #[test]
  fn lifetime_counters_come_from_the_member_row_not_the_attendance_rows() {
    // The point of the counter: a deleted session takes its attendance row with it, and
    // `sessions_attended` drops. The lifetime figure must not.
    let session = session(9, 17);
    let one = attendance(&session, 10, Some(utc(16)));
    let member_stats = TeamMemberStats {
      team_member_id: Uuid::now_v7(),
      check_ins: 40,
      overtime_warnings: 3,
      updated_at: utc(12),
      joined_at: Some(utc(9)),
    };

    let profile = build(&ProfileInput {
      member_type: "student".to_string(),
      member_sessions: &[one],
      sessions: &[session],
      attendance_stats: &[],
      member_stats: &member_stats,
      tz: FixedOffset::east_opt(0).expect("utc"),
      now: utc(23),
      total_secs: 3600.0,
      this_week_secs: 0.0,
      active_secs: 0.0,
      global_rank: None,
      group_rank: None,
    });

    assert_eq!(profile.sessions_attended, 1, "only one attendance row survives");
    assert_eq!(profile.lifetime_check_ins, 40, "but the lifetime record remembers all of them");
    assert_eq!(profile.overtime_warnings, 3);
  }
}
