//! Titles and achievements for real members — the bridge between the pure catalogue in
//! [`super::achievements`] and the data a member has actually accrued.
//!
//! Everything here is computed on demand and stored nowhere. The catalogue holds predicates over
//! a [`MemberProfile`]; this builds those profiles from the database and runs the predicates.
//!
//! One snapshot loads the whole picture — sessions, attendance, recorded statistics and the
//! leaderboard — and every member is derived from it. That is deliberate even when only one
//! member was asked for: ranks are a property of the field, not of a person, so there is no such
//! thing as computing one member's rank without looking at everybody. Loading the rest alongside
//! it costs one extra query each and removes the N+1 that a per-member path would otherwise
//! invite.

use std::collections::HashMap;

use async_trait::async_trait;
use chrono::{DateTime, Utc};
use uuid::Uuid;

use crate::domains::session::SessionRepository;
use crate::domains::settings::SettingsRepository;
use crate::domains::team_member::TeamMemberRepository;
use crate::domains::team_member_session::TeamMemberSessionRepository;
use crate::time::parse_tz;

use super::achievements::{self, ACHIEVEMENTS};
use super::logic::StatisticsLogic;
use super::model::{AttendanceStats, TeamMemberStats};
use super::profile::{self, MemberProfile, ProfileInput};
use super::repository::MemberStatsRepository;

/// One member's derived figures, plus the first check-in a stat card wants to show.
pub struct MemberSnapshot {
  pub profile: MemberProfile,
  /// Their earliest check-in. The schema keeps no enrollment date, so this is the closest
  /// honest answer to "in TimeKeeper since".
  pub first_check_in: Option<DateTime<Utc>>,
}

/// One achievement as it stands for a particular member.
#[derive(async_graphql::SimpleObject)]
pub struct AchievementView {
  /// Stable identifier. Safe to persist or match on; the display name is not.
  pub key: String,
  /// Standard Unicode emoji — never a custom server emoji, which would not render for everyone.
  pub emoji: String,
  pub name: String,
  /// How it is earned.
  pub how: String,
  /// Hidden ones should be rendered as a locked secret until `earned` is true.
  pub hidden: bool,
  pub earned: bool,
  /// How many team members currently hold this one.
  pub holders: i32,
  /// How many members there are to hold it — the denominator behind [`rarity_pct`].
  pub total_members: i32,
  /// Share of the team holding this, 0-100. The whole point of a collection is that some of it
  /// is hard to get; without this every badge looks equally ordinary.
  ///
  /// Zero when there are no members at all, rather than undefined.
  pub rarity_pct: f64,
}

impl AchievementView {
  /// A one-word description of how hard this is to hold, from the share of the team that does.
  ///
  /// Bands rather than a bare percentage because "12%" means nothing without knowing the team
  /// size, and on a roster of twelve every figure is a multiple of eight.
  #[must_use]
  pub fn rarity_label(&self) -> &'static str {
    if self.total_members == 0 {
      return "Unrated";
    }
    match self.rarity_pct {
      p if p <= 0.0 => "Unclaimed",
      p if p < 10.0 => "Legendary",
      p if p < 25.0 => "Rare",
      p if p < 50.0 => "Uncommon",
      p if p < 90.0 => "Common",
      _ => "Everyone",
    }
  }
}

/// A member's title and their whole collection.
#[derive(async_graphql::SimpleObject)]
pub struct MemberAccolades {
  pub team_member_id: Uuid,
  /// The member's display name, so a client listing accolades need not join the roster itself.
  pub name: String,
  pub member_type: String,
  pub title: String,
  /// Why they hold that title, in the second person.
  pub title_reason: String,
  pub earned_count: i32,
  pub total_count: i32,
  /// The entire catalogue in its declared order, each flagged earned or not — so a client can
  /// render the full board rather than only what somebody has.
  pub achievements: Vec<AchievementView>,
}

#[async_trait]
pub trait AccoladesLogic: Send + Sync {
  /// One member's derived figures, or `None` when no such member exists.
  async fn profile_for(&self, team_member_id: Uuid) -> anyhow::Result<Option<MemberSnapshot>>;

  /// Accolades for every member, ordered by achievements held (most first), then by name.
  async fn for_all(&self) -> anyhow::Result<Vec<MemberAccolades>>;

  async fn for_member(&self, team_member_id: Uuid) -> anyhow::Result<Option<MemberAccolades>>;

  /// The whole catalogue with nothing marked earned, but rated for rarity against the real team.
  /// What there is to collect, and how many people already have it.
  async fn catalogue(&self) -> anyhow::Result<Vec<AchievementView>>;
}

pub struct DefaultAccoladesLogic {
  sessions: std::sync::Arc<dyn SessionRepository>,
  team_members: std::sync::Arc<dyn TeamMemberRepository>,
  team_member_sessions: std::sync::Arc<dyn TeamMemberSessionRepository>,
  settings: std::sync::Arc<dyn SettingsRepository>,
  member_stats: std::sync::Arc<dyn MemberStatsRepository>,
  statistics: std::sync::Arc<dyn StatisticsLogic>,
}

impl DefaultAccoladesLogic {
  pub fn new(
    sessions: std::sync::Arc<dyn SessionRepository>,
    team_members: std::sync::Arc<dyn TeamMemberRepository>,
    team_member_sessions: std::sync::Arc<dyn TeamMemberSessionRepository>,
    settings: std::sync::Arc<dyn SettingsRepository>,
    member_stats: std::sync::Arc<dyn MemberStatsRepository>,
    statistics: std::sync::Arc<dyn StatisticsLogic>,
  ) -> Self {
    Self { sessions, team_members, team_member_sessions, settings, member_stats, statistics }
  }

  /// Builds a profile for every member from a single load of the whole picture.
  async fn snapshot_all(&self) -> anyhow::Result<HashMap<Uuid, MemberSnapshot>> {
    let settings = self.settings.get().await?;
    let tz = parse_tz(&settings.timezone);
    let now = Utc::now();

    let sessions = self.sessions.get_all().await?;
    let members = self.team_members.get_all().await?;
    let all_attendance = self.team_member_sessions.get_all().await?;
    let all_stats = self.member_stats.get_all_attendance().await?;
    let member_stats = self.member_stats.get_all_members().await?;

    // Unfiltered: the configured `leaderboard_member_types` default is about what the *board*
    // shows, and must never decide whose rank exists.
    let entries = self.statistics.get_leaderboard(Some(Vec::new())).await?;
    let total_ranked = entries.len();

    let mut attendance_by_member: HashMap<Uuid, Vec<_>> = HashMap::new();
    for ms in all_attendance {
      attendance_by_member.entry(ms.team_member_id).or_default().push(ms);
    }

    let mut stats_by_member: HashMap<Uuid, Vec<AttendanceStats>> = HashMap::new();
    let attendance_owner: HashMap<Uuid, Uuid> =
      attendance_by_member.iter().flat_map(|(owner, rows)| rows.iter().map(|ms| (ms.id, *owner))).collect();
    for stats in all_stats {
      if let Some(owner) = attendance_owner.get(&stats.team_member_session_id) {
        stats_by_member.entry(*owner).or_default().push(stats);
      }
    }

    let stats_row_by_member: HashMap<Uuid, TeamMemberStats> =
      member_stats.into_iter().map(|row| (row.team_member_id, row)).collect();

    // Group sizes are per member type, matching `!leaderboard students` / `!leaderboard mentors`.
    let mut group_entries: HashMap<&str, Vec<Uuid>> = HashMap::new();
    for entry in &entries {
      group_entries.entry(entry.team_member.member_type.as_str()).or_default().push(entry.team_member_id);
    }

    let mut snapshots = HashMap::new();
    for member in members {
      let entry = entries.iter().find(|e| e.team_member_id == member.id);
      let global_rank =
        entries.iter().position(|e| e.team_member_id == member.id).map(|i| (i + 1, total_ranked.max(1)));
      let group = group_entries.get(member.member_type.as_str());
      let group_rank = group.and_then(|ids| ids.iter().position(|id| *id == member.id).map(|i| (i + 1, ids.len())));

      let member_sessions = attendance_by_member.get(&member.id).cloned().unwrap_or_default();
      let attendance_stats = stats_by_member.get(&member.id).cloned().unwrap_or_default();
      let counters = stats_row_by_member.get(&member.id).cloned().unwrap_or_else(|| TeamMemberStats::zeroed(member.id));

      let first_check_in = member_sessions.iter().map(|ms| ms.check_in_time).min();

      let profile = profile::build(&ProfileInput {
        member_type: member.member_type.clone(),
        member_sessions: &member_sessions,
        sessions: &sessions,
        attendance_stats: &attendance_stats,
        member_stats: &counters,
        tz,
        now,
        total_secs: entry.map_or(0.0, |e| e.total_secs),
        this_week_secs: entry.map_or(0.0, |e| e.this_week.regular_secs + e.this_week.overtime_secs),
        active_secs: entry.map_or(0.0, |e| e.active_session.regular_secs + e.active_session.overtime_secs),
        global_rank,
        group_rank,
      });

      snapshots.insert(member.id, MemberSnapshot { profile, first_check_in });
    }

    Ok(snapshots)
  }
}

/// How many members hold each achievement, keyed on achievement key.
fn count_holders(profiles: &[&MemberProfile]) -> HashMap<&'static str, i32> {
  let mut holders: HashMap<&'static str, i32> = ACHIEVEMENTS.iter().map(|a| (a.key, 0)).collect();
  for profile in profiles {
    for achievement in ACHIEVEMENTS {
      if (achievement.check)(profile) {
        *holders.entry(achievement.key).or_default() += 1;
      }
    }
  }
  holders
}

/// Renders the whole catalogue against one profile.
fn accolades_for(
  team_member_id: Uuid,
  name: String,
  profile: &MemberProfile,
  holders: &HashMap<&'static str, i32>,
  total_members: i32,
) -> MemberAccolades {
  let title = achievements::title_for(profile);
  let achievements: Vec<AchievementView> =
    ACHIEVEMENTS.iter().map(|a| view_for(a, (a.check)(profile), holders, total_members)).collect();

  let earned_count = i32::try_from(achievements.iter().filter(|a| a.earned).count()).unwrap_or(i32::MAX);
  let total_count = i32::try_from(achievements.len()).unwrap_or(i32::MAX);

  MemberAccolades {
    team_member_id,
    name,
    member_type: profile.member_type.clone(),
    title: title.name.to_string(),
    title_reason: title.reason.to_string(),
    earned_count,
    total_count,
    achievements,
  }
}

#[async_trait]
impl AccoladesLogic for DefaultAccoladesLogic {
  async fn profile_for(&self, team_member_id: Uuid) -> anyhow::Result<Option<MemberSnapshot>> {
    Ok(self.snapshot_all().await?.remove(&team_member_id))
  }

  async fn for_all(&self) -> anyhow::Result<Vec<MemberAccolades>> {
    let snapshots = self.snapshot_all().await?;
    let members = self.team_members.get_all().await?;

    // Rarity is measured against everyone with a profile, which is every member — including the
    // ones holding nothing. Counting only members who hold *something* would quietly inflate
    // every percentage and make a common badge look special.
    let profiles: Vec<&MemberProfile> = snapshots.values().map(|s| &s.profile).collect();
    let total_members = i32::try_from(profiles.len()).unwrap_or(i32::MAX);
    let holders = count_holders(&profiles);

    let mut all: Vec<MemberAccolades> = members
      .into_iter()
      .filter_map(|member| {
        let snapshot = snapshots.get(&member.id)?;
        let name = member.display_name.clone().unwrap_or_else(|| format!("{} {}", member.first_name, member.last_name));
        Some(accolades_for(member.id, name, &snapshot.profile, &holders, total_members))
      })
      .collect();

    // Most decorated first; name breaks the tie so the order is stable between refreshes rather
    // than following whatever order the roster query happened to return.
    all.sort_by(|a, b| {
      b.earned_count.cmp(&a.earned_count).then_with(|| a.name.to_lowercase().cmp(&b.name.to_lowercase()))
    });
    Ok(all)
  }

  async fn for_member(&self, team_member_id: Uuid) -> anyhow::Result<Option<MemberAccolades>> {
    Ok(self.for_all().await?.into_iter().find(|a| a.team_member_id == team_member_id))
  }

  async fn catalogue(&self) -> anyhow::Result<Vec<AchievementView>> {
    let snapshots = self.snapshot_all().await?;
    let profiles: Vec<&MemberProfile> = snapshots.values().map(|s| &s.profile).collect();
    let total_members = i32::try_from(profiles.len()).unwrap_or(i32::MAX);
    let holders = count_holders(&profiles);

    Ok(ACHIEVEMENTS.iter().map(|a| view_for(a, false, &holders, total_members)).collect())
  }
}

/// One catalogue entry rendered for a viewer, carrying both whether they hold it and how many
/// others do. Single place that turns an [`achievements::Achievement`] into a view, so the
/// Discord embeds and the app can never disagree about what a badge is called or how rare it is.
fn view_for(
  achievement: &'static achievements::Achievement,
  earned: bool,
  holders: &HashMap<&'static str, i32>,
  total_members: i32,
) -> AchievementView {
  let held = holders.get(achievement.key).copied().unwrap_or(0);
  let rarity_pct = if total_members > 0 { f64::from(held) * 100.0 / f64::from(total_members) } else { 0.0 };

  AchievementView {
    key: achievement.key.to_string(),
    emoji: achievement.emoji.to_string(),
    name: achievement.name.to_string(),
    how: achievement.how.to_string(),
    hidden: achievement.hidden,
    earned,
    holders: held,
    total_members,
    rarity_pct,
  }
}
