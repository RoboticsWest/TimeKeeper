# Maintenance & Reset

## Maintenance Mode

**Setup → System → Maintenance Mode** puts TimeKeeper into a read-only-ish,
politely-unavailable state:

- the client shows a dismissible amber banner with the reason,
- the Discord bot **refuses every recognized command** with a
  *Maintenance Mode* warning.

An optional **Maintenance Message** overrides
*"TimeKeeper is under maintenance. Some features may be unavailable — please try
again shortly."* if you left it blank.

Use it before disruptive changes (a schema migration team, a kiosk reshuffle) —
it's softer than turning the server off and tells members what's happening.

## Purge Database

**Setup → Database → Purge Database** wipes everything. The exact warning shown:

> **WARNING: This will permanently delete ALL data including sessions, team
> members, locations, users, and settings. Only the default admin account will
> be recreated. This action cannot be undone!**

After a purge:

- the system returns to the [bootstrap state](../getting_started/server_reference.md#first-boot):
  `admin` / `admin` (or `TK_ADMIN_PASSWORD`), fresh settings defaults,
- settings are recreated from defaults (including Discord config, branding logo
  and leaderboard options),
- the JWT secret is regenerated — existing logged-in clients get signed out.

!!! danger "Back up first"

    A purge is immediate and permanent. If you keep data, dump your Postgres
    first (`pg_dump`, or copy `.pgdata/` in embedded mode), and export the
    rosters/schedules via **Setup → Data → Export CSV** to re-import the
    non-record data afterwards.

## Data exports (non-destructive safety net)

**Setup → Data** exports everything a purge discards except the attendance
records themselves: `Export Students CSV` · `Export Mentors CSV` · `Export
Schedule CSV` · `Export Attendance CSV`. Combined with a database dump, that is
a full recovery kit.

## Device settings (per client)

From the gear icon — these affect only this device:

| Setting | Purpose |
|---------|---------|
| Device Location | which location's sessions this kiosk/device participates in. |
| Kiosk Mode | desktop-only: fullscreen + always-on-top. |
| Scan Debounce (minutes) | minimum seconds between repeated card scans (default 5). |
| Use TLS (HTTPS/WSS) | non-web: `https` + `wss` against the API. |
| Server Address / GraphQL Port | where the API lives (hidden on web). |

## Version & updates

- The app bar shows the running version; a gate polls the server for a newer
  build every 3 h and offers **A newer TimeKeeper is available** with
  *Copy link* / *Later*.
- Rollbacks in production are instant — old builds stay at `/v/<prev>/` for one
  cycle (see [Deployment](../getting_started/deployment.md#caddy)).
