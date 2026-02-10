import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/generated/api/session.pbgrpc.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/helpers/auth_interceptor.dart';
import 'package:time_keeper/helpers/collection_storage.dart';
import 'package:time_keeper/helpers/reconnecting_stream.dart';
import 'package:time_keeper/providers/auth_provider.dart';
import 'package:time_keeper/providers/grpc_channel_provider.dart';

part 'session_provider.g.dart';

@Riverpod(keepAlive: true)
SessionServiceClient sessionService(Ref ref) {
  final channel = ref.watch(grpcChannelProvider);
  final token = ref.watch(tokenProvider);
  final options = authCallOptions(token);

  return SessionServiceClient(channel, options: options);
}

@riverpod
Stream<StreamSessionsResponse> sessionsStream(Ref ref) {
  final reconnectingStream = ReconnectingStream<StreamSessionsResponse>(
    () async {
      final client = ref.read(sessionServiceProvider);
      return client.streamSessions(StreamSessionsRequest());
    },
  );

  ref.onDispose(reconnectingStream.close);
  return reconnectingStream.stream;
}

@Riverpod(keepAlive: true)
class Sessions extends _$Sessions {
  late final CollectionStorage<Session> _storage;

  @override
  Map<String, Session> build() {
    _storage = CollectionStorage(
      tableName: 'sessions',
      fromBuffer: Session.fromBuffer,
    );

    final localSessions = _storage.getAll();

    _storage.bindToStream(
      ref: ref,
      streamProvider: sessionsStreamProvider,
      extractItems: (response) => response.sessions,
      hasItem: (item) => item.hasSession(),
      getId: (item) => item.id,
      getItem: (item) => item.session,
      onUpdate: (updates) => state = {...state, ...updates},
    );

    return localSessions;
  }
}
