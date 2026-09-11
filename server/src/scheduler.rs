use std::future::Future;
use std::time::Duration;

use chrono::{Datelike, Duration as ChronoDuration, NaiveDate, NaiveTime, Utc, Weekday};
use tokio::task::JoinSet;
use tokio_util::sync::CancellationToken;

/// When a [Service] repeats. Recomputed on every cycle (rather than a single `tokio::time::interval`
/// set up once) so the wall-clock variants can account for rollover - the cost is that `Every` no
/// longer self-corrects for time spent in `execute()` the way `tokio::time::interval` does, which
/// is fine for anything running on the order of minutes or longer.
///
/// All wall-clock variants are interpreted in UTC.
#[derive(Debug, Clone, Copy)]
pub enum Schedule {
  /// Runs on a fixed cadence.
  Every(Duration),
  /// Runs once every 24h at this wall-clock time.
  DailyAt(NaiveTime),
  /// Runs on `weekday` at `time`, every `interval_weeks` weeks (1 = weekly, 2 = fortnightly/
  /// biweekly, etc). The phase (which weeks count) is anchored to a fixed epoch shared by every
  /// service, so e.g. two independent fortnightly services stay on the same fortnight cycle
  /// rather than drifting relative to each other based on when each was first deployed.
  WeeklyAt { weekday: Weekday, time: NaiveTime, interval_weeks: u32 },
  /// Runs once a month on `day` (1-31) at `time`. Months shorter than `day` clamp to their last
  /// day - e.g. `day: 31` runs on the 28th/29th in February.
  MonthlyAt { day: u32, time: NaiveTime },
  /// Runs once a year on `month`/`day` at `time`. `day: 29, month: 2` clamps to Feb 28 in
  /// non-leap years.
  YearlyAt { month: u32, day: u32, time: NaiveTime },
}

pub trait Service: Send + Sync + 'static {
  fn name(&self) -> &'static str;
  fn schedule(&self) -> Schedule;
  /// Whether to run once immediately on startup, ahead of the regular schedule. Defaults to
  /// `false` so an expensive or disruptive job doesn't fire on every restart - override to
  /// `true` for services that should be caught up right away.
  fn run_immediately(&self) -> bool {
    false
  }
  fn execute(&self) -> impl Future<Output = anyhow::Result<()>> + Send;
}

#[derive(Default)]
pub struct Pool {
  tasks: JoinSet<()>,
}

impl Pool {
  pub fn add(&mut self, svc: impl Service, cancel: CancellationToken) {
    self.tasks.spawn(run(svc, cancel));
  }

  pub async fn wait(&mut self) {
    while self.tasks.join_next().await.is_some() {}
  }
}

/// Time remaining until the next occurrence of `time` (today if it hasn't passed yet today,
/// otherwise tomorrow), in UTC.
fn duration_until_daily(time: NaiveTime) -> Duration {
  let now = Utc::now();
  let mut next = now.date_naive().and_time(time).and_utc();
  if next <= now {
    next += ChronoDuration::days(1);
  }
  (next - now).to_std().unwrap_or(Duration::ZERO)
}

/// Fixed Monday that every `WeeklyAt` schedule measures its `interval_weeks` phase from, so
/// independent services with the same interval stay in sync with each other regardless of when
/// each was deployed. Arbitrary otherwise - only its weekday (Monday) and being in the past matter.
fn week_epoch() -> NaiveDate {
  NaiveDate::from_ymd_opt(2000, 1, 3).unwrap()
}

/// Time remaining until the next occurrence of `weekday` at `time`, restricted to weeks whose
/// index (counted from [week_epoch]) is a multiple of `interval_weeks`.
fn duration_until_weekly(weekday: Weekday, time: NaiveTime, interval_weeks: u32) -> Duration {
  let interval_weeks = i64::from(interval_weeks.max(1));
  let now = Utc::now();
  let today = now.date_naive();
  let epoch = week_epoch();

  for offset in 0..(interval_weeks * 7 + 7) {
    let candidate_date = today + ChronoDuration::days(offset);
    if candidate_date.weekday() != weekday {
      continue;
    }
    let monday_of_week =
      candidate_date - ChronoDuration::days(i64::from(candidate_date.weekday().num_days_from_monday()));
    let week_index = (monday_of_week - epoch).num_days().div_euclid(7);
    if week_index.rem_euclid(interval_weeks) != 0 {
      continue;
    }
    let candidate = candidate_date.and_time(time).and_utc();
    if candidate > now {
      return (candidate - now).to_std().unwrap_or(Duration::ZERO);
    }
  }
  Duration::ZERO
}

/// Number of days in `year`/`month`.
fn days_in_month(year: i32, month: u32) -> u32 {
  let next_month_first =
    if month == 12 { NaiveDate::from_ymd_opt(year + 1, 1, 1) } else { NaiveDate::from_ymd_opt(year, month + 1, 1) }
      .unwrap();
  let this_month_first = NaiveDate::from_ymd_opt(year, month, 1).unwrap();
  // A single month is always 28-31 days - always fits in u32.
  u32::try_from((next_month_first - this_month_first).num_days()).unwrap_or(31)
}

/// `(year, month)` that is `add` months after `year`/`month`.
fn add_months(year: i32, month: u32, add: u32) -> (i32, u32) {
  let total = (month - 1) + add;
  // `total / 12` is a small year-offset count - always fits in i32.
  (year + i32::try_from(total / 12).unwrap_or(i32::MAX), total % 12 + 1)
}

/// Time remaining until the next occurrence of `day`-of-month at `time`, clamping `day` to the
/// last day of any month shorter than it.
fn duration_until_monthly(day: u32, time: NaiveTime) -> Duration {
  let now = Utc::now();
  let today = now.date_naive();

  for month_offset in 0..2 {
    let (year, month) = add_months(today.year(), today.month(), month_offset);
    let clamped_day = day.clamp(1, days_in_month(year, month));
    let candidate = NaiveDate::from_ymd_opt(year, month, clamped_day).unwrap().and_time(time).and_utc();
    if candidate > now {
      return (candidate - now).to_std().unwrap_or(Duration::ZERO);
    }
  }
  Duration::ZERO
}

/// Time remaining until the next occurrence of `month`/`day` at `time`, clamping `day` to the
/// last day of `month` (e.g. Feb 29 in a non-leap year becomes Feb 28).
fn duration_until_yearly(month: u32, day: u32, time: NaiveTime) -> Duration {
  let now = Utc::now();
  let this_year = now.year();

  for year in [this_year, this_year + 1] {
    let clamped_day = day.clamp(1, days_in_month(year, month));
    let candidate = NaiveDate::from_ymd_opt(year, month, clamped_day).unwrap().and_time(time).and_utc();
    if candidate > now {
      return (candidate - now).to_std().unwrap_or(Duration::ZERO);
    }
  }
  Duration::ZERO
}

async fn execute_once(svc: &impl Service) {
  let start = std::time::Instant::now();
  match svc.execute().await {
    Ok(()) => log::debug!("[{}] completed in {:?}", svc.name(), start.elapsed()),
    Err(err) => log::error!("[{}] error: {err}", svc.name()),
  }
}

async fn run(svc: impl Service, cancel: CancellationToken) {
  log::info!("[{}] started (schedule: {:?}, run_immediately: {})", svc.name(), svc.schedule(), svc.run_immediately());

  if svc.run_immediately() {
    execute_once(&svc).await;
  }

  loop {
    let wait = match svc.schedule() {
      Schedule::Every(interval) => interval,
      Schedule::DailyAt(time) => duration_until_daily(time),
      Schedule::WeeklyAt { weekday, time, interval_weeks } => duration_until_weekly(weekday, time, interval_weeks),
      Schedule::MonthlyAt { day, time } => duration_until_monthly(day, time),
      Schedule::YearlyAt { month, day, time } => duration_until_yearly(month, day, time),
    };

    tokio::select! {
        () = cancel.cancelled() => {
            log::info!("[{}] shutting down", svc.name());
            return;
        }
        () = tokio::time::sleep(wait) => {
            execute_once(&svc).await;
        }
    }
  }
}
