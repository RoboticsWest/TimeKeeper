import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/models/team_member_session.dart';
import 'package:time_keeper/providers/aggregate_revision_provider.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';

part 'attendance_counts_provider.g.dart';

const _countsQuery = r'''
  query SessionAttendanceCounts($sessionIds: [UUID!]!) {
    sessionAttendanceCounts(sessionIds: $sessionIds) { sessionId members checkedIn }
  }
''';

const _summaryQuery = r'''
  query AttendanceSummary {
    attendanceSummary { records members }
  }
''';

/// How many people a session has seen, and how many are still in it.
class SessionAttendanceCount {
  /// Distinct members with at least one attendance row for the session.
  final int members;

  /// Of those, how many have not checked out.
  final int checkedIn;

  const SessionAttendanceCount({required this.members, required this.checkedIn});

  static const empty = SessionAttendanceCount(members: 0, checkedIn: 0);
}

/// Attendance counters for one page of sessions, counted in SQL.
///
/// The Sessions table used to count these in Dart over a client-side copy of the whole attendance
/// table — which is why the whole table had to be downloaded to render a column of numbers.
/// Keyed by the ids on screen, so paging asks about a page's worth at a time.
@riverpod
Future<Map<String, SessionAttendanceCount>> sessionAttendanceCounts(Ref ref, List<String> sessionIds) async {
  if (sessionIds.isEmpty) return const {};
  // Recounted when attendance changes, on the same debounce as the other aggregates.
  ref.watch(aggregateRevisionProvider);

  final client = ref.watch(timeKeeperGraphQLClientProvider);
  final result = await client.query(
    QueryOptions(document: gql(_countsQuery), variables: {'sessionIds': sessionIds}, fetchPolicy: FetchPolicy.noCache),
  );
  if (result.hasException || result.data == null) return const {};

  final rows = result.data!['sessionAttendanceCounts'] as List<dynamic>? ?? const [];
  return {
    for (final row in rows.whereType<Map<String, dynamic>>())
      row['sessionId'] as String: SessionAttendanceCount(
        members: (row['members'] as num?)?.toInt() ?? 0,
        checkedIn: (row['checkedIn'] as num?)?.toInt() ?? 0,
      ),
  };
}

/// Table-wide attendance totals.
class AttendanceSummary {
  /// Attendance rows in total.
  final int records;

  /// Distinct members who have ever checked in.
  final int members;

  const AttendanceSummary({required this.records, required this.members});

  static const empty = AttendanceSummary(records: 0, members: 0);
}

/// Table-wide attendance totals, for the KPI tiles that only ever showed a count.
///
/// One aggregate row instead of the whole table: the Sessions page's "Unique Members" tile used to
/// be a `Set` built by walking every attendance record the client had downloaded.
@riverpod
Future<AttendanceSummary> attendanceSummary(Ref ref) async {
  ref.watch(aggregateRevisionProvider);

  final client = ref.watch(timeKeeperGraphQLClientProvider);
  final result = await client.query(QueryOptions(document: gql(_summaryQuery), fetchPolicy: FetchPolicy.noCache));
  if (result.hasException || result.data == null) return AttendanceSummary.empty;

  final row = result.data!['attendanceSummary'] as Map<String, dynamic>?;
  if (row == null) return AttendanceSummary.empty;
  return AttendanceSummary(
    records: (row['records'] as num?)?.toInt() ?? 0,
    members: (row['members'] as num?)?.toInt() ?? 0,
  );
}

const _sessionAttendanceQuery = r'''
  query SessionAttendance($sessionId: UUID!) {
    attendance(filter: { sessionIds: [$sessionId] }, limit: 1000) {
      items {
        id
        teamMemberId
        sessionId
        checkInTime
        checkOutTime
        teamMember { id firstName lastName memberType displayName }
      }
    }
  }
''';

/// One session's attendance rows, newest activity first.
///
/// Asked for the session actually being looked at, rather than filtered out of a client-side copy
/// of the whole table. A session is attended by at most the size of the team, so a single page
/// covers it.
@riverpod
Future<List<TeamMemberSession>> sessionAttendance(Ref ref, String sessionId) async {
  ref.watch(aggregateRevisionProvider);

  final client = ref.watch(timeKeeperGraphQLClientProvider);
  final result = await client.query(
    QueryOptions(
      document: gql(_sessionAttendanceQuery),
      variables: {'sessionId': sessionId},
      fetchPolicy: FetchPolicy.noCache,
    ),
  );
  if (result.hasException || result.data == null) return const [];

  final page = result.data!['attendance'] as Map<String, dynamic>?;
  final rows = page?['items'] as List<dynamic>? ?? const [];
  return rows.whereType<Map<String, dynamic>>().map(TeamMemberSession.fromJson).toList();
}
