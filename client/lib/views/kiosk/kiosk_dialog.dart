import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/generated/api/api.pbgrpc.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/helpers/grpc_call_wrapper.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/utils/grpc_result.dart';
import 'package:time_keeper/widgets/dialogs/base_dialog.dart';
import 'package:time_keeper/widgets/dialogs/popup_dialog.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';

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

class _KioskDialogContent extends HookConsumerWidget {
  final List<Session> sessions;

  const _KioskDialogContent({required this.sessions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchText = useState('');
    final teamMembers = ref.watch(teamMembersProvider);
    final currentLocation = ref.watch(currentLocationProvider) ?? '';

    Future<GrpcResult<CheckInOutResponse>> checkMemberInOut(
      String teamMemberId,
    ) async {
      final req = CheckInOutRequest(
        teamMemberId: teamMemberId,
        location: Location(location: currentLocation),
      );
      return await callGrpcEndpoint(
        () => ref.read(sessionServiceProvider).checkInOut(req),
      );
    }

    final filteredMembers = searchText.value.isEmpty
        ? <MapEntry<String, TeamMember>>[]
        : teamMembers.entries.where((entry) {
            final member = entry.value;
            final query = searchText.value.toLowerCase();
            return member.firstName.toLowerCase().contains(query) ||
                member.lastName.toLowerCase().contains(query) ||
                member.alias.toLowerCase().contains(query) ||
                member.secondaryAlias.toLowerCase().contains(query);
          }).toList();

    bool isCheckedIn(String memberId) {
      for (final session in sessions) {
        for (final ms in session.memberSessions) {
          if (ms.teamMemberId == memberId &&
              ms.hasCheckInTime() &&
              !ms.hasCheckOutTime()) {
            return true;
          }
        }
      }
      return false;
    }

    Widget membersList() {
      if (filteredMembers.isEmpty) {
        return Center(
          child: Text(
            searchText.value.isEmpty
                ? 'Type to search for a team member'
                : 'No members found',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        );
      } else {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: filteredMembers.length,
          itemBuilder: (context, index) {
            final entry = filteredMembers[index];
            final member = entry.value;
            final memberId = entry.key;
            final checkedIn = isCheckedIn(memberId);
            final alias = member.alias.isNotEmpty ? ' (${member.alias})' : '';

            return ListTile(
              title: Text('${member.firstName} ${member.lastName}$alias'),
              subtitle: Text(member.memberType.name),
              trailing: FilledButton.icon(
                icon: Icon(
                  checkedIn ? Icons.logout : Icons.login,
                  color: Colors.white,
                ),
                label: Text(
                  checkedIn ? 'Check Out' : 'Check In',
                  style: TextStyle(color: Colors.white),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: checkedIn
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                ),
                onPressed: () async {
                  var future = SnackBarDialog.fromGrpcStatus(
                    result: await checkMemberInOut(memberId),
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    future.show(context);
                  }
                },
              ),
            );
          },
        );
      }
    }

    return SizedBox(
      width: 400,
      height: 350,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: searchController,
            autofocus: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Search by name or alias...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => searchText.value = value,
          ),
          const SizedBox(height: 12),
          Expanded(child: membersList()),
        ],
      ),
    );
  }
}
