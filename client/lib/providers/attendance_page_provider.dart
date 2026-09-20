import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/models/paged_result.dart';
import 'package:time_keeper/models/team_member_session.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/providers/paged_notifier.dart';
import 'package:time_keeper/providers/paged_query.dart';
import 'package:time_keeper/providers/team_member_session_provider.dart';
import 'package:time_keeper/utils/time_utils.dart';

part 'attendance_page_provider.g.dart';

const _teamMemberSessionFields = 'id teamMemberId sessionId checkInTime checkOutTime';

const _attendancePageQuery =
    '''
  query AttendancePage(\$filter: AttendanceFilterInput, \$offset: Int, \$limit: Int) {
    attendance(filter: \$filter, offset: \$offset, limit: \$limit) {
      items { $_teamMemberSessionFields }
      totalCount
      offset
      limit
      hasMore
    }
  }
''';

/// How far back the attendance date filter reaches.
enum AttendanceDateRange { allTime, today, last7Days, last30Days }

/// Which states of a visit to show.
enum AttendanceStatusFilter { all, checkedIn, completed }

/// Attendance list filters, mirrored onto `AttendanceFilterInput` on the server.
///
/// Every filter is applied in SQL, so the fetch cost stays proportional to the page rather than
/// to the whole table.
class AttendanceFilterState {
  /// Case-insensitive match over the member's name.
  final String search;

  /// Single selected session, or null for every session.
  final String? sessionId;

  /// Single selected location, or null for every location.
  final String? locationId;

  final AttendanceDateRange dateRange;

  /// Empty means every type; otherwise "student" / "mentor".
  final List<String> memberTypes;

  final AttendanceStatusFilter status;

  const AttendanceFilterState({
    this.search = '',
    this.sessionId,
    this.locationId,
    this.dateRange = AttendanceDateRange.allTime,
    this.memberTypes = const [],
    this.status = AttendanceStatusFilter.all,
  });

  bool get isEmpty =>
      search.trim().isEmpty &&
      sessionId == null &&
      locationId == null &&
      dateRange == AttendanceDateRange.allTime &&
      memberTypes.isEmpty &&
      status == AttendanceStatusFilter.all;

  /// Builds the `AttendanceFilterInput` value, or null when nothing is constrained.
  Map<String, dynamic>? toServerFilter() {
    final now = DateTime.now();
    final (DateTime? from, DateTime? to) = switch (dateRange) {
      AttendanceDateRange.allTime => (null, null),
      AttendanceDateRange.today => _dayRange(now),
      AttendanceDateRange.last7Days => (
        now.subtract(const Duration(days: 6)).copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0),
        null,
      ),
      AttendanceDateRange.last30Days => (
        now.subtract(const Duration(days: 29)).copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0),
        null,
      ),
    };

    final filter = <String, dynamic>{
      if (search.trim().isNotEmpty) 'search': search.trim(),
      if (sessionId != null) 'sessionIds': [sessionId],
      if (locationId != null) 'locationIds': [locationId],
      if (from != null) 'from': toServerTime(from),
      if (to != null) 'to': toServerTime(to),
      if (memberTypes.isNotEmpty) 'memberTypes': memberTypes,
      if (status == AttendanceStatusFilter.checkedIn) 'checkedInOnly': true,
      if (status == AttendanceStatusFilter.completed) 'checkedInOnly': false,
    };
    return filter.isEmpty ? null : filter;
  }

  static (DateTime, DateTime) _dayRange(DateTime now) {
    final start = DateTime(now.year, now.month, now.day);
    return (start, start.add(const Duration(days: 1)));
  }
}

/// The administrator's attendance history, rendered one page at a time.
///
/// Backed by the server-side `attendance` query so the UI never holds the whole (unbounded)
/// table in memory at once. Realtime deltas re-pull the current page so the list stays honest
/// without being fetched wholesale.
@Riverpod(keepAlive: true)
class AttendancePage extends _$AttendancePage with PagedAsyncNotifier<TeamMemberSession> {
  AttendanceFilterState _filter = const AttendanceFilterState();

  @override
  Future<PagedResult<TeamMemberSession>> build() async {
    // Re-seed when the client is rebuilt (endpoint, TLS or token changed), like the collections.
    ref.watch(timeKeeperGraphQLClientProvider);
    // Keep the page honest: a change event means the filtered page is stale.
    ref.listen(teamMemberSessionChangesProvider, (previous, next) {
      next.whenData((_) => loadDebounced());
    });
    return fetch(currentOffset, currentPageSize);
  }

  @override
  Future<PagedResult<TeamMemberSession>> fetch(int offset, int pageSize) {
    return fetchPagedPage<TeamMemberSession>(
      ref: ref,
      document: _attendancePageQuery,
      rootField: 'attendance',
      variables: {'filter': _filter.toServerFilter(), 'offset': offset, 'limit': pageSize},
      fromJson: TeamMemberSession.fromJson,
    ).then(
      (result) =>
          result ??
          const PagedResult<TeamMemberSession>(items: [], totalCount: 0, offset: 0, limit: 50, hasMore: false),
    );
  }

  void setFilter(AttendanceFilterState filter) {
    if (identical(filter, _filter)) return;
    _filter = filter;
    resetToFirstPage();
  }
}
