import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:time_keeper/generated/api/settings.pbgrpc.dart';
import 'package:time_keeper/generated/common/common.pbenum.dart';
import 'package:time_keeper/helpers/grpc_call_wrapper.dart';
import 'package:time_keeper/providers/auth_provider.dart';
import 'package:time_keeper/providers/settings_provider.dart';
import 'package:time_keeper/utils/grpc_result.dart';
import 'package:time_keeper/utils/permissions.dart';
import 'package:time_keeper/providers/entity_sync_provider.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/providers/team_member_session_provider.dart';
import 'package:time_keeper/hooks/use_rfid_scanner.dart';
import 'package:time_keeper/utils/time.dart';
import 'package:time_keeper/views/kiosk/checked_in_list.dart';
import 'package:time_keeper/views/kiosk/kiosk_dialog.dart';
import 'package:time_keeper/views/kiosk/kiosk_scan_handler.dart';
import 'package:time_keeper/views/kiosk/session_info_bar.dart';
import 'package:time_keeper/widgets/dialogs/toast_overlay.dart';

final _log = Logger();

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(entitySyncProvider);
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
                  session.hasStartTime() &&
                  (deviceLocationId == null ||
                      session.locationId == deviceLocationId),
            )
            .toList()
          ..sort(
            (a, b) =>
                a.startTime.toDateTime().compareTo(b.startTime.toDateTime()),
          );

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
              .where(
                (ms) =>
                    ms.sessionId == currentSessionId &&
                    ms.hasCheckInTime() &&
                    !ms.hasCheckOutTime(),
              )
              .length
        : 0;

    final roles = ref.watch(rolesProvider);
    final hasKiosk = roles.any((role) => role.hasPermission(Role.KIOSK));

    // RFID scanning (PCSC + keyboard) - only active when user has KIOSK permission
    useRfidScanner(
      enabled: hasKiosk,
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
        final result = await callGrpcEndpoint(
          () => ref
              .read(settingsServiceProvider)
              .getSettings(GetSettingsRequest()),
        );

        if (result is GrpcSuccess<GetSettingsResponse>) {
          final s = result.data.settings;
          thresholdDuration.value = Duration(
            seconds: s.nextSessionThresholdSecs.toInt(),
          );
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
      final sessionStart = currentSession.startTime.toDateTime();

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
        if (hasKiosk)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
            child: Align(
              alignment: Alignment.center,
              child: FilledButton.icon(
                icon: const Icon(Icons.how_to_reg, color: Colors.white),
                label: const Text(
                  'Kiosk Check In / Out',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  KioskDialog(sessions: unfinishedSessions).show(context);
                },
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
