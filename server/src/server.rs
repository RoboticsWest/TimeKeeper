use std::sync::Arc;
use std::time::Duration;

use anyhow::Result;
use tokio_util::sync::CancellationToken;

use crate::{
  api::{self, Api},
  auth::{
    jwt::init_jwt_secret,
    permissions_repository::{PermissionsRepository, PgPermissionsRepository},
  },
  config::ServerConfig,
  db,
  domains::{
    discord::{self, DiscordDeps},
    location::{DefaultLocationLogic, LocationLogic, LocationRepository, PgLocationRepository},
    notification::{
      DefaultNotificationLogic, DiscordNotificationService, NotificationLogic, NotificationRepository,
      PgNotificationRepository,
    },
    rfid_tag::{DefaultRfidTagLogic, PgRfidTagRepository, RfidTagLogic, RfidTagRepository},
    schedule::{DefaultScheduleLogic, ScheduleLogic},
    secret::{PgSecretRepository, SecretRepository},
    session::{DefaultSessionLogic, PgSessionRepository, SessionLogic, SessionRepository, SessionService},
    session_rsvp::{
      DefaultSessionRsvpLogic, DefaultSessionRsvpMessageLogic, PgSessionRsvpMessageRepository, PgSessionRsvpRepository,
      SessionRsvpLogic, SessionRsvpMessageLogic, SessionRsvpMessageRepository, SessionRsvpRepository,
    },
    settings::{DefaultSettingsLogic, PgLogoRepository, PgSettingsRepository, SettingsLogic, SettingsRepository},
    statistics::{
      AccoladesLogic, DefaultAccoladesLogic, DefaultMemberStatsLogic, DefaultStatisticsLogic, MemberStatsLogic,
      PgMemberStatsRepository, StatisticsLogic,
    },
    team_member::{DefaultTeamMemberLogic, PgTeamMemberRepository, TeamMemberLogic, TeamMemberRepository},
    team_member_session::{
      DefaultTeamMemberSessionLogic, PgTeamMemberSessionRepository, TeamMemberSessionLogic, TeamMemberSessionRepository,
    },
    user::{DefaultUserLogic, PgUserRepository, UserLogic, UserRepository},
  },
  events::{init_event_bus, listen_for_changes},
  scheduler,
  web::Web,
};

pub struct Server {
  config: ServerConfig,
}

impl Server {
  pub fn new(config: Option<ServerConfig>) -> Self {
    let config = config.unwrap_or_else(ServerConfig::parse_from_cli);
    Self { config }
  }

  pub async fn run(self) -> Result<()> {
    let config = self.config;
    log::info!("Running server with config: {config:?}");

    init_event_bus(1024)?;

    // Held for the process lifetime - if this is an embedded Postgres instance, dropping it
    // early would tear down the database out from under the pool. Stopped explicitly at the
    // bottom of this function during graceful shutdown.
    let app_db = db::init(&config).await?;
    let pool = app_db.pool.clone();

    // ── Repositories used cross-domain (raw, `Arc<dyn Trait>`) ──────────────────────────
    let secret_repo = PgSecretRepository::new(pool.clone());
    let user_repo: Arc<dyn UserRepository> = Arc::new(PgUserRepository::new(pool.clone()));
    let rfid_tag_repo: Arc<dyn RfidTagRepository> = Arc::new(PgRfidTagRepository::new(pool.clone()));
    let notification_repo: Arc<dyn NotificationRepository> = Arc::new(PgNotificationRepository::new(pool.clone()));
    let settings_repo: Arc<dyn SettingsRepository> = Arc::new(PgSettingsRepository::new(pool.clone()));
    let team_member_repo: Arc<dyn TeamMemberRepository> = Arc::new(PgTeamMemberRepository::new(pool.clone()));
    let session_repo: Arc<dyn SessionRepository> = Arc::new(PgSessionRepository::new(pool.clone()));
    let location_repo: Arc<dyn LocationRepository> = Arc::new(PgLocationRepository::new(pool.clone()));
    let team_member_session_repo: Arc<dyn TeamMemberSessionRepository> =
      Arc::new(PgTeamMemberSessionRepository::new(pool.clone()));
    let session_rsvp_repo: Arc<dyn SessionRsvpRepository> = Arc::new(PgSessionRsvpRepository::new(pool.clone()));
    let session_rsvp_message_repo: Arc<dyn SessionRsvpMessageRepository> =
      Arc::new(PgSessionRsvpMessageRepository::new(pool.clone()));
    let permissions_repo: Arc<dyn PermissionsRepository> = Arc::new(PgPermissionsRepository::new(pool.clone()));

    // ── JWT secret ───────────────────────────────────────────────────────────────────────
    let secret = secret_repo.get().await?;
    init_jwt_secret(secret.secret_bytes)?;

    // ── Admin user bootstrap ────────────────────────────────────────────────────────────
    let admin_id = match user_repo.get_by_username(db::DEFAULT_ADMIN_USERNAME).await? {
      None => {
        let password = config.admin_password.clone().unwrap_or_else(|| db::DEFAULT_ADMIN_PASSWORD.to_string());
        log::info!(
          "Creating Admin user with {} password",
          if config.admin_password.is_some() { "provided" } else { "default" }
        );
        user_repo.add(db::DEFAULT_ADMIN_USERNAME, &password).await?.id
      }
      Some(existing) => {
        if let Some(new_password) = &config.admin_password {
          log::info!("Updating Admin password to provided value");
          user_repo.update(existing.id, &existing.username, new_password).await?;
        }
        existing.id
      }
    };

    // Idempotent - safe to run on every startup, including against a pre-existing admin user
    // from before this role/resource model existed.
    let super_role_id = permissions_repo.ensure_role("admin", true).await?;
    permissions_repo.assign_role(admin_id, super_role_id).await?;

    // ── Domain logic ────────────────────────────────────────────────────────────────────
    let location_logic: Arc<dyn LocationLogic> =
      Arc::new(DefaultLocationLogic::new(PgLocationRepository::new(pool.clone())));
    let user_logic: Arc<dyn UserLogic> = Arc::new(DefaultUserLogic::new(PgUserRepository::new(pool.clone())));
    let rfid_tag_logic: Arc<dyn RfidTagLogic> =
      Arc::new(DefaultRfidTagLogic::new(PgRfidTagRepository::new(pool.clone())));
    let notification_logic: Arc<dyn NotificationLogic> =
      Arc::new(DefaultNotificationLogic::new(PgNotificationRepository::new(pool.clone())));
    let team_member_logic: Arc<dyn TeamMemberLogic> =
      Arc::new(DefaultTeamMemberLogic::new(PgTeamMemberRepository::new(pool.clone()), rfid_tag_repo.clone()));
    let team_member_session_logic: Arc<dyn TeamMemberSessionLogic> = Arc::new(DefaultTeamMemberSessionLogic::new(
      PgTeamMemberSessionRepository::new(pool.clone()),
      team_member_repo.clone(),
      session_repo.clone(),
      location_repo.clone(),
    ));
    // Recorded statistics. Constructed before the session logic because check-in, checkout and
    // auto-checkout all write through it.
    let member_stats_logic: Arc<dyn MemberStatsLogic> =
      Arc::new(DefaultMemberStatsLogic::new(PgMemberStatsRepository::new(pool.clone())));
    let session_logic: Arc<dyn SessionLogic> = Arc::new(DefaultSessionLogic::new(
      PgSessionRepository::new(pool.clone()),
      team_member_session_repo.clone(),
      notification_repo.clone(),
      settings_repo.clone(),
      member_stats_logic.clone(),
    ));
    let session_rsvp_logic: Arc<dyn SessionRsvpLogic> =
      Arc::new(DefaultSessionRsvpLogic::new(PgSessionRsvpRepository::new(pool.clone())));
    let session_rsvp_message_logic: Arc<dyn SessionRsvpMessageLogic> =
      Arc::new(DefaultSessionRsvpMessageLogic::new(PgSessionRsvpMessageRepository::new(pool.clone())));
    let statistics_logic: Arc<dyn StatisticsLogic> = Arc::new(DefaultStatisticsLogic::new(
      session_repo.clone(),
      team_member_repo.clone(),
      team_member_session_repo.clone(),
      settings_repo.clone(),
    ));
    let accolades_logic: Arc<dyn AccoladesLogic> = Arc::new(DefaultAccoladesLogic::new(
      session_repo.clone(),
      team_member_repo.clone(),
      team_member_session_repo.clone(),
      settings_repo.clone(),
      Arc::new(PgMemberStatsRepository::new(pool.clone())),
      statistics_logic.clone(),
    ));
    let schedule_logic: Arc<dyn ScheduleLogic> =
      Arc::new(DefaultScheduleLogic::new(location_repo.clone(), session_repo.clone()));
    let settings_logic: Arc<dyn SettingsLogic> = Arc::new(DefaultSettingsLogic::new(
      PgSettingsRepository::new(pool.clone()),
      PgLogoRepository::new(pool.clone()),
      notification_repo.clone(),
      team_member_session_repo.clone(),
      session_repo.clone(),
      team_member_repo.clone(),
      location_repo.clone(),
      user_repo.clone(),
      Arc::new(PgSecretRepository::new(pool.clone())),
      session_rsvp_repo.clone(),
      session_rsvp_message_repo.clone(),
      permissions_repo.clone(),
    ));

    // ── Shutdown coordination ───────────────────────────────────────────────────────────
    let cancel = CancellationToken::new();

    // ── Postgres NOTIFY listener (feeds every GraphQL subscription) ────────────────────
    let notify_cancel = cancel.clone();
    let notify_db_url = app_db.database_url.clone();
    let mut notify_handle = tokio::spawn(async move {
      if let Err(e) = listen_for_changes(&notify_db_url, notify_cancel).await {
        log::error!("Postgres NOTIFY listener error: {e}");
      }
    });

    // ── Scheduled background services ───────────────────────────────────────────────────
    let mut scheduler = scheduler::Pool::default();
    scheduler.add(SessionService::new(session_logic.clone()), cancel.clone());
    scheduler.add(
      DiscordNotificationService::new(
        settings_logic.clone(),
        session_logic.clone(),
        location_logic.clone(),
        notification_logic.clone(),
        team_member_logic.clone(),
        session_rsvp_message_logic.clone(),
        member_stats_logic.clone(),
      ),
      cancel.clone(),
    );

    // ── Discord bot (gateway connection + chat commands) ────────────────────────────────
    let discord_deps = DiscordDeps {
      team_members: team_member_logic.clone(),
      team_member_sessions: team_member_session_logic.clone(),
      sessions: session_logic.clone(),
      locations: location_logic.clone(),
      settings: settings_logic.clone(),
      statistics: statistics_logic.clone(),
      member_stats: member_stats_logic.clone(),
      accolades: accolades_logic.clone(),
      session_rsvps: session_rsvp_logic.clone(),
      session_rsvp_messages: session_rsvp_message_logic.clone(),
    };
    let discord_cancel = cancel.clone();
    let mut discord_handle = tokio::spawn(async move { discord::run(discord_deps, discord_cancel).await });

    // ── GraphQL API server (queries/mutations/subscriptions, merged per-domain) ────────
    let schema = api::build_schema(
      location_logic,
      user_logic,
      rfid_tag_logic,
      notification_logic.clone(),
      team_member_logic.clone(),
      team_member_session_logic.clone(),
      session_logic.clone(),
      session_rsvp_logic,
      statistics_logic,
      member_stats_logic,
      accolades_logic,
      schedule_logic,
      settings_logic,
      permissions_repo,
    );

    let graphql_addr: std::net::SocketAddr =
      format!("{}:{}", config.addr, config.graphql_port).parse().expect("Error parsing API address");
    let graphql_server = Api::new(graphql_addr, schema.clone());
    let api_cancel = cancel.clone();
    let mut graphql_handle = tokio::spawn(async move {
      if let Err(e) = graphql_server.serve(api_cancel).await {
        log::error!("API Server Error: {e:?}");
      }
    });

    // ── Web server (static Flutter build) ───────────────────────────────────────────────
    let mut web_handle = if config.no_web {
      None
    } else {
      let web_addr = format!("{}:{}", config.addr, config.web_port).parse().expect("Error parsing web address");
      let web_server = Web::new(web_addr, config.web_dir.clone(), schema.clone());
      let web_cancel = cancel.clone();
      Some(tokio::spawn(async move {
        if let Err(e) = web_server.serve(web_cancel).await {
          log::error!("Web Server Error: {e:?}");
        }
      }))
    };

    // ── Wait for shutdown signal ─────────────────────────────────────────────────────────
    tokio::signal::ctrl_c().await.expect("Failed to listen for shutdown signal");
    log::warn!("Received shutdown signal, beginning graceful shutdown...");
    cancel.cancel();

    let timeout_future = async {
      let api_result = (&mut graphql_handle).await;
      let web_result = match &mut web_handle {
        Some(handle) => handle.await,
        None => Ok(()),
      };
      let (discord_result, notify_result) = tokio::join!(&mut discord_handle, &mut notify_handle);
      api_result.and(web_result).and(discord_result).and(notify_result)
    };

    match tokio::time::timeout(Duration::from_secs(5), timeout_future).await {
      Ok(Ok(())) => log::info!("Request handlers shut down gracefully"),
      Ok(Err(e)) => log::error!("Service task panicked: {e:?}"),
      Err(_) => {
        log::warn!("Shutdown timeout - force aborting...");
        graphql_handle.abort();
        if let Some(handle) = &mut web_handle {
          handle.abort();
        }
        discord_handle.abort();
        notify_handle.abort();
      }
    }

    scheduler.wait().await;

    app_db.shutdown().await;

    log::info!("Server exited gracefully");
    Ok(())
  }
}
