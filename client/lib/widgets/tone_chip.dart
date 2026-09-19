import 'package:flutter/material.dart';
import 'package:time_keeper/shapes.dart';

/// A compact chip that carries its meaning in a colored dot and a tinted
/// ground, not in the text ink.
///
/// The app's house rule is that status color goes on chips, meters, strips and
/// borders and never on body text. White-on-saturated satisfied that rule but
/// read poorly: "Finished" on a mid-grey fill was the weakest contrast pair in
/// the app, and two chips whose fills were both blue were not distinguishable
/// at all. A tinted ground plus a full-strength dot keeps the hue as the
/// identifier while the label stays ordinary `onSurface` ink, which is legible
/// in both themes regardless of which hue is passed in.
class ToneChip extends StatelessWidget {
  /// The hue that identifies this value. Used at full strength for the dot and
  /// the border, and knocked back for the ground.
  final Color color;
  final String label;

  /// Draws the label in [color] as well. Reserved for the one case that is a
  /// genuine alert rather than a category — see [ToneChip.alert].
  final bool emphasize;

  const ToneChip({super.key, required this.color, required this.label}) : emphasize = false;

  /// A chip that should read as a warning rather than a category. Still a
  /// chip, so the house rule holds — this is not body text.
  const ToneChip.alert({super.key, required this.color, required this.label}) : emphasize = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(6, 2, 8, 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.20 : 0.13),
        borderRadius: kBorderRadiusRow,
        border: Border.all(color: color.withValues(alpha: isDark ? 0.55 : 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: emphasize ? color : theme.colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }
}
