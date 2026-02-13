import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/generated/api/sync.pbgrpc.dart';
import 'package:time_keeper/helpers/auth_interceptor.dart';
import 'package:time_keeper/helpers/reconnecting_stream.dart';
import 'package:time_keeper/providers/auth_provider.dart';
import 'package:time_keeper/providers/grpc_channel_provider.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/rfid_tag_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/providers/team_member_session_provider.dart';

part 'entity_sync_provider.g.dart';

@Riverpod(keepAlive: true)
SyncServiceClient syncService(Ref ref) {
  final channel = ref.watch(grpcChannelProvider);
  final token = ref.watch(tokenProvider);
  final options = authCallOptions(token);

  return SyncServiceClient(channel, options: options);
}

@riverpod
Stream<StreamEntitiesResponse> entityStream(Ref ref) {
  final reconnectingStream = ReconnectingStream<StreamEntitiesResponse>(
    () async {
      final client = ref.read(syncServiceProvider);
      return client.streamEntities(StreamEntitiesRequest());
    },
  );

  ref.onDispose(reconnectingStream.close);
  return reconnectingStream.stream;
}

/// Auto-dispose provider that bridges [entityStreamProvider] to entity notifiers.
/// Views watch this to activate the combined entity stream.
@riverpod
void entitySync(Ref ref) {
  ref.listen(entityStreamProvider, (previous, next) {
    next.whenData((response) {
      switch (response.whichPayload()) {
        case StreamEntitiesResponse_Payload.sessions:
          ref.read(sessionsProvider.notifier).syncFromStream(response.sessions);
        case StreamEntitiesResponse_Payload.locations:
          ref
              .read(locationsProvider.notifier)
              .syncFromStream(response.locations);
        case StreamEntitiesResponse_Payload.teamMembers:
          ref
              .read(teamMembersProvider.notifier)
              .syncFromStream(response.teamMembers);
        case StreamEntitiesResponse_Payload.teamMemberSessions:
          ref
              .read(teamMemberSessionsProvider.notifier)
              .syncFromStream(response.teamMemberSessions);
        case StreamEntitiesResponse_Payload.rfidTags:
          ref.read(rfidTagsProvider.notifier).syncFromStream(response.rfidTags);
        case StreamEntitiesResponse_Payload.notSet:
          break;
      }
    });
  });
}
