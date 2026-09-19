import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/team_member.dart';
import 'package:time_keeper/providers/settings_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/providers/team_member_session_provider.dart';
import 'package:time_keeper/utils/api_result.dart';
import 'package:time_keeper/views/setup/common/file_upload_setting.dart';
import 'package:time_keeper/views/setup/common/setting_row.dart';
import 'package:time_keeper/views/setup/common/settings_page_layout.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';
import 'package:time_keeper/widgets/dialogs/popup_dialog.dart';
import 'package:time_keeper/views/setup/common/switch_setting.dart';

class MemberSetupTab extends HookConsumerWidget {
  const MemberSetupTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showOvertime = useState(true);
    final quickPinEnabled = useState(false);
    final selectedMemberTypes = useState<Set<TeamMemberType>>(Set.from(TeamMemberType.values));

    // Load current settings on mount
    useEffect(() {
      Future<void> loadSettings() async {
        final s = await ref.read(settingsQueryProvider.future);
        if (s != null) {
          showOvertime.value = s.leaderboardShowOvertime;
          quickPinEnabled.value = s.quickPinEnabled;
          if (s.leaderboardMemberTypes.isNotEmpty) {
            selectedMemberTypes.value = s.leaderboardMemberTypes.map(TeamMemberType.fromJson).toSet();
          }
        }
      }

      loadSettings();
      return null;
    }, const []);

    Future<void> updateLeaderboardSettings() async {
      final res = await ref
          .read(settingsServiceProvider.notifier)
          .updateLeaderboard(
            showOvertime: showOvertime.value,
            memberTypes: selectedMemberTypes.value.map((t) => t.toJson()).toList(),
          );

      if (context.mounted) {
        PopupDialog.fromApiResult(result: res).show(context);
      }
    }

    Future<ApiCallResult> uploadStudentCsv(Uint8List bytes) {
      return ref.read(teamMembersProvider.notifier).uploadStudentCsv(utf8.decode(bytes));
    }

    Future<ApiCallResult> uploadMentorCsv(Uint8List bytes) {
      return ref.read(teamMembersProvider.notifier).uploadMentorCsv(utf8.decode(bytes));
    }

    String memberTypeName(TeamMemberType type) {
      switch (type) {
        case TeamMemberType.student:
          return 'Students';
        case TeamMemberType.mentor:
          return 'Mentors';
      }
    }

    return SettingsPageLayout(
      title: 'Team Member Setup',
      subtitle: 'Configure your team settings',
      children: [
        SwitchSetting(
          label: 'Quick PIN Sign-In',
          description:
              'Show a PIN keypad on the kiosk so members without an RFID card can '
              'sign themselves in and out. Set each member\'s PIN from the Team page.',
          value: quickPinEnabled.value,
          onChanged: (enabled) async {
            quickPinEnabled.value = enabled;
            final res = await ref.read(settingsServiceProvider.notifier).updateGeneral(quickPinEnabled: enabled);
            if (!res.success) {
              quickPinEnabled.value = !enabled;
              if (context.mounted) {
                PopupDialog.fromApiResult(result: res).show(context);
              }
            }
          },
        ),
        const SizedBox(height: 24),
        FileUploadSetting(
          label: 'Upload Student CSV',
          description: 'Upload a CSV file containing the student data',
          allowedExtensions: ['csv'],
          uploadButtonLabel: 'Upload',
          onUpload: (file) async {
            if (file.bytes != null) {
              ConfirmDialog.warn(
                title: 'Confirm Upload',
                message: const Text('Uploading students can have impacts on existing data integrity'),
                onConfirmAsyncApi: () async {
                  return await uploadStudentCsv(file.bytes!);
                },
                showResultDialog: true,
                successMessage: const Text('Students uploaded successfully!'),
              ).show(context);
            }
          },
        ),
        const SizedBox(height: 24),
        FileUploadSetting(
          label: 'Upload Mentor CSV',
          description: 'Upload a CSV file containing the mentor data',
          allowedExtensions: ['csv'],
          uploadButtonLabel: 'Upload',
          onUpload: (file) async {
            if (file.bytes != null) {
              ConfirmDialog.warn(
                title: 'Confirm Upload',
                message: const Text('Uploading mentors can have impacts on existing data integrity'),
                onConfirmAsyncApi: () async {
                  return await uploadMentorCsv(file.bytes!);
                },
                showResultDialog: true,
                successMessage: const Text('Mentors uploaded successfully!'),
              ).show(context);
            }
          },
        ),
        const SizedBox(height: 24),
        FileUploadSetting(
          label: 'Import Attendance',
          description:
              'Upload a CSV file containing attendance records '
              '(FIRST_NAME, LAST_NAME, LOCATION, CHECK_IN_TIME, CHECK_OUT_TIME)',
          allowedExtensions: ['csv'],
          uploadButtonLabel: 'Import',
          onUpload: (file) async {
            if (file.bytes != null) {
              ConfirmDialog.warn(
                title: 'Confirm Import',
                message: const Text(
                  'Importing attendance can have impacts on existing data integrity. '
                  'Duplicate records (same member + session) will be skipped.',
                ),
                onConfirmAsyncApi: () async {
                  return await ref
                      .read(teamMemberSessionsProvider.notifier)
                      .importAttendanceCsv(utf8.decode(file.bytes!));
                },
                showResultDialog: true,
                successMessage: const Text('Attendance imported successfully!'),
              ).show(context);
            }
          },
        ),
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),
        Text('Leaderboard Configuration', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'Configure how the leaderboard calculates and displays member rankings. '
          'These settings also apply to the Discord !leaderboard command.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        SettingRow(
          label: 'Show Overtime Separately',
          description:
              'When enabled, overtime is displayed as a separate value on the leaderboard. '
              'When disabled, overtime is combined into the total hours.',
          child: Row(
            children: [
              Switch(value: showOvertime.value, onChanged: (value) => showOvertime.value = value),
              const SizedBox(width: 8),
              Text(showOvertime.value ? 'Enabled' : 'Disabled'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SettingRow(
          label: 'Member Types on Leaderboard',
          description: 'Select which member types appear on the leaderboard',
          child: Wrap(
            spacing: 8,
            children: TeamMemberType.values.map((type) {
              final isSelected = selectedMemberTypes.value.contains(type);
              return FilterChip(
                label: Text(memberTypeName(type)),
                selected: isSelected,
                onSelected: (selected) {
                  final updated = Set<TeamMemberType>.from(selectedMemberTypes.value);
                  if (selected) {
                    updated.add(type);
                  } else {
                    updated.remove(type);
                  }
                  selectedMemberTypes.value = updated;
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: updateLeaderboardSettings,
          icon: const Icon(Icons.save),
          label: const Text('Update Leaderboard Settings'),
        ),
      ],
    );
  }
}
