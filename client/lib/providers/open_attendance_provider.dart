import 'dart:async';

import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/models/team_member_session.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/providers/team_member_session_provider.dart';
import 'package:time_keeper/utils/time_utils.dart';

part 'open_attendance_provider.g.dart';

/// The kiosk board prints a name and a location for every row, so the query asks for them. Both
/// are resolved server-side and batched: the set is bounded by the size of the team, and one extra
/// query for the whole board beats holding the roster and the locations table to look ids up in.
const _openAttendanceQuery = r'''
  query OpenAttendance {
    openAttendance {
      id
      teamMemberId
      sessionId
      checkInTime
      checkOutTime
      teamMember { id firstName lastName memberType displayName }
      session { id startTime endTime locationId finished location { id location } }
    }
  }
''';

/// How long attendance has to stay quiet before the open set is re-read.
///
/// A session starting means a room full of people tagging in at once; without this each scan would
/// pull the list again.
const _quietPeriod = Duration(milliseconds: 400);

/// Who is checked in right now, keyed by attendance id.
///
/// This is the answer to every question the app asks of attendance on a hot path — the kiosk's
/// board, the roster's Check In/Check Out button, the RFID scan's "are they already in?" — and it
/// is bounded by the size of the team rather than by how long the club has existed.
///
/// It exists because those callers used to read [teamMemberSessionsProvider], the *whole*
/// attendance table, which the app downloaded at every login. At a couple of seasons' history that
/// is several megabytes of JSON parsed on the UI isolate before the first screen settles, and on a
/// link with real latency it is most of what "the app feels sluggish" meant. The full collection
/// still exists for the things that genuinely need history (statistics, session totals, CSV
/// export) and is now fetched only when one of those is opened.
///
/// Re-read rather than patched from deltas: a change event can *remove* a row from this set (the
/// checkout that closed it), and an event for a row that was never in it still has to be
/// considered. Asking the server is both simpler and cheap, because the answer is small.
@Riverpod(keepAlive: true)
class OpenAttendance extends _$OpenAttendance {
  Timer? _debounce;

  @override
  Map<String, TeamMemberSession> build() {
    // Re-seed when the client is rebuilt (endpoint, TLS or token changed), like the collections.
    ref.watch(timeKeeperGraphQLClientProvider);

    ref.listen(teamMemberSessionChangesProvider, (previous, next) {
      next.whenData((_) {
        _debounce?.cancel();
        _debounce = Timer(_quietPeriod, () => unawaited(refresh()));
      });
    });

    ref.onDispose(() => _debounce?.cancel());

    unawaited(refresh());
    return {};
  }

  Future<void> refresh() async {
    final client = ref.read(timeKeeperGraphQLClientProvider);
    final result = await client.query(
      QueryOptions(document: gql(_openAttendanceQuery), fetchPolicy: FetchPolicy.noCache),
    );
    // A failed read leaves the previous answer in place rather than claiming the building is
    // empty — "nobody is checked in" is a statement the kiosk acts on.
    if (result.hasException || result.data == null) return;

    final rows = result.data!['openAttendance'] as List<dynamic>? ?? const [];
    final visits = rows.whereType<Map<String, dynamic>>().map(TeamMemberSession.fromJson);
    state = {for (final visit in visits) visit.id: visit};
  }
}

const _lastActivityQuery = r'''
  query LastAttendanceActivity($teamMemberId: UUID!) {
    lastAttendanceActivity(teamMemberId: $teamMemberId)
  }
''';

/// When [memberId] last checked in or out, or null if they never have (or the lookup failed).
///
/// One indexed row lookup, asked at the moment the kiosk needs it. The scan debounce used to
/// answer this by walking a client-side copy of every attendance row ever recorded — which is the
/// only reason that copy had to exist on a kiosk at all.
///
/// Null on failure is deliberate: a debounce that cannot reach the server must not refuse a scan.
Future<DateTime?> fetchLastAttendanceActivity(GraphQLClient client, String memberId) async {
  final result = await client.query(
    QueryOptions(
      document: gql(_lastActivityQuery),
      variables: {'teamMemberId': memberId},
      fetchPolicy: FetchPolicy.noCache,
    ),
  );
  if (result.hasException || result.data == null) return null;

  final value = result.data!['lastAttendanceActivity'] as String?;
  return value == null ? null : parseServerTime(value);
}
