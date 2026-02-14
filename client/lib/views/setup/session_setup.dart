import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/generated/api/schedule.pbgrpc.dart';
import 'package:time_keeper/generated/api/settings.pbgrpc.dart';
import 'package:time_keeper/generated/api/user.pbgrpc.dart';
import 'package:time_keeper/helpers/grpc_call_wrapper.dart';
import 'package:time_keeper/providers/auth_provider.dart';
import 'package:time_keeper/providers/schedule_provider.dart';
import 'package:time_keeper/providers/settings_provider.dart';
import 'package:time_keeper/utils/grpc_result.dart';
import 'package:time_keeper/views/setup/common/file_upload_setting.dart';
import 'package:time_keeper/views/setup/common/setting_row.dart';
import 'package:time_keeper/views/setup/common/settings_page_layout.dart';
import 'package:time_keeper/views/setup/common/text_field_setting.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';
import 'package:time_keeper/widgets/dialogs/popup_dialog.dart';

const _timezones = [
  'UTC',
  '-12',
  '-11',
  '-10',
  '-9',
  '-8',
  '-7',
  '-6',
  '-5',
  '-4',
  '-3',
  '-2',
  '-1',
  '+1',
  '+2',
  '+3',
  '+4',
  '+5',
  '+6',
  '+7',
  '+8',
  '+9',
  '+10',
  '+11',
  '+12',
];

class SessionSetupTab extends HookConsumerWidget {
  const SessionSetupTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminPasswordController = useTextEditingController();
    final thresholdController = useTextEditingController();
    final selectedTimezone = useState('UTC');

    // Load current settings on mount
    useEffect(() {
      Future<void> loadSettings() async {
        final result = await callGrpcEndpoint(
          () => ref
              .read(settingsServiceProvider)
              .getSettings(GetSettingsRequest()),
        );
        if (result is GrpcSuccess<GetSettingsResponse>) {
          final s = result.data.settings;
          final hours = s.nextSessionThresholdSecs.toInt() / 3600;
          thresholdController.text = hours.toString();
          selectedTimezone.value = s.timezone.isEmpty ? 'UTC' : s.timezone;
        }
      }

      loadSettings();
      return null;
    }, const []);

    Future<void> updateTimezone(String timezone) async {
      final current = await callGrpcEndpoint(
        () =>
            ref.read(settingsServiceProvider).getSettings(GetSettingsRequest()),
      );

      if (current is! GrpcSuccess<GetSettingsResponse>) {
        if (context.mounted) {
          PopupDialog.fromGrpcStatus(result: current).show(context);
        }
        return;
      }

      final s = current.data.settings;
      final res = await callGrpcEndpoint(
        () => ref
            .read(settingsServiceProvider)
            .updateSettings(
              UpdateSettingsRequest(
                nextSessionThresholdSecs: s.nextSessionThresholdSecs,
                timezone: timezone,
                discordEnabled: s.discordEnabled,
                discordBotToken: s.discordBotToken,
                discordGuildId: s.discordGuildId,
                discordChannelId: s.discordChannelId,
                discordSelfLinkEnabled: s.discordSelfLinkEnabled,
                discordNameSyncEnabled: s.discordNameSyncEnabled,
                discordStartReminderMins: s.discordStartReminderMins,
                discordEndReminderMins: s.discordEndReminderMins,
                discordStartReminderMessage: s.discordStartReminderMessage,
                discordEndReminderMessage: s.discordEndReminderMessage,
                discordOvertimeDmEnabled: s.discordOvertimeDmEnabled,
                discordOvertimeDmMins: s.discordOvertimeDmMins,
                discordOvertimeDmMessage: s.discordOvertimeDmMessage,
                discordAutoCheckoutDmEnabled: s.discordAutoCheckoutDmEnabled,
                discordAutoCheckoutDmMessage: s.discordAutoCheckoutDmMessage,
                discordCheckoutEnabled: s.discordCheckoutEnabled,
              ),
            ),
      );

      if (context.mounted) {
        PopupDialog.fromGrpcStatus(result: res).show(context);
      }
    }

    Future<GrpcResult<UploadScheduleCsvResponse>> uploadCsvSchedule(
      Uint8List bytes,
    ) async {
      final req = UploadScheduleCsvRequest(csvData: bytes);
      return await callGrpcEndpoint(
        () => ref.read(scheduleServiceProvider).uploadScheduleCsv(req),
      );
    }

    Future<GrpcResult<UploadScheduleIcsResponse>> uploadIcsSchedule(
      Uint8List bytes,
    ) async {
      final req = UploadScheduleIcsRequest(icsData: bytes);
      return await callGrpcEndpoint(
        () => ref.read(scheduleServiceProvider).uploadScheduleIcs(req),
      );
    }

    return SettingsPageLayout(
      title: 'Sessions Setup',
      subtitle: 'Configure your session settings',
      children: [
        TextFieldSetting(
          label: 'Admin Password',
          description: 'Update the admin password for this event',
          controller: adminPasswordController,
          hintText: 'Enter password',
          obscureText: true,
          onUpdate: () async {
            final res = await callGrpcEndpoint(
              () => ref
                  .read(userServiceProvider)
                  .updateAdminPassword(
                    UpdateAdminPasswordRequest(
                      password: adminPasswordController.text,
                    ),
                  ),
            );

            // Show error dialog if request failed
            if (context.mounted) {
              PopupDialog.fromGrpcStatus(result: res).show(context);
            }
          },
        ),
        const SizedBox(height: 24),
        TextFieldSetting(
          label: 'Next Session Threshold (hours)',
          description:
              'Time before a session starts to consider check-ins for the next session and auto-finish the current one',
          controller: thresholdController,
          hintText: 'e.g. 4',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          onUpdate: () async {
            final hours = double.tryParse(thresholdController.text);
            if (hours == null || hours <= 0) return;
            final secs = Int64((hours * 3600).round());
            final res = await callGrpcEndpoint(
              () => ref
                  .read(settingsServiceProvider)
                  .updateSettings(
                    UpdateSettingsRequest(nextSessionThresholdSecs: secs),
                  ),
            );
            if (context.mounted) {
              PopupDialog.fromGrpcStatus(result: res).show(context);
            }
          },
        ),
        const SizedBox(height: 24),
        SettingRow(
          label: 'Timezone',
          description:
              'UTC offset used when the server formats times in Discord messages. '
              'Does not affect how times are stored (always UTC).',
          child: DropdownButton<String>(
            value: selectedTimezone.value,
            isExpanded: true,
            items: _timezones
                .map(
                  (tz) => DropdownMenuItem(
                    value: tz,
                    child: Text(tz == 'UTC' ? 'UTC' : 'UTC$tz'),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                selectedTimezone.value = value;
                updateTimezone(value);
              }
            },
          ),
        ),
        const SizedBox(height: 24),
        FileUploadSetting(
          label: 'Schedule Upload (CSV)',
          description: 'Upload a CSV file containing the schedule',
          allowedExtensions: ['csv'],
          uploadButtonLabel: 'Upload',
          onUpload: (file) async {
            if (file.bytes != null) {
              ConfirmDialog.warn(
                title: 'Confirm Upload',
                message: const Text(
                  'Uploading a schedule can have impacts on existing data integrity',
                ),
                onConfirmAsyncGrpc: () async {
                  return await uploadCsvSchedule(file.bytes!);
                },
                showResultDialog: true,
                successMessage: const Text('Schedule uploaded successfully!'),
              ).show(context);
            }
          },
        ),
        const SizedBox(height: 24),
        FileUploadSetting(
          label: 'Schedule Upload (ICS)',
          description: 'Upload an ICalendar file containing the sessions',
          allowedExtensions: ['ics'],
          uploadButtonLabel: 'Upload',
          onUpload: (file) async {
            if (file.bytes != null) {
              ConfirmDialog.warn(
                title: 'Confirm Upload',
                message: const Text(
                  'Uploading a schedule can have impacts on existing data integrity',
                ),
                onConfirmAsyncGrpc: () async {
                  return await uploadIcsSchedule(file.bytes!);
                },
                showResultDialog: true,
                successMessage: const Text('Schedule uploaded successfully!'),
              ).show(context);
            }
          },
        ),
      ],
    );
  }
}
