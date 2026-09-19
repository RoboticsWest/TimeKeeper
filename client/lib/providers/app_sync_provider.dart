import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/providers/auth_provider.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/notification_provider.dart';
import 'package:time_keeper/providers/rfid_tag_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/session_rsvp_provider.dart';
import 'package:time_keeper/providers/settings_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/providers/team_member_session_provider.dart';
import 'package:time_keeper/providers/user_provider.dart';

part 'app_sync_provider.g.dart';

/// App-lifetime data bootstrap, wired once from [App].
///
/// The providers it touches are all `keepAlive`, so building them here keeps every dataset and
/// every change subscription alive for the whole session - regardless of which view is open. That
/// is what makes data stay current: a row changed on the server shows up without navigating away
/// and back, let alone restarting the app.
///
/// Datasets built before login would come back empty, so a fresh login re-pulls everything.
@Riverpod(keepAlive: true)
class AppDataSync extends _$AppDataSync {
  @override
  void build() {
    // Re-pull all datasets on a fresh login (covers manual login, re-login after logout). Logged
    // out, providers built earlier keep their last data; the re-pull makes them match the new
    // session. First fetch on app start is covered by the `ref.read`s below.
    ref.listen(tokenProvider, (previous, next) {
      if ((previous?.isEmpty ?? true) && (next?.isNotEmpty ?? false)) {
        _refreshAll();
      }
    });

    final loggedIn = ref.watch(isLoggedInProvider);
    if (!loggedIn) return;

    // Start every collection (kicks its initial fetch) and live subscription. `ref.read` is used
    // rather than `ref.watch` so the bootstrap itself never rebuilds when data changes.
    ref.read(usersProvider.notifier);
    ref.read(teamMembersProvider.notifier);
    ref.read(teamMemberSessionsProvider.notifier);
    ref.read(sessionRsvpsProvider.notifier);
    ref.read(rfidTagsProvider.notifier);
    ref.read(locationsProvider.notifier);
    ref.read(notificationsProvider.notifier);
    ref.read(sessionsProvider.notifier);

    ref.read(usersSyncProvider);
    ref.read(teamMembersSyncProvider);
    ref.read(teamMemberSessionsSyncProvider);
    ref.read(sessionRsvpsSyncProvider);
    ref.read(rfidTagsSyncProvider);
    ref.read(locationsSyncProvider);
    ref.read(notificationsSyncProvider);
    ref.read(sessionsSyncProvider);
    // Settings are a single row rather than a collection, so they have their own stream.
    ref.read(settingsChangesProvider);
  }

  void _refreshAll() {
    ref.read(usersProvider.notifier).refresh();
    ref.read(teamMembersProvider.notifier).refresh();
    ref.read(teamMemberSessionsProvider.notifier).refresh();
    ref.read(sessionRsvpsProvider.notifier).refresh();
    ref.read(rfidTagsProvider.notifier).refresh();
    ref.read(locationsProvider.notifier).refresh();
    ref.read(notificationsProvider.notifier).refresh();
    ref.read(sessionsProvider.notifier).refresh();
    ref.invalidate(settingsQueryProvider);
  }
}
