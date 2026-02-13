import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/generated/api/settings.pbgrpc.dart';
import 'package:time_keeper/generated/db/db.pbenum.dart';
import 'package:time_keeper/helpers/grpc_call_wrapper.dart';
import 'package:time_keeper/providers/settings_provider.dart';
import 'package:time_keeper/utils/grpc_result.dart';
import 'package:time_keeper/views/setup/common/setting_row.dart';
import 'package:time_keeper/views/setup/common/settings_page_layout.dart';
import 'package:time_keeper/views/setup/common/text_field_setting.dart';
import 'package:time_keeper/widgets/dialogs/popup_dialog.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';

class IntegrationsSetupTab extends HookConsumerWidget {
  const IntegrationsSetupTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final botTokenController = useTextEditingController();
    final guildIdController = useTextEditingController();
    final channelIdController = useTextEditingController();
    final reminderMinsController = useTextEditingController();
    final selfLinkEnabled = useState(false);
    final nameSyncEnabled = useState(true);
    final discordRoles = useState<List<DiscordRole>>([]);
    final selectedRoleId = useState<String?>(null);
    final isLoadingRoles = useState(false);
    final importingType = useState<TeamMemberType?>(null);

    // Load current settings on mount
    useEffect(() {
      Future<void> loadSettings() async {
        final result = await callGrpcEndpoint(
          () => ref
              .read(settingsServiceProvider)
              .getSettings(GetSettingsRequest()),
        );
        if (result is GrpcSuccess<GetSettingsResponse>) {
          botTokenController.text = result.data.settings.discordBotToken;
          guildIdController.text = result.data.settings.discordGuildId;
          channelIdController.text = result.data.settings.discordChannelId;
          final mins = result.data.settings.discordReminderMins;
          reminderMinsController.text = mins > 0 ? mins.toString() : '10';
          selfLinkEnabled.value = result.data.settings.discordSelfLinkEnabled;
          nameSyncEnabled.value = result.data.settings.discordNameSyncEnabled;
        }
      }

      loadSettings();
      return null;
    }, const []);

    Future<void> updateDiscordSettings() async {
      // Fetch existing settings first so we don't overwrite other fields
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

      final res = await callGrpcEndpoint(
        () => ref
            .read(settingsServiceProvider)
            .updateSettings(
              UpdateSettingsRequest(
                nextSessionThresholdSecs:
                    current.data.settings.nextSessionThresholdSecs,
                discordBotToken: botTokenController.text,
                discordGuildId: guildIdController.text,
                discordChannelId: channelIdController.text,
                discordReminderMins: Int64(
                  int.tryParse(reminderMinsController.text) ?? 10,
                ),
                discordSelfLinkEnabled: selfLinkEnabled.value,
                discordNameSyncEnabled: nameSyncEnabled.value,
              ),
            ),
      );

      if (context.mounted) {
        PopupDialog.fromGrpcStatus(result: res).show(context);
      }
    }

    Future<void> fetchDiscordRoles() async {
      isLoadingRoles.value = true;
      final result = await callGrpcEndpoint(
        () => ref
            .read(settingsServiceProvider)
            .getDiscordRoles(GetDiscordRolesRequest()),
      );
      isLoadingRoles.value = false;

      if (result is GrpcSuccess<GetDiscordRolesResponse>) {
        discordRoles.value = result.data.roles;
        selectedRoleId.value = null;
      } else if (context.mounted) {
        PopupDialog.fromGrpcStatus(result: result).show(context);
      }
    }

    Future<void> importMembers(TeamMemberType memberType) async {
      if (selectedRoleId.value == null) return;

      importingType.value = memberType;
      final result = await callGrpcEndpoint(
        () => ref
            .read(settingsServiceProvider)
            .importDiscordMembers(
              ImportDiscordMembersRequest(
                roleId: selectedRoleId.value!,
                memberType: memberType,
              ),
            ),
      );
      importingType.value = null;

      if (!context.mounted) return;

      if (result is GrpcSuccess<ImportDiscordMembersResponse>) {
        final r = result.data;
        SnackBarDialog.success(
          message:
              'Imported ${r.imported} new, linked ${r.linked} existing, ${r.alreadyLinked} already linked.',
        ).show(context);
      } else {
        PopupDialog.fromGrpcStatus(result: result).show(context);
      }
    }

    return SettingsPageLayout(
      title: 'Integrations',
      subtitle: 'Configure third-party integrations and API connections',
      children: [
        Text('Discord', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'Connect a Discord bot to enable notifications and team communication features.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        TextFieldSetting(
          label: 'Bot Token',
          description:
              'The bot token from the Discord Developer Portal (Applications > Bot > Token)',
          controller: botTokenController,
          hintText: 'Enter bot token',
          obscureText: true,
          onUpdate: updateDiscordSettings,
        ),
        const SizedBox(height: 24),
        TextFieldSetting(
          label: 'Server ID',
          description:
              'The ID of your Discord server (Enable Developer Mode, right-click server, Copy Server ID)',
          controller: guildIdController,
          hintText: 'Enter server ID',
          onUpdate: updateDiscordSettings,
        ),
        const SizedBox(height: 24),
        TextFieldSetting(
          label: 'Notification Channel ID',
          description:
              'The ID of the channel where the bot will post session reminders (right-click channel, Copy Channel ID)',
          controller: channelIdController,
          hintText: 'Enter channel ID',
          onUpdate: updateDiscordSettings,
        ),
        const SizedBox(height: 24),
        TextFieldSetting(
          label: 'Reminder Minutes',
          description:
              'How many minutes before a session starts to send a reminder notification',
          controller: reminderMinsController,
          hintText: '10',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onUpdate: updateDiscordSettings,
        ),
        const SizedBox(height: 24),
        SettingRow(
          label: 'Self-Linking',
          description:
              'Allow team members to link their Discord account using the !link command',
          child: Row(
            children: [
              Switch(
                value: selfLinkEnabled.value,
                onChanged: (value) {
                  selfLinkEnabled.value = value;
                  updateDiscordSettings();
                },
              ),
              const SizedBox(width: 8),
              Text(selfLinkEnabled.value ? 'Enabled' : 'Disabled'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SettingRow(
          label: 'Name Syncing',
          description:
              'Periodically sync team member names from their Discord server nickname',
          child: Row(
            children: [
              Switch(
                value: nameSyncEnabled.value,
                onChanged: (value) {
                  nameSyncEnabled.value = value;
                  updateDiscordSettings();
                },
              ),
              const SizedBox(width: 8),
              Text(nameSyncEnabled.value ? 'Enabled' : 'Disabled'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),
        Text(
          'Import Members from Discord',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Import Discord server members into TimeKeeper by role. '
          'Members are matched by display name and linked to their Discord account.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        SettingRow(
          label: 'Discord Role',
          description:
              'Select a role from your Discord server to import members from',
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: selectedRoleId.value,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select a role',
                  ),
                  items: discordRoles.value
                      .map(
                        (role) => DropdownMenuItem(
                          value: role.id,
                          child: Text(role.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => selectedRoleId.value = value,
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: isLoadingRoles.value ? null : fetchDiscordRoles,
                icon: isLoadingRoles.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: const Text('Fetch Roles'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            FilledButton.icon(
              onPressed:
                  selectedRoleId.value == null || importingType.value != null
                  ? null
                  : () => importMembers(TeamMemberType.STUDENT),
              icon: importingType.value == TeamMemberType.STUDENT
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.person_add),
              label: const Text('Import as Students'),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed:
                  selectedRoleId.value == null || importingType.value != null
                  ? null
                  : () => importMembers(TeamMemberType.MENTOR),
              icon: importingType.value == TeamMemberType.MENTOR
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.person_add),
              label: const Text('Import as Mentors'),
            ),
          ],
        ),
      ],
    );
  }
}
