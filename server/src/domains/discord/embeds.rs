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
   `!mystats` — Your own attendance stats and leaderboard rank\n\
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

/// A member's personal stats card — what the leaderboard says about them plus a few extras
/// (sessions attended, average check-in time) that only make sense about one person.
pub struct MyStats {
  pub name: String,
  /// Position on the leaderboard and how many entries it has, when the member is ranked.
  pub rank: Option<(usize, usize)>,
  pub total: String,
  pub this_week: String,
  /// Only present when the leaderboard's overtime display setting makes it meaningful.
  pub overtime: Option<String>,
  pub active_session: Option<String>,
  pub sessions_attended: usize,
  pub avg_check_in: Option<String>,
}

/// Rendered as inline fields so desktop gets a tidy two-row stats grid and a phone stacks the
/// same fields — the same `inline_fields` rule as the rest of the bot.
pub fn my_stats(stats: &MyStats) -> CreateEmbed {
  let mut items: Vec<(String, String)> = Vec::new();

  match stats.rank {
    Some((position, total)) => {
      let medal = match position {
        1 => "\u{1f947} ",
        2 => "\u{1f948} ",
        3 => "\u{1f949} ",
        _ => "",
      };
      items.push(("Rank".to_string(), format!("{medal}#{position} of {total}")));
    }
    None => items.push(("Rank".to_string(), "Not on the leaderboard yet".to_string())),
  }

  items.push(("All-time hours".to_string(), stats.total.clone()));
  items.push(("This week".to_string(), stats.this_week.clone()));
  if let Some(overtime) = &stats.overtime {
    items.push(("Overtime".to_string(), overtime.clone()));
  }
  if let Some(active) = &stats.active_session {
    items.push(("Active session".to_string(), active.clone()));
  }
  items.push(("Sessions attended".to_string(), stats.sessions_attended.to_string()));
  items.push(("Avg check-in".to_string(), stats.avg_check_in.clone().unwrap_or_else(|| "\u{2014}".to_string())));

  inline_fields(base(&format!("Stats for {}", stats.name), BRAND_BLUE), &items)
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

  #[test]
  fn my_stats_builds_a_ranked_personal_card() {
    let stats = MyStats {
      name: "Ada".into(),
      rank: Some((4, 27)),
      total: "18h 30m".into(),
      this_week: "3h 15m".into(),
      overtime: Some("1h 5m".into()),
      active_session: None,
      sessions_attended: 12,
      avg_check_in: Some("2:15PM".into()),
    };

    let v = json(my_stats(&stats));
    assert_eq!(v["title"], "Stats for Ada");
    let fields = v["fields"].as_array().expect("fields");
    let by_name: HashMap<&str, &str> =
      fields.iter().map(|f| (f["name"].as_str().expect("name"), f["value"].as_str().expect("value"))).collect();
    assert_eq!(by_name["Rank"], "#4 of 27");
    assert_eq!(by_name["All-time hours"], "18h 30m");
    assert_eq!(by_name["This week"], "3h 15m");
    assert_eq!(by_name["Overtime"], "1h 5m");
    assert_eq!(by_name["Sessions attended"], "12");
    assert_eq!(by_name["Avg check-in"], "2:15PM");
    assert!(!by_name.contains_key("Active session"));
  }

  #[test]
  fn my_stats_medals_and_falls_back_for_unranked_members() {
    let v = json(my_stats(&MyStats {
      name: "Grace".into(),
      rank: Some((1, 27)),
      total: "40h 0m".into(),
      this_week: "1h 0m".into(),
      overtime: None,
      active_session: Some("0h 30m".into()),
      sessions_attended: 20,
      avg_check_in: None,
    }));
    let fields = v["fields"].as_array().expect("fields");
    let rank = &fields[0];
    assert_eq!(rank["name"], "Rank");
    assert!(rank["value"].as_str().expect("value").contains('\u{1f947}'), "the leader carries the gold medal");

    let unranked = json(my_stats(&MyStats {
      name: "Alan".into(),
      rank: None,
      total: "0h 0m".into(),
      this_week: "0h 0m".into(),
      overtime: None,
      active_session: None,
      sessions_attended: 0,
      avg_check_in: None,
    }));
    let unranked_fields = unranked["fields"].as_array().expect("fields");
    let by_name: HashMap<&str, &str> = unranked_fields
      .iter()
      .map(|f| (f["name"].as_str().expect("name"), f["value"].as_str().expect("value")))
      .collect();
    assert_eq!(by_name["Rank"], "Not on the leaderboard yet");
    assert_eq!(by_name["Avg check-in"], "\u{2014}");
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
