import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/generated/api/rfid_tag.pbgrpc.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/helpers/auth_interceptor.dart';
import 'package:time_keeper/helpers/collection_storage.dart';
import 'package:time_keeper/helpers/reconnecting_stream.dart';
import 'package:time_keeper/providers/auth_provider.dart';
import 'package:time_keeper/providers/grpc_channel_provider.dart';

part 'rfid_tag_provider.g.dart';

@Riverpod(keepAlive: true)
RfidTagServiceClient rfidTagService(Ref ref) {
  final channel = ref.watch(grpcChannelProvider);
  final token = ref.watch(tokenProvider);
  final options = authCallOptions(token);

  return RfidTagServiceClient(channel, options: options);
}

@riverpod
Stream<StreamRfidTagsResponse> rfidTagsStream(Ref ref) {
  final reconnectingStream = ReconnectingStream<StreamRfidTagsResponse>(
    () async {
      final client = ref.read(rfidTagServiceProvider);
      return client.streamRfidTags(StreamRfidTagsRequest());
    },
  );

  ref.onDispose(reconnectingStream.close);
  return reconnectingStream.stream;
}

@Riverpod(keepAlive: true)
class RfidTags extends _$RfidTags {
  late final CollectionStorage<RfidTag> _storage;

  @override
  Map<String, RfidTag> build() {
    _storage = CollectionStorage(
      tableName: 'rfid_tags',
      fromBuffer: RfidTag.fromBuffer,
    );

    return _storage.getAll();
  }

  void syncFromStream(StreamRfidTagsResponse response) {
    _storage.syncResponse(
      syncType: response.syncType,
      items: response.rfidTags,
      hasItem: (item) => item.hasRfidTag(),
      getId: (item) => item.id,
      getItem: (item) => item.rfidTag,
      getState: () => state,
      setState: (newState) => state = newState,
    );
  }
}

@Riverpod(keepAlive: true)
Map<String, RfidTag> rfidTagsByMember(Ref ref, String memberId) {
  final tags = ref.watch(rfidTagsProvider);
  return Map.fromEntries(
    tags.entries.where((entry) => entry.value.teamMemberId == memberId),
  );
}
