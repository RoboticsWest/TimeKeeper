import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/generated/api/team_member_session.pbgrpc.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/helpers/auth_interceptor.dart';
import 'package:time_keeper/helpers/collection_storage.dart';
import 'package:time_keeper/helpers/reconnecting_stream.dart';
import 'package:time_keeper/providers/auth_provider.dart';
import 'package:time_keeper/providers/grpc_channel_provider.dart';

part 'team_member_session_provider.g.dart';

@Riverpod(keepAlive: true)
TeamMemberSessionServiceClient teamMemberSessionService(Ref ref) {
  final channel = ref.watch(grpcChannelProvider);
  final token = ref.watch(tokenProvider);
  final options = authCallOptions(token);

  return TeamMemberSessionServiceClient(channel, options: options);
}

@riverpod
Stream<StreamTeamMemberSessionsResponse> teamMemberSessionsStream(Ref ref) {
  final reconnectingStream =
      ReconnectingStream<StreamTeamMemberSessionsResponse>(() async {
        final client = ref.read(teamMemberSessionServiceProvider);
        return client.streamTeamMemberSessions(
          StreamTeamMemberSessionsRequest(),
        );
      });

  ref.onDispose(reconnectingStream.close);
  return reconnectingStream.stream;
}

@Riverpod(keepAlive: true)
class TeamMemberSessions extends _$TeamMemberSessions {
  late final CollectionStorage<TeamMemberSession> _storage;

  @override
  Map<String, TeamMemberSession> build() {
    _storage = CollectionStorage(
      tableName: 'team_member_sessions',
      fromBuffer: TeamMemberSession.fromBuffer,
    );

    return _storage.getAll();
  }

  void syncFromStream(StreamTeamMemberSessionsResponse response) {
    _storage.syncResponse(
      syncType: response.syncType,
      items: response.teamMemberSessions,
      hasItem: (item) => item.hasTeamMemberSession(),
      getId: (item) => item.id,
      getItem: (item) => item.teamMemberSession,
      getState: () => state,
      setState: (newState) => state = newState,
    );
  }
}
