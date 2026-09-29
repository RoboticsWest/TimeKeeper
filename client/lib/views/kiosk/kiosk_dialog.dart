import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/session.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/utils/api_result.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/providers/open_attendance_provider.dart';
import 'package:time_keeper/helpers/session_helper.dart';
import 'package:time_keeper/views/kiosk/kiosk_scan_handler.dart' show kNoDeviceLocationMessage;
import 'package:time_keeper/widgets/dialogs/base_dialog.dart';
import 'package:time_keeper/widgets/dialogs/popup_dialog.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';
import 'package:time_keeper/widgets/member_search_list.dart';

class KioskDialog extends BaseDialog {
  final List<Session> sessions;

  KioskDialog({required this.sessions});

  @override
  void show(BuildContext context) {
    PopupDialog.info(
      title: 'Kiosk Check In / Out',
      message: _KioskDialogContent(sessions: sessions),
      actions: [
        Builder(
          builder: (context) => TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        ),
      ],
    ).show(context);
  }
}

class _KioskDialogContent extends ConsumerWidget {
  final List<Session> sessions;

  const _KioskDialogContent({required this.sessions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamMembers = ref.watch(teamMembersProvider);
    final openVisits = ref.watch(openAttendanceProvider);
    final currentLocation = ref.watch(currentLocationProvider);

    return SizedBox(
      width: 400,
      height: 350,
      child: MemberSearchList(
        teamMembers: teamMembers,
        trailingBuilder: (memberId, member) {
          final checkedIn = isMemberCheckedIn(memberId, openVisits.values);

          return FilledButton.icon(
            icon: Icon(checkedIn ? Icons.logout : Icons.login, color: Colors.white),
            label: Text(checkedIn ? 'Check Out' : 'Check In', style: const TextStyle(color: Colors.white)),
            style: FilledButton.styleFrom(
              backgroundColor: checkedIn ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
            ),
            onPressed: () async {
              // Checking out needs no location — the open visit knows its session. Checking in
              // does, and this kiosk's is a device setting: without it the mutation used to be
              // sent an empty string and come back as a UUID parse error.
              if (!checkedIn && (currentLocation == null || currentLocation.isEmpty)) {
                SnackBarDialog.error(message: kNoDeviceLocationMessage).show(context);
                return;
              }

              final name = member.displayLabel;
              // The navigator's context outlives the dialog route, so the outcome can still be
              // reported once the dialog has been popped.
              final host = Navigator.of(context).context;
              final result = await ref
                  .read(sessionCheckInOutProvider.notifier)
                  .checkInOut(memberId, checkedIn ? null : currentLocation);
              if (context.mounted) Navigator.of(context).pop();
              if (!host.mounted) return;
              switch (result) {
                case ApiSuccess():
                  SnackBarDialog.success(message: checkedIn ? '$name checked out' : '$name checked in').show(host);
                case ApiFailure(userMessage: final msg):
                  SnackBarDialog.error(message: msg).show(host);
              }
            },
          );
        },
      ),
    );
  }
}
