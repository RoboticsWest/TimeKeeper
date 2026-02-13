use std::sync::OnceLock;
use std::time::Duration;

use serenity::async_trait;
use serenity::model::channel::Message;
use serenity::model::gateway::Ready;
use serenity::model::id::UserId;
use serenity::prelude::*;

use crate::{core::shutdown::ShutdownNotifier, generated::db::Settings, modules::settings::SettingsRepository};

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

/// Starts the Discord bot using the token from settings.
/// Returns early if no token is configured.
/// Automatically reconnects on disconnect until a shutdown signal is received.
pub async fn start_discord_bot() {
  let token = match Settings::get() {
    Ok(settings) if !settings.discord_bot_token.is_empty() => settings.discord_bot_token,
    Ok(_) => {
      log::warn!("Discord bot token not configured, skipping bot startup");
      return;
    }
    Err(e) => {
      log::error!("Failed to read settings for Discord bot: {e}");
      return;
    }
  };

  let mut shutdown_rx = ShutdownNotifier::get().subscribe();

  loop {
    let intents = GatewayIntents::GUILD_MESSAGES | GatewayIntents::MESSAGE_CONTENT;

    let mut client = match Client::builder(&token, intents).event_handler(Handler).await {
      Ok(client) => client,
      Err(e) => {
        log::error!("Failed to create Discord client: {e}");
        return;
      }
    };

    let shard_manager = client.shard_manager.clone();
    let mut shutdown_for_shard = ShutdownNotifier::get().subscribe();

    tokio::spawn(async move {
      let _ = shutdown_for_shard.recv().await;
      shard_manager.shutdown_all().await;
    });

    if let Err(e) = client.start().await {
      log::error!("Discord bot error: {e}");
    }

    // Check if we should reconnect or shut down
    if let Err(tokio::sync::broadcast::error::TryRecvError::Empty) = shutdown_rx.try_recv() {
      log::warn!("Discord bot disconnected, reconnecting in {}s...", RECONNECT_DELAY.as_secs());
      tokio::time::sleep(RECONNECT_DELAY).await;
    } else {
      log::info!("Discord bot shutting down");
      return;
    }
  }
}
