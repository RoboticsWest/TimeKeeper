import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/helpers/collection_storage.dart';
import 'package:time_keeper/models/change_event.dart';
import 'package:time_keeper/models/session.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/utils/api_result.dart';

part 'session_provider.g.dart';

const _sessionFields = 'id startTime endTime locationId finished';

const _sessionsQuery = '''
  query Sessions {
    sessions { $_sessionFields }
  }
''';

const _sessionChangesSubscription = '''
  subscription SessionChanges {
    sessionChanges { operation id data { $_sessionFields } }
  }
''';

const _createSessionMutation = '''
  mutation CreateSession(\$startTime: DateTime!, \$endTime: DateTime!, \$locationId: UUID!) {
    createSession(startTime: \$startTime, endTime: \$endTime, locationId: \$locationId) { $_sessionFields }
  }
''';

const _updateSessionMutation = '''
  mutation UpdateSession(\$id: UUID!, \$startTime: DateTime!, \$endTime: DateTime!, \$locationId: UUID!, \$finished: Boolean!) {
    updateSession(id: \$id, startTime: \$startTime, endTime: \$endTime, locationId: \$locationId, finished: \$finished) { $_sessionFields }
  }
''';

const _deleteSessionMutation = r'''
  mutation DeleteSession($id: UUID!) {
    deleteSession(id: $id)
  }
''';

const _checkInOutMutation = r'''
  mutation CheckInOut($teamMemberId: UUID!, $locationId: UUID!) {
    checkInOut(teamMemberId: $teamMemberId, locationId: $locationId)
  }
''';

@riverpod
Stream<ChangeEvent<Session>> sessionChanges(Ref ref) {
  final client = ref.watch(timeKeeperGraphQLClientProvider);
  return client
      .subscribe(SubscriptionOptions(document: gql(_sessionChangesSubscription)))
      .where((result) => result.data != null)
      .map((result) => ChangeEvent.fromJson(result.data!['sessionChanges'] as Map<String, dynamic>, Session.fromJson));
}

@Riverpod(keepAlive: true)
class Sessions extends _$Sessions {
  late final CollectionStorage<Session> _storage;

  @override
  Map<String, Session> build() {
    _storage = CollectionStorage(tableName: 'sessions', fromJson: Session.fromJson, toJson: (s) => s.toJson());
    _fetchInitial();
    return _storage.getAll();
  }

  Future<void> _fetchInitial() async {
    final client = ref.read(timeKeeperGraphQLClientProvider);
    final result = await client.query(QueryOptions(document: gql(_sessionsQuery), fetchPolicy: FetchPolicy.noCache));
    if (result.hasException || result.data == null) return;

    final items = (result.data!['sessions'] as List<dynamic>).map((e) => Session.fromJson(e as Map<String, dynamic>)).toList();
    state = _storage.seedFromList(items, (s) => s.id);
  }

  void applyChange(ChangeEvent<Session> change) {
    state = _storage.applyChange(change, state);
  }

  Future<ApiCallResult> create(DateTime startTime, DateTime endTime, String locationId) => _mutate(_createSessionMutation, {
    'startTime': startTime.toUtc().toIso8601String(),
    'endTime': endTime.toUtc().toIso8601String(),
    'locationId': locationId,
  });

  Future<ApiCallResult> update(String id, DateTime startTime, DateTime endTime, String locationId, bool finished) =>
      _mutate(_updateSessionMutation, {
        'id': id,
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime.toUtc().toIso8601String(),
        'locationId': locationId,
        'finished': finished,
      });

  Future<ApiCallResult> delete(String id) => _mutate(_deleteSessionMutation, {'id': id});

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

@riverpod
void sessionsSync(Ref ref) {
  ref.listen(sessionChangesProvider, (previous, next) {
    next.whenData((change) {
      ref.read(sessionsProvider.notifier).applyChange(change);
    });
  });
}

/// Kiosk RFID check-in/out. Returns `true` if the member is now checked in, `false` if checked out.
@Riverpod(keepAlive: true)
class SessionCheckInOut extends _$SessionCheckInOut {
  @override
  void build() {}

  Future<ApiResult<bool>> checkInOut(String teamMemberId, String locationId) async {
    final client = ref.read(timeKeeperGraphQLClientProvider);
    final result = await client.mutate(
      MutationOptions(
        document: gql(_checkInOutMutation),
        variables: {'teamMemberId': teamMemberId, 'locationId': locationId},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );
    if (result.hasException) {
      final message = result.exception!.graphqlErrors.isNotEmpty
          ? result.exception!.graphqlErrors.map((e) => e.message).join('; ')
          : result.exception.toString();
      return ApiFailure(userMessage: message);
    }
    return ApiSuccess(result.data!['checkInOut'] as bool);
  }
}
