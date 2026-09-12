import 'package:flutter/material.dart';

class ChartLegendEntry {
  final String label;
  final Color color;

  const ChartLegendEntry({required this.label, required this.color});
}

/// Legend for a chart with two or more series.
///
/// A legend is always present once there are two series, so identity is never
/// carried by color alone. The label wears ordinary text ink — the swatch
/// beside it carries the identity.
class ChartLegend extends StatelessWidget {
  final List<ChartLegendEntry> entries;

  const ChartLegend({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 14,
      runSpacing: 4,
      children: [
        for (final entry in entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: entry.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                entry.label,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11),
              ),
            ],
          ),
      ],
    );
  }
}
