FROM ghcr.io/cirruslabs/flutter:stable AS flutter-build
WORKDIR /src/client
COPY client .
RUN flutter pub get
RUN dart run flutter_launcher_icons
RUN flutter build web --release --wasm --no-web-resources-cdn

FROM rust:1-bookworm AS rust-build
WORKDIR /src
RUN apt-get update && apt-get install -y --no-install-recommends libpq-dev && rm -rf /var/lib/apt/lists/*
COPY Cargo.toml Cargo.lock ./
COPY database ./database
COPY server ./server
RUN cargo build --release -p server

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends libpq5 ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=rust-build /src/target/release/server /app/server
COPY --from=flutter-build /src/client/build/web /app/client/build/web
ENTRYPOINT ["/app/server", "--web-port", "80"]
