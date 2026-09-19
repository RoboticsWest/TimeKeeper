import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/settings.dart';
import 'package:time_keeper/models/team_member.dart';
import 'package:time_keeper/providers/settings_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/utils/api_result.dart';
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
    final channelAnnouncementIdController = useTextEditingController();
    final channelNotificationIdController = useTextEditingController();
    final startReminderMinsController = useTextEditingController();
    final endReminderMinsController = useTextEditingController();
    final startReminderMessageController = useTextEditingController();
    final endReminderMessageController = useTextEditingController();
    final autoDeleteStartReminder = useState(false);
    final autoDeleteEndReminder = useState(false);
    final rsvpReactionsEnabled = useState(true);
    final selfLinkEnabled = useState(false);
    final nameSyncEnabled = useState(true);
    final overtimeDmEnabled = useState(true);
    final overtimeDmMinsController = useTextEditingController();
    final overtimeDmMessageController = useTextEditingController();
    final autoCheckoutDmEnabled = useState(true);
    final autoCheckoutDmMessageController = useTextEditingController();
    final discordEnabled = useState(false);
    final checkoutEnabled = useState(false);
    final discordRoles = useState<List<DiscordRole>>([]);
    final selectedRoleId = useState<String?>(null);
    final isLoadingRoles = useState(false);
    final importingType = useState<TeamMemberType?>(null);

    // Load current settings on mount
    useEffect(() {
      Future<void> loadSettings() async {
        final s = await ref.read(settingsQueryProvider.future);
        if (s != null) {
          discordEnabled.value = s.discordEnabled;
          botTokenController.text = s.discordBotToken;
          guildIdController.text = s.discordGuildId;
          channelAnnouncementIdController.text = s.discordAnnouncementChannelId;
          channelNotificationIdController.text = s.discordNotificationChannelId;
          final startMins = s.discordStartReminderMins;
          startReminderMinsController.text = startMins > 0 ? startMins.toString() : '1440';
          final endMins = s.discordEndReminderMins;
          endReminderMinsController.text = endMins > 0 ? endMins.toString() : '15';
          startReminderMessageController.text = s.discordStartReminderMessage;
          endReminderMessageController.text = s.discordEndReminderMessage;
          autoDeleteStartReminder.value = s.discordAutoDeleteStartReminder;
          autoDeleteEndReminder.value = s.discordAutoDeleteEndReminder;
          rsvpReactionsEnabled.value = s.discordRsvpReactionsEnabled;
          selfLinkEnabled.value = s.discordSelfLinkEnabled;
          nameSyncEnabled.value = s.discordNameSyncEnabled;
          overtimeDmEnabled.value = s.discordOvertimeDmEnabled;
          final overtimeMins = s.discordOvertimeDmMins;
          overtimeDmMinsController.text = overtimeMins > 0 ? overtimeMins.toString() : '10';
          overtimeDmMessageController.text = s.discordOvertimeDmMessage;
          autoCheckoutDmEnabled.value = s.discordAutoCheckoutDmEnabled;
          autoCheckoutDmMessageController.text = s.discordAutoCheckoutDmMessage;
          checkoutEnabled.value = s.discordCheckoutEnabled;
        }
      }

      loadSettings();
      return null;
    }, const []);

    Future<void> updateDiscordCore() async {
      final res = await ref
          .read(settingsServiceProvider.notifier)
          .updateDiscordCore(
            discordEnabled: discordEnabled.value,
            discordBotToken: botTokenController.text,
            discordGuildId: guildIdController.text,
            discordAnnouncementChannelId: channelAnnouncementIdController.text,
            discordNotificationChannelId: channelNotificationIdController.text,
          );

      if (context.mounted) {
        PopupDialog.fromApiResult(result: res).show(context);
      }
    }

    Future<void> updateDiscordReminder() async {
      final res = await ref
          .read(settingsServiceProvider.notifier)
          .updateDiscordReminder(
            discordStartReminderMins: int.tryParse(startReminderMinsController.text) ?? 1440,
            discordEndReminderMins: int.tryParse(endReminderMinsController.text) ?? 15,
            discordStartReminderMessage: startReminderMessageController.text,
            discordEndReminderMessage: endReminderMessageController.text,
            discordAutoDeleteStartReminder: autoDeleteStartReminder.value,
            discordAutoDeleteEndReminder: autoDeleteEndReminder.value,
          );

      if (context.mounted) {
        PopupDialog.fromApiResult(result: res).show(context);
      }
    }

    Future<void> updateDiscordBehavior() async {
      final res = await ref
          .read(settingsServiceProvider.notifier)
          .updateDiscordBehavior(
            discordRsvpReactionsEnabled: rsvpReactionsEnabled.value,
            discordSelfLinkEnabled: selfLinkEnabled.value,
            discordNameSyncEnabled: nameSyncEnabled.value,
            discordOvertimeDmEnabled: overtimeDmEnabled.value,
            discordOvertimeDmMins: int.tryParse(overtimeDmMinsController.text) ?? 10,
            discordOvertimeDmMessage: overtimeDmMessageController.text,
            discordAutoCheckoutDmEnabled: autoCheckoutDmEnabled.value,
            discordAutoCheckoutDmMessage: autoCheckoutDmMessageController.text,
            discordCheckoutEnabled: checkoutEnabled.value,
          );

      if (context.mounted) {
        PopupDialog.fromApiResult(result: res).show(context);
      }
    }

    Future<void> fetchDiscordRoles() async {
      isLoadingRoles.value = true;
      // Invalidate so the next read re-fetches from the server rather than using a stale future.
      ref.invalidate(discordRolesQueryProvider);
      final roles = await ref.read(discordRolesQueryProvider.future);
      isLoadingRoles.value = false;

      discordRoles.value = roles;
      selectedRoleId.value = null;
    }

    Future<void> importMembers(TeamMemberType memberType) async {
      if (selectedRoleId.value == null) return;

      importingType.value = memberType;
      final result = await ref
          .read(settingsServiceProvider.notifier)
          .importDiscordMembers(selectedRoleId.value!, memberType.toJson());
      importingType.value = null;

      if (!context.mounted) return;

      switch (result) {
        case ApiSuccess(data: final r):
          // Re-fetch so the Team Members tab reflects the import immediately even if the
          // change-event subscription is down or the app started before the import.
          await ref.read(teamMembersProvider.notifier).refresh();
          if (!context.mounted) return;
          SnackBarDialog.success(
            message: 'Imported ${r.imported} new, linked ${r.linked} existing, ${r.alreadyLinked} already linked.',
          ).show(context);
        case ApiFailure(userMessage: final msg):
          PopupDialog.error(title: 'Error', message: Text(msg)).show(context);
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
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        SettingRow(
          label: 'Enable Discord Integration',
          description:
              'Master switch for the Discord bot and all Discord features. '
              'Configure your settings below first, then enable this to start the bot.',
          child: Row(
            children: [
              Switch(
                value: discordEnabled.value,
                onChanged: (value) {
                  discordEnabled.value = value;
                  updateDiscordCore();
                },
              ),
              const SizedBox(width: 8),
              Text(discordEnabled.value ? 'Enabled' : 'Disabled'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextFieldSetting(
          label: 'Bot Token',
          description: 'The bot token from the Discord Developer Portal (Applications > Bot > Token)',
          controller: botTokenController,
          hintText: 'Enter bot token',
          obscureText: true,
          onUpdate: updateDiscordCore,
        ),
        const SizedBox(height: 24),
        TextFieldSetting(
          label: 'Server ID',
          description: 'The ID of your Discord server (Enable Developer Mode, right-click server, Copy Server ID)',
          controller: guildIdController,
          hintText: 'Enter server ID',
          onUpdate: updateDiscordCore,
        ),
        const SizedBox(height: 24),
        TextFieldSetting(
          label: 'Announcement Channel ID',
          description:
              'The ID of the channel where the bot will post session reminders (right-click channel, Copy Channel ID)',
          controller: channelAnnouncementIdController,
          hintText: 'Enter channel ID',
          onUpdate: updateDiscordCore,
        ),
        const SizedBox(height: 24),
        TextFieldSetting(
          label: 'Notification Channel ID',
          description:
              'The ID of the channel where the bot will post notifications and user directed messages (right-click channel, Copy Channel ID)',
          controller: channelNotificationIdController,
          hintText: 'Enter channel ID',
          onUpdate: updateDiscordCore,
        ),
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),
        Text('Reminders (Announcement Channel)', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'Configure when and what the bot posts before sessions start and end. '
          'Placeholders: {mins}, {location}, {relative_day}, {weekday}, {date}, {start_time}, {end_time}. '
          'Set minutes to 0 to disable.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        TextFieldSetting(
          label: 'Start Reminder (minutes before)',
          description: 'How many minutes before a session starts to send a reminder (default: 1440 = 24 hours)',
          controller: startReminderMinsController,
          hintText: '1440',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onUpdate: updateDiscordReminder,
        ),
        const SizedBox(height: 24),
        TextFieldSetting(
          label: 'Start Reminder Message',
          description:
              'Custom message for the start reminder. {relative_day} renders as "today", "tomorrow" or a '
              'weekday depending on when the reminder actually fires — prefer it over writing '
              '"tomorrow", which is wrong whenever a session is created at short notice. '
              'Supports {mins}, {location}, {relative_day}, {weekday}, {date}, {start_time}, {end_time}',
          controller: startReminderMessageController,
          hintText:
              '@here Session {relative_day} from {start_time} to {end_time} @ {location} \u2014 starting in ~{mins} minutes!',
          multiline: true,
          onUpdate: updateDiscordReminder,
        ),
        const SizedBox(height: 24),
        SettingRow(
          label: 'Auto Delete Start Reminders',
          description:
              'Automatically delete the start reminder message from Discord once the session start time has passed.',
          child: Row(
            children: [
              Switch(
                value: autoDeleteStartReminder.value,
                onChanged: (value) {
                  autoDeleteStartReminder.value = value;
                  updateDiscordReminder();
                },
              ),
              const SizedBox(width: 8),
              Text(autoDeleteStartReminder.value ? 'Enabled' : 'Disabled'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SettingRow(
          label: 'Start Reminder RSVP Reactions',
          description:
              'Add thumbs up/down reactions to session start reminders so members can RSVP. '
              'RSVPs are tracked and visible in the Sessions view.',
          child: Row(
            children: [
              Switch(
                value: rsvpReactionsEnabled.value,
                onChanged: (value) {
                  rsvpReactionsEnabled.value = value;
                  updateDiscordBehavior();
                },
              ),
              const SizedBox(width: 8),
              Text(rsvpReactionsEnabled.value ? 'Enabled' : 'Disabled'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextFieldSetting(
          label: 'End Reminder (minutes before)',
          description: 'How many minutes before a session ends to send a reminder (default: 15)',
          controller: endReminderMinsController,
          hintText: '15',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onUpdate: updateDiscordReminder,
        ),
        const SizedBox(height: 24),
        TextFieldSetting(
          label: 'End Reminder Message',
          description:
              'Custom message for the end reminder. Supports {mins}, {location}, {relative_day}, {weekday}, {date}, {start_time}, {end_time}',
          controller: endReminderMessageController,
          hintText: '@here Session at {location} is ending in ~{mins} minutes \u2014 don\'t forget to sign out!',
          multiline: true,
          onUpdate: updateDiscordReminder,
        ),
        const SizedBox(height: 24),
        SettingRow(
          label: 'Auto Delete End Reminders',
          description:
              'Automatically delete the end reminder message from Discord once the session end time has passed.',
          child: Row(
            children: [
              Switch(
                value: autoDeleteEndReminder.value,
                onChanged: (value) {
                  autoDeleteEndReminder.value = value;
                  updateDiscordReminder();
                },
              ),
              const SizedBox(width: 8),
              Text(autoDeleteEndReminder.value ? 'Enabled' : 'Disabled'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SettingRow(
          label: 'Self-Linking',
          description: 'Allow team members to link their Discord account using the !link command',
          child: Row(
            children: [
              Switch(
                value: selfLinkEnabled.value,
                onChanged: (value) {
                  selfLinkEnabled.value = value;
                  updateDiscordBehavior();
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
          description: 'Periodically sync team member names from their Discord server nickname',
          child: Row(
            children: [
              Switch(
                value: nameSyncEnabled.value,
                onChanged: (value) {
                  nameSyncEnabled.value = value;
                  updateDiscordBehavior();
                },
              ),
              const SizedBox(width: 8),
              Text(nameSyncEnabled.value ? 'Enabled' : 'Disabled'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SettingRow(
          label: 'Discord Checkout',
          description:
              'Allow team members to check themselves out using the !checkout command. '
              'If used after a session ends, checkout time is set to the session end time.',
          child: Row(
            children: [
              Switch(
                value: checkoutEnabled.value,
                onChanged: (value) {
                  checkoutEnabled.value = value;
                  updateDiscordBehavior();
                },
              ),
              const SizedBox(width: 8),
              Text(checkoutEnabled.value ? 'Enabled' : 'Disabled'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),
        Text('Notifications (Notification Channel)', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'Send notifications to team members for overtime and auto-checkout warnings. '
          'Members must have a linked Discord account. '
          'Placeholders: {username}, {name}, {location}, {end_time}.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        SettingRow(
          label: 'Overtime Notification',
          description: 'Notify members who are still checked in after a session ends',
          child: Row(
            children: [
              Switch(
                value: overtimeDmEnabled.value,
                onChanged: (value) {
                  overtimeDmEnabled.value = value;
                  updateDiscordBehavior();
                },
              ),
              const SizedBox(width: 8),
              Text(overtimeDmEnabled.value ? 'Enabled' : 'Disabled'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextFieldSetting(
          label: 'Overtime Notification (minutes after session end)',
          description: 'How many minutes after a session ends to send the overtime notification (default: 10)',
          controller: overtimeDmMinsController,
          hintText: '10',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onUpdate: updateDiscordBehavior,
        ),
        const SizedBox(height: 24),
        TextFieldSetting(
          label: 'Overtime Notification Message',
          description: 'Custom message for overtime notifications. Supports {username}, {name}, {location}, {end_time}',
          controller: overtimeDmMessageController,
          hintText:
              'Hey {username}, you\'re now in overtime for the session at {location}. The session ended at {end_time}. Don\'t forget to check out!',
          multiline: true,
          onUpdate: updateDiscordBehavior,
        ),
        const SizedBox(height: 24),
        SettingRow(
          label: 'Auto-Checkout Notification',
          description: 'Notify members when they have been auto-checked-out because a new session is starting',
          child: Row(
            children: [
              Switch(
                value: autoCheckoutDmEnabled.value,
                onChanged: (value) {
                  autoCheckoutDmEnabled.value = value;
                  updateDiscordBehavior();
                },
              ),
              const SizedBox(width: 8),
              Text(autoCheckoutDmEnabled.value ? 'Enabled' : 'Disabled'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextFieldSetting(
          label: 'Auto-Checkout Notification Message',
          description:
              'Message sent when a member is auto-checked-out. Supports {username}, {name}, {location}, {end_time}',
          controller: autoCheckoutDmMessageController,
          hintText:
              'Hey {username}, you\'ve been auto-checked-out from the session at {location} (ended at {end_time}) because you were still signed in after it finished.',
          multiline: true,
          onUpdate: updateDiscordBehavior,
        ),
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),
        Text('Import Members from Discord', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'Import Discord server members into TimeKeeper by role. '
          'Members are matched by display name and linked to their Discord account.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        SettingRow(
          label: 'Discord Role',
          description: 'Select a role from your Discord server to import members from',
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: selectedRoleId.value,
                  decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Select a role'),
                  items: discordRoles.value
                      .map((role) => DropdownMenuItem(value: role.id, child: Text(role.name)))
                      .toList(),
                  onChanged: (value) => selectedRoleId.value = value,
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: isLoadingRoles.value ? null : fetchDiscordRoles,
                icon: isLoadingRoles.value
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
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
              onPressed: selectedRoleId.value == null || importingType.value != null
                  ? null
                  : () => importMembers(TeamMemberType.student),
              icon: importingType.value == TeamMemberType.student
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.person_add),
              label: const Text('Import as Students'),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: selectedRoleId.value == null || importingType.value != null
                  ? null
                  : () => importMembers(TeamMemberType.mentor),
              icon: importingType.value == TeamMemberType.mentor
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.person_add),
              label: const Text('Import as Mentors'),
            ),
          ],
        ),
      ],
    );
  }
}
