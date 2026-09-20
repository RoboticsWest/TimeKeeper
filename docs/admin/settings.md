# Settings Reference

Every configurable setting, where it lives in the UI, and its fresh-install
default. The list mirrors `Settings` in the server — the whole object is saved
as one row, so nothing here can silently desync from the code.

## Where each setting is edited

- **Setup → Sessions** — check-in window, auto-checkout, timezone, admin
  password, schedule uploads.
- **Setup → Team Members** — quick PIN sign-in, CSV imports, leaderboard
  configuration.
- **Setup → Integrations** — everything Discord.
- **Setup → Branding** — logo.
- **Setup → System** — maintenance mode.
- **Gear Settings** (device) — kiosk mode, scan debounce, server address/TLS.

## System & attendance

| Setting | Default | Meaning |
|---------|---------|---------|
| Check-in Window | 4 hours | ± this far from a session's start/end a scan still counts. |
| Auto Check-out After | 24 hours | grace before lingering members are auto-checked-out (or when the next session at the location starts). |
| Timezone | — (empty) | UTC offset used for display/schedule parsing. |
| Quick PIN Sign-In | off | allow kiosk PIN logins; PINs are server-side and unique. |
| Admin Password | *(in flux)* | changes the bootstrap `admin` password. |
| Maintenance Mode | off | shows a client banner and makes the Discord bot refuse commands. |
| Maintenance Message | *(default text)* | opt-in reason shown when maintenance is on. |

## Discord

| Setting | Default | Meaning |
|---------|---------|---------|
| Discord Enabled | off | master switch for the bot + notifications. |
| Bot Token | — | bot token from the Discord Developer Portal. |
| Server ID | — | the guild the bot operates in. |
| Announcement Channel ID | — | where start/end reminders post. |
| Notification Channel ID | — | where overtime/auto-checkout ("DM-style") messages post. |
| Self-Linking | off | lets members run `!link Name` to bind their account. |
| Name Syncing | off | copies Discord nicknames into member display names (every 60 s). |
| Checkout | off | enables the Discord `!checkout` command. |
| Start Reminder | 24 h before | minutes ahead of a session start to post, plus the templated message. |
| End Reminder | 15 min before | minutes ahead of a session end to post, plus the templated message. |
| Start / End Auto-Delete | off | delete the reminder from Discord after the start/end time passes. |
| Overtime DM | on · 10 min after end | DM members still checked in after a session ends, once. |
| Auto Checkout DM | on | DM members when auto-checked-out. |
| RSVP Reactions | on | 👍/👎 on start reminders feed per-session RSVPs. |

Message templates support the full
[placeholder set](../app/notifications.md#templates-placeholders).

## Leaderboard

| Setting | Default | Meaning |
|---------|---------|---------|
| Member Types on Leaderboard | student + mentor | which member types appear (app + `!leaderboard`). |
| Show Overtime Separately | on | overtime rendered as `+1h 30m` in red vs folded in. |

## Branding

| Setting | Default | Meaning |
|---------|---------|---------|
| Logo | *(none)* | replaces the app bar / login logo site-wide; PNG or JPG. |

## Defaults recap (fresh install)

A brand-new database seeds this single row.

??? note "The exact default `Settings` row"

    ```text
    check_in_window_secs             = 4h
    auto_checkout_after_secs         = 24h
    quick_pin_enabled                = false
    timezone                         = ""
    leaderboard_show_overtime        = true
    leaderboard_member_types         = [student, mentor]
    maintenance_mode                 = false
    maintenance_message              = ""

    discord_enabled                  = false
    discord_bot_token / guild / chans= "" (unset)
    discord_self_link_enabled        = false
    discord_name_sync_enabled        = false
    discord_checkout_enabled         = false
    discord_start_reminder_mins      = 1440 (24 h)
    discord_end_reminder_mins        = 15
    discord_overtime_dm_enabled      = true
    discord_overtime_dm_mins         = 10
    discord_auto_checkout_dm_enabled = true
    discord_rsvp_reactions_enabled   = true
    discord_auto_delete_start/end    = false / false
    ```

    Changing a field later just upserts the single row — missing columns never
    silently evaporate defaults.
