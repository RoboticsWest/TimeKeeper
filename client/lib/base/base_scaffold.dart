import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/base/app_bar/app_bar.dart';
import 'package:time_keeper/base/base_rail/base_rail.dart';
import 'package:time_keeper/providers/auth_provider.dart';

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

  bool _showRail(bool hasPermissions) => !disableRail && hasPermissions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPermission = ref.watch(hasAnyPermissionProvider);
    // Owned here rather than in BaseRail so the click-away barrier below can
    // collapse the rail too.
    final isExtended = useState(false);
    final showRail = _showRail(hasPermission);

    return Scaffold(
      appBar: BaseAppBar(state: state, showActions: showActions),
      body: Stack(
        children: [
          Row(
            children: [
              // The page is always inset by the *collapsed* width; the expanded
              // rail overlays it instead of pushing it.
              if (showRail) const SizedBox(width: BaseRail.collapsedWidth),
              Expanded(child: child),
            ],
          ),
          if (showRail && isExtended.value)
            Positioned.fill(
              left: BaseRail.collapsedWidth,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => isExtended.value = false,
                child: const SizedBox.expand(),
              ),
            ),
          if (showRail)
            BaseRail(
              isExtended: isExtended.value,
              onToggle: () => isExtended.value = !isExtended.value,
            ),
        ],
      ),
    );
  }
}
