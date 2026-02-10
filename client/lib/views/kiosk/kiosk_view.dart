import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:time_keeper/generated/common/common.pbenum.dart';
import 'package:time_keeper/providers/auth_provider.dart';
import 'package:time_keeper/utils/permissions.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/utils/rfid_scanner.dart';
import 'package:time_keeper/utils/time.dart';
import 'package:time_keeper/views/kiosk/checked_in_list.dart';
import 'package:time_keeper/views/kiosk/kiosk_dialog.dart';
import 'package:time_keeper/views/kiosk/kiosk_scan_handler.dart';
import 'package:time_keeper/views/kiosk/session_info_bar.dart';

final _log = Logger();

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionList = ref.watch(sessionsProvider);

    // filter unfinished sessions sorted by start time
    final unfinishedSessions =
        sessionList.values
            .where((session) => !session.finished && session.hasStartTime())
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

    // RFID keyboard listener - only active when user has KIOSK permission
    final scanBuffer = useRef<RfidScanBuffer?>(null);
    final contextRef = useRef<BuildContext?>(null);
    final refRef = useRef<WidgetRef?>(null);
    contextRef.value = context;
    refRef.value = ref;

    useEffect(() {
      if (!hasKiosk) return null;

      final buffer = RfidScanBuffer(
        onScan: (input) {
          _log.i('RFID scan input: $input');
          final ctx = contextRef.value;
          final r = refRef.value;
          if (ctx != null && ctx.mounted && r != null) {
            handleKioskScan(input: input, context: ctx, ref: r);
          }
        },
      );
      scanBuffer.value = buffer;

      HardwareKeyboard.instance.addHandler(buffer.handleKeyEvent);

      return () {
        HardwareKeyboard.instance.removeHandler(buffer.handleKeyEvent);
        buffer.dispose();
        scanBuffer.value = null;
      };
    }, [hasKiosk]);

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
        ),
        Expanded(child: CheckedInList(sessions: unfinishedSessions)),
      ],
    );
  }
}
