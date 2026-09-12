import 'package:flutter/material.dart';

/// Separator between rail sections.
///
/// Expanded, it's a small caps section label; collapsed, there is no room for
/// text, so it degrades to a short inset rule that still reads as a break.
class RailGroupHeader extends StatelessWidget {
  final String label;

  const RailGroupHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 120) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Divider(height: 1, color: theme.dividerColor),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      },
    );
  }
}
