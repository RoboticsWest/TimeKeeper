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
import 'package:time_keeper/views/setup/common/settings_page_layout.dart';
import 'package:time_keeper/views/setup/common/text_field_setting.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';
import 'package:time_keeper/widgets/dialogs/popup_dialog.dart';

class SessionSetupTab extends HookConsumerWidget {
  const SessionSetupTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminPasswordController = useTextEditingController();
    final thresholdController = useTextEditingController();

    // Load current threshold on mount
    useEffect(() {
      Future<void> loadSettings() async {
        final result = await callGrpcEndpoint(
          () => ref
              .read(settingsServiceProvider)
              .getSettings(GetSettingsRequest()),
        );
        if (result is GrpcSuccess<GetSettingsResponse>) {
          final hours =
              result.data.settings.nextSessionThresholdSecs.toInt() / 3600;
          thresholdController.text = hours.toString();
        }
      }

      loadSettings();
      return null;
    }, const []);

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
