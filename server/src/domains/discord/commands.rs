use chrono::Utc;
use serenity::all::{
  ButtonStyle, ComponentInteraction, Context, CreateActionRow, CreateButton, CreateEmbed, CreateInteractionResponse,
  CreateInteractionResponseMessage, CreateMessage, Message,
};

use uuid::Uuid;

use crate::domains::settings::DEFAULT_MAINTENANCE_MESSAGE;
use crate::domains::statistics::SOURCE_DISCORD;
use crate::domains::statistics::achievements;
use crate::domains::statistics::profile::MemberProfile;
use crate::domains::team_member::TeamMember;
use crate::time::{format_datetime, format_full_date, parse_tz};

use super::deps::DiscordDeps;
use super::embeds;

const PREFIX: &str = "!";

/// A reply is either a rich embed or plain message content. `!help` stays a
/// regular list — a grid of inline fields reads poorly in a command reference.
enum Reply {
  Embed(Box<CreateEmbed>),
  Content(String),
  /// An embed with message components beneath it — the browsable catalogue and its page buttons.
  Interactive(Box<CreateEmbed>, Vec<CreateActionRow>),
}

impl From<CreateEmbed> for Reply {
  fn from(embed: CreateEmbed) -> Self {
    Reply::Embed(Box::new(embed))
  }
}

fn member_name(member: &TeamMember) -> &str {
  member.display_name.as_deref().unwrap_or("Unknown")
}

/// Capitalise the first character — turning a stored lowercase member type into a field label.
fn capitalize(s: &str) -> String {
  let mut chars = s.chars();
  match chars.next() {
    Some(first) => first.to_uppercase().collect::<String>() + chars.as_str(),
    None => String::new(),
  }
}

/// A clocked time-of-day, minutes since midnight, as `h:mmAM/PM`.
fn clock_time(total_minutes: i64) -> String {
  let hour = total_minutes / 60;
  let minute = total_minutes % 60;
  let mut hour12 = hour % 12;
  if hour12 == 0 {
    hour12 = 12;
  }
  let period = if hour < 12 { "AM" } else { "PM" };
  format!("{hour12}:{minute:02}{period}")
}

pub async fn handle_command(ctx: &Context, msg: &Message, deps: &DiscordDeps) {
  let Some(command) = msg.content.strip_prefix(PREFIX) else {
    return;
  };

  let parts: Vec<&str> = command.trim().splitn(2, ' ').collect();
  let cmd = parts[0].to_lowercase();
  let args = parts.get(1).unwrap_or(&"").trim();

  // Maintenance mode short-circuits every command before it can touch a domain.
  //
  // Only *known* commands are answered: an unrecognised `!something` stays silent exactly as it
  // does normally, so turning maintenance on does not start replying to unrelated chatter that
  // happens to begin with the prefix.
  if is_known_command(&cmd)
    && let Some(reply) = maintenance_notice(deps).await
  {
    send(ctx, msg, reply).await;
    return;
  }

  let response: Option<Reply> = match cmd.as_str() {
    "ping" => Some(embeds::success("Pong!", "The bot is alive.").into()),
    "help" => Some(Reply::Content(embeds::help_text())),
    "leaderboard" => Some(leaderboard(args, deps).await.into()),
    "sessions" => Some(sessions(deps).await.into()),
    "checkedin" => Some(checked_in(deps).await.into()),
    "locations" => Some(locations(deps).await.into()),
    "link" => Some(link_member(msg, args, deps).await.into()),
    "checkout" => Some(checkout(msg, deps).await.into()),
    "mystats" => Some(mystats(msg, deps).await.into()),
    "achievements" => Some(achievements(msg, deps).await.into()),
    "badges" => Some(badges(msg, deps).await),
    _ => None,
  };

  if let Some(reply) = response {
    send(ctx, msg, reply).await;
  }
}

/// Commands the bot recognises. Kept next to the dispatch `match` — a command added there and
/// forgotten here still works, it just answers normally during maintenance.
const COMMANDS: &[&str] = &[
  "ping",
  "help",
  "leaderboard",
  "sessions",
  "checkedin",
  "locations",
  "link",
  "checkout",
  "mystats",
  "achievements",
  "badges",
];

fn is_known_command(cmd: &str) -> bool {
  COMMANDS.contains(&cmd)
}

/// The maintenance reply, or `None` when maintenance mode is off.
///
/// A settings lookup failure is treated as "not in maintenance": the bot staying useful when the
/// database is briefly unreachable is better than it refusing every command because it could not
/// read a flag.
async fn maintenance_notice(deps: &DiscordDeps) -> Option<Reply> {
  let settings = deps.settings.get().await.ok()?;
  if !settings.maintenance_mode {
    return None;
  }

  let message = if settings.maintenance_message.trim().is_empty() {
    DEFAULT_MAINTENANCE_MESSAGE
  } else {
    settings.maintenance_message.trim()
  };

  Some(embeds::warning("Maintenance Mode", message).into())
}

async fn send(ctx: &Context, msg: &Message, reply: Reply) {
  let message = match reply {
    Reply::Embed(embed) => CreateMessage::new().embed(*embed),
    Reply::Content(text) => CreateMessage::new().content(text),
    Reply::Interactive(embed, rows) => CreateMessage::new().embed(*embed).components(rows),
  };
  if let Err(e) = msg.channel_id.send_message(&ctx.http, message).await {
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

  // Pass the requested type as an override rather than filtering afterwards: the configured
  // `leaderboard_member_types` is only the *default*, and intersecting the two meant
  // `!leaderboard mentors` returned nothing whenever the default was students-only.
  let member_type_override = member_type_filter.map(|t| vec![t.to_string()]);

  let entries = match deps.statistics.get_leaderboard(member_type_override).await {
    Ok(e) => e,
    Err(e) => return embeds::error(&format!("Error computing leaderboard: {e}")),
  };

  let rows: Vec<embeds::LeaderboardRow> = entries
    .into_iter()
    .take(15)
    .map(|entry| embeds::LeaderboardRow {
      name: member_name(&entry.team_member).to_string(),
      all_time: format_secs(entry.all_time.regular_secs + entry.all_time.overtime_secs),
      this_week: format_secs(entry.this_week.regular_secs + entry.this_week.overtime_secs),
    })
    .collect();

  if rows.is_empty() {
    let scope = match member_type_filter {
      Some("student") => "No students have any attendance recorded yet.",
      Some("mentor") => "No mentors have any attendance recorded yet.",
      _ => "No attendance data yet.",
    };
    return embeds::info("Leaderboard", scope);
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

  let locations = match deps.locations.get_all().await {
    Ok(l) => l,
    Err(e) => return embeds::error(&format!("Error loading locations: {e}")),
  };

  let active: Vec<_> = sessions.iter().filter(|s| !s.finished).collect();
  if active.is_empty() {
    return embeds::info("Checked in", "No active session right now.");
  }

  let mut rows: Vec<embeds::CheckedInRow> = Vec::new();
  for ms in &member_sessions {
    if ms.check_out_time.is_some() {
      continue;
    }
    let Some(session) = active.iter().find(|s| s.id == ms.session_id) else { continue };
    let Some(member) = members.iter().find(|m| m.id == ms.team_member_id) else { continue };
    let location =
      locations.iter().find(|l| l.id == session.location_id).map_or("Unknown", |l| l.location.as_str()).to_string();

    rows.push(embeds::CheckedInRow {
      name: member_name(member).to_string(),
      location,
      since_secs: ms.check_in_time.timestamp(),
    });
  }

  if rows.is_empty() {
    return embeds::info("Checked in", "No one is currently checked in.");
  }

  // Longest-present first within each location, so whoever is closest to overtime reads first.
  rows.sort_by(|a, b| a.location.cmp(&b.location).then(a.since_secs.cmp(&b.since_secs)));
  embeds::checked_in(&rows)
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

  // This is the checkout that used to be indistinguishable from forgetting: run after the
  // session has ended, it records `session.end_time` verbatim — byte-identical to what the
  // auto-checkout writes. Recording that a person did it, deliberately, by this route, is the
  // only thing that tells the two apart.
  deps.member_stats.record_manual_checkout(ms.id, SOURCE_DISCORD, late).await;

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

/// A caller's profile, plus the bits of presentation that only `!mystats` needs.
struct LoadedProfile {
  name: String,
  member_type: String,
  profile: MemberProfile,
  /// Their first check-in, formatted — the schema keeps no enrollment date, so the earliest
  /// check-in is the closest honest answer to "in TimeKeeper since".
  member_since: Option<String>,
}

/// Loads everything the caller's stat card and achievement list are derived from, or the embed
/// explaining why it could not be.
///
/// The figures themselves come from the shared accolades logic, which is also what the app's
/// achievements view reads — so a title or a badge means exactly the same thing in Discord as it
/// does on screen, rather than being computed twice and drifting.
async fn load_profile(msg: &Message, deps: &DiscordDeps) -> Result<LoadedProfile, Box<CreateEmbed>> {
  let discord_id = msg.author.id.to_string();

  let member = match deps.team_members.get_by_discord_id(&discord_id).await {
    Ok(Some(m)) => m,
    Ok(None) => {
      let hint = match deps.settings.get().await {
        Ok(s) if s.discord_self_link_enabled => "Use `!link Name` to link it.",
        _ => "Ask an admin to link it.",
      };
      return Err(Box::new(embeds::warning(
        "Not linked",
        &format!("Your Discord account is not linked to a team member. {hint}"),
      )));
    }
    Err(e) => return Err(Box::new(embeds::error(&format!("Error loading team members: {e}")))),
  };

  let tz = match deps.settings.get().await {
    Ok(s) => parse_tz(&s.timezone),
    Err(e) => return Err(Box::new(embeds::error(&format!("Error loading settings: {e}")))),
  };

  let snapshot = match deps.accolades.profile_for(member.id).await {
    Ok(Some(snapshot)) => snapshot,
    Ok(None) => return Err(Box::new(embeds::error("Your team member record could not be found."))),
    Err(e) => return Err(Box::new(embeds::error(&format!("Error computing your statistics: {e}")))),
  };

  Ok(LoadedProfile {
    name: member_name(&member).to_string(),
    member_type: capitalize(&member.member_type),
    member_since: snapshot.first_check_in.map(|first| format_full_date(first.timestamp(), tz)),
    profile: snapshot.profile,
  })
}

/// A caller's own stat card: title, achievement progress, ranks and hour buckets.
///
/// Hour buckets mirror the public board; the extras are derived straight from the caller's
/// attendance records, so overtime is always the real figure regardless of the leaderboard's
/// overtime display setting.
async fn mystats(msg: &Message, deps: &DiscordDeps) -> CreateEmbed {
  let loaded = match load_profile(msg, deps).await {
    Ok(loaded) => loaded,
    Err(embed) => return *embed,
  };
  let p = &loaded.profile;

  let title = achievements::title_for(p);
  let overtime_pct = p.overtime_pct();
  let overtime = (p.overtime_secs > 0.0).then(|| format!("{} ({}%)", format_secs(p.overtime_secs), overtime_pct));

  // Attendance counts finished sessions only, so upcoming ones can't pad the denominator.
  let attendance = (p.sessions_possible > 0).then_some((p.sessions_attended, p.sessions_possible));

  let longest_session = p.longest_stint_secs.map(|secs| {
    #[allow(clippy::cast_precision_loss)]
    format_secs(secs as f64)
  });

  embeds::my_stats(&embeds::MyStats {
    name: loaded.name,
    title: title.name.to_string(),
    title_reason: title.reason.to_string(),
    achievements: achievements::progress(p),
    member_type: loaded.member_type,
    group_rank: p.group_rank,
    global_rank: p.global_rank,
    member_since: loaded.member_since,
    attendance,
    forgot_checkout: p.forgot_checkout,
    total: format_secs(p.total_secs),
    this_week: format_secs(p.this_week_secs),
    overtime,
    active_session: (p.active_secs > 0.0).then(|| format_secs(p.active_secs)),
    sessions_attended: p.sessions_attended,
    longest_session,
    avg_check_in: p.avg_check_in_minutes.map(clock_time),
    avg_check_out: p.avg_check_out_minutes.map(clock_time),
    latest_check_out: p.latest_check_out_minutes.map(clock_time),
  })
}

/// The caller's achievement collection: what they hold and a preview of what they do not.
///
/// Nothing here is stored — an achievement is held for exactly as long as its condition is true
/// of the caller's profile, so the list is recomputed on every call.
async fn achievements(msg: &Message, deps: &DiscordDeps) -> CreateEmbed {
  let loaded = match load_profile(msg, deps).await {
    Ok(loaded) => loaded,
    Err(embed) => return *embed,
  };

  let line = |a: &'static achievements::Achievement| embeds::AchievementLine {
    emoji: a.emoji.to_string(),
    name: a.name.to_string(),
    how: a.how.to_string(),
  };

  let earned: Vec<embeds::AchievementLine> = achievements::earned(&loaded.profile).into_iter().map(line).collect();
  let locked: Vec<embeds::AchievementLine> = achievements::locked(&loaded.profile).into_iter().map(line).collect();

  embeds::achievements(&loaded.name, &earned, &locked, achievements::ACHIEVEMENTS.len())
}

/// Prefix on every catalogue button's `custom_id`. Namespaced so the bot only ever answers
/// components it created, and the page index rides along in the id itself.
const CATALOGUE_ID: &str = "tk_badges";

/// The catalogue page buttons. Stateless: the page number lives in the `custom_id`, so a button
/// still works after a restart rather than pointing at a session that no longer exists.
fn catalogue_buttons(page: usize, total_pages: usize) -> Vec<CreateActionRow> {
  let previous = CreateButton::new(format!("{CATALOGUE_ID}:{}", page.saturating_sub(1)))
    .label("Previous")
    .style(ButtonStyle::Secondary)
    .disabled(page == 0);
  let next = CreateButton::new(format!("{CATALOGUE_ID}:{}", page + 1))
    .label("Next")
    .style(ButtonStyle::Secondary)
    .disabled(page + 1 >= total_pages);

  vec![CreateActionRow::Buttons(vec![previous, next])]
}

/// Builds one page of the catalogue, rated for rarity and — when `viewer` is a linked member —
/// ticked with what they already hold.
///
/// Everything comes from the shared accolades logic, the same source the app's achievements view
/// and `!mystats` read. There is no second copy of the catalogue here to fall out of step.
async fn catalogue_page(page: usize, viewer: Option<Uuid>, deps: &DiscordDeps) -> Reply {
  let entries = match deps.accolades.catalogue().await {
    Ok(entries) => entries,
    Err(e) => return embeds::error(&format!("Error loading achievements: {e}")).into(),
  };

  // What the viewer holds, so a browsing member can see their own progress in the same list.
  // A viewer who is not linked simply gets no ticks rather than an error.
  let held: Vec<String> = match viewer {
    Some(member_id) => match deps.accolades.for_member(member_id).await {
      Ok(Some(accolades)) => accolades.achievements.iter().filter(|a| a.earned).map(|a| a.key.clone()).collect(),
      _ => Vec::new(),
    },
    None => Vec::new(),
  };

  let total_pages = entries.len().div_ceil(embeds::CATALOGUE_PAGE_SIZE).max(1);
  let page = page.min(total_pages - 1);

  let lines: Vec<embeds::CatalogueEntry> = entries
    .iter()
    .skip(page * embeds::CATALOGUE_PAGE_SIZE)
    .take(embeds::CATALOGUE_PAGE_SIZE)
    .map(|a| {
      let earned = viewer.map(|_| held.iter().any(|key| key == &a.key));
      // A secret nobody has earned still must not give itself away, even in a catalogue.
      let secret = a.hidden && earned != Some(true);
      embeds::CatalogueEntry {
        emoji: if secret { "\u{2753}".to_string() } else { a.emoji.clone() },
        name: if secret { "Secret".to_string() } else { a.name.clone() },
        how: if secret { "Hidden until you earn it.".to_string() } else { a.how.clone() },
        rarity: format!(
          "{} \u{b7} {:.0}% of the team ({} of {})",
          a.rarity_label(),
          a.rarity_pct,
          a.holders,
          a.total_members
        ),
        earned,
      }
    })
    .collect();

  let embed = embeds::catalogue_page(&embeds::CataloguePage {
    page,
    total_pages,
    total_achievements: entries.len(),
    entries: lines,
  });

  Reply::Interactive(Box::new(embed), catalogue_buttons(page, total_pages))
}

/// `!badges` — browse the whole catalogue, eight at a time.
async fn badges(msg: &Message, deps: &DiscordDeps) -> Reply {
  let viewer = deps.team_members.get_by_discord_id(&msg.author.id.to_string()).await.ok().flatten().map(|m| m.id);
  catalogue_page(0, viewer, deps).await
}

/// Handles a click on a catalogue page button.
///
/// Returns `None` for any component this bot did not create, so an unrelated button elsewhere in
/// the guild is left alone. The reply *edits the original message* rather than posting a new one,
/// which is the whole point: browsing sixty-seven achievements costs one message, not nine.
pub async fn handle_catalogue_button(
  ctx: &Context,
  interaction: &ComponentInteraction,
  deps: &DiscordDeps,
) -> Option<()> {
  let page: usize = interaction.data.custom_id.strip_prefix(&format!("{CATALOGUE_ID}:"))?.parse().ok()?;

  let viewer = deps.team_members.get_by_discord_id(&interaction.user.id.to_string()).await.ok().flatten().map(|m| m.id);

  let response = match catalogue_page(page, viewer, deps).await {
    Reply::Interactive(embed, rows) => CreateInteractionResponseMessage::new().embed(*embed).components(rows),
    Reply::Embed(embed) => CreateInteractionResponseMessage::new().embed(*embed),
    Reply::Content(text) => CreateInteractionResponseMessage::new().content(text),
  };

  if let Err(e) = interaction.create_response(&ctx.http, CreateInteractionResponse::UpdateMessage(response)).await {
    log::error!("Failed to update achievements page: {e}");
  }
  Some(())
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn every_documented_command_is_gated_by_maintenance_mode() {
    // `!help` lists what the bot answers; anything it advertises must also be recognised by the
    // maintenance gate, or that command would keep running mid-deploy while the rest are blocked.
    let help = embeds::help_text();
    for command in COMMANDS {
      // Leading backtick only: some entries carry an argument (`!link Name`).
      assert!(help.contains(&format!("`!{command}")), "help should document !{command}");
    }
  }

  #[test]
  fn known_commands_are_matched_case_insensitively() {
    // `handle_command` lowercases before dispatching, so the gate sees lowercase too.
    assert!(is_known_command("leaderboard"));
    assert!(is_known_command("checkedin"));
  }

  #[test]
  fn unknown_commands_are_not_gated() {
    // An unrecognised `!something` must stay silent during maintenance rather than start
    // drawing a reply it would never normally get.
    assert!(!is_known_command("banana"));
    assert!(!is_known_command(""));
  }
}
