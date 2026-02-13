import 'dart:async';

import 'package:grpc/grpc_or_grpcweb.dart';
import 'package:time_keeper/utils/grpc_result.dart';
import 'package:time_keeper/utils/logger.dart';

/// Wraps a gRPC call and returns a Result type instead of throwing exceptions
Future<GrpcResult<T>> callGrpcEndpoint<T>(Future<T> Function() fn) async {
  try {
    final result = await fn().timeout(const Duration(seconds: 15));
    return GrpcSuccess(result);
  } on TimeoutException {
    logger.e('gRPC call timed out after 15 seconds');
    return GrpcFailure(userMessage: 'Request timed out. Please try again.');
  } on GrpcError catch (e) {
    logger.e('gRPC Error: [${e.code}:${e.codeName}] ${e.message}');

    final userMessage =
        e.message ?? StatusCode.name(e.code) ?? 'An error occurred';

    return GrpcFailure(
      userMessage: userMessage,
      statusCode: e.code,
      technicalMessage: e.message,
    );
  } catch (e) {
    logger.e('Unexpected error: $e');
    return GrpcFailure(
      userMessage: 'An unexpected error occurred',
      technicalMessage: e.toString(),
    );
  }
}
