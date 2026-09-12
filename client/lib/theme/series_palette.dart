import 'package:flutter/material.dart';

/// Categorical palette for charts.
///
/// Eight fixed hues, stepped separately for each brightness — the dark column
/// is the same hues re-stepped for a dark surface, not an automatic flip.
/// Both sets are validated (OKLCH lightness band, chroma floor, adjacent-pair
/// CVD separation, normal-vision floor, contrast) against this app's chart
/// surfaces: white in light mode, `#151515` in dark.
///
/// Slots are assigned in fixed order and never cycled for identity: a ninth
/// series folds into "Other" or becomes small multiples rather than wrapping.
/// [seriesColor] does wrap, because callers that index by position (rail icons,
/// legend swatches) need a total function — but a *chart* must not lean on that.
///
/// In light mode slots 3, 4 and 5 fall below 3:1 against white. They are legal
/// only with relief: a visible direct label, a legend entry, or a table view.
/// Every chart in this app ships a legend or a grid, which satisfies that.
const List<Color> _seriesLight = [
  Color(0xFF2A78D6), // 0 blue
  Color(0xFFEB6834), // 1 orange
  Color(0xFF1BAF7A), // 2 aqua
  Color(0xFFEDA100), // 3 yellow
  Color(0xFFE87BA4), // 4 magenta
  Color(0xFF008300), // 5 green
  Color(0xFF4A3AA7), // 6 violet
  Color(0xFFE34948), // 7 red
];

const List<Color> _seriesDark = [
  Color(0xFF3987E5), // 0 blue
  Color(0xFFD95926), // 1 orange
  Color(0xFF199E70), // 2 aqua
  Color(0xFFC98500), // 3 yellow
  Color(0xFFD55181), // 4 magenta
  Color(0xFF008300), // 5 green
  Color(0xFF9085E9), // 6 violet
  Color(0xFFE66767), // 7 red
];

/// The number of distinct categorical slots before colors repeat.
const int seriesColorCount = 8;

/// Categorical color for [index] at [brightness]. Wraps at [seriesColorCount].
Color seriesColor(int index, Brightness brightness) {
  final palette = brightness == Brightness.dark ? _seriesDark : _seriesLight;
  return palette[index % palette.length];
}

/// Categorical color for [index], reading brightness from [context].
Color seriesColorOf(BuildContext context, int index) =>
    seriesColor(index, Theme.of(context).brightness);

/// Slot 0 is blue, which collides with the app's primary. Anything that sits
/// next to primary-colored chrome — rail icons especially — picks from here
/// instead, so a "selected" primary background never fights the icon on it.
Color seriesColorNonBlue(int index, Brightness brightness) =>
    seriesColor(1 + (index % (seriesColorCount - 1)), brightness);
