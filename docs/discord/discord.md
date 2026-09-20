# Discord Bot

One page to get the Discord integration running and know what it can do.

## What it is

The bot is two parts of the same settings row: a **chat bot** (prefix `!`
commands, reaction handling) and a **notification service** (@here reminders,
overtime/auto-checkout DMs). All Discord config lives in **Setup →
Integrations**.

## Setup checklist

**Discord Developer Portal** (on the bot application):

1. Create a bot, copy its **token**.
2. Enable privileged intents **Message Content** (commands are read from
   message text) and **Server Members** (member import + name sync use the
   `/guilds/{id}/members` REST API).
3. Invite the bot to the guild with permissions to **view channels**, **send
   messages**, **add reactions**, and (for auto-delete) **manage/delete
   messages**.

**In TimeKeeper → Setup → Integrations:**

4. Flip **Discord Enabled**.
5. Paste **Bot Token** and **Server ID**.
6. Set **Announcement Channel ID** (start/end reminders) and **Notification
   Channel ID** (overtime / auto-checkout messages).
7. Tune reminders (minutes + templates), the overtime/auto-checkout DMs,
   self-linking, name sync, and RSVP reactions.

Nothing connects until `discord_enabled` is on and the token/guild are set;
notifications additionally need both channel IDs.

## Linking members

- **`!link Name`** — the member types their server display name (or just their
  first+last) and the bot binds their Discord ID to that member. Refused unless
  **Self-Linking** is on.
- **Import from Discord** (Setup → Integrations) — *Fetch Roles* →
  *Import as Students / Mentors*; members get their Discord IDs for free. See
  [Import & Export](../admin/import_export.md#import-from-discord).
- **Name sync** — with **Name Syncing** on, Discord nicknames overwrite member
  display names every 60 s.

## Commands

| Command | What it does |
|---------|--------------|
| `!ping` | Pong. |
| `!help` | Lists the commands. |
| `!leaderboard` | Hours board — top 15, filters `students` / `mentors` / `help`. |
| `!sessions` | The active session plus up to 5 upcoming ones. |
| `!checkedin` | Who's checked in, grouped by location, longest-first. |
| `!locations` | Every location. |
| `!link Name` | Link the caller's Discord account to a member. |
| `!checkout` | Check yourself out of your current session (records hours; needs **Discord Checkout** enabled + a linked account). |
| `!mystats` | Your title, ranks, attendance and overtime. |
| `!awards` | Your achievements; `!awards all` = browse the whole catalogue (8 per page, Prev/Next buttons); `!awards help`. |

Mentioning the bot replies *"Sup? Use `!help`…"*. Unknown commands stay silent.
During **maintenance mode** every recognized command replies with the
maintenance warning instead.

!!! note "Which commands need a linked account"

    `!checkout`, `!mystats` and `!awards` identify you by your linked
    Discord ID — unlinked callers are told to `!link Name` or ask an admin.

## Notifications & reminders

| Kickoff | What happens | Channel |
|---------|--------------|---------|
| `start - startReminderMins` | `@here` session-start reminder (+ 👍/👎 if RSVP reactions on) | Announcement |
| `end - endReminderMins` | `@here` end reminder — *"don't forget to sign out!"* | Announcement |
| `end + overtimeMins` | DM every member still checked in (once) | Notification |
| auto-check-out fires | DM the checked-out member | Notification |

- Reminders are pre-scheduled when a session is created; a late one asks
  *"Send reminder now?"* at creation time. Editing a session's times re-derives
  still-pending reminders.
- **Auto-delete** (per reminder type) removes the message from Discord after
  its start/end time passes.
- Template placeholders: `{location}`, `{start_time}`, `{end_time}`,
  `{relative_day}`, `{weekday}`, `{mins}`, … plus `{username}` / `{name}` in
  DMs — see [Notifications & RSVP](../app/notifications.md#templates-placeholders).
- Everything is logged in the **Notifications** admin view with a delivery
  status (Scheduled / Sent / Skipped / Cancelled / Failed).

## RSVP

With **RSVP Reactions** on, start reminders carry 👍/👎 and members' reactions
become per-session RSVPs (`going` / `not_going`), feeding the kiosk's expected
count and the sessions table. Unreacting clears the RSVP.

## Defaults (fresh install)

Start reminder **24 h before** · end reminder **15 min before** · overtime DM
**10 min after** end (on) · RSVP reactions **on** · auto-delete **off** ·
self-link / name sync / checkout / bot itself **off** until you switch them on.
