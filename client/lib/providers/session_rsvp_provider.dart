import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/models/change_event.dart';
import 'package:time_keeper/models/session_rsvp.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/providers/realtime_collection.dart';

part 'session_rsvp_provider.g.dart';

const _sessionRsvpFields = 'id sessionId teamMemberId status';

const _sessionRsvpsQuery =
    '''
  query SessionRsvps {
    sessionRsvps { $_sessionRsvpFields }
  }
''';

const _sessionRsvpChangesSubscription =
    '''
  subscription SessionRsvpChanges {
    sessionRsvpChanges { operation id data { $_sessionRsvpFields } }
  }
''';

@riverpod
Stream<ChangeEvent<SessionRsvp>> sessionRsvpChanges(Ref ref) {
  final client = ref.watch(timeKeeperGraphQLClientProvider);
  return client
      .subscribe(SubscriptionOptions(document: gql(_sessionRsvpChangesSubscription)))
      .where((result) => result.data != null)
      .map(
        (result) =>
            ChangeEvent.fromJson(result.data!['sessionRsvpChanges'] as Map<String, dynamic>, SessionRsvp.fromJson),
      );
}

@Riverpod(keepAlive: true)
class SessionRsvps extends _$SessionRsvps {
  @override
  Map<String, SessionRsvp> build() {
    // Re-seed whenever the client is rebuilt (endpoint, TLS or token changed).
    // Without this a fetch that failed at startup is never retried.
    ref.watch(timeKeeperGraphQLClientProvider);
    _fetchInitial();
    return {};
  }

  Future<void> _fetchInitial() async {
    final items = await fetchCollection<SessionRsvp>(
      ref: ref,
      document: _sessionRsvpsQuery,
      rootField: 'sessionRsvps',
      fromJson: SessionRsvp.fromJson,
      idOf: (item) => item.id,
    );
    // Null means every attempt failed; keep what we have rather than
    // replacing real data with an empty map.
    if (items != null) state = items;
  }

  Future<void> refresh() => _fetchInitial();

  void applyChange(ChangeEvent<SessionRsvp> change) {
    state = applyChangeToMap(state, change);
  }
}

@Riverpod(keepAlive: true)
void sessionRsvpsSync(Ref ref) {
  ref.listen(
    sessionRsvpChangesProvider,
    changeListener<SessionRsvp>(
      apply: (change) => ref.read(sessionRsvpsProvider.notifier).applyChange(change),
      refresh: () => ref.read(sessionRsvpsProvider.notifier).refresh(),
    ),
  );
}
