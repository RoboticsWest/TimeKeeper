import 'package:flutter/material.dart';
import 'package:time_keeper/router/app_routes.dart';

class SettingsAction extends StatelessWidget {
  const SettingsAction({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => AppRoute.setup.go(context),
      icon: Icon(Icons.settings),
    );
  }
}
