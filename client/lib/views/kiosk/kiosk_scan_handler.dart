import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:time_keeper/generated/api/api.pbgrpc.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/helpers/grpc_call_wrapper.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/utils/grpc_result.dart';
import 'package:time_keeper/widgets/dialogs/toast_overlay.dart';

final _log = Logger();

/// Handles an RFID scan input by matching it against team members
/// and checking them in/out.
Future<void> handleKioskScan({
  required String input,
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final trimmed = input.trim().toLowerCase();
  if (trimmed.isEmpty) return;

  final teamMembers = ref.read(teamMembersProvider);
  final match = _findMember(trimmed, teamMembers);

  if (match == null) {
    _log.w('No member matched scan: $input');
    if (context.mounted) {
      ToastOverlay.error(
        context,
        title: 'Unrecognized',
        message: 'Unrecognized value "$input", contact admin.',
      );
    }
    return;
  }

  final memberId = match.key;
  final member = match.value;
  final alias = member.alias.isNotEmpty ? ' (${member.alias})' : '';
  final name = '${member.firstName} ${member.lastName}$alias';

  _log.i('Scan matched member: $name');

  final currentLocation = ref.read(currentLocationProvider) ?? '';
  final result = await callGrpcEndpoint(
    () => ref
        .read(sessionServiceProvider)
        .checkInOut(
          CheckInOutRequest(
            teamMemberId: memberId,
            location: Location(location: currentLocation),
          ),
        ),
  );

  if (!context.mounted) return;

  final now = DateTime.now();
  final timeStr = formatTime(now);

  switch (result) {
    case GrpcSuccess(data: final response):
      if (response.checkedIn) {
        ToastOverlay.success(
          context,
          title: 'Checked In',
          message: '$name\n$timeStr',
        );
      } else {
        ToastOverlay.warn(
          context,
          title: 'Checked Out',
          message: '$name\n$timeStr',
        );
      }
    case GrpcFailure(userMessage: final msg):
      ToastOverlay.error(
        context,
        title: 'Check In Failed',
        message: 'Failed for $name: $msg',
      );
  }
}

/// Tries to match scan input against team member fields.
/// Checks in order: first+last name, alias, secondary alias.
MapEntry<String, TeamMember>? _findMember(
  String input,
  Map<String, TeamMember> teamMembers,
) {
  for (final entry in teamMembers.entries) {
    final member = entry.value;
    final fullName = '${member.firstName} ${member.lastName}'
        .trim()
        .toLowerCase();

    if (fullName == input) return entry;
  }

  for (final entry in teamMembers.entries) {
    final member = entry.value;

    if (member.alias.isNotEmpty && member.alias.trim().toLowerCase() == input) {
      return entry;
    }

    if (member.secondaryAlias.isNotEmpty &&
        member.secondaryAlias.trim().toLowerCase() == input) {
      return entry;
    }
  }

  return null;
}
