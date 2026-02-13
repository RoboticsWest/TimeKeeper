use std::sync::OnceLock;
use std::time::Duration;

use serenity::async_trait;
use serenity::model::channel::Message;
use serenity::model::gateway::Ready;
use serenity::model::id::UserId;
use serenity::prelude::*;

use crate::{
  core::{events::EVENT_BUS, shutdown::ShutdownNotifier},
  generated::db::Settings,
  modules::settings::SettingsRepository,
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

  async fn ready(&self, _ctx: Context, ready: Ready) {
    BOT_USER_ID.set(ready.user.id).ok();
    log::info!("Discord bot connected as {}", ready.user.name);
  }
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
    let intents = GatewayIntents::GUILD_MESSAGES | GatewayIntents::MESSAGE_CONTENT;

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
      Ok(settings) if !settings.discord_bot_token.is_empty() => settings.discord_bot_token,
      Ok(_) => {
        log::info!("Discord bot token not configured, waiting for settings update...");

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
