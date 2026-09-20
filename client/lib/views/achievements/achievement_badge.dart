import 'package:flutter/material.dart';
import 'package:time_keeper/models/accolades.dart';
import 'package:time_keeper/shapes.dart';

/// One achievement tile.
///
/// Held and unheld use the same layout and differ only in ink and ground, so the board reads as
/// one collection with gaps in it rather than two lists side by side — which is what makes an
/// unearned one feel like something to go and get.
///
/// The condition lives in a tooltip rather than on the tile. At sixty-seven of these the text
/// would dominate the grid, and hover is the natural place for detail that is only wanted one
/// at a time. Long-press gives touch devices the same thing.
class AchievementBadge extends StatelessWidget {
  final Achievement achievement;

  /// The hue for an earned badge. Unearned ones ignore it and stay neutral.
  final Color color;

  const AchievementBadge({super.key, required this.achievement, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secret = achievement.isSecret;
    final earned = achievement.earned;

    // A secret achievement must give nothing away: not its name, not how to get it.
    final label = secret ? 'Secret' : achievement.name;
    final emoji = secret ? '❓' : achievement.emoji;
    final tooltip = secret
        ? 'A hidden achievement. Keep going.'
        : '${achievement.name}\n${achievement.how}'
              '\n\n${achievement.rarityText} (${achievement.holders} of '
              '${achievement.totalMembers} active)'
              '${earned ? '' : '\n\nNot yet earned'}';

    final ground = earned
        ? color.withValues(alpha: isDark ? 0.18 : 0.12)
        : theme.colorScheme.onSurface.withValues(alpha: isDark ? 0.04 : 0.03);
    final border = earned
        ? color.withValues(alpha: isDark ? 0.55 : 0.45)
        : theme.colorScheme.onSurface.withValues(alpha: 0.12);

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 300),
      child: Container(
        width: 148,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: ground,
          borderRadius: kBorderRadiusCard,
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            // Unearned emoji are dimmed rather than replaced, so the shape of the collection is
            // visible at a glance without the greyed-out ones competing for attention.
            Opacity(
              opacity: earned ? 1 : 0.35,
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: earned ? FontWeight.w600 : FontWeight.w400,
                      color: earned ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.55),
                      fontStyle: secret ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                  // Rarity on the tile, not only in the tooltip: a badge two people in the club
                  // hold should look different from one everybody has without having to hover.
                  if (!secret)
                    Text(
                      achievement.rarityLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: earned ? color : theme.colorScheme.onSurface.withValues(alpha: 0.40),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
