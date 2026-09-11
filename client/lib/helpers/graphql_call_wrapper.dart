import 'dart:async';

import 'package:graphql/client.dart';
import 'package:time_keeper/utils/api_result.dart';
import 'package:time_keeper/utils/logger.dart';

/// Wraps a GraphQL query/mutation call and returns a Result type instead of throwing exceptions.
/// Callers pull whichever fields they need out of the returned JSON map themselves - no codegen,
/// no generated response types.
Future<ApiResult<Map<String, dynamic>>> callGraphQLEndpoint(
  Future<QueryResult> Function() fn,
) async {
  try {
    final result = await fn().timeout(const Duration(seconds: 15));

    if (result.hasException) {
      final exception = result.exception!;
      final message = exception.graphqlErrors.isNotEmpty
          ? exception.graphqlErrors.map((e) => e.message).join('; ')
          : exception.toString();

      logger.e('GraphQL Error: $message');
      return ApiFailure(userMessage: message, technicalMessage: exception.toString());
    }

    final data = result.data;
    if (data == null) {
      return const ApiFailure(userMessage: 'No data returned');
    }

    return ApiSuccess(data);
  } on TimeoutException {
    logger.e('GraphQL call timed out after 15 seconds');
    return ApiFailure(userMessage: 'Request timed out. Please try again.');
  } catch (e) {
    logger.e('Unexpected error: $e');
    return ApiFailure(userMessage: 'An unexpected error occurred', technicalMessage: e.toString());
  }
}
