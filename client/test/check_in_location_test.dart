import 'package:flutter_test/flutter_test.dart';
import 'package:time_keeper/helpers/session_helper.dart';
import 'package:time_keeper/models/session.dart';
import 'package:time_keeper/models/team_member.dart';
import 'package:time_keeper/models/team_member_session.dart';

/// What these guard: the roster's check-in dialog offers exactly the locations the server would
/// accept a check-in at.
///
/// The roster used to send the *device's* configured location — a kiosk setting, unset on an
/// admin's machine — which reached the server as an empty string and came back as a UUID parse
/// error. Asking where instead only helps if the answers on offer are the real ones, so this
/// mirrors `SessionLogic::check_in_out`'s rule and has to keep mirroring it.
void main() {
  final now = DateTime(2026, 9, 28, 19);
  const window = Duration(hours: 1);
  const shop = 'loc-shop';
  const bay = 'loc-bay';

  Session session({
    required String id,
    required String locationId,
    required DateTime start,
    Duration length = const Duration(hours: 3),
    bool finished = false,
  }) {
    return Session(id: id, startTime: start, endTime: start.add(length), locationId: locationId, finished: finished);
  }

  Map<String, Session> map(List<Session> sessions) => {for (final s in sessions) s.id: s};

  MapEntry<String, Session>? eligible(Map<String, Session> sessions, {String at = shop}) =>
      eligibleSessionAt(locationId: at, sessions: sessions, checkInWindow: window, now: now);

  group('eligibleSessionAt', () {
    test('finds a session in progress at that location', () {
      final sessions = map([session(id: 'a', locationId: shop, start: now.subtract(const Duration(hours: 1)))]);
      expect(eligible(sessions)?.key, 'a');
    });

    test('ignores a session at another location', () {
      final sessions = map([session(id: 'a', locationId: bay, start: now.subtract(const Duration(hours: 1)))]);
      expect(eligible(sessions), isNull);
    });

    test('ignores a finished session even while its times still contain now', () {
      final sessions = map([
        session(id: 'a', locationId: shop, start: now.subtract(const Duration(hours: 1)), finished: true),
      ]);
      expect(eligible(sessions), isNull);
    });

    test('accepts a session that has not started yet but is inside the window', () {
      final sessions = map([session(id: 'a', locationId: shop, start: now.add(const Duration(minutes: 30)))]);
      expect(eligible(sessions)?.key, 'a');
    });

    test('rejects one that starts beyond the window', () {
      final sessions = map([session(id: 'a', locationId: shop, start: now.add(const Duration(hours: 2)))]);
      expect(eligible(sessions), isNull);
    });

    test('accepts one that ended inside the window', () {
      final sessions = map([
        session(id: 'a', locationId: shop, start: now.subtract(const Duration(hours: 3, minutes: 30))),
      ]);
      expect(eligible(sessions)?.key, 'a');
    });

    test('rejects one that ended beyond the window', () {
      final sessions = map([session(id: 'a', locationId: shop, start: now.subtract(const Duration(hours: 5)))]);
      expect(eligible(sessions), isNull);
    });

    test('prefers a session in progress over one merely inside the window', () {
      final sessions = map([
        session(id: 'soon', locationId: shop, start: now.add(const Duration(minutes: 20))),
        session(id: 'running', locationId: shop, start: now.subtract(const Duration(hours: 1))),
      ]);
      expect(eligible(sessions)?.key, 'running');
    });

    test('between two upcoming sessions, picks the nearer one', () {
      final sessions = map([
        session(id: 'later', locationId: shop, start: now.add(const Duration(minutes: 50))),
        session(id: 'sooner', locationId: shop, start: now.add(const Duration(minutes: 10))),
      ]);
      expect(eligible(sessions)?.key, 'sooner');
    });

    test('no sessions at all is not an error', () {
      expect(eligible(const {}), isNull);
    });
  });

  group('openVisitOf', () {
    TeamMemberSession visit(String id, String memberId, {DateTime? out}) {
      return TeamMemberSession(
        id: id,
        teamMemberId: memberId,
        sessionId: 's',
        checkInTime: now.subtract(const Duration(hours: 1)),
        checkOutTime: out,
      );
    }

    test('finds the row a checkout would close', () {
      final visits = {'open': visit('open', 'm1'), 'closed': visit('closed', 'm1', out: now)};
      expect(openVisitOf('m1', visits)?.key, 'open');
    });

    test('a member with no open visit has none', () {
      expect(openVisitOf('m1', {'closed': visit('closed', 'm1', out: now)}), isNull);
      expect(openVisitOf('m2', {'open': visit('open', 'm1')}), isNull);
    });
  });

  group('lastActivityOf', () {
    test('an open visit last changed when it was opened', () {
      final open = TeamMemberSession(id: 'a', teamMemberId: 'm', sessionId: 's', checkInTime: now);
      expect(lastActivityOf(open), now);
    });

    test('a closed visit last changed when it was closed', () {
      final closed = TeamMemberSession(
        id: 'a',
        teamMemberId: 'm',
        sessionId: 's',
        checkInTime: now.subtract(const Duration(hours: 4)),
        checkOutTime: now,
      );
      expect(lastActivityOf(closed), now);
    });
  });

  group('TeamMember.displayLabel', () {
    TeamMember member({String? displayName}) => TeamMember(
      id: 'm',
      firstName: 'Ada',
      lastName: 'Lovelace',
      memberType: TeamMemberType.student,
      displayName: displayName,
    );

    test('falls back to the full name rather than an empty string', () {
      expect(member().displayLabel, 'Ada Lovelace');
      expect(member(displayName: '').displayLabel, 'Ada Lovelace');
      expect(member(displayName: '   ').displayLabel, 'Ada Lovelace');
    });

    test('prefers the nickname when there is one', () {
      expect(member(displayName: 'Countess').displayLabel, 'Countess');
    });

    test('members without a nickname sort by name rather than to the top', () {
      final withName = member(displayName: 'Zed');
      final withoutName = member();
      final sorted = [withName, withoutName]..sort(TeamMember.compareByName);
      expect(sorted.map((m) => m.displayLabel), ['Ada Lovelace', 'Zed']);
    });
  });
}
