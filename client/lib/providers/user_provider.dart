import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/generated/api/user.pbgrpc.dart';
import 'package:time_keeper/helpers/collection_storage.dart';
import 'package:time_keeper/helpers/reconnecting_stream.dart';
import 'package:time_keeper/providers/auth_provider.dart';

part 'user_provider.g.dart';

@Riverpod(keepAlive: true)
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

    final localUsers = _storage.getAll();

    _storage.bindToStream(
      ref: ref,
      streamProvider: usersStreamProvider,
      extractItems: (response) => response.users,
      getSyncType: (response) => response.syncType,
      hasItem: (item) => item.hasId(),
      getId: (item) => item.id,
      getItem: (item) => item,
      onSync: (fullState) => state = fullState,
      onUpdate: (updates) => state = {...state, ...updates},
    );

    return localUsers;
  }
}
