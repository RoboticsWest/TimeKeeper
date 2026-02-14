//! One-time migration: populate the `discord_notifications` table from legacy boolean flags
//! that were previously stored inline on `Session` (fields 5,6) and `TeamMemberSession` (fields 5,6).
//!
//! After the proto change those fields are `reserved`, so prost drops them on decode.
//! We read the raw protobuf bytes from sled and manually extract the old booleans.

use anyhow::Result;
use prost::encoding::{self, WireType};

use crate::{
  core::db::get_db,
  generated::db::{Notification, NotificationType},
  modules::notification::NotificationRepository,
};

/// Run the notification migration if the notifications table is empty.
/// Must be called after `init_db()` and before services start.
pub fn run_notification_migration() -> Result<()> {
  // Only migrate if the notifications table is empty
  let existing = Notification::get_all()?;
  if !existing.is_empty() {
    log::debug!("Notification migration: table already populated ({} records), skipping", existing.len());
    return Ok(());
  }

  let db = get_db()?;
  let mut count = 0;

  // Migrate Session records (fields 5=start_reminder_sent, 6=end_reminder_sent)
  let sessions_table = db.get_table("sessions");
  for result in sessions_table.scan_raw() {
    let (session_id, bytes) = result?;
    let (start_sent, end_sent) = extract_session_bools(&bytes);

    if start_sent {
      Notification::add(&Notification {
        notification_type: NotificationType::SessionStartReminder as i32,
        session_id: session_id.clone(),
        team_member_id: None,
        sent: true,
      })?;
      count += 1;
    }

    if end_sent {
      Notification::add(&Notification {
        notification_type: NotificationType::SessionEndReminder as i32,
        session_id,
        team_member_id: None,
        sent: true,
      })?;
      count += 1;
    }
  }

  // Migrate TeamMemberSession records (fields 5=overtime_notified, 6=auto_checkout_notified)
  let tms_table = db.get_table("team_member_sessions");
  for result in tms_table.scan_raw() {
    let (_, bytes) = result?;
    let (overtime, auto_checkout) = extract_tms_bools(&bytes);
    let (team_member_id, session_id) = extract_tms_ids(&bytes);

    if session_id.is_empty() {
      continue;
    }

    if overtime {
      Notification::add(&Notification {
        notification_type: NotificationType::Overtime as i32,
        session_id: session_id.clone(),
        team_member_id: Some(team_member_id.clone()),
        sent: true,
      })?;
      count += 1;
    }

    if auto_checkout {
      Notification::add(&Notification {
        notification_type: NotificationType::AutoCheckout as i32,
        session_id,
        team_member_id: Some(team_member_id),
        sent: true,
      })?;
      count += 1;
    }
  }

  if count > 0 {
    log::info!("Notification migration: created {count} records from legacy boolean flags");
  } else {
    log::debug!("Notification migration: no legacy flags found, nothing to migrate");
  }

  Ok(())
}

/// Extract bool fields 5 and 6 from raw protobuf bytes (Session).
fn extract_session_bools(bytes: &[u8]) -> (bool, bool) {
  extract_bool_fields(bytes, 5, 6)
}

/// Extract bool fields 5 and 6 from raw protobuf bytes (TeamMemberSession).
fn extract_tms_bools(bytes: &[u8]) -> (bool, bool) {
  extract_bool_fields(bytes, 5, 6)
}

/// Extract string fields 1 (team_member_id) and 2 (session_id) from raw TeamMemberSession bytes.
fn extract_tms_ids(bytes: &[u8]) -> (String, String) {
  let mut team_member_id = String::new();
  let mut session_id = String::new();
  let mut cursor = bytes;

  while !cursor.is_empty() {
    let Ok((tag, wire_type)) = encoding::decode_key(&mut cursor) else {
      break;
    };

    match (tag, wire_type) {
      (1, WireType::LengthDelimited) => {
        if let Ok(s) = decode_string(&mut cursor) {
          team_member_id = s;
        }
      }
      (2, WireType::LengthDelimited) => {
        if let Ok(s) = decode_string(&mut cursor) {
          session_id = s;
        }
      }
      _ => {
        if skip_field(wire_type, &mut cursor).is_err() {
          break;
        }
      }
    }
  }

  (team_member_id, session_id)
}

/// Generic helper: extract two bool fields by field number from raw protobuf bytes.
fn extract_bool_fields(bytes: &[u8], field_a: u32, field_b: u32) -> (bool, bool) {
  let mut a = false;
  let mut b = false;
  let mut cursor = bytes;

  while !cursor.is_empty() {
    let Ok((tag, wire_type)) = encoding::decode_key(&mut cursor) else {
      break;
    };

    if tag == field_a && wire_type == WireType::Varint {
      if let Ok(val) = encoding::decode_varint(&mut cursor) {
        a = val != 0;
      }
    } else if tag == field_b && wire_type == WireType::Varint {
      if let Ok(val) = encoding::decode_varint(&mut cursor) {
        b = val != 0;
      }
    } else if skip_field(wire_type, &mut cursor).is_err() {
      break;
    }
  }

  (a, b)
}

/// Decode a length-delimited string from a protobuf byte stream.
fn decode_string(buf: &mut &[u8]) -> Result<String> {
  let len = encoding::decode_varint(buf)? as usize;
  if buf.len() < len {
    return Err(anyhow::anyhow!("buffer underflow"));
  }
  let s = String::from_utf8_lossy(&buf[..len]).into_owned();
  *buf = &buf[len..];
  Ok(s)
}

/// Skip a protobuf field value based on wire type.
fn skip_field(wire_type: WireType, buf: &mut &[u8]) -> Result<()> {
  match wire_type {
    WireType::Varint => {
      encoding::decode_varint(buf)?;
    }
    WireType::SixtyFourBit => {
      if buf.len() < 8 {
        return Err(anyhow::anyhow!("buffer underflow"));
      }
      *buf = &buf[8..];
    }
    WireType::LengthDelimited => {
      let len = encoding::decode_varint(buf)? as usize;
      if buf.len() < len {
        return Err(anyhow::anyhow!("buffer underflow"));
      }
      *buf = &buf[len..];
    }
    WireType::ThirtyTwoBit => {
      if buf.len() < 4 {
        return Err(anyhow::anyhow!("buffer underflow"));
      }
      *buf = &buf[4..];
    }
    _ => {
      return Err(anyhow::anyhow!("unsupported wire type"));
    }
  }
  Ok(())
}
