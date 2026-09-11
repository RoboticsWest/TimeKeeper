use std::sync::Arc;

use uuid::Uuid;

use crate::domains::settings::SettingsLogic;

use super::logic::{SessionRsvpLogic, SessionRsvpMessageLogic};

/// Reacts to a member adding an RSVP-emoji reaction on a tracked session announcement - the
/// caller (`domains::discord::listener`) has already resolved the Discord event into a team member id
/// and RSVP status; this owns the actual RSVP mutation.
pub async fn handle_reaction_add(
  settings: &Arc<dyn SettingsLogic>,
  session_rsvps: &Arc<dyn SessionRsvpLogic>,
  session_rsvp_messages: &Arc<dyn SessionRsvpMessageLogic>,
  discord_message_id: &str,
  team_member_id: Uuid,
  status: &str,
) {
  if !reactions_enabled(settings).await {
    return;
  }

  let Ok(Some(rsvp_msg)) = session_rsvp_messages.get_by_message_id(discord_message_id).await else { return };

  if let Err(e) = session_rsvps.upsert(rsvp_msg.session_id, team_member_id, status).await {
    log::error!("Failed to upsert RSVP: {e}");
  }
}

/// Reacts to a member removing an RSVP-emoji reaction - clears their RSVP for the session.
pub async fn handle_reaction_remove(
  settings: &Arc<dyn SettingsLogic>,
  session_rsvps: &Arc<dyn SessionRsvpLogic>,
  session_rsvp_messages: &Arc<dyn SessionRsvpMessageLogic>,
  discord_message_id: &str,
  team_member_id: Uuid,
) {
  if !reactions_enabled(settings).await {
    return;
  }

  let Ok(Some(rsvp_msg)) = session_rsvp_messages.get_by_message_id(discord_message_id).await else { return };

  if let Err(e) = session_rsvps.remove_by_session_and_member(rsvp_msg.session_id, team_member_id).await {
    log::error!("Failed to remove RSVP: {e}");
  }
}

async fn reactions_enabled(settings: &Arc<dyn SettingsLogic>) -> bool {
  match settings.get().await {
    Ok(s) => s.discord_rsvp_reactions_enabled,
    Err(e) => {
      log::error!("Failed to load settings for reaction handling: {e}");
      false
    }
  }
}
