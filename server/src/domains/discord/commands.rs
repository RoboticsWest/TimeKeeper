use chrono::Utc;
use serenity::all::{Context, CreateEmbed, CreateMessage, Message};

use crate::domains::team_member::TeamMember;
use crate::time::{format_datetime, parse_tz};

use super::deps::DiscordDeps;
use super::embeds;

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
    "ping" => Some(embeds::success("Pong!", "The bot is alive.")),
    "help" => Some(embeds::help()),
    "leaderboard" => Some(leaderboard(args, deps).await),
    "sessions" => Some(sessions(deps).await),
    "checkedin" => Some(checked_in(deps).await),
    "locations" => Some(locations(deps).await),
    "link" => Some(link_member(msg, args, deps).await),
    "checkout" => Some(checkout(msg, deps).await),
    _ => None,
  };

  if let Some(embed) = response
    && let Err(e) = msg.channel_id.send_message(&ctx.http, CreateMessage::new().embed(embed)).await
  {
    log::error!("Failed to send Discord message: {e}");
  }
}

fn format_secs(secs: f64) -> String {
  #[allow(clippy::cast_possible_truncation)]
  let total_mins = (secs / 60.0).round() as i64;
  let hours = total_mins / 60;
  let mins = total_mins % 60;
  format!("{hours}h {mins}m")
}

async fn leaderboard(args: &str, deps: &DiscordDeps) -> CreateEmbed {
  let arg = args.trim();

  if arg.eq_ignore_ascii_case("help") {
    return embeds::leaderboard_help();
  }

  let (member_type_filter, subtitle) = match arg {
    "" => (None, "All members"),
    a if a.eq_ignore_ascii_case("students") || a.eq_ignore_ascii_case("student") => (Some("student"), "Students"),
    a if a.eq_ignore_ascii_case("mentors") || a.eq_ignore_ascii_case("mentor") => (Some("mentor"), "Mentors"),
    other => {
      return embeds::warning(
        "Unknown filter",
        &format!("`{other}` is not a leaderboard filter. Try `!leaderboard help`."),
      );
    }
  };

  let entries = match deps.statistics.get_leaderboard().await {
    Ok(e) => e,
    Err(e) => return embeds::error(&format!("Error computing leaderboard: {e}")),
  };

  let rows: Vec<embeds::LeaderboardRow> = entries
    .into_iter()
    .filter(|e| member_type_filter.is_none_or(|t| e.team_member.member_type == t))
    .take(15)
    .map(|entry| embeds::LeaderboardRow {
      name: member_name(&entry.team_member).to_string(),
      all_time: format_secs(entry.all_time.regular_secs + entry.all_time.overtime_secs),
      this_week: format_secs(entry.this_week.regular_secs + entry.this_week.overtime_secs),
    })
    .collect();

  if rows.is_empty() {
    return embeds::info("Leaderboard", "No attendance data yet.");
  }

  embeds::leaderboard(&rows, subtitle)
}

async fn sessions(deps: &DiscordDeps) -> CreateEmbed {
  let sessions = match deps.sessions.get_all().await {
    Ok(s) => s,
    Err(e) => return embeds::error(&format!("Error loading sessions: {e}")),
  };
  let locations = match deps.locations.get_all().await {
    Ok(l) => l,
    Err(e) => return embeds::error(&format!("Error loading locations: {e}")),
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
    return embeds::info("Sessions", "No active or upcoming sessions.");
  }

  upcoming.sort_by_key(|(start, _, _)| *start);

  let row = |(start, end, loc): &(i64, i64, String)| embeds::SessionRow {
    location: loc.clone(),
    when: format!("<t:{start}:F> \u{2013} <t:{end}:t>"),
  };

  let active_rows: Vec<_> = active.iter().map(row).collect();
  let upcoming_rows: Vec<_> = upcoming.iter().take(5).map(row).collect();

  embeds::sessions(&active_rows, &upcoming_rows)
}

async fn checked_in(deps: &DiscordDeps) -> CreateEmbed {
  let sessions = match deps.sessions.get_all().await {
    Ok(s) => s,
    Err(e) => return embeds::error(&format!("Error loading sessions: {e}")),
  };
  let members = match deps.team_members.get_all().await {
    Ok(m) => m,
    Err(e) => return embeds::error(&format!("Error loading team members: {e}")),
  };
  let member_sessions = match deps.team_member_sessions.get_all().await {
    Ok(ms) => ms,
    Err(e) => return embeds::error(&format!("Error loading attendance: {e}")),
  };

  let active_session_ids: Vec<_> = sessions.iter().filter(|s| !s.finished).map(|s| s.id).collect();
  if active_session_ids.is_empty() {
    return embeds::info("Checked in", "No active session right now.");
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
    return embeds::info("Checked in", "No one is currently checked in.");
  }

  checked_in_names.sort();
  embeds::checked_in(&checked_in_names)
}

async fn locations(deps: &DiscordDeps) -> CreateEmbed {
  let locations = match deps.locations.get_all().await {
    Ok(l) => l,
    Err(e) => return embeds::error(&format!("Error loading locations: {e}")),
  };

  if locations.is_empty() {
    return embeds::info("Locations", "No locations configured.");
  }

  let mut names: Vec<String> = locations.iter().map(|l| l.location.clone()).collect();
  names.sort_unstable();

  embeds::locations(&names)
}

async fn link_member(msg: &Message, args: &str, deps: &DiscordDeps) -> CreateEmbed {
  let settings = match deps.settings.get().await {
    Ok(s) => s,
    Err(e) => return embeds::error(&format!("Error loading settings: {e}")),
  };

  if !settings.discord_self_link_enabled {
    return embeds::warning("Self-linking is off", "Ask an admin to enable it in settings.");
  }

  let search_text = args.trim();
  if search_text.is_empty() {
    return embeds::info("Link your account", "Usage: `!link Name` — for example `!link John Smith`.");
  }

  let discord_id = msg.author.id.to_string();

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
    return embeds::warning("No match", &format!("No team member found matching `{search_text}`."));
  };

  let name = member_name(&member).to_string();

  if member.discord_id.as_ref().is_some_and(|id| !id.is_empty()) {
    return embeds::warning("Already linked", &format!("**{name}** is already linked to a Discord account."));
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
      Some(&discord_id),
      member.quick_pin.as_deref(),
    )
    .await
  {
    return embeds::error(&format!("Error linking account: {e}"));
  }

  // Store the ID, but show the humans a name they recognise.
  embeds::success("Account linked", &format!("**{name}** is now linked to **{}**.", msg.author.name))
}

async fn checkout(msg: &Message, deps: &DiscordDeps) -> CreateEmbed {
  let settings = match deps.settings.get().await {
    Ok(s) => s,
    Err(e) => return embeds::error(&format!("Error loading settings: {e}")),
  };

  let tz = parse_tz(&settings.timezone);

  if !settings.discord_checkout_enabled {
    return embeds::warning("Checkout is off", "Contact an admin to enable Discord checkout in settings.");
  }

  // Indexed lookup on the snowflake, rather than scanning every member.
  let found = match deps.team_members.get_by_discord_id(&msg.author.id.to_string()).await {
    Ok(m) => m,
    Err(e) => return embeds::error(&format!("Error loading team members: {e}")),
  };

  let Some(member) = found else {
    return embeds::warning(
      "Not linked",
      if settings.discord_self_link_enabled {
        "Your Discord account is not linked to a team member. Use `!link Name` to link it."
      } else {
        "Your Discord account is not linked to a team member. Ask an admin to link it."
      },
    );
  };

  let name = member_name(&member).to_string();

  let member_sessions = match deps.team_member_sessions.get_by_member_id(member.id).await {
    Ok(ms) => ms,
    Err(e) => return embeds::error(&format!("Error loading attendance: {e}")),
  };

  let active = member_sessions.into_iter().find(|ms| ms.check_out_time.is_none());

  let Some(ms) = active else {
    return embeds::warning("Not checked in", &format!("**{name}** is not currently checked in."));
  };

  let session = match deps.sessions.get(ms.session_id).await {
    Ok(Some(s)) => s,
    Ok(None) => return embeds::error("Session not found."),
    Err(e) => return embeds::error(&format!("Error loading session: {e}")),
  };

  let now = Utc::now();
  let (checkout_time, late) = if now > session.end_time { (session.end_time, true) } else { (now, false) };

  if let Err(e) = deps
    .team_member_sessions
    .update(ms.id, ms.team_member_id, ms.session_id, ms.check_in_time, Some(checkout_time))
    .await
  {
    return embeds::error(&format!("Error checking out: {e}"));
  }

  if late {
    embeds::success(
      "Checked out",
      &format!(
        "**{name}** was checked out at the session's end time ({}), since the session had already ended.",
        format_datetime(session.end_time.timestamp(), tz)
      ),
    )
  } else {
    embeds::success(
      "Checked out",
      &format!("**{name}** was checked out at {}.", format_datetime(checkout_time.timestamp(), tz)),
    )
  }
}
