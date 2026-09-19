import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/models/change_event.dart';
import 'package:time_keeper/models/session.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/providers/realtime_collection.dart';
import 'package:time_keeper/utils/api_result.dart';
import 'package:time_keeper/utils/time_utils.dart';

part 'session_provider.g.dart';

const _sessionFields = 'id startTime endTime locationId finished actualStartTime actualEndTime';

const _sessionsQuery =
    '''
  query Sessions {
    sessions { $_sessionFields }
  }
''';

const _sessionChangesSubscription =
    '''
  subscription SessionChanges {
    sessionChanges { operation id data { $_sessionFields } }
  }
''';

const _createSessionMutation =
    '''
  mutation CreateSession(\$startTime: DateTime!, \$endTime: DateTime!, \$locationId: UUID!, \$sendLateReminder: Boolean) {
    createSession(startTime: \$startTime, endTime: \$endTime, locationId: \$locationId, sendLateReminder: \$sendLateReminder) { $_sessionFields }
  }
''';

const _reminderPreviewQuery = r'''
  query SessionReminderPreview($startTime: DateTime!, $endTime: DateTime!, $locationId: UUID!) {
    sessionReminderPreview(startTime: $startTime, endTime: $endTime, locationId: $locationId) {
      hasLateReminder
      lateReminders
      relativeDay
    }
  }
''';

const _updateSessionMutation =
    '''
  mutation UpdateSession(\$id: UUID!, \$startTime: DateTime!, \$endTime: DateTime!, \$locationId: UUID!, \$finished: Boolean!) {
    updateSession(id: \$id, startTime: \$startTime, endTime: \$endTime, locationId: \$locationId, finished: \$finished) { $_sessionFields }
  }
''';

const _deleteSessionMutation = r'''
  mutation DeleteSession($id: UUID!) {
    deleteSession(id: $id)
  }
''';

const _checkInOutByPinMutation = r'''
  mutation CheckInOutByPin($pin: String!, $locationId: UUID!) {
    checkInOutByPin(pin: $pin, locationId: $locationId) { checkedIn teamMemberId }
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
  @override
  Map<String, Session> build() {
    // Re-seed whenever the client is rebuilt (endpoint, TLS or token changed).
    // Without this a fetch that failed at startup is never retried.
    ref.watch(timeKeeperGraphQLClientProvider);
    _fetchInitial();
    return {};
  }

  Future<void> _fetchInitial() async {
    final items = await fetchCollection<Session>(
      ref: ref,
      document: _sessionsQuery,
      rootField: 'sessions',
      fromJson: Session.fromJson,
      idOf: (item) => item.id,
    );
    // Null means every attempt failed; keep what we have rather than
    // replacing real data with an empty map.
    if (items != null) state = items;
  }

  /// Re-fetches the full list. Subscriptions only apply delta events, so a re-fetch heals any
  /// change that happened while the connection was down.
  Future<void> refresh() => _fetchInitial();

  void applyChange(ChangeEvent<Session> change) {
    state = applyChangeToMap(state, change);
  }

  /// Creates a session.
  ///
  /// [sendLateReminder] decides what happens to a reminder whose lead time has already elapsed
  /// — the common case of scheduling a session a couple of hours out when the start reminder is
  /// set to 24 hours. False records it as skipped rather than firing a "Session tomorrow"
  /// announcement moments after the session was created. Ask [reminderPreview] first.
  Future<ApiCallResult> create(
    DateTime startTime,
    DateTime endTime,
    String locationId, {
    bool sendLateReminder = false,
  }) => _mutate(_createSessionMutation, {
    'startTime': toServerTime(startTime),
    'endTime': toServerTime(endTime),
    'locationId': locationId,
    'sendLateReminder': sendLateReminder,
  });

  /// Dry-run of the reminder scheduling for a session that does not exist yet.
  ///
  /// Returns null if the preview could not be fetched, in which case the caller should create
  /// the session without pestering the user.
  Future<SessionReminderPreview?> reminderPreview(DateTime startTime, DateTime endTime, String locationId) async {
    final client = ref.read(timeKeeperGraphQLClientProvider);
    final result = await client.query(
      QueryOptions(
        document: gql(_reminderPreviewQuery),
        variables: {'startTime': toServerTime(startTime), 'endTime': toServerTime(endTime), 'locationId': locationId},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );
    if (result.hasException || result.data == null) return null;
    final data = result.data!['sessionReminderPreview'] as Map<String, dynamic>;
    return SessionReminderPreview(
      hasLateReminder: data['hasLateReminder'] as bool,
      lateReminders: (data['lateReminders'] as List<dynamic>).cast<String>(),
      relativeDay: data['relativeDay'] as String,
    );
  }

  Future<ApiCallResult> update(String id, DateTime startTime, DateTime endTime, String locationId, bool finished) =>
      _mutate(_updateSessionMutation, {
        'id': id,
        'startTime': toServerTime(startTime),
        'endTime': toServerTime(endTime),
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

@Riverpod(keepAlive: true)
void sessionsSync(Ref ref) {
  ref.listen(
    sessionChangesProvider,
    changeListener<Session>(
      apply: (change) => ref.read(sessionsProvider.notifier).applyChange(change),
      refresh: () => ref.read(sessionsProvider.notifier).refresh(),
    ),
  );
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

  /// Checks in/out by quick PIN. The PIN is resolved server-side — kiosks never
  /// receive other members' PINs — so this returns the member it matched along
  /// with the resulting state.
  Future<ApiResult<PinCheckInOut>> checkInOutByPin(String pin, String locationId) async {
    final client = ref.read(timeKeeperGraphQLClientProvider);
    final result = await client.mutate(
      MutationOptions(
        document: gql(_checkInOutByPinMutation),
        variables: {'pin': pin, 'locationId': locationId},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );
    if (result.hasException) {
      final message = result.exception!.graphqlErrors.isNotEmpty
          ? result.exception!.graphqlErrors.map((e) => e.message).join('; ')
          : result.exception.toString();
      return ApiFailure(userMessage: message);
    }
    final data = result.data!['checkInOutByPin'] as Map<String, dynamic>;
    return ApiSuccess(
      PinCheckInOut(checkedIn: data['checkedIn'] as bool, teamMemberId: data['teamMemberId'] as String),
    );
  }
}

/// Result of a successful PIN sign-in.
class PinCheckInOut {
  /// True for checked in, false for checked out.
  final bool checkedIn;
  final String teamMemberId;

  const PinCheckInOut({required this.checkedIn, required this.teamMemberId});
}

/// What creating a session at the chosen times would do to its Discord reminders.
class SessionReminderPreview {
  /// True when at least one reminder's lead time has already elapsed, so creating the session
  /// would fire it immediately.
  final bool hasLateReminder;

  /// Human-readable names of the reminders that would fire immediately.
  final List<String> lateReminders;

  /// How the session's day would read in a message right now ("today", "tomorrow", ...).
  final String relativeDay;

  const SessionReminderPreview({required this.hasLateReminder, required this.lateReminders, required this.relativeDay});
}
