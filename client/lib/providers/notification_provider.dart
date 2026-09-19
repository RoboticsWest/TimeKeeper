import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/models/change_event.dart';
import 'package:time_keeper/models/notification.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/providers/realtime_collection.dart';
import 'package:time_keeper/utils/api_result.dart';
import 'package:time_keeper/utils/time_utils.dart';

part 'notification_provider.g.dart';

const _notificationFields = 'id notificationType sessionId teamMemberId discordMessageId scheduledFor sentAt status';

const _notificationsQuery =
    '''
  query Notifications {
    notifications { $_notificationFields }
  }
''';

const _notificationChangesSubscription =
    '''
  subscription NotificationChanges {
    notificationChanges { operation id data { $_notificationFields } }
  }
''';

const _scheduleNotificationMutation =
    '''
  mutation ScheduleNotification(\$notificationType: String!, \$sessionId: UUID!, \$teamMemberId: UUID, \$scheduledFor: DateTime) {
    scheduleNotification(notificationType: \$notificationType, sessionId: \$sessionId, teamMemberId: \$teamMemberId, scheduledFor: \$scheduledFor) { $_notificationFields }
  }
''';

const _setNotificationStatusMutation =
    '''
  mutation SetNotificationStatus(\$id: UUID!, \$status: String!) {
    setNotificationStatus(id: \$id, status: \$status) { $_notificationFields }
  }
''';

const _cancelNotificationMutation =
    '''
  mutation CancelNotification(\$id: UUID!) {
    cancelNotification(id: \$id) { $_notificationFields }
  }
''';

const _deleteNotificationMutation = r'''
  mutation DeleteNotification($id: UUID!) {
    deleteNotification(id: $id)
  }
''';

@riverpod
Stream<ChangeEvent<Notification>> notificationChanges(Ref ref) {
  final client = ref.watch(timeKeeperGraphQLClientProvider);
  return client
      .subscribe(SubscriptionOptions(document: gql(_notificationChangesSubscription)))
      .where((result) => result.data != null)
      .map(
        (result) =>
            ChangeEvent.fromJson(result.data!['notificationChanges'] as Map<String, dynamic>, Notification.fromJson),
      );
}

@Riverpod(keepAlive: true)
class Notifications extends _$Notifications {
  @override
  Map<String, Notification> build() {
    // Re-seed whenever the client is rebuilt (endpoint, TLS or token changed).
    // Without this a fetch that failed at startup is never retried.
    ref.watch(timeKeeperGraphQLClientProvider);
    _fetchInitial();
    return {};
  }

  Future<void> _fetchInitial() async {
    final items = await fetchCollection<Notification>(
      ref: ref,
      document: _notificationsQuery,
      rootField: 'notifications',
      fromJson: Notification.fromJson,
      idOf: (item) => item.id,
    );
    // Null means every attempt failed; keep what we have rather than
    // replacing real data with an empty map.
    if (items != null) state = items;
  }

  Future<void> refresh() => _fetchInitial();

  void applyChange(ChangeEvent<Notification> change) {
    state = applyChangeToMap(state, change);
  }

  /// Schedules a notification. Idempotent server-side: scheduling one that already exists
  /// returns the existing row rather than duplicating it or resetting its status.
  Future<ApiCallResult> schedule({
    required String notificationType,
    required String sessionId,
    String? teamMemberId,
    DateTime? scheduledFor,
  }) => _mutate(_scheduleNotificationMutation, {
    'notificationType': notificationType,
    'sessionId': sessionId,
    'teamMemberId': teamMemberId,
    'scheduledFor': toServerTimeOrNull(scheduledFor),
  });

  Future<ApiCallResult> setStatus({required String id, required String status}) =>
      _mutate(_setNotificationStatusMutation, {'id': id, 'status': status});

  /// Switches off a scheduled reminder without deleting it.
  ///
  /// Preferred over [delete]: a cancelled row still records that this reminder was deliberately
  /// suppressed, whereas a deleted one is indistinguishable from one never scheduled — which is
  /// exactly how the old model ended up re-sending reminders people had removed.
  Future<ApiCallResult> cancel(String id) => _mutate(_cancelNotificationMutation, {'id': id});

  Future<ApiCallResult> delete(String id) => _mutate(_deleteNotificationMutation, {'id': id});

  Future<ApiCallResult> _mutate(String document, Map<String, dynamic> variables) async {
    final client = ref.read(timeKeeperGraphQLClientProvider);
    final result = await client.mutate(
      MutationOptions(document: gql(document), variables: variables, fetchPolicy: FetchPolicy.noCache),
    );
    if (result.hasException) {
      final message = result.exception!.graphqlErrors.isNotEmpty
          ? result.exception!.graphqlErrors.map((e) => e.message).join('; ')
          : result.exception.toString();
      return ApiCallResult(success: false, message: message);
    }
    return const ApiCallResult(success: true);
  }
}

@Riverpod(keepAlive: true)
void notificationsSync(Ref ref) {
  ref.listen(
    notificationChangesProvider,
    changeListener<Notification>(
      apply: (change) => ref.read(notificationsProvider.notifier).applyChange(change),
      refresh: () => ref.read(notificationsProvider.notifier).refresh(),
    ),
  );
}
