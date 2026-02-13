use anyhow::{Ok, Result};
use log::LevelFilter;
use tracing_subscriber::{EnvFilter, fmt::format::FmtSpan, layer::SubscriberExt, util::SubscriberInitExt};

use log4rs::{
  Config,
  append::{
    console::ConsoleAppender,
    rolling_file::{
      RollingFileAppender,
      policy::compound::{CompoundPolicy, roll::fixed_window::FixedWindowRoller, trigger::size::SizeTrigger},
    },
  },
  config::{Appender, Logger, Root},
  encode::pattern::PatternEncoder,
  filter,
};

// d - Date and time
// l - Log level
// M - Module path
// L - Line number
// m - Message
// n - New line
// h - Highlight log level

fn create_config() -> Result<Config> {
  // log level filter
  #[cfg(debug_assertions)]
  let log_level = LevelFilter::Debug;
  #[cfg(not(debug_assertions))]
  let log_level = LevelFilter::Info;

  // logging to console
  let stdout_log_level = LevelFilter::Info; // always log info to console

  let stdout_appender = ConsoleAppender::builder()
    .encoder(Box::new(PatternEncoder::new("[{d(%Y-%m-%d %H:%M:%S)} {h({l})}] {h({m})}{n}")))
    .build();

  let size_trigger = SizeTrigger::new(1024 * 1024 * 10); // 10MB
  let roller = FixedWindowRoller::builder().base(0).build("logs/tms.{}.log", 10)?;

  let policy = CompoundPolicy::new(Box::new(size_trigger), Box::new(roller));

  // logging to file
  let rolling_appender = RollingFileAppender::builder()
    .encoder(Box::new(PatternEncoder::new("[{d(%Y-%m-%d %H:%M:%S)} {h({l})} {M} LINE: {L}] {h({m})}{n}")))
    .build("logs/tms.log", Box::new(policy))?;

  // Build configuration with filters
  let config = Config::builder()
    .appender(
      Appender::builder()
        .filter(Box::new(filter::threshold::ThresholdFilter::new(stdout_log_level)))
        .build("stdout_appender", Box::new(stdout_appender)),
    )
    .appender(Appender::builder().build("rolling_appender", Box::new(rolling_appender)))
    // Suppress noisy third-party loggers to warn-only
    .logger(Logger::builder().additive(false).appender("rolling_appender").build("serenity", LevelFilter::Warn))
    .logger(Logger::builder().additive(false).appender("rolling_appender").build("tungstenite", LevelFilter::Warn))
    .logger(Logger::builder().additive(false).appender("rolling_appender").build("rustls", LevelFilter::Warn))
    .logger(Logger::builder().additive(false).appender("rolling_appender").build("reqwest", LevelFilter::Warn))
    .logger(Logger::builder().additive(false).appender("rolling_appender").build("h2", LevelFilter::Warn))
    .logger(Logger::builder().additive(false).appender("rolling_appender").build("hyper_util", LevelFilter::Warn))
    // Root logger configuration
    .build(Root::builder().appender("stdout_appender").appender("rolling_appender").build(log_level))?;

  Ok(config)
}

pub fn init_logging() -> Result<()> {
  // Initialize log4rs first for our own application logging via the `log` crate
  let config = create_config()?;
  log4rs::init_config(config)?;

  // Initialize tracing subscriber to intercept tracing events (serenity, hyper, tonic, etc.)
  // and suppress their verbose logs. Only WARN+ from third-party tracing crates is shown.
  let tracing_filter = EnvFilter::new("warn");
  tracing_subscriber::registry()
    .with(tracing_filter)
    .with(tracing_subscriber::fmt::layer().with_span_events(FmtSpan::NONE).with_target(false).without_time())
    .try_init()
    .ok();

  Ok(())
}
