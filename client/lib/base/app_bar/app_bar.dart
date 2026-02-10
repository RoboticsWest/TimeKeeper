import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/base/app_bar/login_action.dart';
import 'package:time_keeper/base/app_bar/settings_action.dart';
import 'package:time_keeper/base/app_bar/theme_action.dart';
import 'package:time_keeper/colors.dart';
import 'package:time_keeper/providers/auth_provider.dart';
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

    return null;
  }

  Widget _leading(BuildContext context, String username) {
    // Show home button only when not on home page
    final isHomePage = state.matchedLocation == '/';

    if (isHomePage) {
      return Center(
        child: Text(username, style: TextStyle(fontWeight: FontWeight.bold)),
      ); // Hide button on home page
    }

    return IconButton(
      icon: Icon(Icons.home),
      onPressed: () => AppRoute.kiosk.go(context),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(isConnectedProvider).value ?? false;
    final username = ref.watch(usernameProvider);

    return AppBar(
      backgroundColor: isConnected ? null : supportErrorColor,
      leading: _leading(context, username ?? ''),
      title: _title(isConnected, ref),
      actions: _actions(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
