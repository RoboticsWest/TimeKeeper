import 'package:flutter/material.dart';
import 'package:time_keeper/shapes.dart';

/// One destination in the left rail.
///
/// The icon keeps its own assigned color in *every* state. Selection is carried
/// by a `primaryContainer` background and a heavier label, never by recoloring
/// the icon — a rail whose icons change color on selection loses the per-item
/// color coding exactly when you are looking for it.
class RailItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const RailItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = isSelected ? colorScheme.primaryContainer : Colors.transparent;
    final foreground = isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant;

    // Reveal the label from the *measured* width rather than the target state,
    // so nothing overflows mid-animation.
    return LayoutBuilder(
      builder: (context, constraints) {
        final showLabel = constraints.maxWidth > 120;

        final tile = Padding(
          padding: EdgeInsets.symmetric(horizontal: showLabel ? 8 : 4, vertical: 2),
          child: Material(
            color: background,
            borderRadius: kBorderRadiusRow,
            child: InkWell(
              borderRadius: kBorderRadiusRow,
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: showLabel ? 8 : 0, vertical: 10),
                child: Row(
                  mainAxisAlignment:
                      showLabel ? MainAxisAlignment.start : MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 22, color: iconColor),
                    if (showLabel) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: foreground,
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );

        return showLabel ? tile : Tooltip(message: label, child: tile);
      },
    );
  }
}
