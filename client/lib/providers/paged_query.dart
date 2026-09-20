/// Shared machinery for the server-driven paged list providers.
library;

import 'package:graphql/client.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/paged_result.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/utils/logger.dart';

typedef JsonMap = Map<String, dynamic>;

/// Fetches one page of `rootField` from [document].
///
/// Returns null on failure so the caller can keep its previous page instead of clobbering it
/// with an empty one. The caller owns loading state — this never retries.
Future<PagedResult<T>?> fetchPagedPage<T>({
  required Ref ref,
  required String document,
  required Map<String, dynamic> variables,
  required String rootField,
  required T Function(JsonMap json) fromJson,
}) async {
  final client = ref.read(timeKeeperGraphQLClientProvider);
  final result = await client.query(
    QueryOptions(document: gql(document), variables: variables, fetchPolicy: FetchPolicy.noCache),
  );

  if (result.hasException || result.data == null) {
    logger.w('[$rootField] paged query failed: ${result.exception}');
    return null;
  }
  final data = result.data![rootField] as JsonMap?;
  if (data == null) return null;
  return PagedResult.fromJson(data, fromJson);
}
