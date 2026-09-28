import 'package:flutter/material.dart';

/// The search box above a paged table.
///
/// Searching is server-side on every list, so the term here narrows the whole table rather than
/// the page on screen. [isPending] reports that a keystroke has not been committed yet, and
/// [onSubmitted] commits it immediately — pressing Enter should never wait out the debounce.
class TableFilter extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  /// Commits the current text now (Enter, or the search button).
  final VoidCallback? onSubmitted;

  /// True while the typed text has not reached the query yet.
  final bool isPending;

  /// Rows matching the committed term across every page, shown beside the box so the count is
  /// obviously "of the whole table" and not "of this page".
  final int? matchCount;

  const TableFilter({
    super.key,
    required this.controller,
    this.hintText = 'Filter...',
    this.onSubmitted,
    this.isPending = false,
    this.matchCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: ListenableBuilder(
                listenable: controller,
                builder: (context, _) {
                  if (controller.text.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    tooltip: 'Clear search',
                    onPressed: () {
                      controller.clear();
                      onSubmitted?.call();
                    },
                  );
                },
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // A minimum width rather than a fixed one: the status swaps between a spinner with a
        // label and a match count, and pinning it to one width clipped the longer of the two.
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 96),
          child: isPending
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                    const SizedBox(width: 6),
                    Text('Searching', style: theme.textTheme.bodySmall),
                  ],
                )
              : matchCount != null && controller.text.isNotEmpty
              ? Text(
                  '$matchCount ${matchCount == 1 ? 'match' : 'matches'}',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
