/// Represents the result of a GraphQL call - either success with data or failure with error info.
sealed class ApiResult<T> {
  const ApiResult();
}

/// Successful call result.
final class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

/// Failed call result with a user-friendly message and the original error.
final class ApiFailure<T> extends ApiResult<T> {
  final String userMessage;
  final String? technicalMessage;

  const ApiFailure({required this.userMessage, this.technicalMessage});
}

/// Lightweight success/message pair for mutations that don't need to return a parsed value -
/// used by the "form submit" style calls (create/update/delete) throughout the provider layer.
class ApiCallResult {
  final bool success;
  final String? message;
  const ApiCallResult({required this.success, this.message});
}
