import 'package:flutter_test/flutter_test.dart';
import 'package:time_keeper/models/session.dart';

/// Session-level hours must describe the *session*, not the sum of everyone who attended it.
///
/// The regression these guard: the dashboard's headline hours were built by adding up each
/// member's attendance, so two five-hour sessions attended by a dozen people each reported
/// hundreds of hours instead of twelve, and dragged the overtime percentage, the activity
/// chart and the location ranking along with them.
void main() {
  Session session({
    required DateTime start,
    required DateTime end,
    DateTime? actualStart,
    DateTime? actualEnd,
    bool finished = true,
  }) {
    return Session(
      id: 's',
      startTime: start,
      endTime: end,
      locationId: 'loc',
      finished: finished,
      actualStartTime: actualStart,
      actualEndTime: actualEnd,
    );
  }

  final asOf = DateTime(2026, 9, 19, 18);

  group('session hours', () {
    test('two 5h sessions each running 1h over total 12h, not a per-head multiple', () {
      // Exactly the worked example from the bug report: 2 sessions, 5h scheduled each,
      // 1h of overtime each => 12h total, 10h regular, 2h overtime.
      final sessions = [
        session(
          start: DateTime(2026, 9, 17, 9),
          end: DateTime(2026, 9, 17, 14),
          actualStart: DateTime(2026, 9, 17, 9),
          actualEnd: DateTime(2026, 9, 17, 15),
        ),
        session(
          start: DateTime(2026, 9, 18, 9),
          end: DateTime(2026, 9, 18, 14),
          actualStart: DateTime(2026, 9, 18, 9),
          actualEnd: DateTime(2026, 9, 18, 15),
        ),
      ];

      var total = Duration.zero;
      var regular = Duration.zero;
      var overtime = Duration.zero;
      for (final s in sessions) {
        total += s.actualDuration(asOf);
        regular += s.regularDuration(asOf);
        overtime += s.overtimeDuration(asOf);
      }

      expect(total, const Duration(hours: 12));
      expect(regular, const Duration(hours: 10));
      expect(overtime, const Duration(hours: 2));
      expect(regular + overtime, total);
    });

    test('an early start counts as overtime too', () {
      final s = session(
        start: DateTime(2026, 9, 17, 10),
        end: DateTime(2026, 9, 17, 14),
        actualStart: DateTime(2026, 9, 17, 9, 30),
        actualEnd: DateTime(2026, 9, 17, 14),
      );

      expect(s.actualDuration(asOf), const Duration(hours: 4, minutes: 30));
      expect(s.regularDuration(asOf), const Duration(hours: 4));
      expect(s.overtimeDuration(asOf), const Duration(minutes: 30));
    });

    test('a session that finished early has no overtime and less regular time', () {
      final s = session(
        start: DateTime(2026, 9, 17, 10),
        end: DateTime(2026, 9, 17, 14),
        actualStart: DateTime(2026, 9, 17, 10),
        actualEnd: DateTime(2026, 9, 17, 12),
      );

      expect(s.actualDuration(asOf), const Duration(hours: 2));
      expect(s.regularDuration(asOf), const Duration(hours: 2));
      expect(s.overtimeDuration(asOf), Duration.zero);
    });

    test('a session nobody attended contributes nothing', () {
      final s = session(start: DateTime(2026, 9, 17, 10), end: DateTime(2026, 9, 17, 14));

      expect(s.actualDuration(asOf), Duration.zero);
      expect(s.regularDuration(asOf), Duration.zero);
      expect(s.overtimeDuration(asOf), Duration.zero);
    });

    test('a running session accrues up to asOf', () {
      final s = session(
        start: DateTime(2026, 9, 19, 16),
        end: DateTime(2026, 9, 19, 20),
        actualStart: DateTime(2026, 9, 19, 16),
        finished: false,
      );

      // asOf is 18:00, two hours into a four-hour session.
      expect(s.actualDuration(asOf), const Duration(hours: 2));
      expect(s.regularDuration(asOf), const Duration(hours: 2));
      expect(s.overtimeDuration(asOf), Duration.zero);
    });

    test('an unfinished session past its end is capped at asOf, and the excess is overtime', () {
      final s = session(
        start: DateTime(2026, 9, 19, 12),
        end: DateTime(2026, 9, 19, 16),
        actualStart: DateTime(2026, 9, 19, 12),
        finished: false,
      );

      // Ran 12:00 -> 18:00 (asOf): 4h inside the window, 2h past it.
      expect(s.actualDuration(asOf), const Duration(hours: 6));
      expect(s.regularDuration(asOf), const Duration(hours: 4));
      expect(s.overtimeDuration(asOf), const Duration(hours: 2));
    });

    test('scheduledDuration is independent of what actually happened', () {
      final s = session(
        start: DateTime(2026, 9, 17, 10),
        end: DateTime(2026, 9, 17, 14),
        actualStart: DateTime(2026, 9, 17, 11),
        actualEnd: DateTime(2026, 9, 17, 18),
      );

      expect(s.scheduledDuration, const Duration(hours: 4));
      expect(s.actualDuration(asOf), const Duration(hours: 7));
    });
  });
}
