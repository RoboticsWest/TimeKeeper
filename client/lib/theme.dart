import 'package:flutter/material.dart';
import 'package:time_keeper/shapes.dart';

/// The brand blue. Used verbatim as `primary` in light mode; lifted to
/// [_primaryDark] on dark, where `#0751B9` is too dark to read as an accent.
const Color kBrandBlue = Color(0xFF0751B9);
const Color _primaryDark = Color(0xFF4D8DF6);

/// Light scheme: off-white page, **pure white** panels, near-black ink, and
/// dividers you can actually see. Authored by hand rather than derived with
/// `ColorScheme.fromSeed` — the tonal generator is what produced the pastel
/// wash this replaces.
const ColorScheme _lightScheme = ColorScheme(
  brightness: Brightness.light,
  primary: kBrandBlue,
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFDCE8FA),
  onPrimaryContainer: Color(0xFF06265A),
  secondary: Color(0xFF2F6BC4),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFE4EDFB),
  onSecondaryContainer: Color(0xFF0A2E66),
  tertiary: Color(0xFF4A3AA7),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFE5E2F6),
  onTertiaryContainer: Color(0xFF231A57),
  error: Color(0xFFC22727),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFBE0E0),
  onErrorContainer: Color(0xFF6B1111),
  // Page background sits *below* the panels, which are pure white.
  surface: Color(0xFFF4F5F7),
  onSurface: Color(0xFF16181C),
  onSurfaceVariant: Color(0xFF5A5F6A),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFFAFBFC),
  surfaceContainer: Color(0xFFF0F2F5),
  surfaceContainerHigh: Color(0xFFE8EAEE),
  surfaceContainerHighest: Color(0xFFDFE2E7),
  outline: Color(0xFF8A9099),
  outlineVariant: Color(0xFFD4D7DD),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFF2A2D33),
  onInverseSurface: Color(0xFFF2F3F5),
  inversePrimary: _primaryDark,
);

/// Dark scheme: **true neutral** greys, no blue cast anywhere in the surface
/// ramp. Near-black page, distinctly lighter panels, crisp borders, bright ink.
///
/// The page and chrome steps are tuned so the *ratio* between page, chrome and
/// panel matches the light scheme rather than the hex distance. Equal hex
/// steps do not read as equal separation down at the black end: the old
/// `#0D0D0D` page against a `#151515` panel was a 1.03 luminance ratio where
/// light mode's `#F4F5F7` against white is 1.11, which is why dark read flat
/// and "different" next to light. `#151515` itself is fixed — the categorical
/// palette in `theme/series_palette.dart` is validated against it — so the
/// page and the chrome move instead.
const ColorScheme _darkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: _primaryDark,
  onPrimary: Color(0xFF04173A),
  primaryContainer: Color(0xFF123566),
  onPrimaryContainer: Color(0xFFD6E4FB),
  secondary: Color(0xFF7FAEF5),
  onSecondary: Color(0xFF07203F),
  secondaryContainer: Color(0xFF16304F),
  onSecondaryContainer: Color(0xFFDCE8FA),
  tertiary: Color(0xFF9085E9),
  onTertiary: Color(0xFF1C1442),
  tertiaryContainer: Color(0xFF2E2769),
  onTertiaryContainer: Color(0xFFE3E0F8),
  error: Color(0xFFE66767),
  onError: Color(0xFF400A0A),
  errorContainer: Color(0xFF5C1919),
  onErrorContainer: Color(0xFFFBDCDC),
  surface: Color(0xFF060606),
  onSurface: Color(0xFFF2F2F2),
  onSurfaceVariant: Color(0xFFA8A8A8),
  surfaceContainerLowest: Color(0xFF151515),
  // App bar, rail and the setup side pane. Sits between the page and the
  // panels, the same place light mode's `#FAFBFC` sits between `#F4F5F7` and
  // white — chrome that recedes behind content instead of floating above it.
  surfaceContainerLow: Color(0xFF101010),
  surfaceContainer: Color(0xFF1F1F1F),
  surfaceContainerHigh: Color(0xFF262626),
  surfaceContainerHighest: Color(0xFF2E2E2E),
  outline: Color(0xFF6E6E6E),
  outlineVariant: Color(0xFF3A3A3A),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFFE8E8E8),
  onInverseSurface: Color(0xFF1A1A1A),
  inversePrimary: kBrandBlue,
);

ThemeData _buildTheme(ColorScheme cs) {
  final isDark = cs.brightness == Brightness.dark;
  // Deliberately stronger than Material's default hairline — "dividers you can
  // see" is an acceptance criterion for this theme, not a preference.
  final divider = isDark ? const Color(0xFF333333) : const Color(0xFFD4D7DD);

  return ThemeData(
    useMaterial3: true,
    brightness: cs.brightness,
    colorScheme: cs,
    scaffoldBackgroundColor: cs.surface,
    dividerColor: divider,
    visualDensity: VisualDensity.compact,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    splashFactory: InkSparkle.splashFactory,

    dividerTheme: DividerThemeData(color: divider, thickness: 1, space: 1),

    appBarTheme: AppBarTheme(
      backgroundColor: cs.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      foregroundColor: cs.onSurface,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: cs.onSurface, size: 20),
      shape: Border(bottom: BorderSide(color: divider)),
      titleTextStyle: TextStyle(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
    ),

    // Bordered, not elevated. Panels separate from the page by contrast and a
    // 1px edge rather than by a drop shadow.
    cardTheme: CardThemeData(
      elevation: 0,
      color: cs.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: kBorderRadiusCard,
        side: BorderSide(color: divider),
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: cs.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: kBorderRadiusCard,
        side: BorderSide(color: divider),
      ),
      titleTextStyle: TextStyle(color: cs.onSurface, fontSize: 17, fontWeight: FontWeight.w600),
      contentTextStyle: TextStyle(color: cs.onSurface, fontSize: 14),
    ),

    popupMenuTheme: PopupMenuThemeData(
      color: cs.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: kBorderRadiusRow,
        side: BorderSide(color: divider),
      ),
    ),

    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(cs.surfaceContainerLowest),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: kBorderRadiusRow,
            side: BorderSide(color: divider),
          ),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: cs.surfaceContainer,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: kBorderRadiusRow,
        borderSide: BorderSide(color: divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: kBorderRadiusRow,
        borderSide: BorderSide(color: divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: kBorderRadiusRow,
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: kBorderRadiusRow,
        borderSide: BorderSide(color: cs.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: kBorderRadiusRow,
        borderSide: BorderSide(color: cs.error, width: 2),
      ),
      hintStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
      labelStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const RoundedRectangleBorder(borderRadius: kBorderRadiusRow),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        shape: const RoundedRectangleBorder(borderRadius: kBorderRadiusRow),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: cs.onSurface,
        side: BorderSide(color: divider),
        shape: const RoundedRectangleBorder(borderRadius: kBorderRadiusRow),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: cs.primary,
        shape: const RoundedRectangleBorder(borderRadius: kBorderRadiusRow),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(shape: const RoundedRectangleBorder(borderRadius: kBorderRadiusRow)),
    ),

    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: cs.surfaceContainerLow,
      indicatorColor: cs.primaryContainer,
      indicatorShape: const RoundedRectangleBorder(borderRadius: kBorderRadiusRow),
      selectedIconTheme: IconThemeData(color: cs.onSurface, size: 22),
      unselectedIconTheme: IconThemeData(color: cs.onSurfaceVariant, size: 22),
      selectedLabelTextStyle: TextStyle(color: cs.onSurface, fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelTextStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: cs.surfaceContainerHigh,
      side: BorderSide(color: divider),
      shape: const RoundedRectangleBorder(borderRadius: kBorderRadiusRow),
      labelStyle: TextStyle(color: cs.onSurface, fontSize: 12, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      labelPadding: const EdgeInsets.symmetric(horizontal: 2),
    ),

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(color: cs.inverseSurface, borderRadius: kBorderRadiusRow),
      textStyle: TextStyle(color: cs.onInverseSurface, fontSize: 12),
      waitDuration: const Duration(milliseconds: 400),
    ),

    tabBarTheme: TabBarThemeData(
      labelColor: cs.primary,
      unselectedLabelColor: cs.onSurfaceVariant,
      indicatorColor: cs.primary,
      dividerColor: divider,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 14),
    ),

    listTileTheme: ListTileThemeData(
      dense: true,
      shape: const RoundedRectangleBorder(borderRadius: kBorderRadiusRow),
      iconColor: cs.onSurfaceVariant,
    ),

    switchTheme: SwitchThemeData(
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? Colors.transparent : divider,
      ),
    ),

    checkboxTheme: CheckboxThemeData(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2))),
      side: BorderSide(color: cs.outline, width: 1.5),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: kBorderRadiusRow),
      backgroundColor: cs.inverseSurface,
      contentTextStyle: TextStyle(color: cs.onInverseSurface, fontSize: 14),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(color: cs.primary, linearMinHeight: 4),

    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(cs.surfaceContainerHigh),
      headingTextStyle: TextStyle(color: cs.onSurface, fontSize: 12, fontWeight: FontWeight.w700),
      dataTextStyle: TextStyle(color: cs.onSurface, fontSize: 13),
      dividerThickness: 1,
    ),
  );
}

ThemeData buildLightTheme() => _buildTheme(_lightScheme);
ThemeData buildDarkTheme() => _buildTheme(_darkScheme);
