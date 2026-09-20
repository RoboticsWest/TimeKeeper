# TimeKeeper

**Time-tracking and attendance for FIRST Robotics Competition teams.**

TimeKeeper runs a team's daily sessions: team members tap in on a kiosk
(RFID or PIN), sessions start and end, and everyone's hours flow into live
leaderboards, statistics and achievements — with a Discord bot to remind people
when sessions begin and end.

## What it does

- **Sessions & attendance** — sign in and out at a location, with a 4-hour
  check-in window around each session and automatic check-out for stragglers.
- **A self-serve kiosk** — RFID tap (PCSC smart-card readers or keyboard-wedge
  scanners) or a quick PIN signs members in and out. No admin needed.
- **Leaderboards & statistics** — who has the most hours, this week / month /
  all time, overtime tracking, and per-member breakdowns you can export to CSV.
- **Achievements & badges** — earn titles for hours, attendance streaks and
  rituals; rarity is measured against your *active* members.
- **Discord integration** — the bot posts start/end reminders, pings members in
  overtime, links Discord accounts to cards, checks members out, and runs
  `!leaderboard`, `!mystats`, `!awards` and more.
- **Real-time everywhere** — every device updates the instant anything changes,
  thanks to Postgres change notifications pushed over GraphQL subscriptions.

## Where to next

!!! tip "I want to run it myself"

    Follow the [Quickstart](getting_started/quickstart.md) — one binary, no
    database to install. Then branch out to
    [Installation](getting_started/install.md), the
    [server reference](getting_started/server_reference.md) and
    [deployment](getting_started/deployment.md) for a production setup with TLS.

!!! tip "I'm setting it up for our team"

    Start with the [Admin Quickstart](admin/quickstart.md), then read the
    [Settings Reference](admin/settings.md) and [Import & Export](admin/import_export.md)
    to get members in and a schedule uploaded.

!!! tip "I want to understand how it works"

    See the [Architecture](getting_started/architecture.md) page, the
    [Kiosk & RFID](kiosk/kiosk.md) area, and the full
    [Discord Bot](discord/discord.md) page.

!!! tip "I have a problem or an idea"

    Check [Bug Reports](support/bug_reports.md), [Change Requests](support/change_requests.md)
    or the [Q&A discussions](https://github.com/CurtinFRC/TimeKeeper/discussions).

!!! quote ""

    Inspired by the greats — Team 254's "Cheesy Hours" and Team 3132's
    Attendance system — TimeKeeper brings a whole-team attendance kit to your shop.
