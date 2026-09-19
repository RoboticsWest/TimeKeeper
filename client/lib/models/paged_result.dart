/// One page of rows from a server `Page<T>` query, with the total matching row count.
///
/// `total_count` counts rows matching the *filter* across every page, so a pager can render
/// "1–25 of 1,284" and know whether a next page exists without asking for it.
class PagedResult<T> {
  final List<T> items;

  /// Rows matching the filter across every page, not just this page.
  final int totalCount;

  /// The offset these items start at, echoed back by the server so a client can't desync its
  /// pager after a rapid change.
  final int offset;
  final int limit;

  /// Whether another page follows this one.
  final bool hasMore;

  const PagedResult({
    required this.items,
    required this.totalCount,
    required this.offset,
    required this.limit,
    required this.hasMore,
  });

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final rows = (json['items'] as List<dynamic>? ?? const []);
    return PagedResult(
      items: rows.whereType<Map<String, dynamic>>().map(fromJson).toList(),
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 0,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}
