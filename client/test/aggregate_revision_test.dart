import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/change_event.dart';
import 'package:time_keeper/models/session.dart';
import 'package:time_keeper/models/team_member.dart';
import 'package:time_keeper/models/team_member_session.dart';
import 'package:time_keeper/providers/aggregate_revision_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/providers/team_member_session_provider.dart';

/// What this guards: the server-computed aggregates are recomputed once per burst of changes, and
/// not at all just because a collection finished loading.
///
/// The leaderboard and achievements pages used to watch the collection providers themselves. A
/// collection's state changes when its *initial fetch lands*, so opening the achievements page
/// fired the (expensive, whole-database) query once immediately and then again as each of three
/// collections arrived — four recomputations for one answer, which under load exceeded the pool's
/// connection timeout and surfaced as "No team members yet".
void main() {
  TeamMemberSession visit(String id) =>
      TeamMemberSession(id: id, teamMemberId: 'm', sessionId: 's', checkInTime: DateTime(2026));

  ChangeEvent<TeamMemberSession> attendanceChange(String id) =>
      ChangeEvent(operation: ChangeOperation.update, id: id, data: visit(id));

  /// Builds a container whose three change streams are driven by the returned controllers.
  ({ProviderContainer container, StreamController<ChangeEvent<TeamMemberSession>> attendance}) harness() {
    final attendance = StreamController<ChangeEvent<TeamMemberSession>>.broadcast();
    final members = StreamController<ChangeEvent<TeamMember>>.broadcast();
    final sessions = StreamController<ChangeEvent<Session>>.broadcast();

    final container = ProviderContainer(
      overrides: [
        teamMemberSessionChangesProvider.overrideWith((ref) => attendance.stream),
        teamMemberChangesProvider.overrideWith((ref) => members.stream),
        sessionChangesProvider.overrideWith((ref) => sessions.stream),
      ],
    );
    addTearDown(() {
      container.dispose();
      attendance.close();
      members.close();
      sessions.close();
    });
    return (container: container, attendance: attendance);
  }

  test('starts at a revision that does not move on its own', () {
    fakeAsync((async) {
      final h = harness();
      h.container.listen(aggregateRevisionProvider, (_, _) {});

      expect(h.container.read(aggregateRevisionProvider), 0);
      async.elapse(const Duration(seconds: 10));
      expect(h.container.read(aggregateRevisionProvider), 0, reason: 'no changes means no recomputation');
    });
  });

  test('a change advances the revision once the data goes quiet', () {
    fakeAsync((async) {
      final h = harness();
      h.container.listen(aggregateRevisionProvider, (_, _) {});
      async.flushMicrotasks();

      h.attendance.add(attendanceChange('a'));
      async.flushMicrotasks();
      expect(h.container.read(aggregateRevisionProvider), 0, reason: 'still inside the quiet period');

      async.elapse(const Duration(seconds: 3));
      expect(h.container.read(aggregateRevisionProvider), 1);
    });
  });

  test('a burst of changes collapses into one recomputation', () {
    fakeAsync((async) {
      final h = harness();
      h.container.listen(aggregateRevisionProvider, (_, _) {});
      async.flushMicrotasks();

      // A session starting: a room full of people tagging in, or a bulk clear burning through
      // thousands of rows. Each one used to be its own full recomputation.
      for (var i = 0; i < 50; i++) {
        h.attendance.add(attendanceChange('row-$i'));
        async.elapse(const Duration(milliseconds: 100));
      }
      async.elapse(const Duration(seconds: 3));

      expect(h.container.read(aggregateRevisionProvider), 1);
    });
  });

  test('changes separated by a quiet period each count', () {
    fakeAsync((async) {
      final h = harness();
      h.container.listen(aggregateRevisionProvider, (_, _) {});
      async.flushMicrotasks();

      h.attendance.add(attendanceChange('a'));
      async.elapse(const Duration(seconds: 3));
      h.attendance.add(attendanceChange('b'));
      async.elapse(const Duration(seconds: 3));

      expect(h.container.read(aggregateRevisionProvider), 2);
    });
  });
}
