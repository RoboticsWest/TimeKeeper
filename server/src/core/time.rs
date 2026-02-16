use chrono::{TimeZone, Utc};
use chrono_tz::Tz;

/// Parse a timezone string like "UTC", "UTC+8", "UTC-5", or a named timezone like "America/New_York".
/// Returns a chrono_tz::Tz; numeric UTC offsets fall back to UTC.
pub fn parse_tz(timezone: &str) -> Tz {
  if timezone.is_empty() || timezone == "UTC" {
    chrono_tz::UTC
  } else if let Some(stripped) = timezone.strip_prefix("UTC") {
    // Handle numeric offsets like UTC+8, UTC-5
    if let Ok(_hours) = stripped.parse::<i32>() {
      // chrono_tz doesn't support numeric offsets directly
      // fallback to UTC (you can enhance to FixedOffset if needed)
      chrono_tz::UTC
    } else {
      chrono_tz::UTC
    }
  } else {
    timezone.parse::<Tz>().unwrap_or_else(|_| {
      log::warn!("Invalid timezone string '{timezone}', falling back to UTC");
      chrono_tz::UTC
    })
  }
}

/// Format seconds since epoch as a time string (e.g. "3:00PM")
pub fn format_time(secs: i64, tz: &Tz) -> String {
  let dt_utc = Utc.timestamp_opt(secs, 0).single().unwrap_or_else(|| Utc.timestamp_opt(0, 0).single().unwrap());
  let dt_local = tz.from_utc_datetime(&dt_utc.naive_utc());
  dt_local.format("%-I:%M%p").to_string()
}

/// Format seconds since epoch as a date string (e.g. "February 14")
pub fn format_date(secs: i64, tz: &Tz) -> String {
  let dt_utc = Utc.timestamp_opt(secs, 0).single().unwrap_or_else(|| Utc.timestamp_opt(0, 0).single().unwrap());
  let dt_local = tz.from_utc_datetime(&dt_utc.naive_utc());
  dt_local.format("%B %-d").to_string()
}

/// Format seconds since epoch as a short datetime (e.g. "Thu, Feb 19, 3:00PM")
pub fn format_datetime(secs: i64, tz: &Tz) -> String {
  let dt_utc = Utc.timestamp_opt(secs, 0).single().unwrap_or_else(|| Utc.timestamp_opt(0, 0).single().unwrap());
  let dt_local = tz.from_utc_datetime(&dt_utc.naive_utc());
  dt_local.format("%a, %b %e, %-I:%M%p").to_string()
}

/// Format a start and end time as a human-readable range (e.g. "3:00PM to 8:00PM")
pub fn format_time_range(start_secs: i64, end_secs: i64, tz: &Tz) -> String {
  let start = format_time(start_secs, tz);
  let end = format_time(end_secs, tz);
  format!("{start} to {end}")
}
