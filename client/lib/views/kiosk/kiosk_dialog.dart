import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/session.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/utils/api_result.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/providers/team_member_session_provider.dart';
import 'package:time_keeper/helpers/session_helper.dart';
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
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
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
    final teamMemberSessions = ref.watch(teamMemberSessionsProvider);
    final currentLocation = ref.watch(currentLocationProvider) ?? '';

    return SizedBox(
      width: 400,
      height: 350,
      child: MemberSearchList(
        teamMembers: teamMembers,
        trailingBuilder: (memberId, member) {
          final checkedIn = isMemberCheckedIn(
            memberId,
            teamMemberSessions.values,
          );

          return FilledButton.icon(
            icon: Icon(
              checkedIn ? Icons.logout : Icons.login,
              color: Colors.white,
            ),
            label: Text(
              checkedIn ? 'Check Out' : 'Check In',
              style: const TextStyle(color: Colors.white),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: checkedIn
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            ),
            onPressed: () async {
              final result = await ref
                  .read(sessionCheckInOutProvider.notifier)
                  .checkInOut(memberId, currentLocation);
              if (context.mounted) {
                Navigator.of(context).pop();
                switch (result) {
                  case ApiSuccess():
                    SnackBarDialog.success(message: 'Success').show(context);
                  case ApiFailure(userMessage: final msg):
                    SnackBarDialog.error(message: msg).show(context);
                }
              }
            },
          );
        },
      ),
    );
  }
}
