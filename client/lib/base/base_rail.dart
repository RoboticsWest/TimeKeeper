import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/router/app_routes.dart';

class BaseRail extends HookConsumerWidget {
  const BaseRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Derive selected index from current route instead of local state
    final selectedIndex = AppRoute.currentRailIndex(context);
    final isExtended = useState(false);
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: Row(
        children: [
          NavigationRail(
            extended: isExtended.value,
            minWidth: 48,
            minExtendedWidth: 200,
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              // Type-safe navigation using the enum
              final route = AppRoute.fromRailIndex(index);
              route?.go(context);
            },
            leading: Padding(
              padding: const EdgeInsets.only(bottom: 30, top: 20),
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(isExtended.value ? Icons.chevron_left : Icons.menu),
                onPressed: () => isExtended.value = !isExtended.value,
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.handyman),
                label: Text('Settings'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.supervised_user_circle),
                label: Text('Team'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.event_note),
                label: Text('Sessions'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.location_on),
                label: Text('Locations'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.access_time),
                label: Text('Attendance'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics),
                label: Text('Statistics'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
        ],
      ),
    );
  }
}
