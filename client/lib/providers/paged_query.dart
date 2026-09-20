/// Shared machinery for the server-driven paged list providers.
library;

import 'package:graphql/client.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/paged_result.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/utils/logger.dart';

typedef JsonMap = Map<String, dynamic>;

/// Fetches one page of `rootField` from [document], retrying transient failures with backoff.
///
/// Returns null when every attempt failed so the caller can keep its previous page instead of
/// clobbering it with an empty one. The caller owns loading state. The retries exist for the same
/// startup window `realtime_collection.dart` describes: pages can be opened while the server is
/// still coming up, and a single doomed first attempt would otherwise flash an error panel the
/// moment the list opens.
Future<PagedResult<T>?> fetchPagedPage<T>({
  required Ref ref,
  required String document,
  required Map<String, dynamic> variables,
  required String rootField,
  required T Function(JsonMap json) fromJson,
  int attempts = 4,
}) async {
  var delay = const Duration(milliseconds: 400);

  for (var attempt = 1; attempt <= attempts; attempt++) {
    // Re-read per attempt so a client rebuilt in between (login completed,
    // address corrected) is picked up by a later retry.
    final client = ref.read(timeKeeperGraphQLClientProvider);
    final result = await client.query(
      QueryOptions(document: gql(document), variables: variables, fetchPolicy: FetchPolicy.noCache),
    );

    if (!result.hasException && result.data != null) {
      final data = result.data![rootField] as JsonMap?;
      if (data != null) return PagedResult.fromJson(data, fromJson);
    }

    if (attempt == attempts) {
      logger.w('[$rootField] paged query failed after $attempts attempts: ${result.exception}');
      return null;
    }

    await Future<void>.delayed(delay);
    delay *= 2;
  }

  return null;
}
