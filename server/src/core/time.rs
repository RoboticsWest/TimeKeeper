use chrono::{FixedOffset, TimeZone, Utc};

/// Parse a UTC offset string (e.g. "+8", "-5", "UTC") into a `FixedOffset`.
/// Falls back to UTC for empty or invalid values.
pub fn parse_tz(timezone: &str) -> FixedOffset {
  if timezone.is_empty() || timezone == "UTC" {
    return FixedOffset::east_opt(0).unwrap();
  }
  timezone.parse::<i32>().ok().and_then(|hours| FixedOffset::east_opt(hours * 3600)).unwrap_or_else(|| {
    log::warn!("Invalid timezone offset '{timezone}', falling back to UTC");
    FixedOffset::east_opt(0).unwrap()
  })
}

/// Format seconds since epoch as a time string (e.g. "8:00PM").
pub fn format_time(secs: i64, tz: &FixedOffset) -> String {
  Utc
    .timestamp_opt(secs, 0)
    .single()
    .map_or("Unknown".to_string(), |dt| dt.with_timezone(tz).format("%-I:%M%p").to_string())
}

/// Format seconds since epoch as a date string (e.g. "February 14").
pub fn format_date(secs: i64, tz: &FixedOffset) -> String {
  Utc
    .timestamp_opt(secs, 0)
    .single()
    .map_or("Unknown".to_string(), |dt| dt.with_timezone(tz).format("%B %-d").to_string())
}

/// Format seconds since epoch as a short datetime (e.g. "Feb 14, 20:00").
pub fn format_datetime(secs: i64, tz: &FixedOffset) -> String {
  Utc
    .timestamp_opt(secs, 0)
    .single()
    .map_or("Unknown".to_string(), |dt| dt.with_timezone(tz).format("%b %d, %H:%M").to_string())
}
