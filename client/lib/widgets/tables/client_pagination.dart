import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:time_keeper/widgets/tables/pagination_bar.dart';

/// Client-side pager state for views whose full collection is already in memory (locations,
/// users, notifications): page size and offset with automatic clamping when the total shrinks
/// because of a filter or deleted rows.
class ClientPaginationState {
  final int offset;
  final int pageSize;
  final ValueChanged<int> setPageSize;
  final VoidCallback nextPage;
  final VoidCallback previousPage;

  const ClientPaginationState({
    required this.offset,
    required this.pageSize,
    required this.setPageSize,
    required this.nextPage,
    required this.previousPage,
  });

  int _lastOffset(int total) {
    if (total <= 0) return 0;
    return ((total - 1) ~/ pageSize) * pageSize;
  }

  /// The offset, clamped back inside the range once the list shrinks.
  int clampedOffset(int total) => offset > _lastOffset(total) ? _lastOffset(total) : offset;

  /// The rows the table should render for the current page.
  List<T> slice<T>(List<T> items) {
    final start = clampedOffset(items.length);
    final end = (start + pageSize).clamp(0, items.length);
    return items.sublist(start, end);
  }
}

/// Hook backing [ClientPaginationState]. The offset is clamped into range whenever [totalCount]
/// or the page size changes, so a narrower filter never strands the user on an empty page.
ClientPaginationState useClientPagination(int totalCount) {
  final pageSize = useState(PaginationBar.pageSizeOptions.first);
  final offset = useState(0);

  useEffect(() {
    if (totalCount <= 0) {
      offset.value = 0;
      return null;
    }
    final lastOffset = ((totalCount - 1) ~/ pageSize.value) * pageSize.value;
    if (offset.value > lastOffset) offset.value = lastOffset;
    return null;
  }, [totalCount, pageSize.value]);

  void setPageSize(int size) {
    pageSize.value = size;
    offset.value = 0;
  }

  void nextPage() {
    offset.value = (offset.value + pageSize.value).clamp(0, totalCount > 0 ? totalCount - 1 : 0);
  }

  void previousPage() {
    offset.value = (offset.value - pageSize.value).clamp(0, totalCount > 0 ? totalCount - 1 : 0);
  }

  return ClientPaginationState(
    offset: offset.value,
    pageSize: pageSize.value,
    setPageSize: setPageSize,
    nextPage: nextPage,
    previousPage: previousPage,
  );
}
