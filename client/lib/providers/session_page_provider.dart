import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/models/paged_result.dart';
import 'package:time_keeper/models/session.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/providers/paged_notifier.dart';
import 'package:time_keeper/providers/paged_query.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/utils/time_utils.dart';

part 'session_page_provider.g.dart';

const _sessionFields = 'id startTime endTime locationId finished actualStartTime actualEndTime';

const _sessionPageQuery =
    '''
  query SessionPage(\$filter: SessionFilterInput, \$offset: Int, \$limit: Int) {
    sessionPage(filter: \$filter, offset: \$offset, limit: \$limit) {
      items { $_sessionFields }
      totalCount
      offset
      limit
      hasMore
    }
  }
''';

/// Session list filters, mirrored onto `SessionFilterInput` on the server.
class SessionFilterState {
  final String? locationId;

  /// `null` shows both scheduled and finished sessions.
  final bool? finished;

  /// Restricts to sessions starting within this day (local time), or null for every day.
  final DateTime? day;

  const SessionFilterState({this.locationId, this.finished, this.day});

  bool get isEmpty => locationId == null && finished == null && day == null;

  Map<String, dynamic>? toServerFilter() {
    final (from, to) = day == null
        ? (null, null)
        : (
            DateTime(day!.year, day!.month, day!.day),
            DateTime(day!.year, day!.month, day!.day).add(const Duration(days: 1)),
          );

    final filter = <String, dynamic>{
      if (locationId != null) 'locationIds': [locationId],
      if (finished != null) 'finished': finished,
      if (from != null) 'from': toServerTime(from),
      if (to != null) 'to': toServerTime(to),
    };
    return filter.isEmpty ? null : filter;
  }
}

/// A paged, filtered slice of sessions for the table mode of the Sessions view. The calendar and
/// stats still read the whole set from the collection providers.
@Riverpod(keepAlive: true)
class SessionPage extends _$SessionPage with PagedAsyncNotifier<Session> {
  SessionFilterState _filter = const SessionFilterState();

  @override
  Future<PagedResult<Session>> build() async {
    ref.watch(timeKeeperGraphQLClientProvider);
    ref.listen(sessionChangesProvider, (previous, next) {
      next.whenData((_) => loadDebounced());
    });
    return fetch(currentOffset, currentPageSize);
  }

  @override
  Future<PagedResult<Session>> fetch(int offset, int pageSize) {
    return fetchPagedPage<Session>(
      ref: ref,
      document: _sessionPageQuery,
      rootField: 'sessionPage',
      variables: {'filter': _filter.toServerFilter(), 'offset': offset, 'limit': pageSize},
      fromJson: Session.fromJson,
    ).then(
      (result) => result ?? const PagedResult<Session>(items: [], totalCount: 0, offset: 0, limit: 50, hasMore: false),
    );
  }

  void setFilter(SessionFilterState filter) {
    if (identical(filter, _filter)) return;
    _filter = filter;
    resetToFirstPage();
  }
}
