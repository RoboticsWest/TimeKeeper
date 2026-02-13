import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/helpers/kiosk_mode_stub.dart'
    if (dart.library.io) 'package:time_keeper/helpers/kiosk_mode_native.dart'
    if (dart.library.js_interop) 'package:time_keeper/helpers/kiosk_mode_web.dart';
import 'package:time_keeper/providers/kiosk_mode_provider.dart';
import 'package:time_keeper/providers/entity_sync_provider.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/network_config_provider.dart';
import 'package:time_keeper/views/setup/common/dropdown_setting.dart';
import 'package:time_keeper/views/setup/common/settings_page_layout.dart';
import 'package:time_keeper/views/setup/common/text_field_setting.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';

class SettingsView extends HookConsumerWidget {
  const SettingsView({super.key});

  void _showConfirmation(BuildContext context, String message) {
    SnackBarDialog.success(message: message).show(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(entitySyncProvider);
    final serverIp = ref.watch(serverIpProvider);
    final webPort = ref.watch(serverWebPortProvider);
    final apiPort = ref.watch(serverApiPortProvider);
    final locations = ref.watch(locationsProvider);
    final currentLocationId = ref.watch(currentLocationProvider);

    final addressController = useTextEditingController(text: serverIp);
    final webPortController = useTextEditingController(
      text: webPort.toString(),
    );
    final apiPortController = useTextEditingController(
      text: apiPort.toString(),
    );

    final selectedLocationId = useState<String?>(currentLocationId);
    final kioskMode = ref.watch(kioskModeProvider);

    return SettingsPageLayout(
      title: 'Settings',
      subtitle: 'Configure network and device settings',
      children: [
        DropdownSetting<String?>(
          label: 'Device Location',
          description: 'Set the location this device is assigned to',
          value: selectedLocationId.value,
          items: [
            const DropdownMenuItem<String?>(value: null, child: Text('None')),
            ...locations.entries.map(
              (entry) => DropdownMenuItem<String?>(
                value: entry.key,
                child: Text(entry.value.location),
              ),
            ),
          ],
          onChanged: (value) {
            selectedLocationId.value = value;
          },
          onUpdate: () {
            ref
                .read(currentLocationProvider.notifier)
                .setLocation(selectedLocationId.value);
            _showConfirmation(context, 'Device location updated');
          },
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          title: const Text('Kiosk Mode'),
          subtitle: Text(
            isKioskModeSupported
                ? 'Lock the app fullscreen and always-on-top (desktop only)'
                : 'Only available on desktop platforms',
          ),
          value: kioskMode,
          onChanged: isKioskModeSupported
              ? (_) => ref.read(kioskModeProvider.notifier).toggle()
              : null,
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),
        TextFieldSetting(
          label: 'Server Address',
          description: 'The address of the TimeKeeper server',
          controller: addressController,
          hintText: '127.0.0.1',
          onUpdate: () {
            ref.read(serverIpProvider.notifier).setIp(addressController.text);
            _showConfirmation(context, 'Server address updated');
          },
        ),
        const SizedBox(height: 24),
        TextFieldSetting(
          label: 'Web Port',
          description: 'The port used for web connections',
          controller: webPortController,
          hintText: '8080',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onUpdate: () {
            final port = int.tryParse(webPortController.text);
            if (port != null) {
              ref.read(serverWebPortProvider.notifier).setPort(port);
              _showConfirmation(context, 'Web port updated');
            }
          },
        ),
        const SizedBox(height: 24),
        TextFieldSetting(
          label: 'API Port',
          description: 'The port used for gRPC API connections',
          controller: apiPortController,
          hintText: '50051',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onUpdate: () {
            final port = int.tryParse(apiPortController.text);
            if (port != null) {
              ref.read(serverApiPortProvider.notifier).setPort(port);
              _showConfirmation(context, 'API port updated');
            }
          },
        ),
      ],
    );
  }
}
