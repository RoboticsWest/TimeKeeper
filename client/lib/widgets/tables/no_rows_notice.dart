import 'package:flutter/material.dart';

/// Says why a table is empty.
///
/// An empty table with a working server-side filter is ambiguous: the reader cannot tell "nothing
/// matches what you typed" from "there is nothing here" or "the request failed". Stating which —
/// and offering the way out when it is the filter — is the difference between the two.
class NoRowsNotice extends StatelessWidget {
  /// Plural noun for the rows, e.g. "team members".
  final String noun;

  /// Whether a filter or search is currently narrowing the list.
  final bool filtered;

  /// Clears every filter. Shown only when [filtered].
  final VoidCallback? onClearFilters;

  const NoRowsNotice({super.key, required this.noun, required this.filtered, this.onClearFilters});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(filtered ? Icons.filter_alt_off : Icons.inbox, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            filtered ? 'No $noun match the current filters' : 'No $noun yet',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          if (filtered && onClearFilters != null) ...[
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Clear filters'),
            ),
          ],
        ],
      ),
    );
  }
}
