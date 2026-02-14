import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/rfid_tag_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/providers/team_member_session_provider.dart';
import 'package:time_keeper/utils/csv_utils.dart';
import 'package:time_keeper/utils/time.dart';
import 'package:time_keeper/views/setup/common/setting_row.dart';
import 'package:time_keeper/views/setup/common/settings_page_layout.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';

class DataSetupTab extends ConsumerWidget {
  const DataSetupTab({super.key});

  List<List<String>> _buildMemberRows(
    Map<String, TeamMember> members,
    Map<String, RfidTag> allTags,
    TeamMemberType type,
  ) {
    final filtered =
        members.entries.where((e) => e.value.memberType == type).toList()
          ..sort((a, b) {
            final lastCmp = a.value.lastName.compareTo(b.value.lastName);
            if (lastCmp != 0) return lastCmp;
            return a.value.firstName.compareTo(b.value.firstName);
          });

    return filtered.map((entry) {
      final m = entry.value;
      final tags = allTags.values
          .where((t) => t.teamMemberId == entry.key)
          .map((t) => t.tag)
          .join(';');
      return [m.firstName, m.lastName, m.displayName, tags, m.discordUsername];
    }).toList();
  }

  Future<void> _exportMembers(
    BuildContext context,
    Map<String, TeamMember> members,
    Map<String, RfidTag> allTags,
    TeamMemberType type,
  ) async {
    final label = type == TeamMemberType.STUDENT ? 'students' : 'mentors';
    final rows = _buildMemberRows(members, allTags, type);

    if (rows.isEmpty) {
      if (context.mounted) {
        SnackBarDialog.info(message: 'No $label to export').show(context);
      }
      return;
    }

    final headers = [
      'FIRST_NAME',
      'LAST_NAME',
      'DISPLAY_NAME',
      'RFID_TAG',
      'DISCORD_USERNAME',
    ];
    final csv = buildCsv(headers, rows);
    final saved = await saveCsvFile(csv, '$label.csv');

    if (context.mounted) {
      if (saved) {
        SnackBarDialog.info(
          message: 'Exported ${rows.length} $label',
        ).show(context);
      }
    }
  }

  Future<void> _exportSchedule(
    BuildContext context,
    Map<String, Session> sessions,
    Map<String, Location> locations,
  ) async {
    if (sessions.isEmpty) {
      if (context.mounted) {
        SnackBarDialog.info(message: 'No sessions to export').show(context);
      }
      return;
    }

    final sorted = sessions.entries.toList()
      ..sort((a, b) {
        final aTime = a.value.hasStartTime()
            ? a.value.startTime.seconds.toInt()
            : 0;
        final bTime = b.value.hasStartTime()
            ? b.value.startTime.seconds.toInt()
            : 0;
        return aTime.compareTo(bTime);
      });

    final headers = ['LOCATION', 'START_DATE_TIME', 'END_DATE_TIME'];
    final rows = sorted.map((entry) {
      final s = entry.value;
      final locationName = locations[s.locationId]?.location ?? 'Unknown';
      final startStr = s.hasStartTime()
          ? formatRfc3339(s.startTime.toDateTime())
          : '';
      final endStr = s.hasEndTime()
          ? formatRfc3339(s.endTime.toDateTime())
          : '';
      return [locationName, startStr, endStr];
    }).toList();

    final csv = buildCsv(headers, rows);
    final saved = await saveCsvFile(csv, 'schedule.csv');

    if (context.mounted && saved) {
      SnackBarDialog.info(
        message: 'Exported ${rows.length} sessions',
      ).show(context);
    }
  }

  Future<void> _exportAttendance(
    BuildContext context,
    Map<String, TeamMemberSession> teamMemberSessions,
    Map<String, TeamMember> teamMembers,
    Map<String, Session> sessions,
    Map<String, Location> locations,
  ) async {
    if (teamMemberSessions.isEmpty) {
      if (context.mounted) {
        SnackBarDialog.info(
          message: 'No attendance records to export',
        ).show(context);
      }
      return;
    }

    final sorted = teamMemberSessions.entries.toList()
      ..sort((a, b) {
        final aTime = a.value.hasCheckInTime()
            ? a.value.checkInTime.seconds.toInt()
            : 0;
        final bTime = b.value.hasCheckInTime()
            ? b.value.checkInTime.seconds.toInt()
            : 0;
        return aTime.compareTo(bTime);
      });

    final headers = [
      'FIRST_NAME',
      'LAST_NAME',
      'LOCATION',
      'CHECK_IN_TIME',
      'CHECK_OUT_TIME',
    ];
    final rows = sorted.map((entry) {
      final ms = entry.value;
      final member = teamMembers[ms.teamMemberId];
      final session = sessions[ms.sessionId];
      final location = session != null ? locations[session.locationId] : null;

      return [
        member?.firstName ?? '',
        member?.lastName ?? '',
        location?.location ?? '',
        ms.hasCheckInTime() ? formatRfc3339(ms.checkInTime.toDateTime()) : '',
        ms.hasCheckOutTime() ? formatRfc3339(ms.checkOutTime.toDateTime()) : '',
      ];
    }).toList();

    final csv = buildCsv(headers, rows);
    final saved = await saveCsvFile(csv, 'attendance.csv');

    if (context.mounted && saved) {
      SnackBarDialog.info(
        message: 'Exported ${rows.length} attendance records',
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamMembers = ref.watch(teamMembersProvider);
    final rfidTags = ref.watch(rfidTagsProvider);
    final sessions = ref.watch(sessionsProvider);
    final locations = ref.watch(locationsProvider);
    final teamMemberSessions = ref.watch(teamMemberSessionsProvider);

    final studentCount = teamMembers.values
        .where((m) => m.memberType == TeamMemberType.STUDENT)
        .length;
    final mentorCount = teamMembers.values
        .where((m) => m.memberType == TeamMemberType.MENTOR)
        .length;

    return SettingsPageLayout(
      title: 'Data',
      subtitle: 'Export and import data for backup and migration',
      children: [
        // --- Export Section ---
        Text('Export', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),

        SettingRow(
          label: 'Export Students',
          description: '$studentCount students available to export',
          child: FilledButton.icon(
            onPressed: () => _exportMembers(
              context,
              teamMembers,
              rfidTags,
              TeamMemberType.STUDENT,
            ),
            icon: const Icon(Icons.download),
            label: const Text('Export CSV'),
          ),
        ),
        const SizedBox(height: 24),

        SettingRow(
          label: 'Export Mentors',
          description: '$mentorCount mentors available to export',
          child: FilledButton.icon(
            onPressed: () => _exportMembers(
              context,
              teamMembers,
              rfidTags,
              TeamMemberType.MENTOR,
            ),
            icon: const Icon(Icons.download),
            label: const Text('Export CSV'),
          ),
        ),
        const SizedBox(height: 24),

        SettingRow(
          label: 'Export Schedule',
          description: '${sessions.length} sessions available to export',
          child: FilledButton.icon(
            onPressed: () => _exportSchedule(context, sessions, locations),
            icon: const Icon(Icons.download),
            label: const Text('Export CSV'),
          ),
        ),
        const SizedBox(height: 24),

        SettingRow(
          label: 'Export Attendance',
          description:
              '${teamMemberSessions.length} attendance records available to export',
          child: FilledButton.icon(
            onPressed: () => _exportAttendance(
              context,
              teamMemberSessions,
              teamMembers,
              sessions,
              locations,
            ),
            icon: const Icon(Icons.download),
            label: const Text('Export CSV'),
          ),
        ),
      ],
    );
  }
}
