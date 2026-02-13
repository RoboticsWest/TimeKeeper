# TimeKeeper

A time tracking and sign-in management system built for FRC (FIRST Robotics Competition) teams. Track team member attendance across sessions and locations with support for RFID check-in/out, Discord integration, and multi-platform clients.

## Features

- **Session Management** - Create and manage timed sessions at configurable locations
- **RFID Check-In/Out** - Supports both PCSC smart card readers and keyboard-emulating RFID readers
- **Kiosk Mode** - Dedicated fullscreen mode for check-in stations
- **Discord Bot** - Session reminders, attendance commands, leaderboards, and member name syncing
- **Schedule Import** - Import sessions from CSV or ICS (iCalendar) files
- **Multi-Platform Clients** - Desktop (Linux, Windows, macOS), Android, and Web
- **Real-Time Sync** - gRPC streaming keeps all connected clients in sync
