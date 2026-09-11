use tokio_util::sync::CancellationToken;

use crate::events::EVENT_BUS;
use crate::integrations::discord;

use super::deps::DiscordDeps;

/// Long-lived service loop that manages the Discord bot lifecycle: starts, stops, or restarts the
/// gateway connection as `discord_enabled`/`discord_bot_token` change in settings. The actual
/// gateway connection is owned by `integrations::discord` - this loop only decides *when* it
/// should be connected.
pub async fn run(deps: DiscordDeps, cancel: CancellationToken) {
  loop {
    let token = match deps.settings.get().await {
      Ok(settings) if settings.discord_enabled && !settings.discord_bot_token.is_empty() => settings.discord_bot_token,
      Ok(_) => {
        log::info!("Discord bot not enabled or token not configured, waiting for settings update...");

        let Some(event_bus) = EVENT_BUS.get() else { return };
        let mut settings_rx = event_bus.subscribe("settings");

        tokio::select! {
          _ = settings_rx.recv() => {
            log::info!("Settings changed, re-checking Discord bot token...");
            continue;
          }
          () = cancel.cancelled() => {
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

    if !discord::connect(&token, deps.clone(), cancel.clone()).await {
      return;
    }
  }
}
