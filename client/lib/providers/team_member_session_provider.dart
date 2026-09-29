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

const _clearAttendanceMutation = r'''
  mutation ClearAttendance {
    clearAttendance
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

/// The whole attendance table, keyed by id.
///
/// **Built on demand, not at login.** This table grows without bound — a season is tens of
/// thousands of rows, several megabytes of JSON — and downloading it at startup was most of what
/// made the app feel slow on a remote server. Only the things that genuinely need the history read
/// it now: the statistics dashboard and the CSV export. Everything on a hot path
/// ("is this member checked in?", "how many are in this session?") asks a bounded question
/// instead, through [openAttendanceProvider] or the attendance count queries.
///
/// It subscribes to its own change stream rather than relying on a separate sync bridge: with the
/// collection built lazily, a bridge that reached for `.notifier` on the first change event would
/// have quietly re-downloaded the whole table on every client the moment anybody checked in.
@Riverpod(keepAlive: true)
class TeamMemberSessions extends _$TeamMemberSessions {
  @override
  Map<String, TeamMemberSession> build() {
    ref.listen(
      teamMemberSessionChangesProvider,
      changeListener<TeamMemberSession>(apply: applyChange, refresh: refresh),
    );

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

  /// Deletes every attendance records in one request, returning how many rows went.
  ///
  /// The views used to loop `delete(id)` over every row: one HTTP round trip and one change event
  /// each, which on a link with real latency made clearing a season's data a minutes-long sequence
  /// of requests that also drowned every connected client in deltas.
  Future<ApiResult<int>> clearAll() => _mutateCount(_clearAttendanceMutation, 'clearAttendance');

  /// Runs a mutation whose payload is a plain row count.
  Future<ApiResult<int>> _mutateCount(String document, String rootField, [Map<String, dynamic>? variables]) async {
    final client = ref.read(timeKeeperGraphQLClientProvider);
    final result = await client.mutate(
      MutationOptions(document: gql(document), variables: variables ?? const {}, fetchPolicy: FetchPolicy.noCache),
    );
    if (result.hasException) {
      final message = result.exception!.graphqlErrors.isNotEmpty
          ? result.exception!.graphqlErrors.map((e) => e.message).join('; ')
          : result.exception.toString();
      return ApiFailure(userMessage: message);
    }
    return ApiSuccess((result.data?[rootField] as num?)?.toInt() ?? 0);
  }

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
