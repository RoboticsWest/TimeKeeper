import 'package:flutter_test/flutter_test.dart';
import 'package:time_keeper/utils/time_utils.dart';

/// The rule these guard: UTC on the wire, local everywhere above the JSON boundary.
///
/// `DateTime.parse` on an ISO-8601 string with an offset returns a value flagged `isUtc`, and
/// every field getter on it (`.hour`, `.day`, `.weekday`) then reports UTC. Comparisons are
/// unaffected, which is why session ordering and status looked right while every rendered date
/// and time was wrong.
void main() {
  group('parseServerTime', () {
    test('returns a local DateTime, not a UTC-flagged one', () {
      final parsed = parseServerTime('2026-09-25T02:00:00+00:00');
      expect(parsed.isUtc, isFalse, reason: 'field getters on a UTC-flagged value report UTC');
    });

    test('preserves the instant', () {
      final parsed = parseServerTime('2026-09-25T02:00:00+00:00');
      expect(parsed.toUtc().toIso8601String(), DateTime.utc(2026, 9, 25, 2).toIso8601String());
    });

    test('renders in the local zone', () {
      final parsed = parseServerTime('2026-09-25T02:00:00Z');
      final expected = DateTime.utc(2026, 9, 25, 2).toLocal();
      expect(parsed.hour, expected.hour);
      expect(parsed.day, expected.day);
    });

    test('an offset other than Z still resolves to the same instant', () {
      final z = parseServerTime('2026-09-25T02:00:00Z');
      final offset = parseServerTime('2026-09-25T10:00:00+08:00');
      expect(offset.toUtc(), z.toUtc());
    });

    test('a timestamp with no offset is read as UTC rather than local', () {
      // The server serialises timestamptz with an offset, but a bare value must not be
      // silently shifted by the device's offset.
      final bare = parseServerTime('2026-09-25T02:00:00');
      expect(bare.toUtc(), DateTime.utc(2026, 9, 25, 2));
    });

    test('parseServerTimeOrNull handles null and empty', () {
      expect(parseServerTimeOrNull(null), isNull);
      expect(parseServerTimeOrNull(''), isNull);
      expect(parseServerTimeOrNull('2026-09-25T02:00:00Z'), isNotNull);
    });
  });

  group('toServerTime', () {
    test('always serialises as UTC', () {
      final local = DateTime(2026, 9, 25, 10, 30);
      expect(toServerTime(local), local.toUtc().toIso8601String());
      expect(toServerTime(local), endsWith('Z'));
    });

    test('round-trips through the server representation', () {
      final original = DateTime(2026, 9, 25, 10, 30);
      expect(parseServerTime(toServerTime(original)), original);
    });

    test('toServerTimeOrNull handles null', () {
      expect(toServerTimeOrNull(null), isNull);
    });
  });

  group('formatters', () {
    test('a stray UTC value is still rendered in local time', () {
      // The defensive guard inside the formatters: values that never went through
      // parseServerTime (DateTime.now().toUtc(), a chart axis) must not leak UTC to the screen.
      final utcValue = DateTime.utc(2026, 9, 25, 2);
      expect(formatTime(utcValue), formatTime(utcValue.toLocal()));
      expect(formatDate(utcValue), formatDate(utcValue.toLocal()));
    });

    test('formatTime renders a 12-hour clock', () {
      expect(formatTime(DateTime(2026, 9, 25, 15, 5)), '3:05 PM');
      expect(formatTime(DateTime(2026, 9, 25, 0, 0)), '12:00 AM');
      expect(formatTime(DateTime(2026, 9, 25, 12, 0)), '12:00 PM');
    });

    test('formatDate includes the weekday', () {
      // 2026-09-25 is a Friday.
      expect(formatDate(DateTime(2026, 9, 25)), 'Fri, Sep 25');
    });

    test('formatDuration', () {
      expect(formatDuration(const Duration(hours: 2, minutes: 30)), '2h 30m');
      expect(formatDuration(const Duration(minutes: 45)), '45m');
    });
  });

  group('formatRelativeDay', () {
    // 2026-09-19 is a Saturday.
    final now = DateTime(2026, 9, 19, 12);

    test('names today, tomorrow and yesterday', () {
      expect(formatRelativeDay(DateTime(2026, 9, 19, 15), now: now), 'today');
      expect(formatRelativeDay(DateTime(2026, 9, 20, 9), now: now), 'tomorrow');
      expect(formatRelativeDay(DateTime(2026, 9, 18, 9), now: now), 'yesterday');
    });

    test('a session later the same day is today, not tomorrow', () {
      // The reminder-wording bug: a session created two hours ahead must not read "tomorrow".
      expect(formatRelativeDay(DateTime(2026, 9, 19, 14), now: now), 'today');
    });

    test('mid-week uses the weekday name', () {
      expect(formatRelativeDay(DateTime(2026, 9, 23, 9), now: now), 'Wednesday');
    });

    test('beyond a week falls back to a date', () {
      expect(formatRelativeDay(DateTime(2026, 9, 29, 9), now: now), 'Tue, Sep 29');
    });
  });
}
