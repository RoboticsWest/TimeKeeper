import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/helpers/session_helper.dart';
import 'package:time_keeper/models/session.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/settings_provider.dart';
import 'package:time_keeper/utils/api_result.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/widgets/dialogs/popup_dialog.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';

/// Asks an administrator *where* a member is being checked in before checking them in.
///
/// The roster used to reuse the device's configured location for this, which is a kiosk setting:
/// on an admin's laptop it is usually unset, and the check-in failed with a UUID parse error
/// rather than a question. A location is a property of the check-in, not of the machine typing
/// it, so it is asked for here.
void showCheckInDialog(BuildContext context, WidgetRef ref, {required String memberId, required String memberName}) {
  PopupDialog.info(
    title: 'Check In — $memberName',
    message: _CheckInLocations(memberId: memberId, memberName: memberName),
    actions: [
      Builder(
        builder: (context) => TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
      ),
    ],
  ).show(context);
}

/// Confirms a checkout. No location is asked for: the open visit already knows its session.
void showCheckOutDialog(
  BuildContext context,
  WidgetRef ref, {
  required String memberId,
  required String memberName,
  required String whereLabel,
}) {
  PopupDialog.warn(
    title: 'Check Out — $memberName',
    message: Text('Check $memberName out of $whereLabel?'),
    actions: [
      Builder(
        builder: (context) => Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () async {
                // The dialog closes first, so the result has to be reported through a context that
                // outlives it — this one is defunct the moment the route is gone.
                final host = Navigator.of(context).context;
                Navigator.of(context).pop();
                // Null location: the server closes whichever session the member is in.
                final result = await ref.read(sessionCheckInOutProvider.notifier).adminCheckInOut(memberId, null);
                if (!host.mounted) return;
                switch (result) {
                  case ApiSuccess():
                    SnackBarDialog.success(message: '$memberName checked out').show(host);
                  case ApiFailure(userMessage: final msg):
                    SnackBarDialog.error(message: msg).show(host);
                }
              },
              child: const Text('Check Out'),
            ),
          ],
        ),
      ),
    ],
  ).show(context);
}

/// One row per location, each saying which session a check-in there would join.
///
/// Locations with nothing running are listed but disabled, because "there is no session at the
/// Machine Shop right now" is the answer to the admin's question — hiding them would make the
/// list look incomplete instead.
class _CheckInLocations extends ConsumerWidget {
  final String memberId;
  final String memberName;

  const _CheckInLocations({required this.memberId, required this.memberName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(locationsSyncProvider);
    ref.watch(sessionsSyncProvider);
    final locations = ref.watch(locationsProvider);
    final sessions = ref.watch(sessionsProvider);
    final settings = ref.watch(settingsQueryProvider).value;
    final theme = Theme.of(context);

    // Falls back to the server's own default (4h) when settings have not arrived yet, so the
    // list is never wrong in the direction of hiding a session that would in fact accept a scan.
    final window = Duration(seconds: settings?.checkInWindowSecs ?? 4 * 3600);

    final options =
        locations.entries
            .map(
              (entry) => (
                id: entry.key,
                name: entry.value.location,
                session: eligibleSessionAt(locationId: entry.key, sessions: sessions, checkInWindow: window),
              ),
            )
            .toList()
          // Locations that can actually take a check-in first, then alphabetical: the admin is
          // almost always aiming at one of the former.
          ..sort((a, b) {
            if ((a.session != null) != (b.session != null)) return a.session != null ? -1 : 1;
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });

    if (locations.isEmpty) {
      return const SizedBox(
        width: 420,
        child: Text('No locations exist yet. Add one under Locations before checking anybody in.'),
      );
    }

    final anyOpen = options.any((o) => o.session != null);

    return SizedBox(
      width: 460,
      height: 360,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            anyOpen
                ? 'Where is $memberName checking in?'
                : 'No session is running at any location right now, so there is nothing to '
                      'check into. Sessions accept check-ins from ${formatDuration(window)} before '
                      'they start until ${formatDuration(window)} after they end.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: options.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final option = options[i];
                final session = option.session?.value;

                return ListTile(
                  enabled: session != null,
                  leading: Icon(
                    session != null ? Icons.place : Icons.place_outlined,
                    color: session != null ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  ),
                  title: Text(option.name),
                  subtitle: Text(session == null ? 'No session right now' : _sessionLabel(session)),
                  trailing: session == null ? null : const Icon(Icons.login, size: 18),
                  onTap: session == null ? null : () => _checkIn(context, ref, option.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// "today, 6:00 PM – 9:00 PM", or the weekday/date when it is not today.
  static String _sessionLabel(Session session) {
    return '${formatRelativeDay(session.startTime)}, '
        '${formatTime(session.startTime)} – ${formatTime(session.endTime)}';
  }

  Future<void> _checkIn(BuildContext context, WidgetRef ref, String locationId) async {
    // Reported through the navigator's context, which survives the dialog being popped below.
    final host = Navigator.of(context).context;
    Navigator.of(context).pop();

    final result = await ref.read(sessionCheckInOutProvider.notifier).adminCheckInOut(memberId, locationId);
    if (!host.mounted) return;
    switch (result) {
      case ApiSuccess():
        SnackBarDialog.success(message: '$memberName checked in').show(host);
      case ApiFailure(userMessage: final msg):
        SnackBarDialog.error(message: msg).show(host);
    }
  }
}
