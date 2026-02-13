import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:time_keeper/generated/common/common.pbenum.dart';
import 'package:time_keeper/providers/auth_provider.dart';
import 'package:time_keeper/utils/permissions.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
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
    final sessionList = ref.watch(sessionsProvider);
    final deviceLocationId = ref.watch(currentLocationProvider);
    final locations = ref.watch(locationsProvider);

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
          nextSession: nextSession,
          locations: locations,
          deviceLocationName: deviceLocationId != null
              ? locations[deviceLocationId]?.location
              : null,
        ),
        Expanded(child: CheckedInList()),
      ],
    );
  }
}
