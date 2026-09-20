import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:time_keeper/theme/series_palette.dart';

/// Sections of the left rail. Server configuration and account administration
/// are kept apart from the day-to-day operational pages.
enum RailGroup {
  admin('Admin'),
  operations('Operations');

  const RailGroup(this.label);

  final String label;
}

/// Type-safe navigation routes for the entire app.
///
/// Usage:
/// - Named navigation: `AppRoute.setup.go(context)`
/// - With parameters: `AppRoute.setup.go(context, queryParams: {'tab': 'database'})`
///
/// Route definitions:
/// - path: The actual path used in go_router (for route definitions)
/// - name: The route name used for named navigation
/// - railIndex: Ordering within the rail (null if not in rail)
/// - icon/label/colorSlot/group: how the route presents itself in the rail
///
/// Presentation lives on the enum so the rail can be driven by
/// [AppRoute.railRoutes] rather than an inline list whose order has to be kept
/// in sync with [railIndex] by hand.
enum AppRoute {
  // Public routes - reachable by URL or app bar, never shown in the rail.
  kiosk(path: '/', name: 'kiosk'),
  leaderboard(path: '/leaderboard', name: 'leaderboard'),
  calendar(path: '/calendar', name: 'calendar'),
  login(path: '/login', name: 'login'),
  // Device-local settings (server address, port, kiosk location). Reached from
  // the app bar only - distinct from `setup`, which configures the server.
  settings(path: '/settings', name: 'settings'),

  // Protected routes (nested under /protected)
  setup(
    path: '/setup', // Relative to /protected parent
    name: 'setup',
    railIndex: 0,
    icon: Icons.tune,
    label: 'Setup',
    colorSlot: 6,
    group: RailGroup.admin,
  ),
  users(
    path: '/users',
    name: 'users',
    railIndex: 1,
    icon: Icons.person,
    label: 'Users',
    colorSlot: 4,
    group: RailGroup.admin,
  ),
  team(
    path: '/team',
    name: 'team',
    railIndex: 2,
    icon: Icons.supervised_user_circle,
    label: 'Team',
    colorSlot: 2,
    group: RailGroup.operations,
  ),
  sessions(
    path: '/sessions',
    name: 'sessions',
    railIndex: 3,
    icon: Icons.event_note,
    label: 'Sessions',
    colorSlot: 1,
    group: RailGroup.operations,
  ),
  locations(
    path: '/locations',
    name: 'locations',
    railIndex: 4,
    icon: Icons.location_on,
    label: 'Locations',
    colorSlot: 7,
    group: RailGroup.operations,
  ),
  notifications(
    path: '/notifications',
    name: 'notifications',
    railIndex: 5,
    icon: Icons.notifications,
    label: 'Notifications',
    colorSlot: 3,
    group: RailGroup.operations,
  ),
  attendance(
    path: '/attendance',
    name: 'attendance',
    railIndex: 6,
    icon: Icons.access_time,
    label: 'Attendance',
    colorSlot: 5,
    group: RailGroup.operations,
  ),
  achievements(
    path: '/achievements',
    name: 'achievements',
    railIndex: 7,
    icon: Icons.workspace_premium,
    label: 'Achievements',
    // Amber: the one rail item that is not an operational tool, and the colour
    // reads as a medal rather than as another category of work.
    colorSlot: 3,
    group: RailGroup.operations,
  ),
  statistics(
    path: '/statistics',
    name: 'statistics',
    railIndex: 8,
    icon: Icons.analytics,
    label: 'Statistics',
    // Eight rail items against seven non-blue categorical slots means exactly
    // one hue repeats. Setup and Statistics share violet: they sit at opposite
    // ends of the rail and in different groups, so they are never scanned
    // against each other.
    colorSlot: 6,
    group: RailGroup.operations,
  );

  const AppRoute({
    required this.path,
    required this.name,
    this.railIndex,
    this.icon,
    this.label,
    this.colorSlot,
    this.group,
  });

  /// The path used in go_router route definitions
  final String path;

  /// The route name used by go_router for named navigation
  final String name;

  /// Ordering within the rail (null if the route isn't in the rail)
  final int? railIndex;

  /// Rail icon. Null for routes that never appear in the rail.
  final IconData? icon;

  /// Rail label. Null for routes that never appear in the rail.
  final String? label;

  /// Index into the categorical series palette, resolved per brightness.
  /// Slot 0 (blue) is deliberately unused here - it collides with `primary`,
  /// which paints the selected item's background.
  final int? colorSlot;

  /// Which section of the rail this route belongs to.
  final RailGroup? group;

  /// This route's fixed rail color at [brightness]. Each item keeps its own
  /// color in every state; selection is carried by background and weight.
  Color colorFor(Brightness brightness) => seriesColor(colorSlot ?? 0, brightness);

  /// Navigate to this route using go_router's goNamed method
  void go(BuildContext context, {Map<String, String>? pathParams, Map<String, dynamic>? queryParams, Object? extra}) {
    context.goNamed(name, pathParameters: pathParams ?? {}, queryParameters: queryParams ?? {}, extra: extra);
  }

  /// Navigate to this route using go_router's pushNamed method
  Future<T?> push<T>(
    BuildContext context, {
    Map<String, String>? pathParams,
    Map<String, dynamic>? queryParams,
    Object? extra,
  }) {
    return context.pushNamed<T>(
      name,
      pathParameters: pathParams ?? {},
      queryParameters: queryParams ?? {},
      extra: extra,
    );
  }

  /// Get all routes that appear in the navigation rail, in order
  static List<AppRoute> get railRoutes {
    final routes = values.where((route) => route.railIndex != null).toList();
    routes.sort((a, b) => a.railIndex!.compareTo(b.railIndex!));
    return routes;
  }

  /// Rail routes bucketed by [RailGroup], groups in declaration order and
  /// routes within each group in [railIndex] order.
  static Map<RailGroup, List<AppRoute>> get railGroups {
    final grouped = <RailGroup, List<AppRoute>>{};
    for (final group in RailGroup.values) {
      final routes = railRoutes.where((route) => route.group == group).toList();
      if (routes.isNotEmpty) grouped[group] = routes;
    }
    return grouped;
  }

  /// Get the current route based on the current route name
  static AppRoute? current(BuildContext context) {
    final routeName = GoRouterState.of(context).topRoute?.name;

    if (routeName == null) return null;

    for (final route in values) {
      if (routeName == route.name) {
        return route;
      }
    }

    return null;
  }
}
