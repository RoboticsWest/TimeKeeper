import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/generated/api/user.pbgrpc.dart';
import 'package:time_keeper/helpers/collection_storage.dart';
import 'package:time_keeper/helpers/reconnecting_stream.dart';
import 'package:time_keeper/providers/auth_provider.dart';

part 'user_provider.g.dart';

@riverpod
Stream<StreamUsersResponse> usersStream(Ref ref) {
  final reconnectingStream = ReconnectingStream<StreamUsersResponse>(() async {
    final client = ref.read(userServiceProvider);
    return client.streamUsers(StreamUsersRequest());
  });

  ref.onDispose(reconnectingStream.close);
  return reconnectingStream.stream;
}

@Riverpod(keepAlive: true)
class Users extends _$Users {
  late final CollectionStorage<UserResponse> _storage;

  @override
  Map<String, UserResponse> build() {
    _storage = CollectionStorage(
      tableName: 'users',
      fromBuffer: UserResponse.fromBuffer,
    );

    return _storage.getAll();
  }

  void syncFromStream(StreamUsersResponse response) {
    _storage.syncResponse(
      syncType: response.syncType,
      items: response.users,
      hasItem: (item) => item.username.isNotEmpty,
      getId: (item) => item.id,
      getItem: (item) => item,
      getState: () => state,
      setState: (newState) => state = newState,
    );
  }
}

/// Auto-dispose provider that bridges [usersStreamProvider] to [usersProvider].
/// Views watch this to activate the users stream.
@riverpod
void usersSync(Ref ref) {
  ref.listen(usersStreamProvider, (previous, next) {
    next.whenData((response) {
      ref.read(usersProvider.notifier).syncFromStream(response);
    });
  });
}
