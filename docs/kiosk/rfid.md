# RFID Tags & Readers

TimeKeeper pairs **RFID tags** with **team members**, then signs them in and out
with a tap. Each member can hold **multiple tags** (several cards for one
person).

## Reader types

| Type | How it works | Platforms |
|------|--------------|-----------|
| **PCSC smart-card reader** | Native driver talks to the reader directly (APDU *Get-UID*); emits colon-hex UIDs like `DE:AD:BE:EF:01:23`. Internal 3 s debounce on identical UIDs. | **Desktop only** (web falls back to keyboard-wedge) |
| **Keyboard (wedge) scanner** | Acts as a keyboard: scans "type" the UID then Enter. The app's `RfidScanBuffer` captures them globally. | **All platforms** — including web |

Both are started together when the kiosk is active; they don't conflict.

## How a scan matches a member

`_findMember` runs entirely on the client against the replicated tag map, so
taps are instant. Matching is deliberately **fuzzy**:

- Separators (`:`, space, `-`, none) are normalized away,
- both **byte orders** are tried,
- **big- and little-endian decimal** interpretations are tried —
  keyboard readers tend to emit little-endian decimal, PCSC gives colon hex.

So one card works whichever way the reader formats it.

## Assigning tags

1. **Team → edit a member → RFID Tags**: an **Add RFID Tag** field (with a scan
   button on desktop that captures a live card directly), plus remove buttons
   on existing tags.
2. **At the kiosk**: an admin scanning an unknown card gets the *Unrecognized*
   toast → the **Link Card** dialog → search the member → *Card Linked*.
3. **At import**: the team-member CSV can seed tags (see
   [Import & Export](../admin/import_export.md)).

## Unrecognized cards

A card with no matching member shows
**Unrecognized card "*value*", contact admin.** — an admin can link or reassign
it on the spot. If *"the wrong card"* keeps happening, remember tag matching is
fuzzy: a card scanned for someone else is usually just not linked.

## Scan debounce

- **Device setting** — *Scan Debounce (minutes)*, default **5**; the kiosk
  warns *"Please wait X before scanning again."* for the same card within it.
- The **PCSC** path has its own hardcoded **3 s** same-UID cooldown.
- The **keyboard buffer** clears after 500 ms of no input, so a slow wedge scan
  still completes — books don't trigger it, and consecutive fast scans don't
  merge.

## Troubleshooting

| Symptom | Check |
|---------|-------|
| Scan does nothing | Device Location set? `rfidTags` synced (open another device)? Card actually linked in Team? |
| PIN typed as chars appears as a card | Expected — the kiosk suppresses the scanner while the PIN dialog is open; if you see this elsewhere the wedge is interpreting live input. |
| PCSC not active on web | By design: PCSC is desktop-only; use a wedge scanner. |
| Same card works then fails | Debounce cooldown — wait out the device scan-debounce window, or the reader's own. |
