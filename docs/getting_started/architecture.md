# Architecture

TimeKeeper is a **Rust** server (axum + async-graphql + Diesel) with a
**Flutter** client. All real-time behaviour is driven by Postgres change
notifications pushed over GraphQL WebSocket subscriptions.

## High-level picture

```mermaid
flowchart LR
  subgraph Client["Flutter client"]
    APP[Web · desktop · Android]
  end

  subgraph Server["server binary (axum)"]
    WEB[":8080 — static client + API"]
    API[":4000 — /graphql · /graphql/ws · /health"]
    SYNC[Change-stream relay]
    SCHED[SessionService · Discord bot · NotificationService]
    JWT[Auth · JWT · permissions]
  end

  DB[(Postgres 15+)] -->|NOTIFY db_changes| SYNC

  APP -->|WebSocket subscriptions| API
  APP -->|queries · mutations| API
  APP --> WEB
  SCHED -->|HTTP| DISCORD["Discord gateway + REST"]
  SCHED --> DB
  API --> DB
  SYNC -->|row deltas| API
```

### Clients

The Flutter app targets **web, desktop (Linux/macOS/Windows) and Android**, one
codebase. It never queries for data it can subscribe to: each collection is
"seeded by query, kept current by a change subscription", with a re-pull on the
change stream's recovery after an outage (so missed deltas are never silently
dropped).

Only three things poll: `/health` every 10 s, a 30 s minute-quantiser for the
statistics dashboard, and the server version check every 3 h.

### Server internals

| Piece | What it does |
|-------|--------------|
| Web listener (`:8080`) | Serves the compiled Flutter build *and* the API on the same origin; sets `application/wasm` + cross-origin isolation headers for the Wasm build. |
| API listener (`:4000`) | `/graphql`, `/graphql/ws`, `/health`. Same handler set as the web listener. |
| Change stream | Postgres triggers `NOTIFY db_changes` on every write (`0001_init/up.sql`); the relay re-broadcasts rows to subscribed clients by table. |
| SessionService | Every 5 s: checks auto-checkout for past-end sessions, marks sessions finished, yesterday's sweeps. |
| DiscordNotificationService | Every 60 s: fires due reminders/DMs, deletes sent ones if auto-delete is on, syncs Discord nicknames. |
| Discord gateway bot | Prefix `!` chat commands, RSVP 👍/👎 reactions, maintenance gate. |
| Auth | JWT (7-day expiry) with a permissions snapshot resolved at login. |

The web port is optional — `--no-web` yields a pure API server for
[reverse-proxied production](deployment.md).

## Data model

```mermaid
erDiagram
    users ||--o{ user_roles : has
    roles ||--o{ user_roles : granted
    roles ||--o{ role_permissions : grants
    resources ||--o{ role_permissions : scoped

    team_members ||--o{ rfid_tags : owns
    team_members ||--o{ team_member_sessions : checks_in
    team_members ||--o{ session_rsvps : rsvps_to
    locations ||--o{ sessions : hosts
    sessions ||--o{ team_member_sessions : contains
    sessions ||--o{ session_rsvps : receives
    sessions ||--o{ session_rsvp_messages : announced
    sessions ||--o{ notifications : schedules
    team_members ||--o{ notifications : notifies

    users {
        uuid id
        text username
        text password
    }
    team_members {
        uuid id
        text first_name
        text last_name
        text member_type "student | mentor"
        text display_name
        text discord_id
        text quick_pin
    }
    rfid_tags {
        uuid id
        uuid team_member_id
        text tag
    }
    locations {
        uuid id
        text location
    }
    sessions {
        uuid id
        uuid location_id
        timestamptz start_time
        timestamptz end_time
        boolean finished
        timestamptz actual_start_time
        timestamptz actual_end_time
    }
    team_member_sessions {
        uuid id
        uuid team_member_id
        uuid session_id
        timestamptz check_in_time
        timestamptz check_out_time
    }
    session_rsvps {
        uuid id
        uuid session_id
        uuid team_member_id
        text status "going | not_going"
    }
    notifications {
        uuid id
        text notification_type
        uuid session_id
        uuid team_member_id
        timestamptz scheduled_for
        text status "pending | sent | skipped | cancelled | failed"
    }
```

`settings` is a deliberately single-row table (all server config), as are
`secret` (JWT signing secret) and `logos` (branding). Migrations live in
`database/migrations/` (Diesel) — including schema-based views
`permissions_effective` and `user_permissions` that power authorization.

## Realtime pipeline

```mermaid
sequenceDiagram
    autonumber
    participant D as Postgres
    participant S as Server relay
    participant C as Flutter client
    D->>S: INSERT/UPDATE/DELETE → NOTIFY db_changes
    S->>C: WS push {table, entity, kind} delta
    C->>C: apply to id-keyed collection (re-pull on recovery)
```

## Authorization

- A **role** may be `is_super` (bypasses every grant) or carry explicit
  `resource → level` rows.
- Levels are **read < write < delete**, ceiling semantics: `write` satisfies a
  `read` requirement.
- Effective per-user permissions come from the `user_permissions` view (max
  level across the user's roles), then snapshotted into the JWT at login.
- Every server mutation re-checks the claim server-side; the client's rail/UI
  gating is convenience, not security.

See [Users, Roles & Permissions](../admin/users.md).

## Related

- [Running the server](server_reference.md) — listeners, ports, env.
- [Check-in Windows & Auto Checkout](../kiosk/checkout.md) — what the
  SessionService enforces.
