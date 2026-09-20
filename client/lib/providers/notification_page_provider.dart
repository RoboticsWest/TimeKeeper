import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/models/notification.dart';
import 'package:time_keeper/models/paged_result.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/providers/notification_provider.dart';
import 'package:time_keeper/providers/paged_notifier.dart';
import 'package:time_keeper/providers/paged_query.dart';
import 'package:time_keeper/utils/time_utils.dart';

part 'notification_page_provider.g.dart';

const _notificationFields = 'id notificationType sessionId teamMemberId discordMessageId scheduledFor sentAt status';

const _notificationPageQuery =
    '''
  query NotificationsPage(\$filter: NotificationFilterInput, \$offset: Int, \$limit: Int) {
    notificationsPage(filter: \$filter, offset: \$offset, limit: \$limit) {
      items { $_notificationFields }
      totalCount
      offset
      limit
      hasMore
    }
  }
''';

/// Notification list filters, mirrored onto `NotificationFilterInput` on the server.
class NotificationFilterState {
  /// Case-insensitive match over the location name, the member's name, and the type and status.
  ///
  /// The server matches the *raw* `notification_type` and `status` values, but the list shows
  /// labels ("Scheduled" for `pending`). [toServerFilter] resolves a typed label back to its
  /// code so searching for what is on screen still works.
  final String search;

  /// Only notifications belonging to this session.
  final String? sessionId;

  /// Only the per-member kinds aimed at this member.
  final String? teamMemberId;

  /// Empty means every kind; otherwise values from [NotificationType].
  final List<String> notificationTypes;

  /// Empty means every state; otherwise values from [NotificationStatus].
  final List<String> statuses;

  /// Scheduled at or after this instant.
  final DateTime? from;

  /// Scheduled strictly before this instant.
  final DateTime? to;

  const NotificationFilterState({
    this.search = '',
    this.sessionId,
    this.teamMemberId,
    this.notificationTypes = const [],
    this.statuses = const [],
    this.from,
    this.to,
  });

  bool get isEmpty =>
      search.trim().isEmpty &&
      sessionId == null &&
      teamMemberId == null &&
      notificationTypes.isEmpty &&
      statuses.isEmpty &&
      from == null &&
      to == null;

  /// The term actually sent to the server.
  ///
  /// The list renders labels while the server matches the raw column values, so a typed label is
  /// swapped for its code — otherwise searching "Scheduled" (the label for `pending`) or
  /// "Session Start Reminder" (for `session_start_reminder`) would find nothing. The swap is
  /// deliberately whole-string: a partial match would hijack searches for a location or member
  /// whose name happens to share a prefix with a label.
  ///
  /// This cannot be expressed by also sending `statuses`/`notificationTypes` — the server ANDs
  /// those with `search`, which would narrow the result to nothing rather than widen it.
  String _serverSearchTerm() {
    final text = search.trim();
    if (text.isEmpty) return text;
    final needle = text.toLowerCase();

    for (final code in NotificationStatus.all) {
      if (NotificationStatus.label(code).toLowerCase() == needle) return code;
    }
    for (final code in NotificationType.all) {
      if (NotificationType.label(code).toLowerCase() == needle) return code;
    }
    return text;
  }

  Map<String, dynamic>? toServerFilter() {
    final text = _serverSearchTerm();

    final filter = <String, dynamic>{
      if (text.isNotEmpty) 'search': text,
      if (sessionId != null) 'sessionId': sessionId,
      if (teamMemberId != null) 'teamMemberId': teamMemberId,
      if (notificationTypes.isNotEmpty) 'notificationTypes': notificationTypes,
      if (statuses.isNotEmpty) 'statuses': statuses,
      if (from != null) 'from': toServerTime(from!),
      if (to != null) 'to': toServerTime(to!),
    };
    return filter.isEmpty ? null : filter;
  }
}

/// A paged, filtered slice of the notifications table, newest-scheduled first.
///
/// Notifications accumulate a few rows per session, so this grows with the season the same way
/// attendance does; filtering and paging happen in SQL.
@Riverpod(keepAlive: true)
class NotificationPage extends _$NotificationPage with PagedAsyncNotifier<Notification> {
  NotificationFilterState _filter = const NotificationFilterState();

  @override
  Future<PagedResult<Notification>> build() async {
    ref.watch(timeKeeperGraphQLClientProvider);
    ref.listen(notificationChangesProvider, (previous, next) {
      next.whenData((_) => loadDebounced());
    });
    return fetch(currentOffset, currentPageSize);
  }

  @override
  Future<PagedResult<Notification>> fetch(int offset, int pageSize) {
    return fetchPagedPage<Notification>(
      ref: ref,
      document: _notificationPageQuery,
      rootField: 'notificationsPage',
      variables: {'filter': _filter.toServerFilter(), 'offset': offset, 'limit': pageSize},
      fromJson: Notification.fromJson,
    ).then(
      (result) =>
          result ?? const PagedResult<Notification>(items: [], totalCount: 0, offset: 0, limit: 50, hasMore: false),
    );
  }

  void setFilter(NotificationFilterState filter) {
    if (identical(filter, _filter)) return;
    _filter = filter;
    resetToFirstPage();
  }
}
