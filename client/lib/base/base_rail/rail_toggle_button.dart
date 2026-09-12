import 'package:flutter/material.dart';

/// Expand/collapse control at the head of the rail. Sized to the collapsed rail
/// width so it doesn't shift horizontally as the rail animates.
class RailToggleButton extends StatelessWidget {
  final bool isExtended;
  final VoidCallback onPressed;

  const RailToggleButton({super.key, required this.isExtended, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Center(
        child: IconButton(
          tooltip: isExtended ? 'Collapse' : 'Expand',
          visualDensity: VisualDensity.compact,
          icon: Icon(isExtended ? Icons.menu_open : Icons.menu),
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
