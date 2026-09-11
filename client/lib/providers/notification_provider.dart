import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/helpers/collection_storage.dart';
import 'package:time_keeper/models/change_event.dart';
import 'package:time_keeper/models/notification.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/utils/api_result.dart';

part 'notification_provider.g.dart';

const _notificationFields = 'id notificationType sessionId teamMemberId sent discordMessageId';

const _notificationsQuery = '''
  query Notifications {
    notifications { $_notificationFields }
  }
''';

const _notificationChangesSubscription = '''
  subscription NotificationChanges {
    notificationChanges { operation id data { $_notificationFields } }
  }
''';

const _createNotificationMutation = '''
  mutation CreateNotification(\$notificationType: String!, \$sessionId: UUID!, \$teamMemberId: UUID, \$sent: Boolean!) {
    createNotification(notificationType: \$notificationType, sessionId: \$sessionId, teamMemberId: \$teamMemberId, sent: \$sent) { $_notificationFields }
  }
''';

const _updateNotificationMutation = '''
  mutation UpdateNotification(\$id: UUID!, \$notificationType: String!, \$sessionId: UUID!, \$teamMemberId: UUID, \$sent: Boolean!) {
    updateNotification(id: \$id, notificationType: \$notificationType, sessionId: \$sessionId, teamMemberId: \$teamMemberId, sent: \$sent) { $_notificationFields }
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
        (result) => ChangeEvent.fromJson(result.data!['notificationChanges'] as Map<String, dynamic>, Notification.fromJson),
      );
}

@Riverpod(keepAlive: true)
class Notifications extends _$Notifications {
  late final CollectionStorage<Notification> _storage;

  @override
  Map<String, Notification> build() {
    _storage = CollectionStorage(
      tableName: 'notifications',
      fromJson: Notification.fromJson,
      toJson: (n) => n.toJson(),
    );
    _fetchInitial();
    return _storage.getAll();
  }

  Future<void> _fetchInitial() async {
    final client = ref.read(timeKeeperGraphQLClientProvider);
    final result = await client.query(
      QueryOptions(document: gql(_notificationsQuery), fetchPolicy: FetchPolicy.noCache),
    );
    if (result.hasException || result.data == null) return;

    final items = (result.data!['notifications'] as List<dynamic>)
        .map((e) => Notification.fromJson(e as Map<String, dynamic>))
        .toList();
    state = _storage.seedFromList(items, (n) => n.id);
  }

  void applyChange(ChangeEvent<Notification> change) {
    state = _storage.applyChange(change, state);
  }

  Future<ApiCallResult> create({
    required String notificationType,
    required String sessionId,
    String? teamMemberId,
    required bool sent,
  }) => _mutate(_createNotificationMutation, {
    'notificationType': notificationType,
    'sessionId': sessionId,
    'teamMemberId': teamMemberId,
    'sent': sent,
  });

  Future<ApiCallResult> update({
    required String id,
    required String notificationType,
    required String sessionId,
    String? teamMemberId,
    required bool sent,
  }) => _mutate(_updateNotificationMutation, {
    'id': id,
    'notificationType': notificationType,
    'sessionId': sessionId,
    'teamMemberId': teamMemberId,
    'sent': sent,
  });

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

@riverpod
void notificationsSync(Ref ref) {
  ref.listen(notificationChangesProvider, (previous, next) {
    next.whenData((change) {
      ref.read(notificationsProvider.notifier).applyChange(change);
    });
  });
}
