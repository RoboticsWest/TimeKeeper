/// The single crossing point between the server's clock and the user's.
///
/// The database stores every instant as UTC, because the server can live in any
/// region and an absolute instant is the only thing that survives a move. The
/// client is the opposite: nobody wants to read "Session at 02:00" because that
/// is what it says in Greenwich. So the rule this file exists to enforce is:
///
///   **UTC on the wire, local everywhere above the JSON boundary.**
///
/// [parseServerTime] is the only thing that should ever turn a server timestamp
/// into a [DateTime], and [toServerTime] the only thing that sends one back.
/// Model `fromJson`/`toJson` call them; nothing else needs to think about it.
///
/// `DateTime.parse` on an ISO-8601 string with an offset returns a DateTime
/// flagged `isUtc`, and every field getter on such a value (`.hour`, `.day`,
/// `.weekday`) reports UTC. Comparisons (`isBefore`, `compareTo`) are unaffected
/// because they work on the absolute instant — which is why session *ordering*
/// and *status* were right while every rendered date and time was wrong.
library;

const weekdayAbbr = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

const weekdayFull = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

const monthAbbr = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

// ---------------------------------------------------------------------------
// Boundary conversion
// ---------------------------------------------------------------------------

/// Parses a server timestamp into the device's local zone.
///
/// Accepts anything `DateTime.parse` does. A string with no offset is treated
/// as UTC rather than local, matching how the server serialises `Timestamptz`
/// — guessing "local" there would silently shift every value by the offset.
DateTime parseServerTime(String value) {
  final parsed = DateTime.parse(value);
  return (parsed.isUtc
          ? parsed
          : DateTime.utc(
              parsed.year,
              parsed.month,
              parsed.day,
              parsed.hour,
              parsed.minute,
              parsed.second,
              parsed.millisecond,
              parsed.microsecond,
            ))
      .toLocal();
}

/// [parseServerTime] for a nullable JSON field.
DateTime? parseServerTimeOrNull(Object? value) {
  if (value == null) return null;
  final text = value as String;
  if (text.isEmpty) return null;
  return parseServerTime(text);
}

/// Serialises a local [DateTime] for the server. Always UTC, always ISO-8601.
String toServerTime(DateTime value) => value.toUtc().toIso8601String();

/// [toServerTime] for a nullable field.
String? toServerTimeOrNull(DateTime? value) => value == null ? null : toServerTime(value);

extension ServerTimeConversion on DateTime {
  /// This instant as the server wants it: UTC, ISO-8601.
  String get asServerTime => toServerTime(this);
}

// ---------------------------------------------------------------------------
// Display
// ---------------------------------------------------------------------------

/// Every formatter below calls this first.
///
/// [parseServerTime] means values arriving from the API are already local, so
/// this is normally a no-op. It is here for the values that never went through
/// the API at all — `DateTime.now().toUtc()`, a `DateTime.utc(...)` built in a
/// test or a chart axis — so that a stray UTC value can never render as if it
/// were local. Formatting is the last place to catch that.
DateTime _local(DateTime value) => value.isUtc ? value.toLocal() : value;

/// "Wed, Jan 5"
String formatDate(DateTime value) {
  final dt = _local(value);
  return '${weekdayAbbr[dt.weekday - 1]}, ${monthAbbr[dt.month - 1]} ${dt.day}';
}

/// "Jan 5" — no weekday, for axes and dense tables.
String formatShortDate(DateTime value) {
  final dt = _local(value);
  return '${monthAbbr[dt.month - 1]} ${dt.day}';
}

/// "Wednesday"
String formatWeekday(DateTime value) => weekdayFull[_local(value).weekday - 1];

/// "3:05 PM"
String formatTime(DateTime value) {
  final dt = _local(value);
  return formatTimeOfDay(dt.hour, dt.minute);
}

/// "Wed, Jan 5, 3:05 PM"
String formatDateTime(DateTime value) => '${formatDate(value)}, ${formatTime(value)}';

/// "3:05 PM" from a bare hour/minute pair (already local by construction).
String formatTimeOfDay(int hour, int minute) {
  final h = hour % 12 == 0 ? 12 : hour % 12;
  final m = minute.toString().padLeft(2, '0');
  final period = hour < 12 ? 'AM' : 'PM';
  return '$h:$m $period';
}

/// "2026-09-19" — sortable, for CSV and range labels.
String formatIsoDate(DateTime value) {
  final dt = _local(value);
  return '${dt.year}-${_two(dt.month)}-${_two(dt.day)}';
}

String _two(int value) => value.toString().padLeft(2, '0');

/// How a human would name the day [value] falls on, relative to [now]:
/// "today", "tomorrow", "yesterday", or the weekday name.
///
/// This is the client-side twin of the server's `{relative_day}` placeholder,
/// and exists for the same reason: a reminder written as "Session tomorrow"
/// reads as a lie when the session was only created two hours beforehand.
String formatRelativeDay(DateTime value, {DateTime? now}) {
  final target = _local(value);
  final reference = _local(now ?? DateTime.now());

  final targetDay = DateTime(target.year, target.month, target.day);
  final today = DateTime(reference.year, reference.month, reference.day);
  final dayDelta = targetDay.difference(today).inDays;

  switch (dayDelta) {
    case 0:
      return 'today';
    case 1:
      return 'tomorrow';
    case -1:
      return 'yesterday';
    default:
      // Beyond a week either way a weekday name stops being unambiguous.
      if (dayDelta > 1 && dayDelta < 7) return formatWeekday(target);
      return formatDate(target);
  }
}

/// RFC 3339 with the local UTC offset, e.g. "2026-09-19T15:05:00-07:00".
/// Used for CSV export, where a bare local time would be unreadable elsewhere.
String formatRfc3339(DateTime value) {
  final dt = _local(value);
  final offset = dt.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final hours = offset.inHours.abs().toString().padLeft(2, '0');
  final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
  final base = dt.toIso8601String().replaceAll('Z', '').replaceAll(RegExp(r'[+-]\d{2}:\d{2}$'), '');
  return '$base$sign$hours:$minutes';
}

// ---------------------------------------------------------------------------
// Durations
// ---------------------------------------------------------------------------

/// "2h 30m", or "30m" under an hour.
String formatDuration(Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  if (hours > 0) return '${hours}h ${minutes}m';
  return '${minutes}m';
}

/// [formatDuration] from a seconds count, rendering zero as "0m" rather than
/// an empty string.
String formatSecsAsHoursMinutes(double secs) {
  final totalMinutes = (secs / 60).round();
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  if (hours > 0) return '${hours}h ${minutes}m';
  if (minutes > 0) return '${minutes}m';
  return '0m';
}
