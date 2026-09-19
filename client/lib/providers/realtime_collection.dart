/// Shared machinery for the id-keyed collections that are seeded by one query
/// and then kept current by a GraphQL subscription.
///
/// The weak point of that model is the *seed*, not the subscription. A
/// subscription only ever carries deltas, so a collection whose single initial
/// fetch failed — server not up yet, endpoint still pointing somewhere else,
/// token not issued yet — stays permanently empty while looking completely
/// healthy: the socket is connected, events arrive, they are applied to
/// nothing. That is the failure behind "I added a session and the UI didn't
/// update": the page was never populated in the first place.
///
/// Two guards here address it:
///   * [fetchCollection] retries with backoff instead of giving up silently.
///   * [changeListener] re-pulls the whole collection when the change stream
///     recovers from an error, because every event during the outage was lost.
///
/// Callers must also `ref.watch(timeKeeperGraphQLClientProvider)` in `build()`
/// so that a change of endpoint, TLS mode or token re-runs the seed.
library;

import 'package:graphql/client.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/change_event.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/utils/logger.dart';

typedef JsonMap = Map<String, dynamic>;

/// Fetches [rootField] from [document] and returns it keyed by id.
///
/// Returns null when every attempt failed, so the caller can leave the existing
/// state alone rather than clobbering good data with an empty map.
Future<Map<String, T>?> fetchCollection<T>({
  required Ref ref,
  required String document,
  required String rootField,
  required T Function(JsonMap json) fromJson,
  required String Function(T item) idOf,
  int attempts = 4,
}) async {
  var delay = const Duration(milliseconds: 400);

  for (var attempt = 1; attempt <= attempts; attempt++) {
    // Re-read per attempt: a retry is most likely to succeed precisely because
    // the client was rebuilt (login completed, address corrected) in between.
    final client = ref.read(timeKeeperGraphQLClientProvider);
    final result = await client.query(QueryOptions(document: gql(document), fetchPolicy: FetchPolicy.noCache));

    if (!result.hasException && result.data != null) {
      final rows = result.data![rootField] as List<dynamic>?;
      if (rows != null) {
        final items = rows.map((e) => fromJson(e as JsonMap));
        return {for (final item in items) idOf(item): item};
      }
    }

    if (attempt == attempts) {
      logger.w(
        '[$rootField] initial fetch failed after $attempts attempts; '
        'collection will stay empty until the next refresh',
      );
      return null;
    }

    await Future<void>.delayed(delay);
    delay *= 2;
  }

  return null;
}

/// Builds the listener that applies a change subscription to a collection.
///
/// Returned rather than registered here so the caller keeps the `ref.listen`
/// call — the provider type involved is not re-exported by `hooks_riverpod`,
/// and inferring it at the call site is simpler than naming it.
void Function(AsyncValue<ChangeEvent<T>>? previous, AsyncValue<ChangeEvent<T>> next) changeListener<T>({
  required void Function(ChangeEvent<T> change) apply,
  required Future<void> Function() refresh,
}) {
  return (previous, next) {
    // An error that resolves back to data means the socket dropped and came
    // back. Deltas emitted while it was down were never delivered to anyone,
    // and no later event will mention them, so only a re-pull can recover.
    if (previous is AsyncError && next is AsyncData) {
      logger.i('Change stream recovered; re-pulling collection to close the gap');
      refresh();
    }
    next.whenData(apply);
  };
}
