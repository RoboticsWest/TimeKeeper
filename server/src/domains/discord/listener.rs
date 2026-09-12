use serenity::all::{Context, Message, Reaction, ReactionType, UserId};

use crate::domains::session_rsvp;
use crate::domains::team_member::TeamMember;

use super::commands::handle_command;
use super::deps::DiscordDeps;

fn reaction_to_rsvp_status(emoji: &ReactionType) -> Option<&'static str> {
  match emoji {
    ReactionType::Unicode(s) if s == "👍" => Some("going"),
    ReactionType::Unicode(s) if s == "👎" => Some("not_going"),
    _ => None,
  }
}

async fn resolve_team_member(deps: &DiscordDeps, reaction: &Reaction) -> Option<TeamMember> {
  // The reaction already carries the user's ID, which is exactly what members
  // are keyed on - no need to resolve it back into a username over HTTP.
  let user_id = reaction.user_id?;
  deps.team_members.get_by_discord_id(&user_id.to_string()).await.ok()?
}

/// Handles an incoming chat message: mention greeting, then `!`-prefixed commands.
pub async fn on_message(ctx: &Context, msg: &Message, deps: &DiscordDeps, bot_user_id: Option<UserId>) {
  if msg.author.bot {
    return;
  }

  if let Some(bot_id) = bot_user_id
    && msg.mentions.iter().any(|u| u.id == bot_id)
  {
    let _ = msg.channel_id.say(&ctx.http, "Sup? Use `!help` to see what I can do.").await;
    return;
  }

  handle_command(ctx, msg, deps).await;
}

/// Handles a member adding an RSVP-emoji reaction to a tracked session announcement.
pub async fn on_reaction_add(reaction: &Reaction, deps: &DiscordDeps, bot_user_id: Option<UserId>) {
  let Some(user_id) = reaction.user_id else { return };
  if Some(user_id) == bot_user_id {
    return;
  }
  let Some(status) = reaction_to_rsvp_status(&reaction.emoji) else { return };
  let Some(member) = resolve_team_member(deps, reaction).await else { return };

  session_rsvp::listener::handle_reaction_add(
    &deps.settings,
    &deps.session_rsvps,
    &deps.session_rsvp_messages,
    &reaction.message_id.to_string(),
    member.id,
    status,
  )
  .await;
}

/// Handles a member removing an RSVP-emoji reaction - clears their RSVP for the session.
pub async fn on_reaction_remove(reaction: &Reaction, deps: &DiscordDeps, bot_user_id: Option<UserId>) {
  let Some(user_id) = reaction.user_id else { return };
  if Some(user_id) == bot_user_id {
    return;
  }
  if reaction_to_rsvp_status(&reaction.emoji).is_none() {
    return;
  }
  let Some(member) = resolve_team_member(deps, reaction).await else { return };

  session_rsvp::listener::handle_reaction_remove(
    &deps.settings,
    &deps.session_rsvps,
    &deps.session_rsvp_messages,
    &reaction.message_id.to_string(),
    member.id,
  )
  .await;
}
