import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/models/change_event.dart';
import 'package:time_keeper/models/team_member_session.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/providers/realtime_collection.dart';
import 'package:time_keeper/utils/api_result.dart';
import 'package:time_keeper/utils/time_utils.dart';

part 'team_member_session_provider.g.dart';

const _teamMemberSessionFields = 'id teamMemberId sessionId checkInTime checkOutTime';

const _teamMemberSessionsQuery =
    '''
  query TeamMemberSessions {
    teamMemberSessions { $_teamMemberSessionFields }
  }
''';

const _teamMemberSessionChangesSubscription =
    '''
  subscription TeamMemberSessionChanges {
    teamMemberSessionChanges { operation id data { $_teamMemberSessionFields } }
  }
''';

const _updateTeamMemberSessionMutation =
    '''
  mutation UpdateTeamMemberSession(\$id: UUID!, \$checkInTime: DateTime!, \$checkOutTime: DateTime) {
    updateTeamMemberSession(id: \$id, checkInTime: \$checkInTime, checkOutTime: \$checkOutTime) { $_teamMemberSessionFields }
  }
''';

const _deleteTeamMemberSessionMutation = r'''
  mutation DeleteTeamMemberSession($id: UUID!) {
    deleteTeamMemberSession(id: $id)
  }
''';

const _importAttendanceCsvMutation = r'''
  mutation ImportAttendanceCsv($csvData: String!) {
    importAttendanceCsv(csvData: $csvData)
  }
''';

@riverpod
Stream<ChangeEvent<TeamMemberSession>> teamMemberSessionChanges(Ref ref) {
  final client = ref.watch(timeKeeperGraphQLClientProvider);
  return client
      .subscribe(SubscriptionOptions(document: gql(_teamMemberSessionChangesSubscription)))
      .where((result) => result.data != null)
      .map(
        (result) => ChangeEvent.fromJson(
          result.data!['teamMemberSessionChanges'] as Map<String, dynamic>,
          TeamMemberSession.fromJson,
        ),
      );
}

@Riverpod(keepAlive: true)
class TeamMemberSessions extends _$TeamMemberSessions {
  @override
  Map<String, TeamMemberSession> build() {
    // Re-seed whenever the client is rebuilt (endpoint, TLS or token changed).
    // Without this a fetch that failed at startup is never retried.
    ref.watch(timeKeeperGraphQLClientProvider);
    _fetchInitial();
    return {};
  }

  Future<void> _fetchInitial() async {
    final items = await fetchCollection<TeamMemberSession>(
      ref: ref,
      document: _teamMemberSessionsQuery,
      rootField: 'teamMemberSessions',
      fromJson: TeamMemberSession.fromJson,
      idOf: (item) => item.id,
    );
    // Null means every attempt failed; keep what we have rather than
    // replacing real data with an empty map.
    if (items != null) state = items;
  }

  Future<void> refresh() => _fetchInitial();

  void applyChange(ChangeEvent<TeamMemberSession> change) {
    state = applyChangeToMap(state, change);
  }

  Future<ApiCallResult> update(String id, DateTime checkInTime, DateTime? checkOutTime) => _mutate(
    _updateTeamMemberSessionMutation,
    {'id': id, 'checkInTime': toServerTime(checkInTime), 'checkOutTime': toServerTimeOrNull(checkOutTime)},
  );

  Future<ApiCallResult> delete(String id) => _mutate(_deleteTeamMemberSessionMutation, {'id': id});

  Future<ApiCallResult> importAttendanceCsv(String csvData) =>
      _mutate(_importAttendanceCsvMutation, {'csvData': csvData});

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
void teamMemberSessionsSync(Ref ref) {
  ref.listen(
    teamMemberSessionChangesProvider,
    changeListener<TeamMemberSession>(
      apply: (change) => ref.read(teamMemberSessionsProvider.notifier).applyChange(change),
      refresh: () => ref.read(teamMemberSessionsProvider.notifier).refresh(),
    ),
  );
}
