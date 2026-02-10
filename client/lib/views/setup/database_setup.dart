import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/generated/api/settings.pbgrpc.dart';
import 'package:time_keeper/helpers/grpc_call_wrapper.dart';
import 'package:time_keeper/providers/settings_provider.dart';
import 'package:time_keeper/views/setup/common/locked_button_setting.dart';
import 'package:time_keeper/views/setup/common/settings_page_layout.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';

class DatabaseSetupTab extends ConsumerWidget {
  const DatabaseSetupTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsPageLayout(
      title: 'Database',
      subtitle: 'Manage database operations',
      children: [
        LockedButtonSetting.danger(
          label: 'Purge Database',
          description: 'Permanently delete all data from the database.',
          actionButtonLabel: 'Purge',
          actionIcon: Icons.delete_forever,
          noticeMessage:
              'WARNING: This will permanently delete ALL data including '
              'sessions, team members, locations, users, and settings. '
              'Only the default admin account will be recreated. '
              'This action cannot be undone!',
          onAction: () {
            ConfirmDialog.error(
              title: 'Confirm Database Purge',
              message: const Text(
                'Are you absolutely sure you want to purge the entire database? '
                'This will delete all data and cannot be undone.',
              ),
              onConfirmAsyncGrpc: () async {
                return await callGrpcEndpoint(
                  () => ref
                      .read(settingsServiceProvider)
                      .purgeDatabase(PurgeDatabaseRequest()),
                );
              },
              showResultDialog: true,
              successMessage: const Text('Database purged successfully'),
            ).show(context);
          },
        ),
      ],
    );
  }
}
