import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/base/base_rail/rail_group.dart';
import 'package:time_keeper/base/base_rail/rail_item.dart';
import 'package:time_keeper/base/base_rail/rail_toggle_button.dart';
import 'package:time_keeper/router/app_routes.dart';

/// Primary rail — icon-only by default, expanding as an *overlay* rather than
/// pushing the page, so expanding it never reflows the content behind it.
///
/// Expand state is owned by BaseScaffold, which also drives the click-away
/// barrier that collapses the rail.
class BaseRail extends ConsumerWidget {
  static const double collapsedWidth = 56;
  static const double expandedWidth = 240;

  final bool isExtended;
  final VoidCallback onToggle;

  const BaseRail({super.key, required this.isExtended, required this.onToggle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentRoute = AppRoute.current(context);
    final groups = AppRoute.railGroups;

    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      // The width animation shouldn't repaint the page behind it.
      child: RepaintBoundary(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            border: Border(right: BorderSide(color: theme.dividerColor)),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: isExtended ? expandedWidth : collapsedWidth,
            child: ClipRect(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RailToggleButton(isExtended: isExtended, onPressed: onToggle),
                  Divider(height: 1, color: theme.dividerColor),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 8),
                      children: [
                        for (final entry in groups.entries) ...[
                          RailGroupHeader(label: entry.key.label),
                          for (final route in entry.value)
                            RailItem(
                              icon: route.icon!,
                              iconColor: route.colorFor(theme.brightness),
                              label: route.label!,
                              isSelected: route == currentRoute,
                              onTap: () => route.go(context),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
