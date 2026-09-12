# TimeKeeper rebuild — handoff (2026-09-12, session 3)

Phases 1–6 are committed on `feat/rebuild-ui-discord-pin`. This session worked the
three follow-up tasks left by the previous handoff. **All three are implemented and
uncommitted in the working tree.** `cargo clippy --all-targets`, `cargo build --bin
main`, `cargo test -p server --lib` (8 tests) and `dart analyze lib` are all clean.

What is *not* done: a final light-mode sweep of every route, a `flutter build linux`,
Discord verified against a real guild, and committing.

---

## Environment (all still running — reuse, do not restart)

```bash
podman ps | grep tk-migtest                     # scratch DB, host port 55432
pgrep -f target/debug/main                      # server, --graphql-port 4000
pgrep -f 'flutter_tools.snapshot run -d linux'  # the app, log at /tmp/mar/flutter_run.log
```

- Login `admin` / `admin`. GraphQL at `http://localhost:4000/graphql`.
- **marionette_mcp works.** VM service URI: `ws://127.0.0.1:43989/8YLoquIu-ck=/ws`
  (re-read from `/tmp/mar/flutter_run.log` if the app is restarted). Connect with it
  before anything else.
- **Driving layout width** (Wayland — `window_manager.setSize` is ignored, verified):
  `client/lib/helpers/debug_window.dart` registers a VM service extension. Call it via
  marionette `call_custom_extension`:
  ```json
  {"extension": "tkDebug.setWindowSize", "args": {"width": 860, "height": 800}}
  ```
  Omit both args to clear. Verified at 700, 860 and 1340.
- **Screenshot coordinates**: `take_screenshots` returns a 2000px-wide canvas but
  `tap` takes *logical* pixels. At a 1340-logical override the scale is ~0.78, so
  `logical = image_px / 0.78`. Getting this wrong silently taps the wrong thing.
- The app starts logged in as `admin` on the Kiosk view in dark mode.
- **The device location is now set to "Workshop"** (Settings → Device Location). It was
  `None`, which is what exposed the bug below. Leave it set or you will re-trigger it.
- Seed scripts: `/tmp/seed.py` then `/tmp/seed2.py`. Still not copied into the repo.
- A member with a PIN exists: `Pat Tester`, PIN `4821`. PIN sign-in is enabled.

---

## Task 1 — Visual/UX pass — **done**, with two real bugs found beyond the brief

Every reported symptom reproduced at narrow width and was fixed. Verified by
screenshot at 700 / 860 / 1340 in both themes.

### Narrow-width table shredding (the big one)
`widgets/tables/base_table.dart` laid every column out as a flex `Expanded` with no
floor, so on a narrow pane header labels wrapped one character per line
("Loca / tion"), chips clipped mid-word ("Stude"), and the Team table threw real
`OVERFLOWED BY 8.0 PIXELS` markers with the "Check In" button text running vertically.
Sessions, Team, Attendance, Locations, Users and Calendar all share this widget.

Fix: `BaseTableCell` gained a `width` for fixed columns, `BaseTable` gained
`minFlexWidth` (default 120), and below `sum(fixed) + flexUnits * minFlexWidth` the
table scrolls horizontally inside a `Scrollbar` instead of squeezing. `EditTable`'s
action columns are now a fixed 52px instead of a full flex unit. `TableHeaderText`
is `maxLines: 1` + ellipsis. Cell padding went 16 → 12 horizontal.

An eight-column table genuinely does not fit a phone-width pane; scrolling is the
honest answer. **If you'd rather it collapsed to cards below ~700px, that is a
design call I did not make** — say so and it is a contained change in `BaseTable`.

### KPI strip clipped
`statistics_view.dart` wrapped `KpiStrip` in a hardcoded `SizedBox(height: 4 * 46)`
that did not match the grid's real height — half the tiles were sliced off at 860.
`KpiStrip` now sizes itself: it picks its column count from its own `LayoutBuilder`
(8 / 4 / 3 / 2 at 1460 / 760 / 480), uses `mainAxisExtent: 72` and `shrinkWrap`.
The 8-column breakpoint is 1460 because below that "448h 14m" plus its delta chip
ellipsises, and a KPI tile must never ellipsise its number.

### Stats toolbar
Was a single `Row` (title + resolved range + 3 menus + export). Below 900 the title
and the controls now split onto two lines with the controls in a `Wrap`. The fixed
`SizedBox(height: 44)` around it is gone.

### Chips — colour as identifier
New `widgets/tone_chip.dart`: tinted ground + full-strength dot + `onSurface` label,
replacing white-on-saturated. `MemberTypeChip` now uses two genuinely distinct,
CVD-validated palette slots — **student = slot 2 (aqua), mentor = slot 6 (violet)**;
slot 0 is skipped because it is the same blue as `primary`. `SessionStatusChip` uses
the same widget, which fixes the weak "Finished" pair; overtime is the one status
that spends its hue on the label too (`ToneChip.alert`), because it is an alert and
not a category. The house rule holds: no colour on body text, no row tints.

### Dark mode
The complaint was real and measurable. Page-to-panel luminance ratio was **1.03** in
dark against **1.11** in light — the same hex step reads as almost nothing down at the
black end, which is why dark looked flat next to light. `#151515` is fixed (the series
palette is validated against it), so the page and chrome moved instead:
`surface` `#0D0D0D` → `#060606`, `surfaceContainerLow` `#1A1A1A` → `#101010`. That puts
chrome between page and panel, where light mode's `#FAFBFC` sits between `#F4F5F7` and
white. Ratios now match light within ~0.01.

### Two bugs found that were not in the brief
1. **Opening the PIN pad threw a red error screen.** `PinEntryDialog` suppressed the
   RFID scanner from a `useEffect`, and flutter_hooks runs effects while the tree is
   still building, which Riverpod rejects. Suppression moved into
   `PinEntryDialog.show(context, ref)` around the dialog's future, with `finally` to
   release. **This means `show` now takes a `WidgetRef`** — the only caller is
   `kiosk_view.dart:164`.
2. **Checking in from a device with no location leaked a raw Rust error** to the person
   at the kiosk: `Failed to parse "UUID": invalid length: expected length 32 for simple
   format, found 0`. Both the PIN and RFID paths sent `locationId: ''`. Both now stop
   with `kNoDeviceLocationMessage` (in `kiosk_scan_handler.dart`) instead.

### Confirmed working
Rail collapse/expand as an overlay, click-away close, Admin/Operations grouping,
"Setup" at top, per-icon colours; nine range presets + custom; **KPI deltas do
recompute on range change** (checked Last 30 → Last 7: every tile's delta moved);
metric and D/W/M toggles; Overtime-only filter; Setup's two-pane list; PIN pad renders,
accepts digits and reports "No active session at this location" cleanly.

### Not re-verified (previous session already did, server-side)
Wrong-PIN error text, the 10th-failure throttle, and the disabled/unknown-PIN paths.

---

## Task 2 — Logo re-colour — **done**

`default_logo.svg` teal `#009485` → **`#2A78D6`**, and the PNGs were re-rasterised
from the SVGs with `rsvg-convert -w 1024 -h 1024` (geometry is byte-for-byte the same
shape as before; only the hue changed — diffed against `git show HEAD:` visually).

`#2A78D6` rather than `kBrandBlue` `#0751B9` on purpose: the logo is one static PNG
used on the login view in **both** themes, and `#0751B9` is only 2.4:1 against the new
`#060606` page. `#2A78D6` is the palette's slot-0 blue and clears 3.9:1 on light and
4.6:1 on dark. `default_pink_logo` went `#E91E63` → `#D55181` (palette slot 4).

Note `pubspec.yaml:46` feeds `default_logo.png` to flutter_launcher_icons, so the app
icon changes with it — **the launcher icons have not been regenerated.**

---

## Task 3 — Discord embeds — **done, but never sent to a real guild**

New `server/src/domains/discord/embeds.rs`: pure builders returning `CreateEmbed`,
with the brand blue and the reserved support colours from `client/lib/colors.dart`.
All eight commands in `commands.rs` now return a `CreateEmbed` and go out via
`send_message(CreateMessage::new().embed(..))`. `!leaderboard students|mentors|help`
still works and now labels the filter in the embed.

Mobile rules followed: no fixed-width column padding anywhere (a monospace table holds
alignment on desktop and shreds on a phone); grids come from `inline: true` fields,
which Discord collapses to one column on mobile; name lists cap at 24 fields plus an
"…and N more". Components V2 was not used.

**The one judgement call worth reviewing:** reminder and DM templates are
operator-authored and the defaults contain `@here` and `{username}` → `<@id>`. A
mention inside an embed renders as a link but **pings nobody**. So in
`notification/service.rs` the rendered template stays in the message *content* and an
embed rides alongside it carrying the structured facts (Location / Starts / Ends, plus
Member for the DMs) — `Self::send_with_facts`. Moving the templates into the embed
description would look tidier and would silently kill every ping.

8 unit tests cover the builders by serialising `CreateEmbed` to JSON (it has no
getters). They assert colour, field layout, the 24-field cap, and that the leaderboard
never emits double-space padding.

### Still to do here
- Enter a bot token + guild in Setup → Integrations and **eyeball every command on a
  phone and on desktop.** Nothing in this task has been seen rendered by Discord.
- Check the leaderboard description against Discord's 4096-char limit with 15 long
  display names. It should be far under, but it is untested.

---

## Suggested next steps

1. Sweep the remaining routes in **light** mode at 700/860/1340 — I verified Statistics
   and the tables in light, but Users, Locations, Notifications, Calendar, Leaderboard
   and Login were only checked in dark.
2. `cd client && flutter build linux` (only `dart analyze` has been run since the edits).
3. Regenerate launcher icons for the new logo.
4. Add the widget-test harness the previous handoff suggested — pumping each view at
   700/900/1280 would have caught every one of the layout bugs above mechanically, and
   `client/test/` still does not exist.
5. Commit. The work splits cleanly into: narrow-layout/table fixes, chips + dark-mode
   ramp, the two kiosk bug fixes, the logo, and the Discord embeds.

---

## Things worth knowing before you change code

- **Migrations are append-only.** `0001`–`0004` apply from scratch. Add `0005_…`.
  `database/src/schema.rs` is generated by `diesel print-schema`; `views.rs` is hand-maintained.
- **Run `./run_codegen` after any provider/model change** (riverpod codegen). No
  provider signatures changed this session, so it was not needed.
- `client/lib/shapes.dart` — exactly two radii, `kRadiusRow` 4 and `kRadiusCard` 6.
  Don't add a third.
- `client/lib/theme/series_palette.dart` — **if you change these hexes, re-run the
  validator** in the `dataviz` skill (`scripts/validate_palette.js`) for
  `--mode light --surface "#FFFFFF"` and `--mode dark --surface "#151515"`. I did not
  change them. I *did* change the dark page and chrome, which the palette is not
  validated against — the palette's stated surface is `#151515`, still the panel colour,
  so that validation still holds.
- Read the **`dataviz` skill before touching any chart code**.
- `client/lib/helpers/debug_window.dart` and the `_DebugSizeOverride` in `app.dart` are
  debug-only scaffolding for marionette. They compile out of release builds. Decide
  whether they ship or get stripped before merge.

## Deviation from the original plan, already flagged in an earlier commit

`check_in_out_by_pin` returns `PinCheckInOut { checked_in, team_member_id }` rather than
a bare `Result<bool>`, because the toast UX names the member and a bool cannot identify
one. The kiosk already replicates team members (minus PINs), so the ID leaks nothing.
