import 'package:flutter/material.dart';

/// Bottom-of-table pager: "1–25 of 1,284" plus a rows-per-page dropdown and prev/next buttons,
/// the pattern familiar from shop-style listings.
class PaginationBar extends StatelessWidget {
  final int totalCount;
  final int offset;
  final int pageSize;
  final bool hasMore;
  final ValueChanged<int> onPageSizeChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  /// Jumps to the first/last page. Optional so a pager without them still renders.
  final VoidCallback? onFirst;
  final VoidCallback? onLast;

  /// The choices offered in the rows-per-page dropdown.
  static const List<int> pageSizeOptions = [25, 50, 100, 200];

  const PaginationBar({
    super.key,
    required this.totalCount,
    required this.offset,
    required this.pageSize,
    required this.hasMore,
    required this.onPageSizeChanged,
    required this.onPrevious,
    required this.onNext,
    this.onFirst,
    this.onLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final start = totalCount == 0 || offset >= totalCount ? 0 : offset + 1;
    final end = totalCount == 0 ? 0 : (offset + pageSize).clamp(0, totalCount);
    // Which page of how many — "51–100 of 1,284" alone leaves the reader doing the division to
    // work out whether it is worth paging on.
    final pageCount = totalCount == 0 ? 0 : ((totalCount - 1) ~/ pageSize) + 1;
    final pageNumber = totalCount == 0 ? 0 : (offset ~/ pageSize) + 1;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Text(
            totalCount == 0 ? 'No records' : '$start\u2013$end of $totalCount',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          if (pageCount > 1) ...[
            const SizedBox(width: 12),
            Text(
              'Page $pageNumber of $pageCount',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
          const Spacer(),
          Text('Rows per page', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: pageSizeOptions.contains(pageSize) ? pageSize : pageSizeOptions.first,
              items: [for (final size in pageSizeOptions) DropdownMenuItem(value: size, child: Text('$size'))],
              onChanged: (size) {
                if (size != null) onPageSizeChanged(size);
              },
            ),
          ),
          const SizedBox(width: 4),
          if (onFirst != null)
            IconButton(
              tooltip: 'First page',
              onPressed: start > 1 ? onFirst : null,
              icon: const Icon(Icons.first_page),
            ),
          IconButton(
            tooltip: 'Previous page',
            onPressed: start > 1 ? onPrevious : null,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(tooltip: 'Next page', onPressed: hasMore ? onNext : null, icon: const Icon(Icons.chevron_right)),
          if (onLast != null)
            IconButton(tooltip: 'Last page', onPressed: hasMore ? onLast : null, icon: const Icon(Icons.last_page)),
        ],
      ),
    );
  }
}
