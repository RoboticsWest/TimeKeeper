# Deployment

One environment, one server. The `Deploy` workflow (`.github/workflows/deploy.yml`) runs on
every push to `main` and splits the app in two:

| Piece | Built as | Lands at | Served by |
| --- | --- | --- | --- |
| GraphQL API | `ghcr.io/roboticswest/timekeeper:<sha>` | container `timekeeper` on the `proxy` network | itself, on port 4000 |
| Flutter web client | static build artifact | `/srv/timekeeper/web` on the host | Caddy, directly |

The API container runs `--no-web`, so the Rust binary's built-in static file server is off and
the image doesn't carry the Flutter build. That's the only difference from the all-in-one
binary in the releases, which still serves both itself.

Everything sits on one public origin (`tk.roboticswest.org`). Caddy routes `/graphql*` and
`/health` to the API container and serves everything else from the static directory, so the
client talks to the API same-origin and no CORS or TLS configuration is involved.

## Files

- `timekeeper/Dockerfile` — API-only image.
- `timekeeper/docker-compose.yml` — deployed to `/srv/timekeeper/docker-compose.yml`; reads
  `IMAGE_TAG`, `DATABASE_URL` and `TK_ADMIN_PASSWORD` from the `.env` the workflow writes.

## Server-side prerequisites (one-time, not managed from this repo)

The reverse proxy config lives on the server and fronts every project there, so it is neither
stored here nor touched by CI. What TimeKeeper needs from it:

1. An external docker network named `proxy`, with Caddy, Postgres and this container attached.
2. Caddy mounting the static build read-only: `/srv/timekeeper/web:/srv/timekeeper/web:ro`.
3. A site block for `timekeeper.roboticswest.org` / `tk.roboticswest.org` that sends
   `/graphql` **and everything under it** plus `/health` to `timekeeper:4000`, and serves
   `/srv/timekeeper/web` for everything else with an SPA fallback to `index.html`.
   Caddy's `path` matcher is exact, so a `/graphql` matcher will not catch the subscription
   endpoint `/graphql/ws` — match a prefix instead.
4. Repository secrets: `SSH_HOST`, `SSH_USERNAME`, `SSH_PRIVATE_KEY`, `SSH_PORT`,
   `DATABASE_URL`, `TK_ADMIN_PASSWORD`, `TS_OAUTH_CLIENT_ID`, `TS_OAUTH_CLIENT_SECRET`.

## Checking a deploy

```sh
curl -fsS https://tk.roboticswest.org/health     # -> OK, proxied to the API container
docker ps --filter name=timekeeper               # healthcheck should read (healthy)
docker logs timekeeper
```

A 502 on `/health` means Caddy reached nothing: check the container is up, is on the `proxy`
network, and that `docker exec timekeeper curl -s localhost:4000/health` answers.
