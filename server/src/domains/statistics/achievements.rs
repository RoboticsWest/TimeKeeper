//! Titles and achievements — the whole catalogue, in one editable list.
//!
//! Both are **derived, never stored**. A title is recomputed from a [`MemberProfile`] every time
//! it is shown, and an achievement is "held" precisely while its condition is true of the
//! profile. Nothing is written to the database, so there is no award table to wipe, no backfill
//! to run and — deliberately — no "achievement unlocked" ping that could fire a thousand times
//! after a restore. If unlock notifications are ever wanted, the missing piece is a record of
//! what was *already* announced, and that is the only piece that needs a table.
//!
//! Adding to the catalogue is meant to be a one-line job: append an entry to [`ACHIEVEMENTS`] or
//! [`TITLES`]. Every condition is a plain `fn(&MemberProfile) -> bool`, so a new one needs no
//! database, no async and no Discord — just a profile value and an assertion.
//!
//! Two rules keep the lists sane:
//!
//! * **`key` is permanent.** It is what a rendered stat card and any future stored award would
//!   refer to. Rename the `name`, never the `key`.
//! * **[`TITLES`] is ordered, most specific first.** [`title_for`] returns the first match, so a
//!   narrow, funny title must sit above the broad one it would otherwise be swallowed by. The
//!   final entry matches everyone and is what makes the return type infallible.
//!
//! Emoji are all standard Unicode, never custom server emoji: a custom emoji outside its own
//! guild only renders for Nitro subscribers, which would mean half the team seeing `:badge:`.

use super::profile::MemberProfile;

/// One collectable achievement. Held while `check` is true of the profile.
pub struct Achievement {
  /// Stable identifier. Never reuse or rename one.
  pub key: &'static str,
  /// Standard Unicode emoji shown beside the name.
  pub emoji: &'static str,
  pub name: &'static str,
  /// How it is earned, shown whether or not the member holds it.
  pub how: &'static str,
  /// Hidden ones are not listed until earned — the joke lands better as a surprise.
  pub hidden: bool,
  pub check: fn(&MemberProfile) -> bool,
}

/// A title, assigned by the first matching entry in [`TITLES`].
pub struct Title {
  pub key: &'static str,
  pub name: &'static str,
  /// Why they got it, in the second person — shown under the title on a stat card.
  pub reason: &'static str,
  pub check: fn(&MemberProfile) -> bool,
}

// ---------------------------------------------------------------------------------------------
// Achievements
// ---------------------------------------------------------------------------------------------

pub const ACHIEVEMENTS: &[Achievement] = &[
  // -- Hours ----------------------------------------------------------------------------------
  Achievement {
    key: "first_steps",
    emoji: "\u{1f331}",
    name: "First Steps",
    how: "Attend your first session",
    hidden: false,
    check: |p| p.sessions_attended >= 1,
  },
  Achievement {
    key: "hours_5",
    emoji: "\u{23f3}",
    name: "Five Alive",
    how: "Log 5 hours all-time",
    hidden: false,
    check: |p| p.total_hours() >= 5.0,
  },
  Achievement {
    key: "hours_10",
    emoji: "\u{1f51f}",
    name: "Double Digits",
    how: "Log 10 hours all-time",
    hidden: false,
    check: |p| p.total_hours() >= 10.0,
  },
  Achievement {
    key: "hours_25",
    emoji: "\u{1f9f1}",
    name: "Bricklayer",
    how: "Log 25 hours all-time",
    hidden: false,
    check: |p| p.total_hours() >= 25.0,
  },
  Achievement {
    key: "hours_50",
    emoji: "\u{1f6e0}",
    name: "Half Ton",
    how: "Log 50 hours all-time",
    hidden: false,
    check: |p| p.total_hours() >= 50.0,
  },
  Achievement {
    key: "hours_100",
    emoji: "\u{1f4af}",
    name: "Centurion",
    how: "Log 100 hours all-time",
    hidden: false,
    check: |p| p.total_hours() >= 100.0,
  },
  Achievement {
    key: "hours_250",
    emoji: "\u{1f3ed}",
    name: "Industrial Scale",
    how: "Log 250 hours all-time",
    hidden: false,
    check: |p| p.total_hours() >= 250.0,
  },
  Achievement {
    key: "hours_500",
    emoji: "\u{1f5ff}",
    name: "Monolith",
    how: "Log 500 hours all-time",
    hidden: false,
    check: |p| p.total_hours() >= 500.0,
  },
  Achievement {
    key: "big_week",
    emoji: "\u{1f680}",
    name: "Big Week",
    how: "Log 10 hours in a single week",
    hidden: false,
    check: |p| p.this_week_hours() >= 10.0,
  },
  Achievement {
    key: "enormous_week",
    emoji: "\u{2604}",
    name: "What Is Sleep",
    how: "Log 20 hours in a single week",
    hidden: false,
    check: |p| p.this_week_hours() >= 20.0,
  },
  // -- Turning up -----------------------------------------------------------------------------
  Achievement {
    key: "sessions_10",
    emoji: "\u{1f4c5}",
    name: "Regular",
    how: "Attend 10 sessions",
    hidden: false,
    check: |p| p.sessions_attended >= 10,
  },
  Achievement {
    key: "sessions_25",
    emoji: "\u{1f9ed}",
    name: "Fixture",
    how: "Attend 25 sessions",
    hidden: false,
    check: |p| p.sessions_attended >= 25,
  },
  Achievement {
    key: "sessions_50",
    emoji: "\u{1fa91}",
    name: "Part of the Furniture",
    how: "Attend 50 sessions",
    hidden: false,
    check: |p| p.sessions_attended >= 50,
  },
  Achievement {
    key: "sessions_100",
    emoji: "\u{1f3db}",
    name: "Institution",
    how: "Attend 100 sessions",
    hidden: false,
    check: |p| p.sessions_attended >= 100,
  },
  Achievement {
    key: "perfect_attendance",
    emoji: "\u{1f3af}",
    name: "Perfect Attendance",
    how: "Attend every session that has happened (at least 5 of them)",
    hidden: false,
    check: |p| p.sessions_possible >= 5 && p.sessions_attended >= p.sessions_possible,
  },
  Achievement {
    key: "reliable",
    emoji: "\u{1f91d}",
    name: "Reliable",
    how: "Attend 90% of sessions, over at least 10 of them",
    hidden: false,
    check: |p| p.sessions_possible >= 10 && p.attendance_pct() >= 90,
  },
  Achievement {
    key: "streak_5",
    emoji: "\u{1f517}",
    name: "On a Roll",
    how: "Attend 5 sessions in a row",
    hidden: false,
    check: |p| p.attendance_streak >= 5,
  },
  Achievement {
    key: "streak_10",
    emoji: "\u{26d3}",
    name: "Unbroken",
    how: "Attend 10 sessions in a row",
    hidden: false,
    check: |p| p.attendance_streak >= 10,
  },
  Achievement {
    key: "streak_20",
    emoji: "\u{1f9f2}",
    name: "Magnetised",
    how: "Attend 20 sessions in a row",
    hidden: false,
    check: |p| p.attendance_streak >= 20,
  },
  Achievement {
    key: "weekend_3",
    emoji: "\u{1f528}",
    name: "Weekend Warrior",
    how: "Turn up on 3 weekend days",
    hidden: false,
    check: |p| p.weekend_sessions >= 3,
  },
  Achievement {
    key: "weekend_10",
    emoji: "\u{1f5d3}",
    name: "No Such Thing as Sunday",
    how: "Turn up on 10 weekend days",
    hidden: false,
    check: |p| p.weekend_sessions >= 10,
  },
  // -- Punctuality ----------------------------------------------------------------------------
  Achievement {
    key: "early_5",
    emoji: "\u{1f413}",
    name: "Early Bird",
    how: "Arrive before the session starts, 5 times",
    hidden: false,
    check: |p| p.early_arrivals >= 5,
  },
  Achievement {
    key: "early_15",
    emoji: "\u{1f6aa}",
    name: "First Through the Door",
    how: "Arrive before the session starts, 15 times",
    hidden: false,
    check: |p| p.early_arrivals >= 15,
  },
  Achievement {
    key: "clockwork",
    emoji: "\u{23f1}",
    name: "Clockwork",
    how: "Keep every check-in within 15 minutes of the same time, over 10 sessions",
    hidden: false,
    check: |p| p.sessions_attended >= 10 && p.check_in_spread_minutes.is_some_and(|spread| spread <= 15),
  },
  Achievement {
    key: "chaos",
    emoji: "\u{1f3b2}",
    name: "Chaos Schedule",
    how: "Spread your check-ins over more than 6 hours of the day, across 10 sessions",
    hidden: false,
    check: |p| p.sessions_attended >= 10 && p.check_in_spread_minutes.is_some_and(|spread| spread >= 360),
  },
  Achievement {
    key: "night_owl",
    emoji: "\u{1f989}",
    name: "Night Owl",
    how: "Check out at 10pm or later",
    hidden: false,
    check: |p| p.latest_check_out_minutes.is_some_and(|m| m >= 22 * 60),
  },
  Achievement {
    key: "witching_hour",
    emoji: "\u{1f55b}",
    name: "Witching Hour",
    how: "Check out after midnight",
    hidden: false,
    check: |p| p.after_midnight_checkouts >= 1,
  },
  Achievement {
    key: "night_shift",
    emoji: "\u{1f319}",
    name: "Night Shift",
    how: "Check out after midnight 3 times",
    hidden: false,
    check: |p| p.after_midnight_checkouts >= 3,
  },
  // -- Endurance ------------------------------------------------------------------------------
  Achievement {
    key: "long_4h",
    emoji: "\u{1f3c3}",
    name: "Long Haul",
    how: "Stay for a single 4-hour stint",
    hidden: false,
    check: |p| p.longest_stint_hours() >= 4.0,
  },
  Achievement {
    key: "long_8h",
    emoji: "\u{1f9d7}",
    name: "Marathon",
    how: "Stay for a single 8-hour stint",
    hidden: false,
    check: |p| p.longest_stint_hours() >= 8.0,
  },
  Achievement {
    key: "long_12h",
    emoji: "\u{1f30b}",
    name: "Ultramarathon",
    how: "Stay for a single 12-hour stint",
    hidden: false,
    check: |p| p.longest_stint_hours() >= 12.0,
  },
  Achievement {
    key: "cameo",
    emoji: "\u{1f4a8}",
    name: "Cameo",
    how: "Come and go inside 15 minutes",
    hidden: false,
    check: |p| p.shortest_stint_secs.is_some_and(|s| s <= 15 * 60),
  },
  Achievement {
    key: "blink",
    emoji: "\u{26a1}",
    name: "Blink and You'll Miss It",
    how: "Come and go inside 3 minutes",
    hidden: true,
    check: |p| p.shortest_stint_secs.is_some_and(|s| s <= 3 * 60),
  },
  Achievement {
    key: "late_stay_10",
    emoji: "\u{1f4a1}",
    name: "Lights Out Last",
    how: "Stay past the scheduled end 10 times",
    hidden: false,
    check: |p| p.late_stays >= 10,
  },
  // -- Overtime -------------------------------------------------------------------------------
  Achievement {
    key: "overtime_any",
    emoji: "\u{2795}",
    name: "Above and Beyond",
    how: "Log any time outside a scheduled session",
    hidden: false,
    check: |p| p.overtime_secs > 0.0,
  },
  Achievement {
    key: "overtime_25",
    emoji: "\u{23f0}",
    name: "Overtime Achiever",
    how: "Spend a quarter of your hours outside scheduled sessions",
    hidden: false,
    check: |p| p.sessions_attended >= 3 && p.overtime_pct() >= 25,
  },
  Achievement {
    key: "overtime_50",
    emoji: "\u{1f525}",
    name: "Burning the Midnight Oil",
    how: "Spend half your hours outside scheduled sessions",
    hidden: false,
    check: |p| p.sessions_attended >= 3 && p.overtime_pct() >= 50,
  },
  Achievement {
    key: "overtime_75",
    emoji: "\u{1f691}",
    name: "Unhealthy Achiever",
    how: "Spend three quarters of your hours outside scheduled sessions",
    hidden: false,
    check: |p| p.sessions_attended >= 3 && p.overtime_pct() >= 75,
  },
  Achievement {
    key: "overtime_all",
    emoji: "\u{1fae0}",
    name: "Achievement Unhealthy",
    how: "Log every single one of your hours outside a scheduled session",
    hidden: true,
    check: |p| p.sessions_attended >= 3 && p.total_secs > 0.0 && p.overtime_pct() >= 100,
  },
  Achievement {
    key: "no_overtime",
    emoji: "\u{1f9d8}",
    name: "Clocks Off",
    how: "Attend 10 sessions without a minute of overtime",
    hidden: false,
    check: |p| p.sessions_attended >= 10 && p.overtime_secs <= 0.0,
  },
  // -- Forgetting to sign out -------------------------------------------------------------------
  Achievement {
    key: "forgot_1",
    emoji: "\u{1f4a4}",
    name: "Left the Lights On",
    how: "Forget to sign out once",
    hidden: false,
    check: |p| p.forgot_checkout >= 1,
  },
  Achievement {
    key: "forgot_5",
    emoji: "\u{1f47b}",
    name: "Ghost",
    how: "Forget to sign out 5 times",
    hidden: false,
    check: |p| p.forgot_checkout >= 5,
  },
  Achievement {
    key: "forgot_15",
    emoji: "\u{1faa6}",
    name: "Still Technically Here",
    how: "Forget to sign out 15 times",
    hidden: false,
    check: |p| p.forgot_checkout >= 15,
  },
  Achievement {
    key: "forgot_streak_3",
    emoji: "\u{1f501}",
    name: "Creature of Habit",
    how: "Forget to sign out 3 times in a row",
    hidden: false,
    check: |p| p.forgot_checkout_streak >= 3,
  },
  Achievement {
    key: "diligent_forgetter",
    emoji: "\u{1f4cb}",
    name: "Diligent Forgetter",
    how: "Attend 80% of sessions and forget to sign out of half of them",
    hidden: false,
    check: |p| p.sessions_attended >= 5 && p.attendance_pct() >= 80 && p.forgot_pct() >= 50,
  },
  Achievement {
    key: "clean_record",
    emoji: "\u{2705}",
    name: "Clean Record",
    how: "Attend 15 sessions and sign out of every one",
    hidden: false,
    check: |p| p.sessions_attended >= 15 && p.forgot_checkout == 0,
  },
  // -- The board ------------------------------------------------------------------------------
  Achievement {
    key: "ranked",
    emoji: "\u{1f4c8}",
    name: "On the Board",
    how: "Appear on the leaderboard",
    hidden: false,
    check: |p| p.global_rank.is_some(),
  },
  Achievement {
    key: "top_ten",
    emoji: "\u{1f396}",
    name: "Top Ten",
    how: "Reach the top 10 of the leaderboard",
    hidden: false,
    check: |p| p.global_rank.is_some_and(|(position, _)| position <= 10),
  },
  Achievement {
    key: "podium",
    emoji: "\u{1f949}",
    name: "Podium",
    how: "Reach the top 3 of the leaderboard",
    hidden: false,
    check: |p| p.global_rank.is_some_and(|(position, _)| position <= 3),
  },
  Achievement {
    key: "number_one",
    emoji: "\u{1f451}",
    name: "Top of the Board",
    how: "Hold first place on the leaderboard",
    hidden: false,
    check: |p| p.global_rank.is_some_and(|(position, _)| position == 1),
  },
  Achievement {
    key: "best_in_class",
    emoji: "\u{1f3c5}",
    name: "Best in Class",
    how: "Hold first place among your own member type",
    hidden: false,
    check: |p| p.group_rank.is_some_and(|(position, total)| position == 1 && total >= 3),
  },
  Achievement {
    key: "dark_horse",
    emoji: "\u{1f40e}",
    name: "Dark Horse",
    how: "Reach the top 10 with fewer than 10 sessions attended",
    hidden: true,
    check: |p| p.sessions_attended < 10 && p.global_rank.is_some_and(|(position, _)| position <= 10),
  },
  // -- Getting around ---------------------------------------------------------------------------
  Achievement {
    key: "nomad",
    emoji: "\u{1f9f3}",
    name: "Nomad",
    how: "Check in at 2 different locations",
    hidden: false,
    check: |p| p.distinct_locations >= 2,
  },
  Achievement {
    key: "explorer",
    emoji: "\u{1f5fa}",
    name: "Explorer",
    how: "Check in at 4 different locations",
    hidden: false,
    check: |p| p.distinct_locations >= 4,
  },
  // -- Tenure ---------------------------------------------------------------------------------
  Achievement {
    key: "tenure_30",
    emoji: "\u{1f33f}",
    name: "Settled In",
    how: "Be 30 days on from your first check-in",
    hidden: false,
    check: |p| p.days_since_first.is_some_and(|days| days >= 30),
  },
  Achievement {
    key: "tenure_180",
    emoji: "\u{1f342}",
    name: "Seasoned",
    how: "Be 180 days on from your first check-in",
    hidden: false,
    check: |p| p.days_since_first.is_some_and(|days| days >= 180),
  },
  Achievement {
    key: "tenure_365",
    emoji: "\u{1f3f5}",
    name: "Veteran",
    how: "Be a year on from your first check-in",
    hidden: false,
    check: |p| p.days_since_first.is_some_and(|days| days >= 365),
  },
  Achievement {
    key: "tenure_730",
    emoji: "\u{1f9ec}",
    name: "Living History",
    how: "Be two years on from your first check-in",
    hidden: false,
    check: |p| p.days_since_first.is_some_and(|days| days >= 730),
  },
];

/// Every achievement the profile currently satisfies, in catalogue order.
#[must_use]
pub fn earned(profile: &MemberProfile) -> Vec<&'static Achievement> {
  ACHIEVEMENTS.iter().filter(|achievement| (achievement.check)(profile)).collect()
}

/// How many of the catalogue the profile holds, as `(earned, total)`. Hidden achievements count
/// towards the total — a locked collection that visibly has secrets in it is half the fun.
#[must_use]
pub fn progress(profile: &MemberProfile) -> (usize, usize) {
  (earned(profile).len(), ACHIEVEMENTS.len())
}

/// Achievements not yet held and not hidden — the "still to get" list.
#[must_use]
pub fn locked(profile: &MemberProfile) -> Vec<&'static Achievement> {
  ACHIEVEMENTS.iter().filter(|achievement| !achievement.hidden && !(achievement.check)(profile)).collect()
}

// ---------------------------------------------------------------------------------------------
// Titles
// ---------------------------------------------------------------------------------------------

/// Ordered most specific first — [`title_for`] takes the first match. A title added near the top
/// steals members from everything below it, so put the narrow and funny ones up there and the
/// broad ones down the bottom. The last entry matches everybody.
pub const TITLES: &[Title] = &[
  Title {
    key: "achievement_unhealthy",
    name: "Achievement Unhealthy",
    reason: "Every hour you have logged was outside a scheduled session.",
    check: |p| p.sessions_attended >= 3 && p.total_secs > 0.0 && p.overtime_pct() >= 100,
  },
  Title {
    key: "diligent_forgetter",
    name: "The Diligent Forgetter",
    reason: "You turn up to almost everything, and sign out of almost nothing.",
    check: |p| p.sessions_attended >= 5 && p.attendance_pct() >= 80 && p.forgot_pct() >= 50,
  },
  Title {
    key: "immovable_object",
    name: "The Immovable Object",
    reason: "50 sessions and 100 hours deep, with a first-place finish to show for it.",
    check: |p| p.sessions_attended >= 50 && p.total_hours() >= 100.0 && p.global_rank.is_some_and(|(pos, _)| pos == 1),
  },
  Title {
    key: "untouchable",
    name: "The Untouchable",
    reason: "Nobody on the leaderboard is ahead of you.",
    check: |p| p.global_rank.is_some_and(|(position, total)| position == 1 && total >= 3),
  },
  Title {
    key: "dark_horse",
    name: "The Dark Horse",
    reason: "Top ten on the board, and you have barely been to ten sessions.",
    check: |p| p.sessions_attended < 10 && p.global_rank.is_some_and(|(position, _)| position <= 10),
  },
  Title {
    key: "contender",
    name: "The Contender",
    reason: "You are on the podium.",
    check: |p| p.global_rank.is_some_and(|(position, _)| position <= 3),
  },
  Title {
    key: "perfectionist",
    name: "The Perfectionist",
    reason: "You have not missed a single session.",
    check: |p| p.sessions_possible >= 10 && p.sessions_attended >= p.sessions_possible,
  },
  Title {
    key: "phantom",
    name: "The Phantom",
    reason: "You have been auto-signed-out more times than most people have signed in.",
    check: |p| p.forgot_checkout >= 15,
  },
  Title {
    key: "night_shift",
    name: "The Night Shift",
    reason: "You have left the building after midnight more than once.",
    check: |p| p.after_midnight_checkouts >= 3,
  },
  Title {
    key: "unhealthy_achiever",
    name: "The Unhealthy Achiever",
    reason: "Three quarters of your hours are outside the scheduled session.",
    check: |p| p.sessions_attended >= 3 && p.overtime_pct() >= 75,
  },
  Title {
    key: "ultramarathoner",
    name: "The Ultramarathoner",
    reason: "You once stayed for twelve hours straight.",
    check: |p| p.longest_stint_hours() >= 12.0,
  },
  Title {
    key: "overtime_achiever",
    name: "The Overtime Achiever",
    reason: "Half of your hours land outside the scheduled session.",
    check: |p| p.sessions_attended >= 3 && p.overtime_pct() >= 50,
  },
  Title {
    key: "clockwork",
    name: "The Clockwork",
    reason: "Ten sessions, and you have checked in within the same quarter hour every time.",
    check: |p| p.sessions_attended >= 10 && p.check_in_spread_minutes.is_some_and(|spread| spread <= 15),
  },
  Title {
    key: "wildcard",
    name: "The Wildcard",
    reason: "Nobody can predict what time you will walk in.",
    check: |p| p.sessions_attended >= 10 && p.check_in_spread_minutes.is_some_and(|spread| spread >= 360),
  },
  Title {
    key: "institution",
    name: "The Institution",
    reason: "A hundred sessions. You predate most of the team.",
    check: |p| p.sessions_attended >= 100,
  },
  Title {
    key: "night_owl",
    name: "The Night Owl",
    reason: "You have signed out at 10pm or later.",
    check: |p| p.latest_check_out_minutes.is_some_and(|m| m >= 22 * 60),
  },
  Title {
    key: "ghost",
    name: "The Ghost",
    reason: "Five sessions ended with the system signing you out for you.",
    check: |p| p.forgot_checkout >= 5,
  },
  Title {
    key: "marathoner",
    name: "The Marathoner",
    reason: "You once stayed for eight hours straight.",
    check: |p| p.longest_stint_hours() >= 8.0,
  },
  Title {
    key: "weekend_warrior",
    name: "The Weekend Warrior",
    reason: "Five of your check-ins were on a weekend.",
    check: |p| p.weekend_sessions >= 5,
  },
  Title {
    key: "keen_one",
    name: "The Keen One",
    reason: "You are usually there before the session officially starts.",
    check: |p| p.early_arrivals >= 10,
  },
  Title {
    key: "nomad",
    name: "The Nomad",
    reason: "You have checked in at three or more locations.",
    check: |p| p.distinct_locations >= 3,
  },
  Title {
    key: "veteran",
    name: "The Veteran",
    reason: "You have been on the books for over a year.",
    check: |p| p.days_since_first.is_some_and(|days| days >= 365),
  },
  Title {
    key: "sprinter",
    name: "The Sprinter",
    reason: "One of your visits lasted under fifteen minutes.",
    check: |p| p.shortest_stint_secs.is_some_and(|s| s <= 15 * 60),
  },
  Title {
    key: "reliable_one",
    name: "The Reliable One",
    reason: "You turn up to nine sessions in ten.",
    check: |p| p.sessions_possible >= 10 && p.attendance_pct() >= 90,
  },
  Title {
    key: "workhorse",
    name: "The Workhorse",
    reason: "A hundred hours logged.",
    check: |p| p.total_hours() >= 100.0,
  },
  Title {
    key: "regular",
    name: "The Regular",
    reason: "Twenty-five sessions and counting.",
    check: |p| p.sessions_attended >= 25,
  },
  Title {
    key: "clocks_off",
    name: "The Balanced One",
    reason: "Ten sessions, and you have never once run into overtime.",
    check: |p| p.sessions_attended >= 10 && p.overtime_secs <= 0.0,
  },
  Title {
    key: "unwritten",
    name: "The Unwritten",
    reason: "No attendance on record yet — your first check-in writes this.",
    check: |p| p.sessions_attended == 0,
  },
  Title {
    key: "rookie",
    name: "The Rookie",
    reason: "A handful of sessions in. Plenty left to collect.",
    check: |p| p.sessions_attended <= 5,
  },
  // The catch-all. Must stay last, and must match everyone.
  Title {
    key: "team_member",
    name: "The Team Member",
    reason: "Showing up and putting the hours in.",
    check: |_| true,
  },
];

/// The member's title: the first entry in [`TITLES`] whose condition holds.
///
/// Infallible by construction — the final entry matches everybody, and a test enforces it.
#[must_use]
pub fn title_for(profile: &MemberProfile) -> &'static Title {
  TITLES.iter().find(|title| (title.check)(profile)).unwrap_or_else(|| TITLES.last().expect("TITLES is never empty"))
}

#[cfg(test)]
mod tests {
  use std::collections::HashSet;

  use super::*;

  /// A member with nothing on record. Tests set only the fields their rule reads, which keeps
  /// each one legible and stops an unrelated field being accidentally load-bearing.
  fn blank() -> MemberProfile {
    MemberProfile { member_type: "student".to_string(), ..MemberProfile::default() }
  }

  #[test]
  fn achievement_keys_are_unique() {
    // A duplicate key would make the two indistinguishable to anything storing or counting
    // them, and the collision is invisible at a glance in a list this long.
    let mut seen = HashSet::new();
    for achievement in ACHIEVEMENTS {
      assert!(seen.insert(achievement.key), "duplicate achievement key: {}", achievement.key);
    }
  }

  #[test]
  fn title_keys_are_unique() {
    let mut seen = HashSet::new();
    for title in TITLES {
      assert!(seen.insert(title.key), "duplicate title key: {}", title.key);
    }
  }

  #[test]
  fn every_entry_is_described() {
    for achievement in ACHIEVEMENTS {
      assert!(!achievement.name.is_empty(), "{} has no name", achievement.key);
      assert!(!achievement.how.is_empty(), "{} does not say how it is earned", achievement.key);
      assert!(!achievement.emoji.is_empty(), "{} has no emoji", achievement.key);
    }
    for title in TITLES {
      assert!(!title.name.is_empty(), "{} has no name", title.key);
      assert!(!title.reason.is_empty(), "{} has no reason", title.key);
    }
  }

  #[test]
  fn the_last_title_matches_everybody() {
    // `title_for` is infallible only because of this. A new title appended below the catch-all
    // would be unreachable, and the catch-all itself must never grow a condition.
    let last = TITLES.last().expect("TITLES is not empty");
    assert!((last.check)(&blank()));
    assert!((last.check)(&MemberProfile { sessions_attended: 900, total_secs: 9_000_000.0, ..blank() }));
  }

  #[test]
  fn a_brand_new_member_is_unwritten_and_holds_nothing() {
    let profile = blank();
    assert_eq!(title_for(&profile).key, "unwritten");
    assert_eq!(progress(&profile).0, 0, "no achievement should fire on an empty record");
  }

  #[test]
  fn one_session_earns_first_steps_only() {
    let profile = MemberProfile { sessions_attended: 1, sessions_possible: 1, total_secs: 600.0, ..blank() };
    let keys: Vec<&str> = earned(&profile).iter().map(|a| a.key).collect();
    assert_eq!(keys, vec!["first_steps"]);
  }

  #[test]
  fn the_diligent_forgetter_needs_both_halves() {
    // The joke only works on somebody who turns up *and* forgets; either half alone is a
    // different member entirely.
    let forgetful_and_present =
      MemberProfile { sessions_attended: 9, sessions_possible: 10, forgot_checkout: 5, ..blank() };
    assert_eq!(title_for(&forgetful_and_present).key, "diligent_forgetter");

    let forgetful_but_absent =
      MemberProfile { sessions_attended: 5, sessions_possible: 20, forgot_checkout: 5, ..blank() };
    assert_ne!(title_for(&forgetful_but_absent).key, "diligent_forgetter");

    let present_but_tidy = MemberProfile { sessions_attended: 9, sessions_possible: 10, ..blank() };
    assert_ne!(title_for(&present_but_tidy).key, "diligent_forgetter");
  }

  #[test]
  fn overtime_tiers_stack_rather_than_replace() {
    // Tiers are independent conditions, so the 75% member holds 25% and 50% as well. A
    // collection that silently swapped one badge for another would feel like losing something.
    let profile = MemberProfile { sessions_attended: 10, total_secs: 1000.0, overtime_secs: 800.0, ..blank() };
    let keys: Vec<&str> = earned(&profile).iter().map(|a| a.key).collect();
    assert!(keys.contains(&"overtime_25"));
    assert!(keys.contains(&"overtime_50"));
    assert!(keys.contains(&"overtime_75"));
    assert!(!keys.contains(&"overtime_all"), "80% overtime is not all of it");
  }

  #[test]
  fn achievement_unhealthy_outranks_the_ordinary_overtime_titles() {
    // It sits above them in TITLES precisely so the rarer joke wins.
    let profile = MemberProfile { sessions_attended: 4, total_secs: 3600.0, overtime_secs: 3600.0, ..blank() };
    assert_eq!(title_for(&profile).key, "achievement_unhealthy");
    assert!(earned(&profile).iter().any(|a| a.key == "overtime_all"));
  }

  #[test]
  fn ranks_of_one_do_not_crown_anybody() {
    // A board with a single entry makes that member both first and last; "Untouchable" and
    // "Best in Class" should mean beating somebody.
    let alone = MemberProfile { sessions_attended: 3, global_rank: Some((1, 1)), group_rank: Some((1, 1)), ..blank() };
    assert_ne!(title_for(&alone).key, "untouchable");
    assert!(!earned(&alone).iter().any(|a| a.key == "best_in_class"));

    let crowded =
      MemberProfile { sessions_attended: 3, global_rank: Some((1, 12)), group_rank: Some((1, 6)), ..blank() };
    assert_eq!(title_for(&crowded).key, "untouchable");
    assert!(earned(&crowded).iter().any(|a| a.key == "best_in_class"));
  }

  #[test]
  fn hidden_achievements_are_never_previewed_while_locked() {
    let profile = blank();
    assert!(locked(&profile).iter().all(|a| !a.hidden), "a locked list must not leak the secret ones");
    assert!(ACHIEVEMENTS.iter().any(|a| a.hidden), "the catalogue is meant to have secrets in it");
  }

  #[test]
  fn hidden_achievements_still_count_towards_the_total() {
    assert_eq!(progress(&blank()).1, ACHIEVEMENTS.len());
  }

  #[test]
  fn percentages_survive_a_record_with_no_hours() {
    // Division guards: a member who checked in and straight back out has zero seconds.
    let profile = MemberProfile { sessions_attended: 3, ..blank() };
    assert_eq!(profile.overtime_pct(), 0);
    assert_eq!(profile.attendance_pct(), 0);
    assert_eq!(profile.forgot_pct(), 0);
    let _ = earned(&profile);
    let _ = title_for(&profile);
  }
}
