import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/providers/auth_provider.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/notification_provider.dart';
import 'package:time_keeper/providers/open_attendance_provider.dart';
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

    // Start the reference collections (kicks each initial fetch) and their live subscriptions.
    // `ref.read` is used rather than `ref.watch` so the bootstrap itself never rebuilds when data
    // changes.
    //
    // These four are the ones nearly every screen resolves ids against — a session's location
    // name, an attendance row's member, a scanned tag's owner — and they are bounded by the size
    // of the club rather than by how long it has been running, a few hundred rows each. Holding
    // them is what makes navigating between views instant and keeps every screen consistent.
    //
    // Deliberately *not* here:
    //   * `teamMemberSessions` — the attendance history, which grows without bound. Built on
    //     demand by the statistics dashboard and the CSV export; everything else asks a bounded
    //     question instead (`openAttendance`, the attendance count queries).
    //   * `notifications` — its view is server-paged and nothing else reads the collection.
    //   * `users` — same, and nothing displays the collection at all.
    // Their subscriptions come up with the views that need them, so a change still lands live.
    ref.read(teamMembersProvider.notifier);
    ref.read(sessionRsvpsProvider.notifier);
    ref.read(rfidTagsProvider.notifier);
    ref.read(locationsProvider.notifier);
    ref.read(sessionsProvider.notifier);

    ref.read(teamMembersSyncProvider);
    ref.read(sessionRsvpsSyncProvider);
    ref.read(rfidTagsSyncProvider);
    ref.read(locationsSyncProvider);
    ref.read(sessionsSyncProvider);
    // Settings are a single row rather than a collection, so they have their own stream.
    ref.read(settingsChangesProvider);
    // Who is checked in right now: small, and the kiosk's whole reason for existing.
    ref.read(openAttendanceProvider.notifier);
  }

  void _refreshAll() {
    ref.read(teamMembersProvider.notifier).refresh();
    ref.read(sessionRsvpsProvider.notifier).refresh();
    ref.read(rfidTagsProvider.notifier).refresh();
    ref.read(locationsProvider.notifier).refresh();
    ref.read(sessionsProvider.notifier).refresh();
    ref.read(openAttendanceProvider.notifier).refresh();
    ref.invalidate(settingsQueryProvider);
    // Only refreshed if something actually built them.
    if (ref.exists(teamMemberSessionsProvider)) ref.read(teamMemberSessionsProvider.notifier).refresh();
    if (ref.exists(notificationsProvider)) ref.read(notificationsProvider.notifier).refresh();
    if (ref.exists(usersProvider)) ref.read(usersProvider.notifier).refresh();
  }
}
