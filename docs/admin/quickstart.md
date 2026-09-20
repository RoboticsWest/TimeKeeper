# Admin Quickstart

The first-day checklist for bringing a team online. Everything below happens in
**Setup** (server configuration) plus a few other admin pages.

## 1. Secure the admin account

1. Sign in (default `admin` / `admin`).
2. **Setup → Sessions → Admin Password** — change it immediately.
   (A pulse upfront is required for a public kiosk — the default boot credentials
   are well-known.)

## 2. Set the basics

- **Setup → Sessions → Timezone** — pick the team's UTC offset so times display
  and schedules parse correctly.
- **Setup → Branding** — upload the team logo (PNG/JPG); it replaces the
  default in the app bar and login screen.

## 3. Add locations

**Locations** page — add every room with a kiosk or sessions
(e.g. *Workshop*, *Mentors' office*). Each kiosk device then points its
**Device Location** (gear Settings) at one of these.

## 4. Get team members in

Three ways (see [Import & Export](import_export.md) for formats):

1. **Manually** — Team → add, one by one (fine for a pilot).
2. **CSV** — one file of students + one of mentors (or merge and import twice).
3. **Discord** — Setup → Integrations → *Fetch Roles* → *Import as Students /
   Mentors*; members get their Discord ID linked for free.

While here: **Setup → Team Members → Quick PIN Sign-In** if you want PIN taps,
and set **Leaderboard Configuration** (member types shown, overtime separate).

## 5. Assign check-in keys

- **RFID**: Team → edit member → **Add RFID Tag** (paste a scanned value or use
  the scan button). Or let the kiosk prompt-link scanned cards.
- **PIN**: set a unique **Quick PIN** per member (up to 50 digits).

## 6. Create a schedule

Create sessions one at a time (Sessions page) or
[upload a schedule CSV/ICS](import_export.md#schedule) from Setup → Sessions.
Remember to set the check-in window and auto-checkout minutes that suit your
team.

## 7. Wire up Discord (optional but powerful)

Setup → Integrations: master switch, **Bot Token**, **Server ID**, the
announcement and notification channel IDs, reminder minutes/templates, and the
overtime / auto-checkout DMs. See [Discord Bot](../discord/discord.md).

## 8. Point a kiosk device at it

On the shop monitor: sign in as an account with the **admin** or **kiosk**
role, set **Device Location** and turn on **Kiosk Mode** (desktop). Fullscreen,
always-on-top, done.

## 9. Review & broadcast

- **Setup → Sessions** — the Admin Password lives here, next to schedule
  uploads (a mis-click on *Schedule Upload* replaces the snapshot — export a CSV
  first).
- **Setup → Data** — **Export Students/Mentors/Schedule/Attendance CSV** for
  the archive.
- Tell members: sessions post to Discord with 👍 RSVP reactions; they can tap a
  card at the kiosk; `!link` joins their Discord account to their card.
