import 'package:flutter/material.dart';
import 'package:time_keeper/shapes.dart';

/// A titled dashboard panel.
///
/// Deliberately not a [Card]: the dashboard separates panels from the page with
/// a contrast step plus a 1px border, and reserves the one soft shadow for
/// lifting the panel off the page background — stacking Material elevation on
/// top of that reads as mush at this density.
class DashboardPanel extends StatelessWidget {
  final String title;
  final String? subtitle;

  /// Controls rendered at the panel's trailing edge (metric toggles, filters).
  final List<Widget> actions;
  final Widget? footer;

  /// Fixed height. Null lets the panel size to its content.
  final double? height;

  /// Renders [emptyMessage] instead of [child]. Panels keep their frame when
  /// empty so the dashboard grid doesn't reflow as filters change.
  final bool isEmpty;
  final String emptyMessage;
  final Widget child;

  const DashboardPanel({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.footer,
    this.height,
    this.isEmpty = false,
    this.emptyMessage = 'No data for this range',
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: kBorderRadiusCard,
        border: Border.all(color: theme.dividerColor),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              ...actions,
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: isEmpty
                ? Center(
                    child: Text(
                      emptyMessage,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  )
                : child,
          ),
          if (footer != null) ...[const SizedBox(height: 6), footer!],
        ],
      ),
    );
  }
}
