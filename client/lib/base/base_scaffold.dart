import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/base/app_bar/app_bar.dart';
import 'package:time_keeper/base/base_rail.dart';
import 'package:time_keeper/generated/common/common.pbenum.dart';
import 'package:time_keeper/providers/auth_provider.dart';
import 'package:time_keeper/utils/permissions.dart';

class BaseScaffold extends HookConsumerWidget {
  final GoRouterState state;
  final Widget child;
  final bool showActions;
  final bool disableRail;

  const BaseScaffold({
    super.key,
    required this.state,
    required this.child,
    this.showActions = true,
    this.disableRail = false,
  });

  bool _showDrawerInd(bool hasPermissions) {
    return !disableRail && hasPermissions;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(rolesProvider);
    bool hasPermission = roles.any((r) => r.hasPermission(Role.STUDENT));

    return Scaffold(
      appBar: BaseAppBar(state: state, showActions: showActions),
      body: Stack(
        children: [
          Row(
            children: [
              if (_showDrawerInd(hasPermission)) const SizedBox(width: 48),
              Expanded(child: child),
            ],
          ),
          if (_showDrawerInd(hasPermission)) BaseRail(),
        ],
      ),
    );
  }
}
