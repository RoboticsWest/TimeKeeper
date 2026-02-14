import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/base/base_scaffold.dart';
import 'package:time_keeper/generated/common/common.pb.dart';
import 'package:time_keeper/providers/auth_provider.dart';
import 'package:time_keeper/router/app_routes.dart';
import 'package:time_keeper/router/deferred_widget.dart';
import 'package:time_keeper/utils/permissions.dart';

// Deferred
import 'package:time_keeper/views/kiosk/kiosk_view.dart' deferred as kiosk;
import 'package:time_keeper/views/login/login_view.dart' deferred as login;
import 'package:time_keeper/views/setup/setup_view.dart' deferred as setup;
import 'package:time_keeper/views/settings/settings_view.dart'
    deferred as settings;
import 'package:time_keeper/views/sessions/session_view.dart'
    deferred as sessions;
import 'package:time_keeper/views/team/team_view.dart' deferred as team;
import 'package:time_keeper/views/locations/locations_view.dart'
    deferred as locations;
import 'package:time_keeper/views/notifications/notifications_view.dart'
    deferred as notifications;
import 'package:time_keeper/views/users/users_view.dart' deferred as users;
import 'package:time_keeper/views/leaderboard/leaderboard_view.dart'
    deferred as leaderboard;
import 'package:time_keeper/views/attendance/attendance_view.dart'
    deferred as attendance;
import 'package:time_keeper/views/statistics/statistics_view.dart'
    deferred as statistics;
import 'package:time_keeper/views/calendar/calendar_view.dart'
    deferred as calendar;

part 'router.g.dart';

final _protectedRoute = '/protected';

/// Wrapper that delays showing the child until it has completed its first build.
///
/// This prevents the animation from starting while the widget is still building,
/// which would cause visible jank. The widget builds off-screen first, then
/// the animation reveals it smoothly.
class _DelayedAnimationWrapper extends HookWidget {
  final Widget child;

  const _DelayedAnimationWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    final isReady = useState(false);

    useEffect(() {
      // Wait for the widget to complete its first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isReady.value = true;
      });
      return null;
    }, []);

    if (!isReady.value) {
      // Widget is building - show it invisibly so it can complete its build
      return Opacity(opacity: 0.0, child: child);
    }

    // Widget is ready - show it normally and let the animation proceed
    return child;
  }
}

/// Creates a page with a fade + slide up transition.
///
/// The animation waits for the widget to complete its first build before
/// starting, ensuring smooth transitions without visible widget rebuilds.
CustomTransitionPage<void> _buildTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: key,
    child: _DelayedAnimationWrapper(child: child),
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: FadeTransition(
          opacity: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn)),
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.0, 0.03),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
            child: child,
          ),
        ),
      );
    },
  );
}

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final isLoggedIn = ref.watch(isLoggedInProvider);
  final roles = ref.watch(rolesProvider);

  return GoRouter(
    initialLocation: AppRoute.kiosk.path,
    routes: <RouteBase>[
      // Shell Routes (for standard displays)
      ShellRoute(
        pageBuilder: (context, state, child) {
          return NoTransitionPage(
            child: BaseScaffold(state: state, child: child),
          );
        },
        routes: [
          GoRoute(
            name: AppRoute.leaderboard.name,
            path: AppRoute.leaderboard.path,
            pageBuilder: (context, state) => _buildTransitionPage(
              key: state.pageKey,
              child: DeferredWidget(
                libraryKey: AppRoute.leaderboard.path,
                libraryLoader: leaderboard.loadLibrary,
                builder: (context) => leaderboard.LeaderboardView(),
              ),
            ),
          ),
          GoRoute(
            name: AppRoute.calendar.name,
            path: AppRoute.calendar.path,
            pageBuilder: (context, state) => _buildTransitionPage(
              key: state.pageKey,
              child: DeferredWidget(
                libraryKey: AppRoute.calendar.path,
                libraryLoader: calendar.loadLibrary,
                builder: (context) => calendar.CalendarView(),
              ),
            ),
          ),
          GoRoute(
            name: AppRoute.kiosk.name,
            path: AppRoute.kiosk.path,
            pageBuilder: (context, state) => _buildTransitionPage(
              key: state.pageKey,
              child: DeferredWidget(
                libraryKey: AppRoute.kiosk.path,
                libraryLoader: kiosk.loadLibrary,
                builder: (context) => kiosk.HomeView(),
              ),
            ),
          ),

          // Protected Routes
          GoRoute(
            path: _protectedRoute,
            redirect: (context, state) {
              if (!isLoggedIn) {
                return AppRoute.login.path;
              }
              return null;
            },
            routes: [
              // Protected Admin routes
              GoRoute(
                path: '/admin',
                redirect: (context, state) {
                  if (!isLoggedIn && roles.hasPermission(Role.ADMIN)) {
                    return AppRoute.login.path;
                  }
                  return null;
                },
                routes: [
                  GoRoute(
                    name: AppRoute.setup.name,
                    path: AppRoute.setup.path,
                    pageBuilder: (context, state) => _buildTransitionPage(
                      key: state.pageKey,
                      child: DeferredWidget(
                        libraryKey: AppRoute.setup.path,
                        libraryLoader: setup.loadLibrary,
                        builder: (context) => setup.SetupView(),
                      ),
                    ),
                  ),
                  GoRoute(
                    name: AppRoute.users.name,
                    path: AppRoute.users.path,
                    pageBuilder: (context, state) => _buildTransitionPage(
                      key: state.pageKey,
                      child: DeferredWidget(
                        libraryKey: AppRoute.users.path,
                        libraryLoader: users.loadLibrary,
                        builder: (context) => users.UsersView(),
                      ),
                    ),
                  ),
                  GoRoute(
                    name: AppRoute.team.name,
                    path: AppRoute.team.path,
                    pageBuilder: (context, state) => _buildTransitionPage(
                      key: state.pageKey,
                      child: DeferredWidget(
                        libraryKey: AppRoute.team.path,
                        libraryLoader: team.loadLibrary,
                        builder: (context) => team.TeamView(),
                      ),
                    ),
                  ),
                  GoRoute(
                    name: AppRoute.sessions.name,
                    path: AppRoute.sessions.path,
                    pageBuilder: (context, state) => _buildTransitionPage(
                      key: state.pageKey,
                      child: DeferredWidget(
                        libraryKey: AppRoute.sessions.path,
                        libraryLoader: sessions.loadLibrary,
                        builder: (context) => sessions.SessionView(),
                      ),
                    ),
                  ),
                  GoRoute(
                    name: AppRoute.locations.name,
                    path: AppRoute.locations.path,
                    pageBuilder: (context, state) => _buildTransitionPage(
                      key: state.pageKey,
                      child: DeferredWidget(
                        libraryKey: AppRoute.locations.path,
                        libraryLoader: locations.loadLibrary,
                        builder: (context) => locations.LocationsView(),
                      ),
                    ),
                  ),
                  GoRoute(
                    name: AppRoute.notifications.name,
                    path: AppRoute.notifications.path,
                    pageBuilder: (context, state) => _buildTransitionPage(
                      key: state.pageKey,
                      child: DeferredWidget(
                        libraryKey: AppRoute.notifications.path,
                        libraryLoader: notifications.loadLibrary,
                        builder: (context) => notifications.NotificationsView(),
                      ),
                    ),
                  ),
                  GoRoute(
                    name: AppRoute.attendance.name,
                    path: AppRoute.attendance.path,
                    pageBuilder: (context, state) => _buildTransitionPage(
                      key: state.pageKey,
                      child: DeferredWidget(
                        libraryKey: AppRoute.attendance.path,
                        libraryLoader: attendance.loadLibrary,
                        builder: (context) => attendance.AttendanceView(),
                      ),
                    ),
                  ),
                  GoRoute(
                    name: AppRoute.statistics.name,
                    path: AppRoute.statistics.path,
                    pageBuilder: (context, state) => _buildTransitionPage(
                      key: state.pageKey,
                      child: DeferredWidget(
                        libraryKey: AppRoute.statistics.path,
                        libraryLoader: statistics.loadLibrary,
                        builder: (context) => statistics.StatisticsView(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // Standalone Routes
      GoRoute(
        name: AppRoute.login.name,
        path: AppRoute.login.path,
        builder: (context, state) => BaseScaffold(
          showActions: false,
          disableRail: true,
          state: state,
          child: DeferredWidget(
            libraryKey: AppRoute.login.path,
            libraryLoader: login.loadLibrary,
            builder: (context) => login.LoginView(),
          ),
        ),
      ),

      GoRoute(
        name: AppRoute.settings.name,
        path: AppRoute.settings.path,
        builder: (context, state) => BaseScaffold(
          showActions: false,
          disableRail: true,
          state: state,
          child: DeferredWidget(
            libraryKey: AppRoute.settings.path,
            libraryLoader: settings.loadLibrary,
            builder: (context) => settings.SettingsView(),
          ),
        ),
      ),
    ],
  );
}
