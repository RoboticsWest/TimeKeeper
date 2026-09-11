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
