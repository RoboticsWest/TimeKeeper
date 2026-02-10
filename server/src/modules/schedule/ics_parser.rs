use anyhow::{Result, anyhow, bail};
use chrono::{NaiveDate, TimeZone, Utc};
use chrono_tz::Tz;
use icalendar::{Calendar, CalendarComponent, CalendarDateTime, Component, DatePerhapsTime, EventLike};

use crate::{
  generated::common::Timestamp,
  modules::schedule::{Schedule, ScheduleSessionT},
};

/// Try to parse a timezone string (e.g. "Australia/Perth") into a chrono-tz Tz.
fn parse_tz(tzid: &str) -> Option<Tz> {
  tzid.parse::<Tz>().ok()
}

fn date_perhaps_time_to_timestamp(dpt: &DatePerhapsTime, default_tz: Option<Tz>) -> Result<Timestamp> {
  match dpt {
    DatePerhapsTime::DateTime(cal_dt) => calendar_datetime_to_timestamp(cal_dt, default_tz),
    DatePerhapsTime::Date(date) => naive_date_to_timestamp(*date, default_tz),
  }
}

fn calendar_datetime_to_timestamp(cal_dt: &CalendarDateTime, default_tz: Option<Tz>) -> Result<Timestamp> {
  let seconds = match cal_dt {
    CalendarDateTime::Utc(dt) => dt.timestamp(),
    CalendarDateTime::Floating(naive) => {
      if let Some(tz) = default_tz {
        tz.from_local_datetime(naive)
          .single()
          .ok_or_else(|| anyhow!("Ambiguous or invalid local time: {} in {}", naive, tz))?
          .with_timezone(&Utc)
          .timestamp()
      } else {
        naive.and_utc().timestamp()
      }
    }
    CalendarDateTime::WithTimezone { date_time, tzid } => {
      if let Some(tz) = parse_tz(tzid) {
        tz.from_local_datetime(date_time)
          .single()
          .ok_or_else(|| anyhow!("Ambiguous or invalid local time: {} in {}", date_time, tz))?
          .with_timezone(&Utc)
          .timestamp()
      } else {
        log::warn!("Unknown timezone '{}', treating as UTC", tzid);
        date_time.and_utc().timestamp()
      }
    }
  };
  Ok(Timestamp { seconds, nanos: 0 })
}

fn naive_date_to_timestamp(date: NaiveDate, default_tz: Option<Tz>) -> Result<Timestamp> {
  let naive = date.and_hms_opt(0, 0, 0).ok_or_else(|| anyhow!("Could not create datetime from date: {}", date))?;

  let seconds = if let Some(tz) = default_tz {
    tz.from_local_datetime(&naive)
      .single()
      .ok_or_else(|| anyhow!("Ambiguous or invalid local time: {} in {}", naive, tz))?
      .with_timezone(&Utc)
      .timestamp()
  } else {
    naive.and_utc().timestamp()
  };

  Ok(Timestamp { seconds, nanos: 0 })
}

pub struct IcsParser;

impl IcsParser {
  pub fn ics_to_schedule(ics: &str) -> Result<Schedule> {
    let calendar: Calendar = ics.parse().map_err(|e: String| anyhow!(e))?;

    // Read the calendar-level timezone (X-WR-TIMEZONE)
    let default_tz = calendar.property_value("X-WR-TIMEZONE").and_then(|tz_str| {
      let tz = parse_tz(tz_str);
      if tz.is_none() {
        log::warn!("Unknown calendar timezone: {}", tz_str);
      }
      tz
    });

    let mut locations: Vec<String> = Vec::new();
    let mut sessions: Vec<ScheduleSessionT> = Vec::new();

    for component in &calendar.components {
      let CalendarComponent::Event(event) = component else {
        continue;
      };

      let location = match event.get_location() {
        Some(loc) => loc.to_string(),
        None => continue,
      };

      let start = event.get_start().ok_or_else(|| anyhow!("Event missing DTSTART: {:?}", event.get_summary()))?;
      let end = event.get_end().ok_or_else(|| anyhow!("Event missing DTEND: {:?}", event.get_summary()))?;

      let start_time = date_perhaps_time_to_timestamp(&start, default_tz)?;
      let end_time = date_perhaps_time_to_timestamp(&end, default_tz)?;

      if !locations.contains(&location) {
        locations.push(location.clone());
      }

      sessions.push(ScheduleSessionT { start_time, end_time, location_name: location });
    }

    if sessions.is_empty() {
      bail!("No valid events found in ICS data");
    }

    Ok(Schedule { sessions, locations })
  }
}
