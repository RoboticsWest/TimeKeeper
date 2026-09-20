# Installation

There are two supported ways to run TimeKeeper:

| Path | Good for | What you run |
|------|----------|--------------|
| [Single binary](#single-binary) | A single shop machine, desktop, or anything in between | `server` compiled from source — serves the app, the API *and* the database |
| [Docker + Caddy](#docker-caddy-production) | A server that must stay up, TLS, remote access | a `ghcr.io/roboticswest/timekeeper` container behind a reverse proxy |

Both run the same server binary; they only differ in how it gets to Postgres and
how traffic reaches it.

## Requirements

- Rust stable (matching `rust-toolchain.toml`) — only needed to compile from source.
- Postgres 15+ — only if you take the managed-database install.
  The single-binary path brings its own embedded Postgres.
- The Flutter web client is already compiled into the server's expected location
  (`client/build/web`, the default `--web-dir`) when you build it before starting.

## Single binary

This is the development and small-shop recommendation: no Docker, no external
database, two listeners on one machine.

```bash
# From the repository root
cargo run --release -p server
```

To serve a freshly built web client:

```bash
cd client && flutter build web            # produces client/build/web
cd .. && cargo run --release -p server    # serves it on :8080
```

TimeKeeper stores its data in an embedded Postgres under `.pgdata/` (git-ignored)
when `DATABASE_URL` is not set, so the whole system is just the one process.

### Run it as a service (systemd)

```ini
# /etc/systemd/system/timekeeper.service
[Unit]
Description=TimeKeeper
After=network.target

[Service]
WorkingDirectory=/srv/timekeeper
ExecStart=/srv/timekeeper/server
Environment=DATABASE_URL=postgres://timekeeper:secret@127.0.0.1/timekeeper
Environment=TK_ADMIN_PASSWORD=change-me
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Point a reverse proxy at the API port for TLS — see [Deployment](deployment.md).

## Docker + Caddy (production)

The repository ships the exact production layout under `deploy/`:

- `deploy/timekeeper/Dockerfile` — builds the server image
  (`ghcr.io/roboticswest/timekeeper`).
- `deploy/timekeeper/docker-compose.yml` — one container, an *externally
  managed* Postgres via `DATABASE_URL`, health-checked on `:4000/health`.
- `deploy/Caddyfile.example` — Caddy site block that terminates TLS, serves the
  Flutter build from `/srv/timekeeper/web` and proxies `/graphql*` and `/health`
  to the container.

> **Option A — use the published image.** Deploy the post-tag/commit image
> straight from `ghcr.io/roboticswest/timekeeper:<commit>`. The CI pipeline in
> `deploy.yml` builds it for you on every push to `main`.
>
> **Option B — Docker with managed Postgres.** Provide your own Postgres, set
> `DATABASE_URL` and `TK_ADMIN_PASSWORD`, and `docker compose up -d`. The
> container runs the API-only mode (reverse proxy serves the web client).

```bash
export DATABASE_URL=postgres://timekeeper:secret@pg-host/timekeeper
export TK_ADMIN_PASSWORD='a-strong-password'
docker compose -f deploy/timekeeper/docker-compose.yml up -d
```

The container uses **no `--web-port`** — the web client is built separately,
uploaded under `/srv/timekeeper/web`, and served by Caddy (see
[Deployment](deployment.md)).

## Verifying it works

```bash
curl -s http://localhost:4000/health     # → ok (or {"status":"ok",...})
curl -s http://localhost:4000/graphql    # introspection endpoint is live
curl -s http://localhost:8080/           # the web client (single-binary mode)
```

The API answers `/graphql`, `/graphql/ws` (subscriptions) and `/health` on both
ports when the web server is enabled.

## Next steps

- [Running the server](server_reference.md) — the full CLI, ports and env surface.
- [Configuration](configuration.md) — env vars, timezones, encryption and TLS.
