import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:time_keeper/providers/auth_provider.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/settings_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/providers/team_member_session_provider.dart';
import 'package:time_keeper/hooks/use_rfid_scanner.dart';
import 'package:time_keeper/views/kiosk/checked_in_list.dart';
import 'package:time_keeper/views/kiosk/kiosk_dialog.dart';
import 'package:time_keeper/views/kiosk/kiosk_scan_handler.dart';
import 'package:time_keeper/views/kiosk/session_info_bar.dart';
import 'package:time_keeper/widgets/dialogs/toast_overlay.dart';
import 'package:time_keeper/providers/rfid_suppression_provider.dart';
import 'package:time_keeper/views/kiosk/pin_entry_dialog.dart';

final _log = Logger();

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(sessionsSyncProvider);
    ref.watch(locationsSyncProvider);
    ref.watch(teamMembersSyncProvider);
    ref.watch(teamMemberSessionsSyncProvider);
    final sessionList = ref.watch(sessionsProvider);
    final deviceLocationId = ref.watch(currentLocationProvider);
    final locations = ref.watch(locationsProvider);
    final teamMembers = ref.watch(teamMembersProvider);
    final teamMemberSessions = ref.watch(teamMemberSessionsProvider);
    final thresholdDuration = useState<Duration>(Duration.zero);
    final isUpcoming = useState(false);

    // filter unfinished sessions sorted by start time
    final unfinishedSessions =
        sessionList.values
            .where(
              (session) =>
                  !session.finished &&
                  (deviceLocationId == null || session.locationId == deviceLocationId),
            )
            .toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final currentSession = unfinishedSessions.isNotEmpty
        ? unfinishedSessions.first
        : null;
    final nextSession = unfinishedSessions.length > 1
        ? unfinishedSessions[1]
        : null;

    // Count members checked into the current session
    final currentSessionId = currentSession != null
        ? sessionList.entries
              .where((e) => e.value == currentSession)
              .map((e) => e.key)
              .firstOrNull
        : null;

    final checkedInCount = currentSessionId != null
        ? teamMemberSessions.values
              .where((ms) => ms.sessionId == currentSessionId && ms.checkOutTime == null)
              .length
        : 0;

    final hasKiosk = ref.watch(hasAnyPermissionProvider);
    final quickPinEnabled =
        ref.watch(settingsQueryProvider).value?.quickPinEnabled ?? false;

    // The PIN pad accumulates digits terminated by Enter, which is exactly what
    // the keyboard-wedge reader emits - so the scanner stands down while it's open.
    final scannerSuppressed = ref.watch(rfidScannerSuppressedProvider);

    // RFID scanning (PCSC + keyboard) - only active when user has KIOSK permission
    useRfidScanner(
      enabled: hasKiosk && !scannerSuppressed,
      onScan: (uid) {
        _log.i('RFID scan: $uid');
        if (context.mounted) {
          handleKioskScan(input: uid, context: context, ref: ref);
        }
      },
      onError: (message) {
        if (context.mounted) {
          ToastOverlay.error(context, title: 'Scan Error', message: message);
        }
      },
    );

    useEffect(() {
      Future<void> loadSettings() async {
        final settings = await ref.read(settingsQueryProvider.future);
        if (settings != null) {
          thresholdDuration.value = Duration(seconds: settings.nextSessionThresholdSecs);
        }
      }

      loadSettings();
      return null;
    }, []); // ← once on mount

    useEffect(() {
      if (currentSession == null) {
        isUpcoming.value = false;
        return null;
      }

      final now = DateTime.now();
      final sessionStart = currentSession.startTime;

      final thresholdTime = sessionStart.subtract(thresholdDuration.value);

      final shouldBeUpcoming = now.isBefore(thresholdTime);

      isUpcoming.value = shouldBeUpcoming;

      // If we are still before threshold, schedule when it flips
      if (shouldBeUpcoming) {
        final triggerIn = thresholdTime.difference(now);

        final timer = Timer(triggerIn, () {
          isUpcoming.value = false;
        });

        return timer.cancel;
      }

      return null;
    }, [currentSession, thresholdDuration.value]);

    return Column(
      children: [
        if (hasKiosk || quickPinEnabled)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
            child: Align(
              alignment: Alignment.center,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  if (hasKiosk)
                    FilledButton.icon(
                      icon: const Icon(Icons.how_to_reg),
                      label: const Text('Kiosk Check In / Out'),
                      onPressed: () {
                        KioskDialog(sessions: unfinishedSessions).show(context);
                      },
                    ),
                  // Deliberately not gated on permissions: letting a member
                  // without a card sign themselves in is the whole point.
                  if (quickPinEnabled)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.dialpad),
                      label: const Text('Sign In With PIN'),
                      onPressed: () => PinEntryDialog.show(context),
                    ),
                ],
              ),
            ),
          ),
        SessionInfoBar(
          currentSession: currentSession,
          isUpcoming: isUpcoming.value,
          nextSession: nextSession,
          locations: locations,
          deviceLocationName: deviceLocationId != null
              ? locations[deviceLocationId]?.location
              : null,
          checkedInCount: checkedInCount,
          totalMembers: teamMembers.length,
        ),
        Expanded(child: CheckedInList()),
      ],
    );
  }
}
