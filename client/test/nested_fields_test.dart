import 'package:flutter_test/flutter_test.dart';
import 'package:time_keeper/models/team_member_session.dart';

/// What these guard: a list row carries the names it prints.
///
/// The paged queries used to return only foreign keys, so every list view needed a client-side copy
/// of the roster, the sessions and the locations to render a row — which is the only reason those
/// tables were downloaded and held in the first place. The nested fields are resolved server-side
/// (and batched by a data loader, so a page costs one query per relationship rather than one per
/// row), and the selection set stays optional: a caller that only wants ids still gets only ids.
void main() {
  Map<String, dynamic> row({Map<String, dynamic>? member, Map<String, dynamic>? session}) => {
    'id': 'visit-1',
    'teamMemberId': 'member-1',
    'sessionId': 'session-1',
    'checkInTime': '2026-09-28T09:00:00+00:00',
    'checkOutTime': null,
    'teamMember': ?member,
    'session': ?session,
  };

  test('a row with the nested member knows the name to print', () {
    final visit = TeamMemberSession.fromJson(
      row(
        member: {
          'id': 'member-1',
          'firstName': 'Ada',
          'lastName': 'Lovelace',
          'memberType': 'student',
          'displayName': 'Countess',
        },
      ),
    );

    expect(visit.teamMember?.displayLabel, 'Countess');
    expect(visit.teamMemberId, 'member-1', reason: 'the id stays, for callers that only need it');
  });

  test('a row with the nested session knows where it was', () {
    final visit = TeamMemberSession.fromJson(
      row(
        session: {
          'id': 'session-1',
          'startTime': '2026-09-28T08:00:00+00:00',
          'endTime': '2026-09-28T12:00:00+00:00',
          'locationId': 'loc-1',
          'finished': false,
          'location': {'id': 'loc-1', 'location': 'Machine Shop'},
        },
      ),
    );

    expect(visit.session?.location?.location, 'Machine Shop');
    expect(visit.session?.locationId, 'loc-1');
  });

  test('a row without the nested fields still parses', () {
    // The kiosk's open-visit set asks for ids only: it resolves names against the roster it already
    // holds, and paying for the joins there would be waste.
    final visit = TeamMemberSession.fromJson(row());

    expect(visit.teamMember, isNull);
    expect(visit.session, isNull);
    expect(visit.teamMemberId, 'member-1');
    expect(visit.checkOutTime, isNull);
  });

  test('a nested session without its location parses', () {
    final visit = TeamMemberSession.fromJson(
      row(
        session: {
          'id': 'session-1',
          'startTime': '2026-09-28T08:00:00+00:00',
          'endTime': '2026-09-28T12:00:00+00:00',
          'locationId': 'loc-1',
          'finished': true,
        },
      ),
    );

    expect(visit.session, isNotNull);
    expect(visit.session?.location, isNull);
  });
}
