import 'package:flutter/material.dart';

/// A labelled boolean setting.
///
/// Every boolean in Setup was previously hand-assembled from a [SettingRow]
/// plus a bare [Switch] (or, in device Settings, a lone `SwitchListTile` that
/// looked nothing like the rest). This is the one shape they should all use.
class SwitchSetting extends StatelessWidget {
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SwitchSetting({
    super.key,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onChanged != null;

    return InkWell(
      onTap: enabled ? () => onChanged!(!value) : null,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: enabled ? null : theme.disabledColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
