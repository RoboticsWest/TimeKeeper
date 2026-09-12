# TimeKeeper rebuild — handoff

Phases 1–6 of the port/Discord-ID/PIN/UI plan are **implemented and committed** on
branch `feat/rebuild-ui-discord-pin` (6 commits, one per phase, on top of `main`).
`cargo build`, `cargo clippy`, `dart analyze` and `flutter build linux` are all clean.

What remains is **visual/UX polish that needs a real running UI to judge**, plus a
Discord message-formatting task. Do the UI work through **marionette_mcp** — it was
not available in the previous session (not installed, and that session could not run
an MCP setup flow), which is why this is being handed off rather than finished.

---

## Environment already set up for you

A throwaway Postgres, a server and the app may still be running. Check first:

```bash
podman ps | grep tk-migtest          # scratch DB on host port 55432
pgrep -f target/debug/main           # server
pgrep -f bundle/timekeeper           # app
```

Recreate if needed:

```bash
podman run -d --rm --name tk-migtest -e POSTGRES_PASSWORD=test \
  -e POSTGRES_DB=timekeeper -p 55432:5432 docker.io/library/postgres:16

cd server
export DATABASE_URL="postgres://postgres:test@localhost:55432/timekeeper"
cargo run --bin main -- --graphql-port 4000
```

- Login: `admin` / `admin`. GraphQL at `http://localhost:4000/graphql`.
- **Seed data**: `/tmp/seed.py` (locations, 12 members, 50 finished sessions) then
  `/tmp/seed2.py` (402 check-ins, inserted straight into Postgres — there is no
  `createTeamMemberSession` mutation). Re-copy them into the repo if you want them kept.
- Client prefs live at `~/.local/share/com.timekeeper.app/shared_preferences.json`.
  Keys are **unprefixed** (`jwt_token`, `username`). Writing a valid JWT there makes
  the app start logged in, which is the easiest way to reach protected routes.
- PIN sign-in is **off by default**. Turn it on in Setup → Team Members, and note a
  member with a PIN already exists (`Pat Tester`, PIN `4821`).

---

## Task 1 — Visual/UX pass with marionette_mcp

Walk **every route in both light and dark mode**, at wide (≥1280), medium (900–1280)
and **narrow (<900)** widths. Narrow is where the known problems are.

Reported by the user, unverified in detail — reproduce each before fixing:

1. **Dark mode "was different" / needs touch-ups.** The theme is hand-authored in
   `client/lib/theme.dart` (two explicit `ColorScheme`s, no `fromSeed`). Dark is true
   neutral greys, primary lifted to `#4D8DF6`. Judge it on screen and adjust the ramp
   or the component themes there — that one file restyles the whole app.
2. **Wrap-around issues on smaller screens** and **widget build errors**. The previous
   session saw no exceptions in the app log at default size, so these likely need a
   narrow window to reproduce. Prime suspects:
   - `views/statistics/panels/stats_toolbar.dart` — a single `Row` with title, resolved
     range, three menu buttons and an export button. Almost certainly overflows narrow;
     it likely needs to `Wrap` or collapse into an overflow menu.
   - `views/statistics/statistics_view.dart` — `KpiStrip` height at narrow is hardcoded
     `4 * 46`; verify it matches the 2-column grid's real height.
   - `views/sessions/session_stats.dart` — five `Expanded` KpiTiles in one Row.
   - The dashboard is `LayoutBuilder`-driven, so it reacts to the *pane* width, not the
     window; the rail takes 56px off the left.
3. **Chips are hard to read, and color should be used as a clear identifier.**
   `views/team/member_type_chip.dart` is the main one: student vs mentor currently
   render as `colorScheme.primary` vs `colorScheme.secondary`, which are both blue and
   nearly indistinguishable, with white text. Give the two roles genuinely distinct
   hues from `theme/series_palette.dart` (`seriesColor(i, brightness)`), and prefer a
   tinted background with a colored dot/border plus normal text ink over white-on-
   saturated. The user explicitly wants *a touch of color on what matters* as an
   identifier — they were happy with overall contrast, so do not flatten everything.
   Check `widgets/status_chip.dart` too (white on `neutralColor.shade400` for
   "finished" is the weakest contrast pair).

**House rule already applied across the codebase — keep it:** status color goes on
chips, meters, strips and borders; **never on body text, never as a row tint.**

Also confirm the interactive behaviour introduced in this rebuild:
- Rail collapsed (56) ↔ expanded (240), overlays rather than pushes, click-away closes,
  icons keep their own color in every state, Admin/Operations grouping, "Setup" (not
  "Settings") at the top.
- Statistics: metric toggle (Hours/People), D/W/M bucket toggle, 9 range presets +
  custom range picker, drill into a day, "Overtime only" filter, Export CSV, and that
  **KPI deltas change when the range changes**.
- Kiosk PIN pad: enter `4821`, confirm check-in/out, wrong PIN error, and — important —
  that **the RFID keyboard-wedge scanner does not fire a phantom scan while the pad is
  open** (`providers/rfid_suppression_provider.dart` guards this).
- Setup's new two-pane section list.

## Task 2 — Replace the logo art

`client/assets/logos/default_logo.{png,svg}` is teal/green-blue and now clashes with
the brand blue `#0751B9` (`kBrandBlue` in `theme.dart`). There is also a
`default_pink_logo.*` variant. Re-colour to match the new palette. The SVGs are small
(~2KB) and are the easiest source to edit. `widgets/logo_widget.dart` falls back to the
asset when the server has no uploaded logo.

## Task 3 — Make Discord messages look good

Currently **every** command builds a plain `String` and sends it with
`msg.channel_id.say(...)` — bold text, medal emoji and ASCII-ish lists. See
`server/src/domains/discord/commands.rs`: `help`, `leaderboard` (line ~66), `sessions`,
`checked_in`, `locations`, plus the reminder/DM messages in
`server/src/domains/notification/service.rs`.

Requirement from the user: **must render well on both phone and desktop.**

- Recommended: **embeds** (`CreateEmbed` + `CreateMessage`) — serenity 0.12 is already a
  dependency with the `model`/`http` features, embeds reflow properly on mobile, and
  they give you title/fields/colour/footer without hand-aligned columns.
- Be careful with "tables": Discord has no table primitive. Monospace code blocks *do*
  hold alignment on desktop but **wrap badly on narrow phone screens** — so avoid
  fixed-width column padding. Prefer embed fields (`inline: true` gives a responsive
  2–3 column grid that collapses on mobile) or one line per entry.
- Components V2 exists but is flagged and poorly supported in serenity 0.12 — don't
  reach for it unless you verify support first.
- Colour the embeds with the brand blue `#0751B9` and the reserved support colours
  (see `client/lib/colors.dart` for the exact hexes) so Discord matches the app.
- `!leaderboard` takes `students` / `mentors` / `help` filters — keep them working.

Verifying Discord end-to-end needs a test guild + bot token entered in
Setup → Integrations. If you don't have one, at minimum keep the message-building
logic behind pure functions and unit-test the rendered output.

---

## Things worth knowing before you change code

- **Migrations are append-only.** `0001_init`, `0002_drop_branding_colors`,
  `0003_discord_id`, `0004_quick_pin` all apply cleanly from scratch (verified). Add a
  `0005_…` rather than editing an existing one. `database/src/schema.rs` is generated
  by `diesel print-schema`; `views.rs` is hand-maintained.
- **Run `./run_codegen` after any provider/model change** (riverpod codegen).
- `client/lib/shapes.dart` — radii are exactly two values: `kRadiusRow` 4 for
  rows/controls/inputs/chips, `kRadiusCard` 6 for cards/panels. Don't introduce a third.
- `client/lib/theme/series_palette.dart` — 8 categorical hues with per-brightness
  steps, validated for CVD separation, lightness band, chroma and contrast against this
  app's chart surfaces. **If you change these hexes, re-run the validator** in the
  `dataviz` skill (`scripts/validate_palette.js`) for both `--mode light --surface
  "#FFFFFF"` and `--mode dark --surface "#151515"`. Slot 0 is blue and is deliberately
  skipped for rail/setup icons because it collides with `primary`.
- Read the **`dataviz` skill before touching any chart code**.
- There is **no test suite** (`client/test/` does not exist). A widget-test harness that
  pumps each view at several fixed widths would catch the narrow-screen overflows
  mechanically — worth adding alongside the marionette pass, not instead of it.

## One deviation from the original plan, already flagged in the commit

`check_in_out_by_pin` returns `PinCheckInOut { checked_in, team_member_id }` rather than
the specified bare `Result<bool>`. The plan also asked the PIN path to reuse the
existing toast UX, which names the member — a bare bool cannot identify one. The kiosk
already replicates team members (minus PINs), so returning an ID leaks nothing. The
client-side debounce stays RFID-only by design: it guards accidental double-scans,
which deliberate typing doesn't produce.

## Verified already (don't redo)

- Migrations apply from scratch; `discord_id` has its partial unique index.
- PIN: stored and admin-readable; duplicate rejected with a clear message;
  **unauthenticated callers get `quickPin: null`, not an error**; disabled/unknown-PIN/
  no-session paths all return clean messages; throttle engages on the 10th failure.
- `--graphql-port 4000` binds and the server starts clean.
