//! Discord message presentation.
//!
//! Every command used to build a `String` and send it with `channel_id.say`,
//! which meant hand-rolled headings, medal emoji and bullet lists. Embeds give
//! a title, a colour, a footer and fields for free, and — the requirement that
//! drove this — they reflow correctly on a phone. Discord has no table
//! primitive; a monospace block holds its columns on desktop but wraps into
//! nonsense on a narrow screen, so nothing here pads to a fixed width. Where a
//! grid is wanted it comes from inline fields, which Discord collapses to a
//! single column on mobile of its own accord.
//!
//! The builders below are pure: they take already-fetched, plain data and
//! return a `CreateEmbed`. That keeps them unit-testable without a database or
//! a gateway connection, which matters because there is no test guild here.

use std::fmt::Write;

use serenity::all::{Colour, CreateEmbed, CreateEmbedFooter};

/// Brand blue, `#0751B9` — the same `kBrandBlue` the app uses as `primary`.
pub const BRAND_BLUE: Colour = Colour(0x0007_51B9);

/// The reserved support colours from `client/lib/colors.dart`, so a warning in
/// Discord is the same hue as a warning in the app.
pub const SUPPORT_ERROR: Colour = Colour(0x00D9_2B2B);
pub const SUPPORT_WARNING: Colour = Colour(0x00D9_822B);
pub const SUPPORT_SUCCESS: Colour = Colour(0x002B_D92B);
pub const SUPPORT_INFO: Colour = Colour(0x002B_65D9);

/// Discord hard-caps an embed at 25 fields. Leave one spare for an
/// "…and N more" summary rather than silently dropping the tail.
const MAX_FIELDS: usize = 24;

/// Common chrome: brand colour and a footer that names the source.
fn base(title: &str, colour: Colour) -> CreateEmbed {
  CreateEmbed::new().title(title).colour(colour).footer(CreateEmbedFooter::new("TimeKeeper"))
}

/// Neutral informational reply.
pub fn info(title: &str, description: &str) -> CreateEmbed {
  base(title, BRAND_BLUE).description(description)
}

/// Something went right and the user should be able to tell at a glance.
pub fn success(title: &str, description: &str) -> CreateEmbed {
  base(title, SUPPORT_SUCCESS).description(description)
}

/// A refusal the user can act on — a bad filter, a disabled feature.
pub fn warning(title: &str, description: &str) -> CreateEmbed {
  base(title, SUPPORT_WARNING).description(description)
}

/// A failure. Errors keep the red so they never read as ordinary output.
pub fn error(description: &str) -> CreateEmbed {
  base("Something went wrong", SUPPORT_ERROR).description(description)
}

/// Renders `items` as inline fields, which Discord lays out two or three to a
/// row on desktop and stacks on mobile. Overflow past [`MAX_FIELDS`] collapses
/// into a trailing count.
fn inline_fields(mut embed: CreateEmbed, items: &[(String, String)]) -> CreateEmbed {
  for (name, value) in items.iter().take(MAX_FIELDS) {
    embed = embed.field(name, value, true);
  }
  if items.len() > MAX_FIELDS {
    embed = embed.field("\u{200b}", format!("…and {} more", items.len() - MAX_FIELDS), false);
  }
  embed
}

pub fn help_text() -> String {
  "**TimeKeeper commands** — prefix every command with `!`\n\
   `!ping` — Check if the bot is alive\n\
   `!leaderboard` — Hours leaderboard (`!leaderboard help` for filters)\n\
   `!sessions` — Active and upcoming sessions\n\
   `!checkedin` — Who is currently checked in\n\
   `!locations` — List all locations\n\
   `!link Name` — Link your Discord account to a team member\n\
   `!checkout` — Check yourself out of the current session\n\
   `!mystats` — Your own attendance stats, title and leaderboard rank\n\
   `!achievements` — Your unlocked achievements (`all` ranks every member)\n\
   `!badges` — Browse every achievement and how rare it is\n\
   `!help` — Show this message"
    .to_string()
}

pub fn leaderboard_help() -> CreateEmbed {
  base("Leaderboard filters", BRAND_BLUE)
    .field("`!leaderboard`", "Everyone", true)
    .field("`!leaderboard students`", "Students only", true)
    .field("`!leaderboard mentors`", "Mentors only", true)
}

/// One row of the leaderboard, already resolved and formatted upstream.
pub struct LeaderboardRow {
  pub name: String,
  pub all_time: String,
  pub this_week: String,
}

/// One line per person rather than aligned columns: a padded three-column
/// layout looks tidy on a desktop and shreds on a phone, and the ranking is
/// already carried by the order plus the medal.
pub fn leaderboard(rows: &[LeaderboardRow], subtitle: &str) -> CreateEmbed {
  let body: Vec<String> = rows
    .iter()
    .enumerate()
    .map(|(i, row)| {
      let medal = match i {
        0 => "\u{1f947} ",
        1 => "\u{1f948} ",
        2 => "\u{1f949} ",
        _ => "",
      };
      format!("{medal}**{}.** {} — **{}** · {} this week", i + 1, row.name, row.all_time, row.this_week)
    })
    .collect();

  base("Leaderboard", BRAND_BLUE).description(format!("{subtitle}\n\n{}", body.join("\n")))
}

/// A session line, with Discord timestamp markup already applied. Timestamps
/// render in each reader's own locale and timezone, which is the one piece of
/// formatting worth handing to the client rather than doing here.
pub struct SessionRow {
  pub location: String,
  pub when: String,
}

pub fn sessions(active: &[SessionRow], upcoming: &[SessionRow]) -> CreateEmbed {
  let mut embed = base("Sessions", BRAND_BLUE);

  if !active.is_empty() {
    let body: Vec<String> = active.iter().map(|s| format!("**{}** — {}", s.location, s.when)).collect();
    embed = embed.field(format!("Active ({})", active.len()), body.join("\n"), false);
  }
  if !upcoming.is_empty() {
    let body: Vec<String> = upcoming.iter().map(|s| format!("**{}** — {}", s.location, s.when)).collect();
    embed = embed.field(format!("Upcoming ({})", upcoming.len()), body.join("\n"), false);
  }

  embed
}

/// One person currently signed in.
pub struct CheckedInRow {
  pub name: String,
  pub location: String,
  /// When they checked in, as a unix timestamp.
  pub since_secs: i64,
}

/// Who is currently checked in, grouped by location.
///
/// This used to render one *inline field per person* with a zero-width-space value, which left
/// Discord laying names out in a ragged three-column grid of empty cells - unreadable, and
/// worse the moment the count was not a multiple of three. It now follows the leaderboard's
/// shape: a line per person inside one field per location, which reflows properly on a phone
/// and has room to say where each person is and how long they have been there.
pub fn checked_in(rows: &[CheckedInRow]) -> CreateEmbed {
  let mut embed = base(&format!("Checked in ({})", rows.len()), SUPPORT_SUCCESS);

  // Group by location, preserving first-seen order so the layout is stable between calls.
  let mut locations: Vec<&str> = Vec::new();
  for row in rows {
    if !locations.contains(&row.location.as_str()) {
      locations.push(&row.location);
    }
  }

  for location in locations.iter().take(MAX_FIELDS) {
    let body: Vec<String> = rows
      .iter()
      .filter(|r| &r.location == location)
      .map(|r| {
        // `<t:N:R>` renders as "2 hours ago" in each reader's own locale.
        format!("**{}** \u{2014} since <t:{}:t> (<t:{}:R>)", r.name, r.since_secs, r.since_secs)
      })
      .collect();

    embed = embed.field(format!("{location} ({})", body.len()), body.join("\n"), false);
  }

  if locations.len() > MAX_FIELDS {
    embed = embed.field("\u{200b}", format!("\u{2026}and {} more locations", locations.len() - MAX_FIELDS), false);
  }

  embed
}

pub fn locations(names: &[String]) -> CreateEmbed {
  let items: Vec<(String, String)> = names.iter().map(|n| (n.clone(), "\u{200b}".to_string())).collect();
  inline_fields(base(&format!("Locations ({})", names.len()), BRAND_BLUE), &items)
}

/// A member's personal stats card — relative (group) and global leaderboard ranks plus a
/// mix of board-derived hour buckets and record-derived extras.
pub struct MyStats {
  pub name: String,
  /// The title derived for this profile, and why they hold it. Recomputed on every card — no
  /// title is ever stored, so the catalogue can be reshuffled freely.
  pub title: String,
  pub title_reason: String,
  /// (achievements held, achievements in the catalogue).
  pub achievements: (usize, usize),
  /// The member's type, capitalised; used as the "X rank" field label (e.g. "Mentor").
  pub member_type: String,
  /// Position within the member's own group (everyone with the same member type) and how
  /// many that group has, when the member is ranked.
  pub group_rank: Option<(usize, usize)>,
  /// Position on the all-members leaderboard and how many entries it has, when ranked.
  pub global_rank: Option<(usize, usize)>,
  /// When the member first checked in — their first shift, since the schema stores no
  /// enrollment date.
  pub member_since: Option<String>,
  /// (sessions the member attended, finished sessions the club has run) — some way to read
  /// their attendance, present once any session has finished.
  pub attendance: Option<(usize, usize)>,
  /// How many times the system had to sign the member out (checkout exactly on the scheduled
  /// session end) because they never did.
  pub forgot_checkout: usize,
  pub total: String,
  pub this_week: String,
  /// The member's real overtime, as "1h 5m (6%)" — always present when they have any,
  /// independent of the leaderboard's overtime display setting.
  pub overtime: Option<String>,
  pub active_session: Option<String>,
  pub sessions_attended: usize,
  /// Their longest single stint signed in, as "6h 20m".
  pub longest_session: Option<String>,
  pub avg_check_in: Option<String>,
  pub avg_check_out: Option<String>,
  /// Their latest checkout time-of-day across all sessions — the night owl award.
  pub latest_check_out: Option<String>,
}

/// One rank cell: a medal for a top-three position, otherwise a plain "N of total".
fn rank_field(position: usize, total: usize) -> String {
  let medal = match position {
    1 => "\u{1f947} ",
    2 => "\u{1f948} ",
    3 => "\u{1f949} ",
    _ => "",
  };
  format!("{medal}#{position} of {total}")
}

/// The mood for an attendance percentage — the more sessions actually rocked up to, the
/// happier they get.
fn attendance_emoji(pct: u8) -> &'static str {
  match pct {
    100 => "\u{1f525}",
    90..=99 => "\u{1f604}",
    75..=89 => "\u{1f642}",
    50..=74 => "\u{1f62c}",
    _ => "\u{1f634}",
  }
}

/// Rendered as inline fields so desktop gets a tidy stats grid and a phone stacks the same
/// fields — the same `inline_fields` rule as the rest of the bot. Relative rank comes first:
/// the group board is the one a student or mentor actually competes on.
pub fn my_stats(stats: &MyStats) -> CreateEmbed {
  let mut items: Vec<(String, String)> = Vec::new();

  let group_label = format!("{} rank", stats.member_type);
  match stats.group_rank {
    Some((position, total)) => items.push((group_label, rank_field(position, total))),
    None => items.push((group_label, "Not ranked yet".to_string())),
  }
  match stats.global_rank {
    Some((position, total)) => items.push(("Global rank".to_string(), rank_field(position, total))),
    None => items.push(("Global rank".to_string(), "Not ranked yet".to_string())),
  }

  items.push(("In TimeKeeper since".to_string(), stats.member_since.clone().unwrap_or_else(|| "\u{2014}".to_string())));
  match stats.attendance {
    Some((attended, total)) => {
      #[allow(clippy::cast_possible_truncation)]
      let pct = attended.saturating_mul(100).checked_div(total).unwrap_or(100) as u8;
      items
        .push(("Attendance".to_string(), format!("{attended} of {total} sessions ({pct}%) {}", attendance_emoji(pct))));
    }
    None => items.push(("Attendance".to_string(), "No sessions yet".to_string())),
  }

  items.push(("All-time hours".to_string(), stats.total.clone()));
  items.push(("This week".to_string(), stats.this_week.clone()));
  if let Some(overtime) = &stats.overtime {
    items.push(("Overtime".to_string(), overtime.clone()));
  }
  items.push(("Sessions attended".to_string(), stats.sessions_attended.to_string()));
  items.push(("Forgot to check out".to_string(), stats.forgot_checkout.to_string()));
  if let Some(longest) = &stats.longest_session {
    items.push(("Longest session".to_string(), longest.clone()));
  }
  items.push(("Avg check-in".to_string(), stats.avg_check_in.clone().unwrap_or_else(|| "\u{2014}".to_string())));
  items.push(("Avg check-out".to_string(), stats.avg_check_out.clone().unwrap_or_else(|| "\u{2014}".to_string())));
  if let Some(latest) = &stats.latest_check_out {
    items.push(("Latest check-out".to_string(), latest.clone()));
  }
  if let Some(active) = &stats.active_session {
    items.push(("Active session".to_string(), active.clone()));
  }

  let (earned, total) = stats.achievements;
  items.push(("Achievements".to_string(), format!("{earned} of {total} \u{1f3c6}")));

  // The title is the description rather than a field: it is the headline of the card, and a
  // description spans the full width instead of being squeezed into a third of a row.
  let header = base(&format!("Stats for {}", stats.name), BRAND_BLUE)
    .description(format!("**{}**\n*{}*", stats.title, stats.title_reason));
  inline_fields(header, &items)
}

/// One line per achievement in a `!achievements` listing.
pub struct AchievementLine {
  pub emoji: String,
  pub name: String,
  /// How it is earned — the "hover text", shown inline because Discord has no tooltip.
  pub how: String,
}

/// A member's collection: what they hold, then what is still out there.
///
/// Rendered as a description rather than fields. Fields cap at 25 and truncate long values,
/// while a description holds 4096 characters and keeps one achievement per line, which is what
/// makes the list scannable on a phone.
pub fn achievements(name: &str, earned: &[AchievementLine], locked: &[AchievementLine], total: usize) -> CreateEmbed {
  let mut body = format!("**{} of {total} unlocked**\n", earned.len());

  if earned.is_empty() {
    body.push_str("\nNothing yet — check in to a session and the first one is yours.\n");
  } else {
    body.push('\n');
    for line in earned {
      let _ = writeln!(body, "{} **{}** — {}", line.emoji, line.name, line.how);
    }
  }

  // Only a handful of the locked ones: the full list is dozens long and buries what they have.
  if !locked.is_empty() {
    body.push_str("\n**Still to get**\n");
    for line in locked.iter().take(LOCKED_PREVIEW) {
      let _ = writeln!(body, "\u{1f512} **{}** — {}", line.name, line.how);
    }
    if locked.len() > LOCKED_PREVIEW {
      let _ = writeln!(body, "\u{2026}and {} more, some of them secret.", locked.len() - LOCKED_PREVIEW);
    }
  }

  base(&format!("Achievements for {name}"), BRAND_BLUE).description(truncate_description(&body))
}

/// The `!achievements` subcommand reference — a family of three ways in, modelled on the
/// leaderboard's own help page.
pub fn achievements_help() -> CreateEmbed {
  base("Achievements", BRAND_BLUE)
    .field("`!achievements`", "Your unlocked achievements, and what is left", true)
    .field("`!achievements all`", "Every member, ranked by how many they hold", true)
    .field("`!badges`", "Browse every achievement in the catalogue and how rare it is", true)
}

/// One row of the achievements leaderboard — the member's name and where they stand in the
/// catalogue, ready for the same medal treatment the hours leaderboard gives its podium.
pub struct AccoladesRow {
  pub name: String,
  /// Their derived title, for the flavour a bare count would not carry.
  pub title: String,
  /// (achievements held, achievements in the catalogue).
  pub earned: usize,
  pub total: usize,
}

/// Every member ranked by achievements held, most decorated first.
///
/// The same shape as `!leaderboard` — a description of one line per person, medals for the top
/// three — because it is the same question: who is winning the collection.
pub fn achievements_leaderboard(rows: &[AccoladesRow], subtitle: &str) -> CreateEmbed {
  let body: Vec<String> = rows
    .iter()
    .enumerate()
    .map(|(i, row)| {
      let medal = match i {
        0 => "\u{1f947} ",
        1 => "\u{1f948} ",
        2 => "\u{1f949} ",
        _ => "",
      };
      format!("{medal}**{}.** {} — **{} of {}** badges \u{b7} *{}*", i + 1, row.name, row.earned, row.total, row.title)
    })
    .collect();

  base("Achievements", BRAND_BLUE).description(format!("{subtitle}\n\n{}", body.join("\n")))
}

/// How many unearned achievements a listing previews before collapsing into a count.
const LOCKED_PREVIEW: usize = 8;

/// Discord rejects an embed whose description exceeds 4096 characters.
fn truncate_description(body: &str) -> String {
  const LIMIT: usize = 4000;
  if body.chars().count() <= LIMIT {
    return body.to_string();
  }
  body.chars().take(LIMIT).collect::<String>() + "\n\u{2026}"
}

/// One catalogue entry on a browsable page.
pub struct CataloguePage {
  /// Zero-based index of the page being shown.
  pub page: usize,
  pub total_pages: usize,
  pub total_achievements: usize,
  pub entries: Vec<CatalogueEntry>,
}

pub struct CatalogueEntry {
  pub emoji: String,
  pub name: String,
  pub how: String,
  /// "Rare · 17%" — the band plus the figure, since neither alone is much use.
  pub rarity: String,
  /// Whether the member browsing already holds it, when a member is known.
  pub earned: Option<bool>,
}

/// How many achievements one page of `!badges` shows.
///
/// Sixty-seven of them in a single embed is both unreadable and close enough to Discord's 4096
/// character description limit to be a real risk, which is what pagination is here to solve.
/// Eight keeps a page short enough to take in at a glance on a phone.
pub const CATALOGUE_PAGE_SIZE: usize = 8;

/// One page of the achievement catalogue: emoji on the left, description on the right.
///
/// Rendered as a description rather than fields. Inline fields would put the text in narrow
/// columns that wrap mid-sentence, and a two-column field layout cannot keep the emoji hard
/// against the left edge of each row.
pub fn catalogue_page(page: &CataloguePage) -> CreateEmbed {
  let mut body = String::new();

  for entry in &page.entries {
    // Ticked only for a viewer who holds it. An unlinked viewer gets no ticks at all rather
    // than a page of crosses implying they have failed to earn any of them.
    let tick = if entry.earned == Some(true) { " \u{2705}" } else { "" };
    let _ = writeln!(body, "{} **{}**{}", entry.emoji, entry.name, tick);
    let _ = writeln!(body, "\u{2003}{}", entry.how);
    let _ = writeln!(body, "\u{2003}-# {}\n", entry.rarity);
  }

  if body.is_empty() {
    body.push_str("Nothing to show.");
  }

  base(&format!("Achievements \u{2014} page {} of {}", page.page + 1, page.total_pages.max(1)), BRAND_BLUE)
    .description(truncate_description(&body))
    .footer(CreateEmbedFooter::new(format!("TimeKeeper \u{2022} {} achievements to collect", page.total_achievements)))
}

/// The facts behind a session notification, shown next to the operator's own
/// message text rather than instead of it.
///
/// Reminder and DM templates are user-authored and routinely contain `@here`
/// or a `<@id>` mention. Discord does not fire a notification for a mention
/// that lives inside an embed, only for one in the message content — so the
/// rendered template stays as content and this embed carries the structured
/// detail alongside it.
pub fn session_facts(title: &str, colour: Colour, location: &str, start_secs: i64, end_secs: i64) -> CreateEmbed {
  base(title, colour).field("Location", location, true).field("Starts", format!("<t:{start_secs}:t>"), true).field(
    "Ends",
    format!("<t:{end_secs}:t>"),
    true,
  )
}

#[cfg(test)]
mod tests {
  use std::collections::HashMap;

  use super::*;

  /// `CreateEmbed` has no getters, but it serialises to the JSON Discord
  /// receives — which is the thing worth asserting on anyway.
  fn json(embed: CreateEmbed) -> serde_json::Value {
    serde_json::to_value(embed).expect("embed serialises")
  }

  #[test]
  fn info_carries_title_description_and_brand_colour() {
    let v = json(info("Hello", "World"));
    assert_eq!(v["title"], "Hello");
    assert_eq!(v["description"], "World");
    assert_eq!(v["color"], 0x0007_51B9);
    assert_eq!(v["footer"]["text"], "TimeKeeper");
  }

  #[test]
  fn error_is_red() {
    assert_eq!(json(error("boom"))["color"], 0x00D9_2B2B);
  }

  #[test]
  fn help_is_a_plain_text_command_list() {
    let text = help_text();
    assert!(text.starts_with("**TimeKeeper commands**"));
    for command in
      ["!ping", "!leaderboard", "!sessions", "!checkedin", "!locations", "!link", "!checkout", "!mystats", "!help"]
    {
      assert!(text.contains(command), "help should mention {command}");
    }
  }

  #[test]
  fn leaderboard_medals_the_top_three_and_numbers_the_rest() {
    let rows: Vec<LeaderboardRow> = ["A", "B", "C", "D"]
      .iter()
      .map(|n| LeaderboardRow {
        name: (*n).to_string(),
        all_time: "10h 0m".to_string(),
        this_week: "2h 0m".to_string(),
      })
      .collect();

    let description = json(leaderboard(&rows, "All members")).to_string();
    assert!(description.contains("All members"));
    assert!(description.contains("\\u{1f947}") || description.contains('\u{1f947}'));
    assert!(description.contains("**4.** D"));
    // No column padding anywhere - that is what wraps badly on a phone.
    assert!(!description.contains("  "));
  }

  #[test]
  fn sessions_splits_active_from_upcoming() {
    let active = vec![SessionRow { location: "Workshop".into(), when: "<t:1:F>".into() }];
    let upcoming = vec![SessionRow { location: "Shop".into(), when: "<t:2:F>".into() }];

    let v = json(sessions(&active, &upcoming));
    let fields = v["fields"].as_array().expect("fields");
    assert_eq!(fields.len(), 2);
    assert_eq!(fields[0]["name"], "Active (1)");
    assert_eq!(fields[1]["name"], "Upcoming (1)");
    assert!(fields[0]["value"].as_str().expect("value").contains("Workshop"));
  }

  #[test]
  fn sessions_omits_empty_groups() {
    let v = json(sessions(&[], &[SessionRow { location: "Shop".into(), when: "<t:2:F>".into() }]));
    let fields = v["fields"].as_array().expect("fields");
    assert_eq!(fields.len(), 1);
    assert_eq!(fields[0]["name"], "Upcoming (1)");
  }

  #[test]
  fn name_lists_use_inline_fields_and_cap_their_length() {
    let names: Vec<String> = (0..30).map(|i| format!("Location {i}")).collect();
    let v = json(locations(&names));

    assert_eq!(v["title"], "Locations (30)");
    let fields = v["fields"].as_array().expect("fields");
    assert_eq!(fields.len(), MAX_FIELDS + 1);
    assert_eq!(fields[0]["inline"], true);
    assert_eq!(fields[MAX_FIELDS]["value"], "…and 6 more");
  }

  fn checked_in_row(name: &str, location: &str, since: i64) -> CheckedInRow {
    CheckedInRow { name: name.into(), location: location.into(), since_secs: since }
  }

  /// One field per *location* holding a line per person, rather than one inline field per
  /// person - which Discord laid out as a ragged grid of empty cells.
  #[test]
  fn checked_in_groups_people_under_their_location() {
    let v = json(checked_in(&[
      checked_in_row("Ada", "Workshop", 100),
      checked_in_row("Grace", "Workshop", 200),
      checked_in_row("Alan", "Machine Shop", 300),
    ]));

    assert_eq!(v["title"], "Checked in (3)");
    let fields = v["fields"].as_array().expect("fields");
    assert_eq!(fields.len(), 2, "one field per location, not one per person");

    assert_eq!(fields[0]["name"], "Workshop (2)");
    assert_eq!(fields[0]["inline"], false, "a stacked list must not be laid out in columns");
    let workshop = fields[0]["value"].as_str().expect("value");
    assert!(workshop.contains("**Ada**"));
    assert!(workshop.contains("**Grace**"));
    assert_eq!(workshop.lines().count(), 2);

    assert_eq!(fields[1]["name"], "Machine Shop (1)");
  }

  /// Relative timestamps are rendered by Discord in each reader's own timezone.
  #[test]
  fn checked_in_shows_how_long_each_person_has_been_in() {
    let v = json(checked_in(&[checked_in_row("Ada", "Workshop", 1_700_000_000)]));
    let body = v["fields"][0]["value"].as_str().expect("value");
    assert!(body.contains("<t:1700000000:t>"), "absolute check-in time: {body}");
    assert!(body.contains("<t:1700000000:R>"), "relative duration: {body}");
  }

  #[test]
  fn short_name_lists_are_not_truncated() {
    let v = json(locations(&["Workshop".to_string(), "Shop".to_string()]));
    assert_eq!(v["fields"].as_array().expect("fields").len(), 2);
  }

  fn entry(name: &str, earned: Option<bool>) -> CatalogueEntry {
    CatalogueEntry {
      emoji: "\u{2b50}".to_string(),
      name: name.to_string(),
      how: "Do the thing".to_string(),
      rarity: "Rare \u{b7} 17% of the team (2 of 12)".to_string(),
      earned,
    }
  }

  #[test]
  fn a_catalogue_page_numbers_itself_from_one() {
    // The page index is zero-based internally because it indexes a slice; a reader counts from
    // one. Getting this wrong shows up as "page 0 of 9" in front of the whole guild.
    let v = json(catalogue_page(&CataloguePage {
      page: 0,
      total_pages: 9,
      total_achievements: 67,
      entries: vec![entry("First Steps", Some(true))],
    }));

    assert_eq!(v["title"], "Achievements \u{2014} page 1 of 9");
    assert_eq!(v["footer"]["text"], "TimeKeeper \u{2022} 67 achievements to collect");
  }

  #[test]
  fn a_catalogue_page_shows_emoji_then_name_then_rarity() {
    let v = json(catalogue_page(&CataloguePage {
      page: 2,
      total_pages: 9,
      total_achievements: 67,
      entries: vec![entry("Night Owl", Some(false))],
    }));

    let body = v["description"].as_str().expect("description");
    assert!(body.starts_with("\u{2b50} **Night Owl**"), "emoji leads the row, then the name: {body}");
    assert!(body.contains("Do the thing"), "the description follows");
    assert!(body.contains("Rare \u{b7} 17% of the team (2 of 12)"), "and how rare it is");
  }

  #[test]
  fn only_a_holder_gets_a_tick() {
    let held = json(catalogue_page(&CataloguePage {
      page: 0,
      total_pages: 1,
      total_achievements: 1,
      entries: vec![entry("First Steps", Some(true))],
    }));
    assert!(held["description"].as_str().expect("description").contains('\u{2705}'));

    // An unlinked viewer knows nothing about what they hold, so nothing is ticked - a page of
    // unticked rows reads as "not applicable", which is the truth.
    let unlinked = json(catalogue_page(&CataloguePage {
      page: 0,
      total_pages: 1,
      total_achievements: 1,
      entries: vec![entry("First Steps", None)],
    }));
    assert!(!unlinked["description"].as_str().expect("description").contains('\u{2705}'));
  }

  #[test]
  fn my_stats_builds_a_ranked_personal_card() {
    let stats = MyStats {
      name: "Ada".into(),
      title: "The Night Owl".into(),
      title_reason: "You have signed out at 10pm or later.".into(),
      achievements: (12, 48),
      member_type: "Mentor".into(),
      group_rank: Some((2, 6)),
      global_rank: Some((4, 27)),
      member_since: Some("Feb 19, 2026".into()),
      attendance: Some((12, 15)),
      forgot_checkout: 3,
      total: "18h 30m".into(),
      this_week: "3h 15m".into(),
      overtime: Some("1h 5m (6%)".into()),
      active_session: None,
      sessions_attended: 12,
      longest_session: Some("6h 20m".into()),
      avg_check_in: Some("2:15PM".into()),
      avg_check_out: Some("6:40PM".into()),
      latest_check_out: Some("9:47PM".into()),
    };

    let v = json(my_stats(&stats));
    assert_eq!(v["title"], "Stats for Ada");
    let fields = v["fields"].as_array().expect("fields");
    let by_name: HashMap<&str, &str> =
      fields.iter().map(|f| (f["name"].as_str().expect("name"), f["value"].as_str().expect("value"))).collect();
    assert!(by_name.contains_key("Mentor rank"), "relative rank is named for the group");
    assert_eq!(by_name["Mentor rank"], "\u{1f948} #2 of 6", "a group top-three gets the silver medal");
    assert_eq!(by_name["Global rank"], "#4 of 27");
    assert_eq!(by_name["In TimeKeeper since"], "Feb 19, 2026");
    assert_eq!(by_name["Attendance"], "12 of 15 sessions (80%) \u{1f642}");
    assert_eq!(by_name["All-time hours"], "18h 30m");
    assert_eq!(by_name["This week"], "3h 15m");
    assert_eq!(by_name["Overtime"], "1h 5m (6%)");
    assert_eq!(by_name["Sessions attended"], "12");
    assert_eq!(by_name["Forgot to check out"], "3");
    assert_eq!(by_name["Longest session"], "6h 20m");
    assert_eq!(by_name["Avg check-in"], "2:15PM");
    assert_eq!(by_name["Avg check-out"], "6:40PM");
    assert_eq!(by_name["Latest check-out"], "9:47PM");
    assert!(!by_name.contains_key("Active session"));

    // Relative rank leads the card, before the global one.
    assert_eq!(fields[0]["name"], "Mentor rank");
    assert_eq!(fields[1]["name"], "Global rank");
  }

  #[test]
  fn my_stats_medals_and_falls_back_for_unranked_members() {
    let v = json(my_stats(&MyStats {
      name: "Grace".into(),
      title: "The Perfectionist".into(),
      title_reason: "You have not missed a single session.".into(),
      achievements: (20, 48),
      member_type: "Student".into(),
      group_rank: Some((1, 9)),
      global_rank: Some((3, 27)),
      member_since: Some("Mar 1, 2025".into()),
      attendance: Some((20, 20)),
      forgot_checkout: 0,
      total: "40h 0m".into(),
      this_week: "1h 0m".into(),
      overtime: None,
      active_session: Some("0h 30m".into()),
      sessions_attended: 20,
      longest_session: Some("8h 0m".into()),
      avg_check_in: None,
      avg_check_out: None,
      latest_check_out: Some("10:15PM".into()),
    }));
    let fields = v["fields"].as_array().expect("fields");
    assert_eq!(fields[0]["name"], "Student rank");
    assert!(
      fields[0]["value"].as_str().expect("value").contains('\u{1f947}'),
      "the group leader carries the gold medal"
    );
    assert!(
      fields[1]["value"].as_str().expect("value").contains('\u{1f949}'),
      "a global top-three gets the bronze medal"
    );
    assert!(
      fields[3]["value"].as_str().expect("value").contains('\u{1f525}'),
      "every session attended brings the fire"
    );

    let unranked = json(my_stats(&MyStats {
      name: "Alan".into(),
      title: "The Unwritten".into(),
      title_reason: "No attendance on record yet.".into(),
      achievements: (0, 48),
      member_type: "Mentor".into(),
      group_rank: None,
      global_rank: None,
      member_since: None,
      attendance: Some((0, 6)),
      forgot_checkout: 0,
      total: "0h 0m".into(),
      this_week: "0h 0m".into(),
      overtime: None,
      active_session: None,
      sessions_attended: 0,
      longest_session: None,
      avg_check_in: None,
      avg_check_out: None,
      latest_check_out: None,
    }));
    let unranked_fields = unranked["fields"].as_array().expect("fields");
    let by_name: HashMap<&str, &str> = unranked_fields
      .iter()
      .map(|f| (f["name"].as_str().expect("name"), f["value"].as_str().expect("value")))
      .collect();
    assert_eq!(by_name["Mentor rank"], "Not ranked yet");
    assert_eq!(by_name["Global rank"], "Not ranked yet");
    assert_eq!(by_name["In TimeKeeper since"], "\u{2014}");
    assert_eq!(by_name["Attendance"], "0 of 6 sessions (0%) \u{1f634}");
    assert_eq!(by_name["Forgot to check out"], "0");
    assert_eq!(by_name["Avg check-in"], "\u{2014}");
    assert_eq!(by_name["Avg check-out"], "\u{2014}");
  }

  #[test]
  fn session_facts_uses_client_rendered_timestamps() {
    let v = json(session_facts("Starting soon", SUPPORT_INFO, "Workshop", 100, 200));
    let fields = v["fields"].as_array().expect("fields");
    assert_eq!(fields[0]["value"], "Workshop");
    assert_eq!(fields[1]["value"], "<t:100:t>");
    assert_eq!(fields[2]["value"], "<t:200:t>");
    assert!(fields.iter().all(|f| f["inline"] == true));
  }
}
