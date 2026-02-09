import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
      theme: lightTheme,
      darkTheme: darkTheme,
      themeAnimationDuration: Duration.zero,
    );
  }
}
