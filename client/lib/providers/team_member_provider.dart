import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/generated/api/team_member.pbgrpc.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/helpers/auth_interceptor.dart';
import 'package:time_keeper/helpers/collection_storage.dart';
import 'package:time_keeper/helpers/reconnecting_stream.dart';
import 'package:time_keeper/providers/auth_provider.dart';
import 'package:time_keeper/providers/grpc_channel_provider.dart';

part 'team_member_provider.g.dart';

@Riverpod(keepAlive: true)
TeamMemberServiceClient teamMemberService(Ref ref) {
  final channel = ref.watch(grpcChannelProvider);
  final token = ref.watch(tokenProvider);
  final options = authCallOptions(token);

  return TeamMemberServiceClient(channel, options: options);
}

@riverpod
Stream<StreamTeamMembersResponse> teamMembersStream(Ref ref) {
  final reconnectingStream = ReconnectingStream<StreamTeamMembersResponse>(
    () async {
      final client = ref.read(teamMemberServiceProvider);
      return client.streamTeamMembers(StreamTeamMembersRequest());
    },
  );

  ref.onDispose(reconnectingStream.close);
  return reconnectingStream.stream;
}

@Riverpod(keepAlive: true)
class TeamMembers extends _$TeamMembers {
  late final CollectionStorage<TeamMember> _storage;

  @override
  Map<String, TeamMember> build() {
    _storage = CollectionStorage(
      tableName: 'team_members',
      fromBuffer: TeamMember.fromBuffer,
    );

    return _storage.getAll();
  }

  void syncFromStream(StreamTeamMembersResponse response) {
    _storage.syncResponse(
      syncType: response.syncType,
      items: response.teamMembers,
      hasItem: (item) => item.hasTeamMember(),
      getId: (item) => item.id,
      getItem: (item) => item.teamMember,
      getState: () => state,
      setState: (newState) => state = newState,
    );
  }
}

@Riverpod(keepAlive: true)
Map<String, TeamMember> studentTeamMembers(Ref ref) {
  final members = ref.watch(teamMembersProvider);
  return Map.fromEntries(
    members.entries.where(
      (entry) => entry.value.memberType == TeamMemberType.STUDENT,
    ),
  );
}

@Riverpod(keepAlive: true)
Map<String, TeamMember> mentorTeamMembers(Ref ref) {
  final members = ref.watch(teamMembersProvider);
  return Map.fromEntries(
    members.entries.where(
      (entry) => entry.value.memberType == TeamMemberType.MENTOR,
    ),
  );
}
