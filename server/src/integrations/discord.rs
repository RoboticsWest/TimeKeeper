//! Discord gateway client - connecting and subscribing to events. Event handling and command
//! logic live in `domains::discord`; the lifecycle loop that decides when to connect lives in
//! `domains::discord::service`.

use std::sync::OnceLock;
use std::time::Duration;

use serenity::all::{Client, Context, EventHandler, GatewayIntents, Interaction, Message, Reaction, Ready, UserId};
use serenity::async_trait;
use tokio_util::sync::CancellationToken;

use crate::domains::discord::{DiscordDeps, listener};
use crate::events::EVENT_BUS;

const RECONNECT_DELAY: Duration = Duration::from_secs(5);

struct Handler {
  deps: DiscordDeps,
  bot_user_id: OnceLock<UserId>,
}

#[async_trait]
impl EventHandler for Handler {
  async fn message(&self, ctx: Context, msg: Message) {
    listener::on_message(&ctx, &msg, &self.deps, self.bot_user_id.get().copied()).await;
  }

  /// Button clicks. No extra gateway intent is needed for components — Discord delivers an
  /// interaction to the application it belongs to regardless of what the bot subscribes to.
  async fn interaction_create(&self, ctx: Context, interaction: Interaction) {
    if let Interaction::Component(component) = interaction {
      listener::on_component(&ctx, &component, &self.deps).await;
    }
  }

  async fn reaction_add(&self, _ctx: Context, reaction: Reaction) {
    listener::on_reaction_add(&reaction, &self.deps, self.bot_user_id.get().copied()).await;
  }

  async fn reaction_remove(&self, _ctx: Context, reaction: Reaction) {
    listener::on_reaction_remove(&reaction, &self.deps, self.bot_user_id.get().copied()).await;
  }

  async fn ready(&self, _ctx: Context, ready: Ready) {
    let _ = self.bot_user_id.set(ready.user.id);
    log::info!("Discord bot connected as {}", ready.user.name);
  }
}

/// Connects to the Discord gateway with `token` and subscribes to message/reaction events,
/// forwarding them to `domains::discord::listener`. Runs until the connection drops, `cancel` is
/// triggered, or a settings change is observed. Returns `true` if a settings change triggered the
/// return (caller should re-evaluate the token), `false` if it was `cancel` or an unrecoverable
/// client error.
pub async fn connect(token: &str, deps: DiscordDeps, cancel: CancellationToken) -> bool {
  let Some(event_bus) = EVENT_BUS.get() else {
    log::error!("Event bus not initialized");
    return false;
  };

  let mut settings_rx = event_bus.subscribe("settings");

  loop {
    let intents =
      GatewayIntents::GUILD_MESSAGES | GatewayIntents::MESSAGE_CONTENT | GatewayIntents::GUILD_MESSAGE_REACTIONS;

    let handler = Handler { deps: deps.clone(), bot_user_id: OnceLock::new() };
    let mut client = match Client::builder(token, intents).event_handler(handler).await {
      Ok(client) => client,
      Err(e) => {
        log::error!("Failed to create Discord client: {e}");
        return false;
      }
    };

    let shard_manager = client.shard_manager.clone();
    let cancel_for_shard = cancel.clone();
    let mut settings_for_shard = event_bus.subscribe("settings");

    tokio::spawn(async move {
      tokio::select! {
        () = cancel_for_shard.cancelled() => {}
        _ = settings_for_shard.recv() => {}
      }
      shard_manager.shutdown_all().await;
    });

    if let Err(e) = client.start().await {
      log::error!("Discord bot error: {e}");
    }

    if settings_rx.try_recv().is_ok() {
      log::info!("Discord bot restarting due to settings change");
      return true;
    }

    if cancel.is_cancelled() {
      log::info!("Discord bot shutting down");
      return false;
    }

    log::warn!("Discord bot disconnected, reconnecting in {}s...", RECONNECT_DELAY.as_secs());
    tokio::time::sleep(RECONNECT_DELAY).await;
  }
}
