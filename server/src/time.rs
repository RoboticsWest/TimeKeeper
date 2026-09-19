use chrono::{DateTime, FixedOffset, TimeZone, Utc};

/// Parse a timezone string like:
/// - "UTC"
/// - "UTC+8"
/// - "UTC-5"
///
/// Returns a FixedOffset. Falls back to UTC if invalid.
pub fn parse_tz(timezone: &str) -> FixedOffset {
  if timezone.is_empty() || timezone == "UTC" {
    return FixedOffset::east_opt(0).unwrap();
  }

  // Optional "UTC" prefix
  let tz_str = timezone.strip_prefix("UTC").unwrap_or(timezone);

  if let Ok(hours) = tz_str.parse::<i32>() {
    let seconds = hours * 3600;
    if let Some(offset) = FixedOffset::east_opt(seconds) {
      return offset;
    }
  }

  log::warn!("Invalid timezone '{timezone}', falling back to UTC");
  FixedOffset::east_opt(0).unwrap()
}

/// Convert epoch seconds into local DateTime using offset
fn to_local(secs: i64, tz: FixedOffset) -> DateTime<FixedOffset> {
  let dt_utc = Utc.timestamp_opt(secs, 0).single().unwrap_or_else(|| Utc.timestamp_opt(0, 0).single().unwrap());

  dt_utc.with_timezone(&tz)
}

/// Format time (e.g. "3:00PM")
pub fn format_time(secs: i64, tz: FixedOffset) -> String {
  to_local(secs, tz).format("%-I:%M%p").to_string()
}

/// Format date (e.g. "Feb 19")
pub fn format_date(secs: i64, tz: FixedOffset) -> String {
  to_local(secs, tz).format("%b %-d").to_string()
}

/// Format short datetime (e.g. "Thu, Feb 19, 3:00PM")
pub fn format_datetime(secs: i64, tz: FixedOffset) -> String {
  to_local(secs, tz).format("%a, %b %-d, %-I:%M%p").to_string()
}

/// Format the full weekday name (e.g. "Wednesday")
pub fn format_weekday(secs: i64, tz: FixedOffset) -> String {
  to_local(secs, tz).format("%A").to_string()
}

/// How a human would name the day `secs` falls on, relative to `now_secs`:
/// "today", "tomorrow", "yesterday", or the weekday name.
///
/// This backs the `{relative_day}` message placeholder. The reminder templates used to hardcode
/// the word "tomorrow", which is only true when the session was created far enough ahead for
/// the 24h lead time to apply. An admin creating a session two hours beforehand triggered the
/// reminder immediately and announced a session "tomorrow" that was starting the same
/// afternoon. Both days are computed in the configured timezone, not UTC, so a session at
/// 09:00 local is "today" for the people reading the message.
pub fn format_relative_day(secs: i64, tz: FixedOffset, now_secs: i64) -> String {
  let target = to_local(secs, tz).date_naive();
  let today = to_local(now_secs, tz).date_naive();
  let delta = (target - today).num_days();

  match delta {
    0 => "today".to_string(),
    1 => "tomorrow".to_string(),
    -1 => "yesterday".to_string(),
    // Past a week either way a bare weekday name stops being unambiguous.
    2..=6 => format_weekday(secs, tz),
    _ => format_date(secs, tz),
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  fn utc() -> FixedOffset {
    FixedOffset::east_opt(0).unwrap()
  }

  /// 2026-09-19 is a Saturday.
  fn sat_19th_noon() -> i64 {
    1_789_819_200 // 2026-09-19T12:00:00Z
  }

  #[test]
  fn relative_day_names_today_and_tomorrow() {
    let now = sat_19th_noon();
    assert_eq!(format_relative_day(now + 3 * 3600, utc(), now), "today");
    assert_eq!(format_relative_day(now + 24 * 3600, utc(), now), "tomorrow");
    assert_eq!(format_relative_day(now - 24 * 3600, utc(), now), "yesterday");
  }

  /// The bug this exists for: a session created hours beforehand must not be announced
  /// as "tomorrow".
  #[test]
  fn a_session_later_the_same_day_is_today() {
    let now = sat_19th_noon();
    let two_hours_later = now + 2 * 3600;
    assert_eq!(format_relative_day(two_hours_later, utc(), now), "today");
  }

  #[test]
  fn mid_week_uses_the_weekday_name() {
    let now = sat_19th_noon();
    // Saturday + 4 days = Wednesday the 23rd.
    assert_eq!(format_relative_day(now + 4 * 24 * 3600, utc(), now), "Wednesday");
  }

  #[test]
  fn beyond_a_week_falls_back_to_a_date() {
    let now = sat_19th_noon();
    assert_eq!(format_relative_day(now + 10 * 24 * 3600, utc(), now), "Sep 29");
  }

  /// "Today" is decided in the operator's timezone, not UTC.
  #[test]
  fn relative_day_respects_the_configured_timezone() {
    let now = sat_19th_noon(); // 12:00 UTC Sat
    let perth = FixedOffset::east_opt(8 * 3600).unwrap();
    // 2026-09-19T20:00Z is Sunday 04:00 in Perth, but still Saturday in UTC.
    let target = now + 8 * 3600;
    assert_eq!(format_relative_day(target, utc(), now), "today");
    assert_eq!(format_relative_day(target, perth, now), "tomorrow");
  }
}
