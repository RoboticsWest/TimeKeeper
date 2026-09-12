import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/models/change_event.dart';
import 'package:time_keeper/models/team_member.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/utils/api_result.dart';

part 'team_member_provider.g.dart';

const _teamMemberFields = 'id firstName lastName memberType displayName mobileNumber discordId quickPin';

const _teamMembersQuery = '''
  query TeamMembers {
    teamMembers { $_teamMemberFields }
  }
''';

const _teamMemberChangesSubscription = '''
  subscription TeamMemberChanges {
    teamMemberChanges { operation id data { $_teamMemberFields } }
  }
''';

const _uploadStudentCsvMutation = r'''
  mutation UploadStudentCsv($csvData: String!) {
    uploadStudentCsv(csvData: $csvData)
  }
''';

const _uploadMentorCsvMutation = r'''
  mutation UploadMentorCsv($csvData: String!) {
    uploadMentorCsv(csvData: $csvData)
  }
''';

const _createTeamMemberMutation = '''
  mutation CreateTeamMember(\$firstName: String!, \$lastName: String!, \$memberType: String!, \$displayName: String, \$discordId: String, \$quickPin: String) {
    createTeamMember(firstName: \$firstName, lastName: \$lastName, memberType: \$memberType, displayName: \$displayName, discordId: \$discordId, quickPin: \$quickPin) { $_teamMemberFields }
  }
''';

const _updateTeamMemberMutation = '''
  mutation UpdateTeamMember(\$id: UUID!, \$firstName: String!, \$lastName: String!, \$memberType: String!, \$displayName: String, \$discordId: String, \$quickPin: String) {
    updateTeamMember(id: \$id, firstName: \$firstName, lastName: \$lastName, memberType: \$memberType, displayName: \$displayName, discordId: \$discordId, quickPin: \$quickPin) { $_teamMemberFields }
  }
''';

const _deleteTeamMemberMutation = r'''
  mutation DeleteTeamMember($id: UUID!) {
    deleteTeamMember(id: $id)
  }
''';

@riverpod
Stream<ChangeEvent<TeamMember>> teamMemberChanges(Ref ref) {
  final client = ref.watch(timeKeeperGraphQLClientProvider);
  return client
      .subscribe(SubscriptionOptions(document: gql(_teamMemberChangesSubscription)))
      .where((result) => result.data != null)
      .map(
        (result) => ChangeEvent.fromJson(result.data!['teamMemberChanges'] as Map<String, dynamic>, TeamMember.fromJson),
      );
}

@Riverpod(keepAlive: true)
class TeamMembers extends _$TeamMembers {
  @override
  Map<String, TeamMember> build() {
    _fetchInitial();
    return {};
  }

  Future<void> _fetchInitial() async {
    final client = ref.read(timeKeeperGraphQLClientProvider);
    final result = await client.query(QueryOptions(document: gql(_teamMembersQuery), fetchPolicy: FetchPolicy.noCache));
    if (result.hasException || result.data == null) return;

    final items = (result.data!['teamMembers'] as List<dynamic>)
        .map((e) => TeamMember.fromJson(e as Map<String, dynamic>))
        .toList();
    state = {for (final item in items) item.id: item};
  }

  /// Team members only re-syncs via the `teamMemberChanges` subscription. If that connection is
  /// down (or the app started before a server-side change like a Discord import), the local cache
  /// stays stale until a manual refresh.
  Future<void> refresh() => _fetchInitial();

  void applyChange(ChangeEvent<TeamMember> change) {
    state = applyChangeToMap(state, change);
  }

  Future<ApiCallResult> uploadStudentCsv(String csvData) => _mutate(_uploadStudentCsvMutation, {'csvData': csvData});

  Future<ApiCallResult> uploadMentorCsv(String csvData) => _mutate(_uploadMentorCsvMutation, {'csvData': csvData});

  Future<ApiCallResult> create({
    required String firstName,
    required String lastName,
    required String memberType,
    String? displayName,
    String? discordId,
    String? quickPin,
  }) => _mutate(_createTeamMemberMutation, {
    'firstName': firstName,
    'lastName': lastName,
    'memberType': memberType,
    'displayName': displayName,
    'discordId': discordId,
    'quickPin': quickPin,
  });

  Future<ApiCallResult> update({
    required String id,
    required String firstName,
    required String lastName,
    required String memberType,
    String? displayName,
    String? discordId,
    String? quickPin,
  }) => _mutate(_updateTeamMemberMutation, {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'memberType': memberType,
    'displayName': displayName,
    'discordId': discordId,
    'quickPin': quickPin,
  });

  Future<ApiCallResult> delete(String id) => _mutate(_deleteTeamMemberMutation, {'id': id});

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

@Riverpod(keepAlive: true)
void teamMembersSync(Ref ref) {
  ref.listen(teamMemberChangesProvider, (previous, next) {
    next.whenData((change) {
      ref.read(teamMembersProvider.notifier).applyChange(change);
    });
  });
}

@Riverpod(keepAlive: true)
Map<String, TeamMember> studentTeamMembers(Ref ref) {
  final members = ref.watch(teamMembersProvider);
  return Map.fromEntries(members.entries.where((entry) => entry.value.memberType == TeamMemberType.student));
}

@Riverpod(keepAlive: true)
Map<String, TeamMember> mentorTeamMembers(Ref ref) {
  final members = ref.watch(teamMembersProvider);
  return Map.fromEntries(members.entries.where((entry) => entry.value.memberType == TeamMemberType.mentor));
}
