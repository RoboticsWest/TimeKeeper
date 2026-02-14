import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/generated/api/notification.pbgrpc.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/helpers/auth_interceptor.dart';
import 'package:time_keeper/helpers/collection_storage.dart';
import 'package:time_keeper/providers/auth_provider.dart';
import 'package:time_keeper/providers/grpc_channel_provider.dart';

part 'notification_provider.g.dart';

@Riverpod(keepAlive: true)
NotificationServiceClient notificationService(Ref ref) {
  final channel = ref.watch(grpcChannelProvider);
  final token = ref.watch(tokenProvider);
  final options = authCallOptions(token);

  return NotificationServiceClient(channel, options: options);
}

@Riverpod(keepAlive: true)
class Notifications extends _$Notifications {
  late final CollectionStorage<Notification> _storage;

  @override
  Map<String, Notification> build() {
    _storage = CollectionStorage(
      tableName: 'notifications',
      fromBuffer: Notification.fromBuffer,
    );

    return _storage.getAll();
  }

  void syncFromStream(StreamNotificationsResponse response) {
    _storage.syncResponse(
      syncType: response.syncType,
      items: response.notifications,
      hasItem: (item) => item.hasNotification(),
      getId: (item) => item.id,
      getItem: (item) => item.notification,
      getState: () => state,
      setState: (newState) => state = newState,
    );
  }
}
