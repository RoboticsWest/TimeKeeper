import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/helpers/debug_window.dart';
import 'package:time_keeper/providers/theme_provider.dart';
import 'package:time_keeper/providers/token_validator_provider.dart';
import 'package:time_keeper/router/router.dart';
import 'package:time_keeper/theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);

    // Initialize token validator to monitor app lifecycle
    ref.watch(tokenValidatorProvider);

    return MaterialApp.router(
      title: 'TimeKeeper',
      debugShowCheckedModeBanner: true,
      routerConfig: ref.watch(routerProvider),
      themeMode: themeMode,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeAnimationDuration: Duration.zero,
      // Pull text down slightly across the whole app. The dashboard layouts are
      // dense by design and the default scale overflows several of them.
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        minScaleFactor: 0.95,
        maxScaleFactor: 0.95,
        child: _DebugSizeOverride(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}

/// Letterboxes the app into [debugSizeOverride] when one is set, so an
/// automation driver can exercise the responsive breakpoints on a platform
/// where the real window cannot be resized. A no-op in release builds and
/// whenever no override is set.
class _DebugSizeOverride extends StatelessWidget {
  const _DebugSizeOverride({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return child;

    return ValueListenableBuilder<Size?>(
      valueListenable: debugSizeOverride,
      builder: (context, size, _) {
        if (size == null) return child;

        return Align(
          alignment: Alignment.topLeft,
          child: SizedBox.fromSize(
            size: size,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(size: size),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
