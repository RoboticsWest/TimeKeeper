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



## Last prompt
continue. When finished auto format all code in dart and in rust.

also a side note. The discord bot does not display the leaderboard for mentors for some reason. It just says "no attendance data". Can you fix it up? (it may be because of leaderboard checkbox, for reference if it has "only show certain users" in leaderboard, it's only showing those. But specifically if a person goes out of their way to do !leaderboard students or !leaderboard mentors then it should show the leaderboard. That setting is just for the default leaderboard shown on the client and in discord) Also it would be nice to fixup the checked in as well. It's formatted really strangely, it would be better if it could be cleanup because it's hard to see. All messed up on the rows and columns. Make it similar to leaderboard. Also a separate note which will need a lot of thinking as well, updates. There is no way to really do OTA updates I think because of this flutter project. And it's deployed to github, best I can do it either show a popup to the user telling them this is an outdated version either from the server (probably the best solution) or from github. And basically every few hours the client just pops up a message with specifically a link to the latest version on github. Which should just be https://github.com/RoboticsWest/TimeKeeper/releases/latest or whatever.

But checking from github isn't too bad either. I'd like some way of doing OTA or doing an auto update, where the popup just says "auto update" and somehow it magically downloads the binary, decompresses it and replaces the current instance with the next. But it's not clean. Best to just have it link to the latest version on github and let the user handle it. I think only it should do a popup though if it's the major or minor version. Not the patch, because 1.2.3 changes to 1.2.4 because of a typo, but server works fine no need to deploy client or force them to update with an annoying message that pops up every hour or so.

Side side note, anything else we should chuck into the discord bot? It's fairly bland at the moment. Functionality wise there isn't much I want users to do, on purpose. But maybe more info or other options to see things maybe. It could be good, buttons, paginations. etc...

side side note, extra filters on certain pages would be good. Like attendance, team members and sessions. Along with pagination for them. So we can get a better understanding for attendance for the current day or last 100 etc... or for a person, or for mentors in general, or between certain times etc... Pagination might also need to be built into the api, because i can forsee over time we will accumulate hundreds of sessions, and tens of thousands of attendance records. Which wouldn't be efficient to pull all at once for the client. So best to think about it early.

Also add a 50 character limit for the quick pin, both db and ui entry.

Also delete claude from the contributor list on github. And make a note to never commit anything under claude again. (Fix prior commits and make sure nothing is ever under calude or shared with claude again).
