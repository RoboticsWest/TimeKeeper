import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/base/app_bar/login_action.dart';
import 'package:time_keeper/base/app_bar/settings_action.dart';
import 'package:time_keeper/base/app_bar/theme_action.dart';
import 'package:time_keeper/colors.dart';
import 'package:time_keeper/providers/health_provider.dart';
import 'package:time_keeper/router/app_routes.dart';

class BaseAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final GoRouterState state;
  final bool showActions;

  const BaseAppBar({super.key, required this.state, this.showActions = true});

  List<Widget> _actions() {
    if (!showActions) return [];
    return [
      BaseAppBarThemeAction(),
      SettingsAction(),
      BaseAppBarLoginAction(state: state),
    ];
  }

  Widget? _title(bool isConnected, WidgetRef ref) {
    if (!isConnected) {
      return Text(
        'Disconnected',
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    }

    final routeName = state.topRoute?.name;
    if (routeName != null) {
      for (final route in AppRoute.values) {
        if (route.name == routeName) {
          return Text(
            route.name.toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.bold),
          );
        }
      }
    }

    return null;
  }

  Widget _leading(BuildContext context) {
    final isHomePage = state.matchedLocation == '/';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isHomePage)
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () => AppRoute.kiosk.go(context),
          ),
        IconButton(
          icon: Icon(Icons.leaderboard),
          tooltip: 'Leaderboard',
          onPressed: () => AppRoute.leaderboard.go(context),
        ),
        IconButton(
          icon: Icon(Icons.calendar_month),
          tooltip: 'Calendar',
          onPressed: () => AppRoute.calendar.go(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(isConnectedProvider).value ?? false;

    return AppBar(
      backgroundColor: isConnected ? null : supportErrorColor,
      leadingWidth: 120,
      leading: _leading(context),
      title: _title(isConnected, ref),
      actions: _actions(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
