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

pub fn checked_in(names: &[String]) -> CreateEmbed {
  let items: Vec<(String, String)> = names.iter().map(|n| (n.clone(), "\u{200b}".to_string())).collect();
  inline_fields(base(&format!("Checked in ({})", names.len()), SUPPORT_SUCCESS), &items)
}

pub fn locations(names: &[String]) -> CreateEmbed {
  let items: Vec<(String, String)> = names.iter().map(|n| (n.clone(), "\u{200b}".to_string())).collect();
  inline_fields(base(&format!("Locations ({})", names.len()), BRAND_BLUE), &items)
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
    for command in ["!ping", "!leaderboard", "!sessions", "!checkedin", "!locations", "!link", "!checkout", "!help"] {
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
    let names: Vec<String> = (0..30).map(|i| format!("Member {i}")).collect();
    let v = json(checked_in(&names));

    assert_eq!(v["title"], "Checked in (30)");
    let fields = v["fields"].as_array().expect("fields");
    assert_eq!(fields.len(), MAX_FIELDS + 1);
    assert_eq!(fields[0]["inline"], true);
    assert_eq!(fields[MAX_FIELDS]["value"], "…and 6 more");
  }

  #[test]
  fn short_name_lists_are_not_truncated() {
    let v = json(locations(&["Workshop".to_string(), "Shop".to_string()]));
    assert_eq!(v["fields"].as_array().expect("fields").len(), 2);
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
