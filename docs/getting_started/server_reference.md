# Running the Server

The server is a single binary (`server`, crate `server`) that hosts the GraphQL
API, real-time change streams, the Discord bot and — in single-binary mode — the
compiled web app and an embedded database.

Run `./server --help` (or `cargo run -p server -- --help`) for the authoritative
list. Everything below mirrors the current version.

## Command-line arguments

| Flag | Default | Description |
|------|---------|-------------|
| `--addr` | `0.0.0.0` | Bind address for the **web** listener (the static client + API). |
| `--web-port` | `8080` | Port for the web client. Serves the Flutter build and the API on the same origin. |
| `--no-web` | off | Disable the web listener entirely. Use when a reverse proxy serves the client (Caddy in production) or the API is consumed separately. |
| `--web-dir` | `client/build/web` | Directory of the compiled Flutter web build to serve. |
| `--graphql-port` | `4000` | API listener. Serves `/graphql`, `/graphql/ws` (subscriptions) and `/health`. |
| `--database-url` | *(embedded)* | Postgres connection string. See `DATABASE_URL` below. |
| `--backups-path` | `backups` | *(reserved — no backup feature ships yet)* |
| `--admin-password` | `admin` | Password for the bootstrap `admin` account. See `TK_ADMIN_PASSWORD`. |

### Example invocations

```bash
# Single-binary shop machine: web + API + embedded Postgres
./server

# API only, reverse proxy serves the web app
./server --no-web --graphql-port 4000

# External Postgres, custom web port, branded admin password
DATABASE_URL="postgres://user:pass@db/timekeeper" \
TK_ADMIN_PASSWORD='s3cret' \
./server --web-port 8080 --graphql-port 4000
```

## Environment variables

| Variable | Effect |
|----------|--------|
| `DATABASE_URL` | Postgres connection string. When unset, an embedded Postgres is started under `./.pgdata` (username/password `postgres`/`postgres`, database `timekeeper`) and migrated automatically. Set it to run against a managed instance. |
| `TK_ADMIN_PASSWORD` | Overrides the password for the bootstrap `admin` account. Ignored once a real admin user exists. Supersedes `--admin-password` if both are present. |
| `RUST_LOG` | Log level, e.g. `info`, `debug`, `timekeeper=debug`. Tuned by the deployment compose file. |

## The two listeners

```
        :8080  ──►  static Flutter build (index.html + assets)
   +────────────────  /graphql  /graphql/ws  /health   ◄── same origin, zero config

   …health polled by the client every 10 s; app bar turns red "Disconnected" on failure

        :4000  ──►  /graphql  /graphql/ws  /health      ◄── API-only
```

- The client polls `/health` every 10 s and shows a red **Disconnected** app bar
  when the server is unreachable.
- GraphQL subscriptions over WebSocket push row-level changes; the client
  re-syncs a collection when the stream recovers from an outage.

## First boot

On first start the server:

1. Creates/migrates the database and seeds a single-row `settings` record with
   the [defaults](../admin/settings.md).
2. Generates a **JWT signing secret** and persists it (see
   [Encryption & auth](configuration.md#encryption-and-authentication)).
3. Creates the bootstrap **admin** account (`admin` / `admin` unless overridden)
   if no user can sign in.

## Admin bootstrap

- Username `admin`, password `admin` (or `TK_ADMIN_PASSWORD`).
- Change it in **Setup → Sessions → Admin Password**.
- After a **Purge Database**, the system returns to this bootstrap state.

## Shutdown & data

- Graceful shutdown: embedded Postgres is stopped cleanly; in-flight WebSocket
  clients are notified.
- All data lives in whatever `DATABASE_URL` points at. Back it up there — for
  the embedded mode that is the whole `.pgdata/` directory.

## Related

- [Configuration](configuration.md) — env/timezone/device details.
- [Architecture](architecture.md) — what runs inside the process.
- [Deployment](deployment.md) — running it unchained from the dev machine.
