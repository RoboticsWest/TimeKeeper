import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/settings.dart';
import 'package:time_keeper/providers/settings_provider.dart';
import 'package:time_keeper/views/setup/common/settings_page_layout.dart';
import 'package:time_keeper/views/setup/common/switch_setting.dart';
import 'package:time_keeper/views/setup/common/text_field_setting.dart';
import 'package:time_keeper/widgets/dialogs/popup_dialog.dart';

class SystemSetupTab extends HookConsumerWidget {
  const SystemSetupTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenanceMode = useState(false);
    final messageController = useTextEditingController();

    useEffect(() {
      Future<void> loadSettings() async {
        final s = await ref.read(settingsQueryProvider.future);
        if (s != null) {
          maintenanceMode.value = s.maintenanceMode;
          messageController.text = s.maintenanceMessage;
        }
      }

      loadSettings();
      return null;
    }, const []);

    Future<void> saveMessage() async {
      final res = await ref
          .read(settingsServiceProvider.notifier)
          .setMaintenanceMode(maintenanceMessage: messageController.text);
      if (context.mounted) {
        PopupDialog.fromApiResult(result: res).show(context);
      }
    }

    return SettingsPageLayout(
      title: 'System',
      subtitle: 'Operational controls',
      children: [
        SwitchSetting(
          label: 'Maintenance Mode',
          description:
              'Shows a dismissable notice to everyone using the app, and makes the Discord bot '
              'refuse every command. Use it while a deploy is part-way done so people know why '
              'something is missing instead of reporting it as a bug.',
          value: maintenanceMode.value,
          onChanged: (enabled) async {
            maintenanceMode.value = enabled;
            final res = await ref.read(settingsServiceProvider.notifier).setMaintenanceMode(maintenanceMode: enabled);
            if (!res.success) {
              // Put the switch back so it never shows a state the server did not accept.
              maintenanceMode.value = !enabled;
              if (context.mounted) {
                PopupDialog.fromApiResult(result: res).show(context);
              }
            }
          },
        ),
        const SizedBox(height: 24),
        TextFieldSetting(
          label: 'Maintenance Message',
          description:
              'Shown in the banner and in the bot\'s reply. Leave blank to use the default: '
              '"${Settings.defaultMaintenanceMessage}"',
          controller: messageController,
          hintText: Settings.defaultMaintenanceMessage,
          multiline: true,
          onUpdate: saveMessage,
        ),
      ],
    );
  }
}
