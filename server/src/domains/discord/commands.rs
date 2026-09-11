use chrono::Utc;
use serenity::all::{Context, Message};

use crate::domains::team_member::TeamMember;
use crate::time::{format_datetime, parse_tz};

use super::deps::DiscordDeps;

const PREFIX: &str = "!";

fn member_name(member: &TeamMember) -> &str {
  member.display_name.as_deref().unwrap_or("Unknown")
}

pub async fn handle_command(ctx: &Context, msg: &Message, deps: &DiscordDeps) {
  let Some(command) = msg.content.strip_prefix(PREFIX) else {
    return;
  };

  let parts: Vec<&str> = command.trim().splitn(2, ' ').collect();
  let cmd = parts[0].to_lowercase();
  let args = parts.get(1).unwrap_or(&"").trim();

  let response = match cmd.as_str() {
    "ping" => Some("Pong!".to_string()),
    "help" => Some(help()),
    "leaderboard" => Some(leaderboard(args, deps).await),
    "sessions" => Some(sessions(deps).await),
    "checkedin" => Some(checked_in(deps).await),
    "locations" => Some(locations(deps).await),
    "link" => Some(link_member(msg, args, deps).await),
    "checkout" => Some(checkout(msg, deps).await),
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

async fn leaderboard(args: &str, deps: &DiscordDeps) -> String {
  let arg = args.trim();

  if arg.eq_ignore_ascii_case("help") {
    return [
      "**Leaderboard Options**",
      "`!leaderboard` — Show leaderboard (default filter from settings)",
      "`!leaderboard students` — Show only students",
      "`!leaderboard mentors` — Show only mentors",
    ]
    .join("\n");
  }

  let member_type_filter = match arg {
    "" => None,
    a if a.eq_ignore_ascii_case("students") || a.eq_ignore_ascii_case("student") => Some("student"),
    a if a.eq_ignore_ascii_case("mentors") || a.eq_ignore_ascii_case("mentor") => Some("mentor"),
    other => return format!("Unknown filter \"{other}\". Use `!leaderboard help` for options."),
  };

  let entries = match deps.statistics.get_leaderboard().await {
    Ok(e) => e,
    Err(e) => return format!("Error computing leaderboard: {e}"),
  };

  let entries: Vec<_> =
    entries.into_iter().filter(|e| member_type_filter.is_none_or(|t| e.team_member.member_type == t)).collect();

  if entries.is_empty() {
    return "No attendance data yet.".to_string();
  }

  let mut lines = vec!["**Leaderboard**".to_string()];
  for (i, entry) in entries.iter().enumerate().take(15) {
    let name = member_name(&entry.team_member);
    let all_time = entry.all_time.regular_secs + entry.all_time.overtime_secs;
    let this_week = entry.this_week.regular_secs + entry.this_week.overtime_secs;

    let medal = match i {
      0 => "🥇 ",
      1 => "🥈 ",
      2 => "🥉 ",
      _ => "",
    };
    lines.push(format!(
      "{medal}**{}.** {name} - {} (this week: {})",
      i + 1,
      format_secs(all_time),
      format_secs(this_week)
    ));
  }

  lines.join("\n")
}

async fn sessions(deps: &DiscordDeps) -> String {
  let sessions = match deps.sessions.get_all().await {
    Ok(s) => s,
    Err(e) => return format!("Error loading sessions: {e}"),
  };
  let locations = match deps.locations.get_all().await {
    Ok(l) => l,
    Err(e) => return format!("Error loading locations: {e}"),
  };

  let now_secs = Utc::now().timestamp();
  let mut active = Vec::new();
  let mut upcoming = Vec::new();

  for session in &sessions {
    let start = session.start_time.timestamp();
    let end = session.end_time.timestamp();
    let location =
      locations.iter().find(|l| l.id == session.location_id).map_or("Unknown", |l| l.location.as_str()).to_string();

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

  if !active.is_empty() {
    lines.push("**Active Sessions**".to_string());
    for (start, end, loc) in &active {
      lines.push(format!("<t:{start}:F> – <t:{end}:t> @ **{loc}**"));
    }
  }

  if !upcoming.is_empty() {
    upcoming.sort_by_key(|(start, _, _)| *start);
    lines.push("**Upcoming Sessions**".to_string());
    for (start, end, loc) in upcoming.iter().take(5) {
      lines.push(format!("<t:{start}:F> – <t:{end}:t> @ **{loc}**"));
    }
  }

  lines.join("\n")
}

async fn checked_in(deps: &DiscordDeps) -> String {
  let sessions = match deps.sessions.get_all().await {
    Ok(s) => s,
    Err(e) => return format!("Error loading sessions: {e}"),
  };
  let members = match deps.team_members.get_all().await {
    Ok(m) => m,
    Err(e) => return format!("Error loading team members: {e}"),
  };
  let member_sessions = match deps.team_member_sessions.get_all().await {
    Ok(ms) => ms,
    Err(e) => return format!("Error loading attendance: {e}"),
  };

  let active_session_ids: Vec<_> = sessions.iter().filter(|s| !s.finished).map(|s| s.id).collect();
  if active_session_ids.is_empty() {
    return "No active session right now.".to_string();
  }

  let mut checked_in_names: Vec<String> = Vec::new();
  for ms in &member_sessions {
    if !active_session_ids.contains(&ms.session_id) || ms.check_out_time.is_some() {
      continue;
    }
    if let Some(member) = members.iter().find(|m| m.id == ms.team_member_id) {
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

async fn locations(deps: &DiscordDeps) -> String {
  let locations = match deps.locations.get_all().await {
    Ok(l) => l,
    Err(e) => return format!("Error loading locations: {e}"),
  };

  if locations.is_empty() {
    return "No locations configured.".to_string();
  }

  let mut names: Vec<_> = locations.iter().map(|l| l.location.as_str()).collect();
  names.sort_unstable();

  let mut lines = vec!["**Locations**".to_string()];
  for name in names {
    lines.push(format!("- {name}"));
  }
  lines.join("\n")
}

async fn link_member(msg: &Message, args: &str, deps: &DiscordDeps) -> String {
  let settings = match deps.settings.get().await {
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

  let parts: Vec<&str> = search_text.split_whitespace().collect();
  let mut found: Option<TeamMember> = None;

  if parts.len() >= 2 {
    let first_name = parts[0];
    let last_name = parts[1..].join(" ");
    if let Ok(existing) = deps.team_members.get_by_name(first_name, &last_name).await {
      found = existing.into_iter().next();
    }
  }

  if found.is_none()
    && let Ok(all) = deps.team_members.get_all().await
  {
    let search_lower = search_text.to_lowercase();
    found = all.into_iter().find(|m| m.display_name.as_ref().is_some_and(|dn| dn.to_lowercase() == search_lower));
  }

  let Some(member) = found else {
    return format!("No team member found matching \"{search_text}\".");
  };

  let name = member_name(&member).to_string();

  if member.discord_username.as_ref().is_some_and(|u| !u.is_empty()) {
    return format!("{name} is already linked to a Discord account.");
  }

  if let Err(e) = deps
    .team_members
    .update(
      member.id,
      &member.first_name,
      &member.last_name,
      &member.member_type,
      member.display_name.as_deref(),
      member.mobile_number.as_deref(),
      Some(&discord_username),
    )
    .await
  {
    return format!("Error linking account: {e}");
  }

  format!("Linked **{name}** to Discord user **{discord_username}**.")
}

async fn checkout(msg: &Message, deps: &DiscordDeps) -> String {
  let settings = match deps.settings.get().await {
    Ok(s) => s,
    Err(e) => return format!("Error loading settings: {e}"),
  };

  let tz = parse_tz(&settings.timezone);

  if !settings.discord_checkout_enabled {
    return "Discord checkout is not enabled. Contact an admin to enable it in settings.".to_string();
  }

  let discord_username = &msg.author.name;

  let members = match deps.team_members.get_all().await {
    Ok(m) => m,
    Err(e) => return format!("Error loading team members: {e}"),
  };

  let found =
    members.into_iter().find(|m| m.discord_username.as_ref().is_some_and(|u| u.eq_ignore_ascii_case(discord_username)));

  let Some(member) = found else {
    return if settings.discord_self_link_enabled {
      "Your Discord account is not linked to a team member. Use `!link Name` to link it.".to_string()
    } else {
      "Your Discord account is not linked to a team member. Contact an admin to link your account.".to_string()
    };
  };

  let name = member_name(&member).to_string();

  let member_sessions = match deps.team_member_sessions.get_by_member_id(member.id).await {
    Ok(ms) => ms,
    Err(e) => return format!("Error loading attendance: {e}"),
  };

  let active = member_sessions.into_iter().find(|ms| ms.check_out_time.is_none());

  let Some(ms) = active else {
    return format!("{name} is not currently checked in.");
  };

  let session = match deps.sessions.get(ms.session_id).await {
    Ok(Some(s)) => s,
    Ok(None) => return "Error: session not found.".to_string(),
    Err(e) => return format!("Error loading session: {e}"),
  };

  let now = Utc::now();
  let (checkout_time, late) = if now > session.end_time { (session.end_time, true) } else { (now, false) };

  if let Err(e) = deps
    .team_member_sessions
    .update(ms.id, ms.team_member_id, ms.session_id, ms.check_in_time, Some(checkout_time))
    .await
  {
    return format!("Error checking out: {e}");
  }

  if late {
    format!(
      "Checked out **{name}** at session end time ({}) since the session has already ended.",
      format_datetime(session.end_time.timestamp(), tz)
    )
  } else {
    format!("Checked out **{name}** at {}.", format_datetime(checkout_time.timestamp(), tz))
  }
}
