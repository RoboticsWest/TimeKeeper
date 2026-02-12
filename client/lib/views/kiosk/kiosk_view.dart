import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:time_keeper/generated/common/common.pbenum.dart';
import 'package:time_keeper/providers/auth_provider.dart';
import 'package:time_keeper/utils/permissions.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/utils/pcsc_scanner.dart';
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

    // PCSC RFID reader - only active when user has KIOSK permission
    final contextRef = useRef<BuildContext?>(null);
    final refRef = useRef<WidgetRef?>(null);
    contextRef.value = context;
    refRef.value = ref;

    useEffect(() {
      if (!hasKiosk) return null;

      final scanner = PcscScanner(
        onScan: (uid) {
          _log.i('PCSC card UID: $uid');
          final ctx = contextRef.value;
          final r = refRef.value;
          if (ctx != null && ctx.mounted && r != null) {
            handleKioskScan(input: uid, context: ctx, ref: r);
          }
        },
        onError: (message) {
          final ctx = contextRef.value;
          if (ctx != null && ctx.mounted) {
            ToastOverlay.error(ctx, title: 'Scan Error', message: message);
          }
        },
      );

      scanner.start();

      return () {
        scanner.dispose();
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
