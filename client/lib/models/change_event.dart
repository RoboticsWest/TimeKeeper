enum ChangeOperation { insert, update, delete }

ChangeOperation changeOperationFromJson(String value) {
  switch (value) {
    case 'INSERT':
      return ChangeOperation.insert;
    case 'UPDATE':
      return ChangeOperation.update;
    case 'DELETE':
      return ChangeOperation.delete;
    default:
      return ChangeOperation.update;
  }
}

/// Mirrors the server's `Change<T>` GraphQL type - one row changed in a subscribed table.
/// `data` is the freshly re-fetched row, `null` for deletes.
class ChangeEvent<T> {
  final ChangeOperation operation;
  final String id;
  final T? data;

  ChangeEvent({required this.operation, required this.id, this.data});

  static ChangeEvent<T> fromJson<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawData = json['data'] as Map<String, dynamic>?;
    return ChangeEvent<T>(
      operation: changeOperationFromJson(json['operation'] as String),
      id: json['id'] as String,
      data: rawData != null ? fromJsonT(rawData) : null,
    );
  }
}
