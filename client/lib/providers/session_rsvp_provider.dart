import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/helpers/collection_storage.dart';
import 'package:time_keeper/models/change_event.dart';
import 'package:time_keeper/models/session_rsvp.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';

part 'session_rsvp_provider.g.dart';

const _sessionRsvpFields = 'id sessionId teamMemberId status';

const _sessionRsvpsQuery = '''
  query SessionRsvps {
    sessionRsvps { $_sessionRsvpFields }
  }
''';

const _sessionRsvpChangesSubscription = '''
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
        (result) => ChangeEvent.fromJson(result.data!['sessionRsvpChanges'] as Map<String, dynamic>, SessionRsvp.fromJson),
      );
}

@Riverpod(keepAlive: true)
class SessionRsvps extends _$SessionRsvps {
  late final CollectionStorage<SessionRsvp> _storage;

  @override
  Map<String, SessionRsvp> build() {
    _storage = CollectionStorage(
      tableName: 'session_rsvps',
      fromJson: SessionRsvp.fromJson,
      toJson: (r) => r.toJson(),
    );
    _fetchInitial();
    return _storage.getAll();
  }

  Future<void> _fetchInitial() async {
    final client = ref.read(timeKeeperGraphQLClientProvider);
    final result = await client.query(
      QueryOptions(document: gql(_sessionRsvpsQuery), fetchPolicy: FetchPolicy.noCache),
    );
    if (result.hasException || result.data == null) return;

    final items = (result.data!['sessionRsvps'] as List<dynamic>)
        .map((e) => SessionRsvp.fromJson(e as Map<String, dynamic>))
        .toList();
    state = _storage.seedFromList(items, (r) => r.id);
  }

  void applyChange(ChangeEvent<SessionRsvp> change) {
    state = _storage.applyChange(change, state);
  }
}

@riverpod
void sessionRsvpsSync(Ref ref) {
  ref.listen(sessionRsvpChangesProvider, (previous, next) {
    next.whenData((change) {
      ref.read(sessionRsvpsProvider.notifier).applyChange(change);
    });
  });
}
