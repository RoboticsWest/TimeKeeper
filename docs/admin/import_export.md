# Import & Export

TimeKeeper bulk-loads data from CSV, from ICS, and straight from Discord. All
imports run from **Setup**; exports run from **Setup → Data**.

!!! warning "CSV dialect"

    Files are split on commas, **no quoting/escaping support**. Values are
    trimmed. A header row is optional on every format and skipped when the
    first column is the document's uppercase column name.
    Timestamps are parsed as RFC-3339 (`2026-01-15T14:30:00+08:00`, `…Z`) with a
    fallback to naive `YYYY-MM-DDTHH:MM:SS` **treated as UTC**.

## Team members

`student` and `mentor` CSVs share one format; you upload them separately.

**Columns:** `FIRST_NAME, LAST_NAME, DISPLAY_NAME, RFID_TAG, DISCORD_ID`

| Column | Optional | Notes |
|--------|:--------:|-------|
| `FIRST_NAME` | no | |
| `LAST_NAME` | no | |
| `DISPLAY_NAME` | yes | member display name (falls back to first/last). |
| `RFID_TAG` | yes | one tag per row; add more later in the member dialog. |
| `DISCORD_ID` | yes | numeric snowflake — pre-links the account. |

**Import:** Setup → Team Members → *Upload Students CSV* / *Upload Mentors CSV*.

```csv
FIRST_NAME,LAST_NAME,DISPLAY_NAME,RFID_TAG,DISCORD_ID
Ada,Lovelace,Ada,DE:AD:BE:EF:01:23,123456789012345678
Grace,Hopper,,A1:B2:C3:40:50:60,
Alan,Turing,Alan T,,987654321098765432
```

!!! note "Import, don't overwrite"

    Uploads are **additive/upserting** (new rows become members) — the team
    member import does not clear your roster first.

## Attendance

**Columns:** `FIRST_NAME, LAST_NAME, LOCATION, CHECK_IN_TIME, CHECK_OUT_TIME`

- Rows match members by first + last name and locations by name.
- `CHECK_OUT_TIME` may be empty — the record is still a check-in.
- Times: RFC-3339, or naive (UTC). See the dialect note above.

**Import:** Setup → Team Members → *Import Attendance*.

```csv
FIRST_NAME,LAST_NAME,LOCATION,CHECK_IN_TIME,CHECK_OUT_TIME
Ada,Lovelace,Workshop,2026-01-15T09:00:00+08:00,2026-01-15T12:00:00+08:00
Grace,Hopper,Mentors Office,2026-01-15T09:15:00Z,
```

## Schedule

Two formats, one intent — replace the session plan with an imported snapshot.
Uploading for a schedule warns
**"Uploading a schedule can have impacts on existing data integrity"**:
the schedule replaces what's currently planned.

### CSV

**Columns:** `LOCATION, START_DATE_TIME, END_DATE_TIME`

Each row = one session at that location. Locations are auto-created.

**Import:** Setup → Sessions → *Schedule Upload (CSV)*.

```csv
LOCATION,START_DATE_TIME,END_DATE_TIME
Workshop,2026-02-02T15:00:00+08:00,2026-02-02T18:00:00+08:00
Workshop,2026-02-03T15:00:00+08:00,2026-02-03T18:00:00+08:00
Mentors Office,2026-02-02T09:00:00+08:00,2026-02-02T17:00:00+08:00
```

### ICS (iCalendar)

**Import:** Setup → Sessions → *Schedule Upload (ICS)*.

Rules the importer follows:

- Every event needs `DTSTART`, `DTEND` and a **`LOCATION`** — events with no
  location are skipped.
- Times: `Z`-suffixed (UTC), or floating local times resolved in the
  calendar's `X-WR-TIMEZONE` (falling back to UTC), or per-event `TZID`.
- **Recurrence rules (`RRULE`) are not expanded** — list repeating sessions
  explicitly (your calendar export usually does this for you).
- Fails loudly if the file has **no valid events**.

## Import from Discord

Setup → Integrations → *Import Members from Discord*:

1. **Fetch Roles** — lists the guild's roles.
2. Choose a role → **Import as Students** / **Import as Mentors**.

The importer reads up to 1000 guild members, filters by the role, then:

- members already carrying that Discord ID → **already linked**,
- an *unlinked existing member whose display name matches* → the snowflake is
  written (this also restores links broken long ago),
- everyone else → created as a new member holding the role's type and their
  Discord display name.

Result toast:
**"Imported N new, linked X existing, Y already linked."**

## Exports

Setup → Data: **Export Students CSV · Export Mentors CSV · Export Schedule CSV ·
Export Attendance CSV**. The exports mirror the import columns above — a
round-trip through `Import` is loss-free for the non-record data, and the
attendance CSV is your portable archive of the records themselves.
