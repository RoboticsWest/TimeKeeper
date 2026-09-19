import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/providers/auth_provider.dart';
import 'package:time_keeper/providers/schedule_provider.dart';
import 'package:time_keeper/providers/settings_provider.dart';
import 'package:time_keeper/utils/api_result.dart';
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
    final checkInWindowController = useTextEditingController();
    final autoCheckoutController = useTextEditingController();
    final selectedTimezone = useState('UTC');

    // Load current settings on mount
    useEffect(() {
      Future<void> loadSettings() async {
        final settings = await ref.read(settingsQueryProvider.future);
        if (settings != null) {
          checkInWindowController.text = (settings.checkInWindowSecs / 3600).toString();
          autoCheckoutController.text = (settings.autoCheckoutAfterSecs / 3600).toString();
          selectedTimezone.value = settings.timezone.isEmpty ? 'UTC' : settings.timezone;
        }
      }

      loadSettings();
      return null;
    }, const []);

    Future<void> updateTimezone(String timezone) async {
      final res = await ref.read(settingsServiceProvider.notifier).updateGeneral(timezone: timezone);

      if (context.mounted) {
        PopupDialog.fromApiResult(result: res).show(context);
      }
    }

    Future<ApiCallResult> uploadCsvSchedule(Uint8List bytes) {
      return ref.read(scheduleServiceProvider.notifier).uploadCsv(utf8.decode(bytes));
    }

    Future<ApiCallResult> uploadIcsSchedule(Uint8List bytes) {
      return ref.read(scheduleServiceProvider.notifier).uploadIcs(utf8.decode(bytes));
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
            final res = await ref.read(userServiceProvider.notifier).updateAdminPassword(adminPasswordController.text);

            // Show error dialog if request failed
            if (context.mounted) {
              PopupDialog.fromApiResult(result: res).show(context);
            }
          },
        ),
        const SizedBox(height: 24),
        TextFieldSetting(
          label: 'Check-in Window (hours)',
          description:
              'How early before a session starts — and how late after it ends — a kiosk scan still '
              'checks someone in to that session',
          controller: checkInWindowController,
          hintText: 'e.g. 4',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
          onUpdate: () async {
            final hours = double.tryParse(checkInWindowController.text);
            if (hours == null || hours <= 0) return;

            final res = await ref
                .read(settingsServiceProvider.notifier)
                .updateGeneral(checkInWindowSecs: (hours * 3600).round());

            if (context.mounted) {
              PopupDialog.fromApiResult(result: res).show(context);
            }
          },
        ),
        const SizedBox(height: 24),
        TextFieldSetting(
          label: 'Auto Check-out After (hours)',
          description:
              'How long after a session was scheduled to end before anyone still signed in is '
              'checked out automatically. Members are also checked out as soon as the next '
              'session at that location starts.',
          controller: autoCheckoutController,
          hintText: 'e.g. 24',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
          onUpdate: () async {
            final hours = double.tryParse(autoCheckoutController.text);
            if (hours == null || hours <= 0) return;

            final res = await ref
                .read(settingsServiceProvider.notifier)
                .updateGeneral(autoCheckoutAfterSecs: (hours * 3600).round());

            if (context.mounted) {
              PopupDialog.fromApiResult(result: res).show(context);
            }
          },
        ),
        const SizedBox(height: 24),
        SettingRow(
          label: 'Timezone',
          description:
              'UTC offset used when the server formats times in Discord messages. '
              'Does not affect how times are stored (always UTC).',
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: selectedTimezone.value,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: _timezones
                      .map((tz) => DropdownMenuItem(value: tz, child: Text(tz == 'UTC' ? 'UTC' : 'UTC$tz')))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedTimezone.value = value;
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => updateTimezone(selectedTimezone.value),
                icon: const Icon(Icons.save),
                label: const Text('Update'),
              ),
            ],
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
                message: const Text('Uploading a schedule can have impacts on existing data integrity'),
                onConfirmAsyncApi: () async {
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
                message: const Text('Uploading a schedule can have impacts on existing data integrity'),
                onConfirmAsyncApi: () async {
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
