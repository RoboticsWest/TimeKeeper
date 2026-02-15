import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/generated/api/session_rsvp.pbgrpc.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/helpers/auth_interceptor.dart';
import 'package:time_keeper/helpers/collection_storage.dart';
import 'package:time_keeper/providers/auth_provider.dart';
import 'package:time_keeper/providers/grpc_channel_provider.dart';

part 'session_rsvp_provider.g.dart';

@Riverpod(keepAlive: true)
SessionRsvpServiceClient sessionRsvpService(Ref ref) {
  final channel = ref.watch(grpcChannelProvider);
  final token = ref.watch(tokenProvider);
  final options = authCallOptions(token);

  return SessionRsvpServiceClient(channel, options: options);
}

@Riverpod(keepAlive: true)
class SessionRsvps extends _$SessionRsvps {
  late final CollectionStorage<SessionRsvp> _storage;

  @override
  Map<String, SessionRsvp> build() {
    _storage = CollectionStorage(
      tableName: 'session_rsvps',
      fromBuffer: SessionRsvp.fromBuffer,
    );

    return _storage.getAll();
  }

  void syncFromStream(StreamSessionRsvpsResponse response) {
    _storage.syncResponse(
      syncType: response.syncType,
      items: response.rsvps,
      hasItem: (item) => item.hasRsvp(),
      getId: (item) => item.id,
      getItem: (item) => item.rsvp,
      getState: () => state,
      setState: (newState) => state = newState,
    );
  }
}
