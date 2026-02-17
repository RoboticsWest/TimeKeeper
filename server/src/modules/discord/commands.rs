use chrono::Utc;
use serenity::model::channel::Message;
use serenity::prelude::*;

use crate::core::time::{format_datetime, parse_tz};
use crate::{
  generated::{
    common::Timestamp,
    db::{Location, Session, Settings, TeamMember, TeamMemberSession, TeamMemberType},
  },
  modules::{
    location::LocationRepository,
    session::{SessionRepository, helpers::is_member_checked_in},
    settings::SettingsRepository,
    statistics::leaderboard::{LeaderboardConfig, compute_leaderboard},
    team_member::TeamMemberRepository,
    team_member_session::TeamMemberSessionRepository,
  },
};

const PREFIX: &str = "!";

/// Returns the display name for a team member.
/// The repository guarantees display_name is populated on fetch.
fn member_name(member: &TeamMember) -> &str {
  member.display_name.as_deref().unwrap_or("Unknown")
}

pub async fn handle_command(ctx: &Context, msg: &Message) {
  let Some(command) = msg.content.strip_prefix(PREFIX) else {
    return;
  };

  let parts: Vec<&str> = command.trim().splitn(2, ' ').collect();
  let cmd = parts[0].to_lowercase();
  let args = parts.get(1).unwrap_or(&"").trim();

  let response = match cmd.as_str() {
    "ping" => Some("Pong!".to_string()),
    "help" => Some(help()),
    "leaderboard" => Some(leaderboard(args)),
    "sessions" => Some(sessions()),
    "checkedin" => Some(checked_in()),
    "locations" => Some(locations()),
    "link" => Some(link_member(msg, args)),
    "checkout" => Some(checkout(msg)),
    _ => None,
  };

  if let Some(text) = response
    && let Err(e) = msg.channel_id.say(&ctx.http, &text).await
  {
    log::error!("Failed to send Discord message: {e}");
  }
}

fn help() -> String {
  [
    "**TimeKeeper Bot Commands**",
    "`!ping` - Check if the bot is alive",
    "`!leaderboard` - Show the hours leaderboard, use `!leaderboard help` for options",
    "`!sessions` - Show active and upcoming sessions",
    "`!checkedin` - Show who is currently checked in",
    "`!locations` - List all locations",
    "`!link Name` - Link your Discord account to a team member",
    "`!checkout` - Check yourself out of the current session",
    "`!help` - Show this help message",
  ]
  .join("\n")
}

fn format_secs(secs: f64) -> String {
  #[allow(clippy::cast_possible_truncation)]
  let total_mins = (secs / 60.0).round() as i64;
  let hours = total_mins / 60;
  let mins = total_mins % 60;
  format!("{hours}h {mins}m")
}

fn leaderboard(args: &str) -> String {
  let arg = args.trim();

  if arg.eq_ignore_ascii_case("help") {
    let mut lines = vec![
      "**Leaderboard Options**".to_string(),
      "`!leaderboard` \u{2014} Show leaderboard (default filter from settings)".to_string(),
    ];
    for i in 0.. {
      let Ok(t) = TeamMemberType::try_from(i) else { break };
      let name = t.as_str_name().to_lowercase();
      lines.push(format!("`!leaderboard {name}s` \u{2014} Show only {name}s"));
    }
    return lines.join("\n");
  }

  let settings = match Settings::get() {
    Ok(s) => s,
    Err(e) => return format!("Error loading settings: {e}"),
  };

  let mut config = LeaderboardConfig {
    show_overtime: settings.leaderboard_show_overtime,
    member_types: settings.leaderboard_member_types,
  };

  if !arg.is_empty() {
    // Normalize: uppercase, strip trailing 'S' for plural ("MENTORS" → "MENTOR")
    let mut normalized = arg.to_uppercase();
    if normalized.ends_with('S') {
      normalized.pop();
    }
    match TeamMemberType::from_str_name(&normalized) {
      Some(t) => config.member_types = vec![t as i32],
      None => return format!("Unknown filter \"{arg}\". Use `!leaderboard help` for options."),
    }
  }

  let entries = match compute_leaderboard(&config) {
    Ok(e) => e,
    Err(e) => return format!("Error computing leaderboard: {e}"),
  };

  if entries.is_empty() {
    return "No attendance data yet.".to_string();
  }

  let mut lines = vec!["**Leaderboard**".to_string()];
  for (i, entry) in entries.iter().enumerate().take(15) {
    let name = entry.team_member.as_ref().map_or("Unknown", |m| m.display_name.as_deref().unwrap_or("Unknown"));
    let all_time = entry.all_time.as_ref().map_or(0.0, |b| b.regular_secs + b.overtime_secs);
    let this_week = entry.this_week.as_ref().map_or(0.0, |b| b.regular_secs + b.overtime_secs);

    let medal = match i {
      0 => "\u{1f947} ",
      1 => "\u{1f948} ",
      2 => "\u{1f949} ",
      _ => "",
    };
    lines.push(format!(
      "{medal}**{}.** {name} - {} (this week: {})",
      i + 1,
      format_secs(all_time),
      format_secs(this_week),
    ));
  }

  lines.join("\n")
}

pub fn sessions() -> String {
  // Load settings (no longer need timezone parsing)
  if let Err(e) = Settings::get() {
    return format!("Error loading settings: {e}");
  }

  // Load sessions
  let sessions = match Session::get_all() {
    Ok(s) => s,
    Err(e) => return format!("Error loading sessions: {e}"),
  };

  // Load locations
  let locations_map = match Location::get_all() {
    Ok(l) => l,
    Err(e) => return format!("Error loading locations: {e}"),
  };

  let now_secs = Utc::now().timestamp();

  let mut active = Vec::new();
  let mut upcoming = Vec::new();

  // Categorize sessions
  for session in sessions.values() {
    let start = session.start_time.as_ref().map_or(0, |t| t.seconds);
    let end = session.end_time.as_ref().map_or(0, |t| t.seconds);

    let location = session
      .location_id
      .as_str()
      .pipe_ref(|lid| locations_map.get(*lid))
      .map_or("Unknown", |l| l.location.as_str())
      .to_string();

    if !session.finished && start <= now_secs {
      active.push((start, end, location));
    } else if start > now_secs {
      upcoming.push((start, end, location));
    }
  }

  if active.is_empty() && upcoming.is_empty() {
    return "No active or upcoming sessions.".to_string();
  }

  let mut lines = Vec::new();

  // -------------------------
  // Active Sessions
  // -------------------------
  if !active.is_empty() {
    lines.push("**Active Sessions**".to_string());

    for (start, end, loc) in &active {
      lines.push(format!("<t:{start}:F> – <t:{end}:t> @ **{loc}**"));
    }
  }

  // -------------------------
  // Upcoming Sessions
  // -------------------------
  if !upcoming.is_empty() {
    upcoming.sort_by_key(|(start, _, _)| *start);

    lines.push("**Upcoming Sessions**".to_string());

    for (start, end, loc) in upcoming.iter().take(5) {
      lines.push(format!("<t:{start}:F> – <t:{end}:t> @ **{loc}**"));
    }
  }

  lines.join("\n")
}

fn checked_in() -> String {
  let sessions = match Session::get_all() {
    Ok(s) => s,
    Err(e) => return format!("Error loading sessions: {e}"),
  };
  let members = match TeamMember::get_all() {
    Ok(m) => m,
    Err(e) => return format!("Error loading team members: {e}"),
  };
  let member_sessions = match TeamMemberSession::get_all() {
    Ok(ms) => ms,
    Err(e) => return format!("Error loading attendance: {e}"),
  };

  // Find active sessions (not finished)
  let active_session_ids: Vec<_> = sessions.iter().filter(|(_, s)| !s.finished).map(|(id, _)| id.clone()).collect();

  if active_session_ids.is_empty() {
    return "No active session right now.".to_string();
  }

  let mut checked_in_names: Vec<String> = Vec::new();

  for ms in member_sessions.values() {
    if !active_session_ids.contains(&ms.session_id) {
      continue;
    }
    // Checked in but not checked out
    if ms.check_in_time.is_some()
      && ms.check_out_time.is_none()
      && let Some(member) = members.get(&ms.team_member_id)
    {
      checked_in_names.push(member_name(member).to_string());
    }
  }

  if checked_in_names.is_empty() {
    return "No one is currently checked in.".to_string();
  }

  checked_in_names.sort();

  let mut lines = vec![format!("**Currently Checked In ({}):**", checked_in_names.len())];
  for name in &checked_in_names {
    lines.push(format!("- {name}"));
  }
  lines.join("\n")
}

fn locations() -> String {
  let locations_map = match Location::get_all() {
    Ok(l) => l,
    Err(e) => return format!("Error loading locations: {e}"),
  };

  if locations_map.is_empty() {
    return "No locations configured.".to_string();
  }

  let mut names: Vec<_> = locations_map.values().map(|l| l.location.as_str()).collect();
  names.sort_unstable();

  let mut lines = vec!["**Locations**".to_string()];
  for name in names {
    lines.push(format!("- {name}"));
  }
  lines.join("\n")
}

fn link_member(msg: &Message, args: &str) -> String {
  let settings = match Settings::get() {
    Ok(s) => s,
    Err(e) => return format!("Error loading settings: {e}"),
  };

  if !settings.discord_self_link_enabled {
    return "Self-linking is not enabled. Ask an admin to enable it in settings.".to_string();
  }

  let search_text = args.trim();
  if search_text.is_empty() {
    return "Usage: `!link Name` (e.g. `!link John Smith` or `!link DisplayName`)".to_string();
  }

  let discord_username = msg.author.name.clone();

  // Try matching by first+last name first
  let parts: Vec<&str> = search_text.split_whitespace().collect();
  let mut found: Option<(String, TeamMember)> = None;

  if parts.len() >= 2 {
    let first_name = parts[0];
    let last_name = parts[1..].join(" ");
    if let Ok(existing) = TeamMember::get_by_name(first_name, &last_name) {
      found = existing.into_iter().next();
    }
  }

  // Fallback: search by display_name
  if found.is_none()
    && let Ok(all) = TeamMember::get_all()
  {
    let search_lower = search_text.to_lowercase();
    found = all.into_iter().find(|(_, m)| m.display_name.as_ref().is_some_and(|dn| dn.to_lowercase() == search_lower));
  }

  let Some((id, member)) = found else {
    return format!("No team member found matching \"{search_text}\".");
  };

  let name = member_name(&member).to_string();

  if member.discord_username.as_ref().is_some_and(|u| !u.is_empty()) {
    return format!("{name} is already linked to a Discord account.");
  }

  let mut updated = member;
  updated.discord_username = Some(discord_username.clone());
  if let Err(e) = TeamMember::update(&id, &updated) {
    return format!("Error linking account: {e}");
  }

  format!("Linked **{name}** to Discord user **{discord_username}**.")
}

fn checkout(msg: &Message) -> String {
  let settings = match Settings::get() {
    Ok(s) => s,
    Err(e) => return format!("Error loading settings: {e}"),
  };

  let tz = parse_tz(&settings.timezone);

  if !settings.discord_checkout_enabled {
    return "Discord checkout is not enabled. Contact an admin to enable it in settings.".to_string();
  }

  let discord_username = &msg.author.name;

  // Find the team member linked to this Discord account
  let members = match TeamMember::get_all() {
    Ok(m) => m,
    Err(e) => return format!("Error loading team members: {e}"),
  };

  let found = members
    .into_iter()
    .find(|(_, m)| m.discord_username.as_ref().is_some_and(|u| u.eq_ignore_ascii_case(discord_username)));

  let Some((member_id, member)) = found else {
    return if settings.discord_self_link_enabled {
      "Your Discord account is not linked to a team member. Use `!link Name` to link it.".to_string()
    } else {
      "Your Discord account is not linked to a team member. Contact an admin to link your account.".to_string()
    };
  };

  let name = member_name(&member).to_string();

  // Find if they're checked into any session
  let member_sessions = match TeamMemberSession::get_by_member_id(&member_id) {
    Ok(ms) => ms,
    Err(e) => return format!("Error loading attendance: {e}"),
  };

  let active = member_sessions.into_iter().find(|(_, ms)| is_member_checked_in(ms));

  let Some((ms_id, mut ms)) = active else {
    return format!("{name} is not currently checked in.");
  };

  // Get the session to check end_time
  let session = match Session::get(&ms.session_id) {
    Ok(Some(s)) => s,
    Ok(None) => return "Error: session not found.".to_string(),
    Err(e) => return format!("Error loading session: {e}"),
  };

  let now_secs = Utc::now().timestamp();
  let end_secs = session.end_time.as_ref().map_or(now_secs, |t| t.seconds);

  // If past session end time, cap checkout to end_time; otherwise use now
  let (checkout_secs, late) = if now_secs > end_secs { (end_secs, true) } else { (now_secs, false) };

  ms.check_out_time = Some(Timestamp { seconds: checkout_secs, nanos: 0 });
  if let Err(e) = TeamMemberSession::update(&ms_id, &ms) {
    return format!("Error checking out: {e}");
  }

  if late {
    format!(
      "Checked out **{name}** at session end time ({}) since the session has already ended.",
      format_datetime(end_secs, tz)
    )
  } else {
    format!("Checked out **{name}** at {}.", format_datetime(checkout_secs, tz))
  }
}

/// Helper to allow method-chaining on references
trait PipeRef {
  fn pipe_ref<F, R>(&self, f: F) -> R
  where
    F: FnOnce(&Self) -> R;
}

impl<T> PipeRef for T {
  fn pipe_ref<F, R>(&self, f: F) -> R
  where
    F: FnOnce(&Self) -> R,
  {
    f(self)
  }
}
