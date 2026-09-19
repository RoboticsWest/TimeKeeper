import 'package:flutter/material.dart';
import 'package:time_keeper/colors.dart';
import 'package:time_keeper/shapes.dart';

/// A period-over-period change.
///
/// [ratio] is the fractional change (0.12 = +12%). [higherIsBetter] decides
/// which direction is good — overtime going up is not an improvement.
class KpiDelta {
  final double ratio;
  final bool higherIsBetter;

  const KpiDelta({required this.ratio, this.higherIsBetter = true});

  bool get isFlat => ratio.abs() < 0.005;
  bool get isGood => higherIsBetter ? ratio > 0 : ratio < 0;

  String get label {
    if (isFlat) return '0%';
    final pct = (ratio * 100).abs();
    final sign = ratio > 0 ? '+' : '-';
    return pct >= 100 ? '$sign${pct.round()}%' : '$sign${pct.toStringAsFixed(pct < 10 ? 1 : 0)}%';
  }
}

/// One headline number.
///
/// Replaces the three separate "stat chip" implementations that existed across
/// the statistics page. The value wears ordinary text ink; only the delta chip
/// carries color, and it always ships an arrow alongside the hue so direction
/// never depends on color alone.
class KpiTile extends StatelessWidget {
  final String label;
  final String value;
  final KpiDelta? delta;
  final IconData? icon;
  final String? footnote;
  final VoidCallback? onTap;

  const KpiTile({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.icon,
    this.footnote,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final tile = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: kBorderRadiusCard,
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 13, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (delta != null) ...[const SizedBox(width: 6), _DeltaChip(delta: delta!)],
            ],
          ),
          if (footnote != null)
            Text(
              footnote!,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 10),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
        ],
      ),
    );

    if (onTap == null) return tile;
    return InkWell(borderRadius: kBorderRadiusCard, onTap: onTap, child: tile);
  }
}

class _DeltaChip extends StatelessWidget {
  final KpiDelta delta;

  const _DeltaChip({required this.delta});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color color;
    final IconData iconData;
    if (delta.isFlat) {
      color = theme.colorScheme.onSurfaceVariant;
      iconData = Icons.remove;
    } else {
      color = delta.isGood ? supportSuccessColor.shade700 : supportErrorColor.shade600;
      iconData = delta.ratio > 0 ? Icons.arrow_upward : Icons.arrow_downward;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: kBorderRadiusRow),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Arrow plus hue: direction never rests on color alone.
          Icon(iconData, size: 10, color: color),
          const SizedBox(width: 2),
          Text(
            delta.label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
