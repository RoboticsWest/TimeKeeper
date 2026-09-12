# TimeKeeper

A time tracking and sign-in management system built for FRC (FIRST Robotics Competition) teams. Track team member attendance across sessions and locations with support for RFID check-in/out (PCSC or keyboard emulation), Discord integration, and multi-platform clients and servers.

Conceptualised from other attendance systems like 254's [Cheesy Hours](https://github.com/Team254/cheesy-hours) and 3132's [Attendance](https://github.com/Team3132/attendance) systems. Built to be generic and easy to setup with minimal overhead and no external requirements, using an embedded key-value db and simple 3rd party API integrations.

## Features
- **Session Management** - Create and manage timed sessions at configurable locations
- **RFID Check-In/Out** - Supports both PCSC smart card readers and keyboard-emulating RFID readers
- **Kiosk Mode** - Dedicated fullscreen mode for check-in stations
- **Discord Bot** - Session reminders, attendance commands, leaderboards, and member name syncing, self checkouts
- **Schedule Import** - Import sessions from CSV or ICS (iCalendar) files
- **Multi-Platform Clients** - Desktop (Linux, Windows, macOS), Android, and Web
- **Real-Time Sync** - GraphQL subscriptions over WebSocket keep all connected clients in sync

## Quickstart
1. Download the server from the latest [release](https://github.com/CurtinFRC/TimeKeeper/releases)
2. Run it on a device of your choice (cloud server, local, rpi etc...)
- Note: (Run the command `server.exe --help` for start config commands. I.e `server.exe --web-port 80`)
- The server binds two ports: `--web-port` (default `8080`) serves the Flutter web client, and `--graphql-port` (default `4000`) serves the GraphQL API at `/graphql` and subscriptions at `/graphql/ws`. Clients must be pointed at the GraphQL port under Settings.
- Behind a reverse proxy that already serves the Flutter build, pass `--no-web` to run API-only. The web client then reaches the API on the origin it was served from, so no host/port needs configuring. See [`deploy/`](deploy/) for the Docker + Caddy setup used for `tk.roboticswest.org`.
3. Navigate to the servers address using the set port or default port 8080. I.e (`http://10.128.22.120:8080`)
4. Login using the button in the top right of the app bar (default username `admin`, default password `admin`)
5. Using the left rail navigation bar enter the setup page and configure the setup (import ICS or CSV calendar, student and mentor data, notifications etc...)
- Note: Connect to discord first and import users through discord to pre-link their accounts in the system for later use if using discord

## Documentation
Check [documentation](https://curtinfrc.github.io/TimeKeeper/) for more details.
