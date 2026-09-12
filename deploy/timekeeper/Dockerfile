# API-only image. The Flutter web build is NOT baked in — the deployment serves it as a
# static directory from the reverse proxy (see deploy/timekeeper/Caddyfile), so the server
# runs with `--no-web`.
FROM rust:1-bookworm AS build
WORKDIR /src
RUN apt-get update && apt-get install -y --no-install-recommends libpq-dev && rm -rf /var/lib/apt/lists/*
COPY Cargo.toml Cargo.lock ./
COPY database ./database
COPY server ./server
RUN cargo build --release -p server

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends libpq5 ca-certificates curl && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=build /src/target/release/main /app/server
EXPOSE 4000
ENTRYPOINT ["/app/server", "--no-web"]
