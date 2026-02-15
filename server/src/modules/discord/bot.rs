use std::sync::OnceLock;
use std::time::Duration;

use serenity::async_trait;
use serenity::model::channel::{Message, Reaction, ReactionType};
use serenity::model::gateway::Ready;
use serenity::model::id::UserId;
use serenity::prelude::*;

use crate::{
  core::{events::EVENT_BUS, shutdown::ShutdownNotifier},
  generated::db::{RsvpStatus, SessionRsvpMessage, Settings, TeamMember},
  modules::{
    session_rsvp::{SessionRsvpMessageRepository, SessionRsvpRepository},
    settings::SettingsRepository,
    team_member::TeamMemberRepository,
  },
};

use super::commands;

const RECONNECT_DELAY: Duration = Duration::from_secs(5);

static BOT_USER_ID: OnceLock<UserId> = OnceLock::new();

struct Handler;

#[async_trait]
impl EventHandler for Handler {
  async fn message(&self, ctx: Context, msg: Message) {
    if msg.author.bot {
      return;
    }

    // Easter egg: respond when the bot is pinged
    if let Some(&bot_id) = BOT_USER_ID.get()
      && msg.mentions.iter().any(|u| u.id == bot_id)
    {
      let _ = msg.channel_id.say(&ctx.http, "Sup? Use `!help` to see what I can do.").await;
      return;
    }

    commands::handle_command(&ctx, &msg).await;
  }

  async fn reaction_add(&self, ctx: Context, reaction: Reaction) {
    log::info!("Reaction add event: {:?}", reaction.user_id);

    let Some(user_id) = reaction.user_id else {
      log::warn!("Reaction had no user_id");
      return;
    };

    if Some(user_id) == BOT_USER_ID.get().copied() {
      log::info!("Ignoring bot reaction");
      return;
    }

    let Some(user_id) = reaction.user_id else {
      return;
    };

    if Some(user_id) == BOT_USER_ID.get().copied() {
      return;
    }

    if !Settings::get().is_ok_and(|s| s.discord_rsvp_reactions_enabled) {
      return;
    }

    let Some(status) = reaction_to_rsvp_status(&reaction.emoji) else { return };
    let message_id = reaction.message_id.to_string();

    let Ok(Some(rsvp_msg)) = SessionRsvpMessage::get_by_message_id(&message_id) else { return };

    let Some(member_id) = resolve_team_member_id(&ctx, &reaction).await else { return };

    if let Err(e) = crate::generated::db::SessionRsvp::upsert(&rsvp_msg.session_id, &member_id, status as i32) {
      log::error!("Failed to upsert RSVP: {e}");
    }
  }

  async fn reaction_remove(&self, ctx: Context, reaction: Reaction) {
    log::info!("Reaction remove event: {:?}", reaction.user_id);

    let Some(user_id) = reaction.user_id else {
      log::warn!("Reaction had no user_id");
      return;
    };

    if Some(user_id) == BOT_USER_ID.get().copied() {
      log::info!("Ignoring bot reaction");
      return;
    }

    let Some(user_id) = reaction.user_id else {
      return;
    };

    if Some(user_id) == BOT_USER_ID.get().copied() {
      return;
    }

    if !Settings::get().is_ok_and(|s| s.discord_rsvp_reactions_enabled) {
      return;
    }

    let message_id = reaction.message_id.to_string();

    let Ok(Some(rsvp_msg)) = SessionRsvpMessage::get_by_message_id(&message_id) else { return };

    // Only handle our RSVP emojis
    if reaction_to_rsvp_status(&reaction.emoji).is_none() {
      return;
    }

    let Some(member_id) = resolve_team_member_id(&ctx, &reaction).await else { return };

    if let Err(e) = crate::generated::db::SessionRsvp::remove_by_session_and_member(&rsvp_msg.session_id, &member_id) {
      log::error!("Failed to remove RSVP: {e}");
    }
  }

  async fn ready(&self, _ctx: Context, ready: Ready) {
    BOT_USER_ID.set(ready.user.id).ok();
    log::info!("Discord bot connected as {}", ready.user.name);
  }
}

fn reaction_to_rsvp_status(emoji: &ReactionType) -> Option<RsvpStatus> {
  match emoji {
    ReactionType::Unicode(s) if s == "👍" => Some(RsvpStatus::Going),
    ReactionType::Unicode(s) if s == "👎" => Some(RsvpStatus::NotGoing),
    _ => None,
  }
}

async fn resolve_team_member_id(ctx: &Context, reaction: &Reaction) -> Option<String> {
  let user_id = reaction.user_id?;

  // Fetch the user from Discord to get their username
  let user = user_id.to_user(&ctx.http).await.ok()?;
  let username = user.name;

  // Find the team member linked to this Discord username
  let members = TeamMember::get_all().ok()?;
  let (member_id, _) =
    members.into_iter().find(|(_, m)| m.discord_username.as_ref().is_some_and(|u| u == &username))?;

  Some(member_id)
}

/// Runs the Discord bot connection loop with a specific token.
/// Returns when the bot is intentionally shut down (via shutdown signal or token change event).
/// Returns `true` if a settings change triggered the return (caller should re-evaluate token),
/// or `false` if it was a shutdown signal.
async fn run_bot(token: &str, shutdown: &'static ShutdownNotifier) -> bool {
  let mut shutdown_rx = shutdown.subscribe();
  let mut settings_rx =
    EVENT_BUS.get().and_then(|bus| bus.subscribe::<Settings>().ok()).expect("Event bus not initialized");

  loop {
    let intents =
      GatewayIntents::GUILD_MESSAGES | GatewayIntents::MESSAGE_CONTENT | GatewayIntents::GUILD_MESSAGE_REACTIONS;

    let mut client = match Client::builder(token, intents).event_handler(Handler).await {
      Ok(client) => client,
      Err(e) => {
        log::error!("Failed to create Discord client: {e}");
        return false;
      }
    };

    let shard_manager = client.shard_manager.clone();
    let mut shutdown_for_shard = shutdown.subscribe();
    let mut settings_for_shard =
      EVENT_BUS.get().and_then(|bus| bus.subscribe::<Settings>().ok()).expect("Event bus not initialized");

    // Shut down shards if we receive a shutdown signal or settings change
    tokio::spawn(async move {
      tokio::select! {
        _ = shutdown_for_shard.recv() => {}
        _ = settings_for_shard.recv() => {}
      }
      shard_manager.shutdown_all().await;
    });

    if let Err(e) = client.start().await {
      log::error!("Discord bot error: {e}");
    }

    // Determine why we disconnected
    // Check settings change first (higher priority — we want to re-evaluate the token)
    if settings_rx.try_recv().is_ok() {
      log::info!("Discord bot restarting due to settings change");
      return true;
    }

    if let Err(tokio::sync::broadcast::error::TryRecvError::Empty) = shutdown_rx.try_recv() {
      // Neither settings nor shutdown — unexpected disconnect, reconnect
      log::warn!("Discord bot disconnected, reconnecting in {}s...", RECONNECT_DELAY.as_secs());
      tokio::time::sleep(RECONNECT_DELAY).await;
    } else {
      log::info!("Discord bot shutting down");
      return false;
    }
  }
}

/// Long-lived task that manages the Discord bot lifecycle.
/// Reacts to settings changes via the event bus — starts, stops, or restarts
/// the bot as the token is added, removed, or changed.
pub async fn discord_bot_service(shutdown: &'static ShutdownNotifier) {
  let mut shutdown_rx = shutdown.subscribe();

  loop {
    // Read current token
    let token = match Settings::get() {
      Ok(settings) if settings.discord_enabled && !settings.discord_bot_token.is_empty() => settings.discord_bot_token,
      Ok(_) => {
        log::info!("Discord bot not enabled or token not configured, waiting for settings update...");

        // Wait for either a settings change or shutdown
        let mut settings_rx =
          EVENT_BUS.get().and_then(|bus| bus.subscribe::<Settings>().ok()).expect("Event bus not initialized");

        tokio::select! {
          _ = settings_rx.recv() => {
            log::info!("Settings changed, re-checking Discord bot token...");
            continue;
          }
          _ = shutdown_rx.recv() => {
            log::info!("Discord bot service shutting down (no token was configured)");
            return;
          }
        }
      }
      Err(e) => {
        log::error!("Failed to read settings for Discord bot: {e}");
        return;
      }
    };

    // Run the bot — returns true if settings changed, false if shutting down
    if !run_bot(&token, shutdown).await {
      return;
    }
  }
}
