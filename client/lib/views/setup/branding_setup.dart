import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/generated/api/settings.pbgrpc.dart';
import 'package:time_keeper/helpers/grpc_call_wrapper.dart';
import 'package:time_keeper/providers/branding_provider.dart';
import 'package:time_keeper/providers/settings_provider.dart';
import 'package:time_keeper/utils/grpc_result.dart';
import 'package:time_keeper/views/setup/common/file_upload_setting.dart';
import 'package:time_keeper/views/setup/common/setting_row.dart';
import 'package:time_keeper/views/setup/common/settings_page_layout.dart';
import 'package:time_keeper/widgets/dialogs/popup_dialog.dart';

Color? _parseHex(String hex) {
  hex = hex.replaceFirst('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  final value = int.tryParse(hex, radix: 16);
  if (value == null) return null;
  return Color(value);
}

String _colorToHex(Color color) {
  return '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

class BrandingSetupTab extends HookConsumerWidget {
  const BrandingSetupTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryController = useTextEditingController();
    final secondaryController = useTextEditingController();
    final primaryPreview = useState<Color>(const Color(0xFF009485));
    final secondaryPreview = useState<Color>(const Color(0xFF005994));

    useEffect(() {
      Future<void> loadSettings() async {
        final result = await callGrpcEndpoint(
          () => ref
              .read(settingsServiceProvider)
              .getSettings(GetSettingsRequest()),
        );
        if (result is GrpcSuccess<GetSettingsResponse>) {
          final s = result.data.settings;
          final primary = _parseHex(s.primaryColor);
          if (primary != null) {
            primaryController.text = _colorToHex(primary);
            primaryPreview.value = primary;
          }
          final secondary = _parseHex(s.secondaryColor);
          if (secondary != null) {
            secondaryController.text = _colorToHex(secondary);
            secondaryPreview.value = secondary;
          }
        }
      }

      loadSettings();
      return null;
    }, const []);

    Future<void> updateColor({
      required String hex,
      required bool isPrimary,
    }) async {
      final color = _parseHex(hex);
      if (color == null) {
        PopupDialog.error(
          title: 'Invalid Color',
          message: const Text('Invalid hex color format'),
        ).show(context);
        return;
      }

      final normalizedHex = _colorToHex(color);
      final res = await callGrpcEndpoint(
        () => ref
            .read(settingsServiceProvider)
            .updateBrandingSettings(
              isPrimary
                  ? UpdateBrandingSettingsRequest(primaryColor: normalizedHex)
                  : UpdateBrandingSettingsRequest(
                      secondaryColor: normalizedHex,
                    ),
            ),
      );

      if (context.mounted) {
        PopupDialog.fromGrpcStatus(result: res).show(context);
      }
    }

    return SettingsPageLayout(
      title: 'Branding',
      subtitle: 'Customize your organization\'s colors and logo',
      children: [
        _ColorFieldSetting(
          label: 'Primary Color',
          description: 'Main color used for the app bar, buttons, and accents',
          controller: primaryController,
          previewColor: primaryPreview,
          onUpdate: () =>
              updateColor(hex: primaryController.text, isPrimary: true),
        ),
        const SizedBox(height: 24),
        _ColorFieldSetting(
          label: 'Secondary Color',
          description: 'Accent color used for secondary elements',
          controller: secondaryController,
          previewColor: secondaryPreview,
          onUpdate: () =>
              updateColor(hex: secondaryController.text, isPrimary: false),
        ),
        const SizedBox(height: 24),
        FileUploadSetting(
          label: 'Logo',
          description:
              'Upload a logo image displayed on the login screen. Supported formats: PNG, JPG',
          allowedExtensions: ['png', 'jpg', 'jpeg'],
          uploadButtonLabel: 'Upload',
          onUpload: (file) async {
            if (file.bytes != null) {
              final res = await callGrpcEndpoint(
                () => ref
                    .read(settingsServiceProvider)
                    .uploadLogo(UploadLogoRequest(logo: file.bytes!)),
              );
              if (context.mounted) {
                PopupDialog.fromGrpcStatus(result: res).show(context);
                if (res is GrpcSuccess) {
                  await ref.read(brandingProvider.notifier).refresh();
                }
              }
            }
          },
        ),
      ],
    );
  }
}

class _ColorFieldSetting extends StatelessWidget {
  final String label;
  final String description;
  final TextEditingController controller;
  final ValueNotifier<Color> previewColor;
  final VoidCallback onUpdate;

  const _ColorFieldSetting({
    required this.label,
    required this.description,
    required this.controller,
    required this.previewColor,
    required this.onUpdate,
  });

  void _showColorPicker(BuildContext context) {
    Color pickedColor = previewColor.value;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pick $label'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickedColor,
              onColorChanged: (color) => pickedColor = color,
              enableAlpha: false,
              hexInputBar: true,
              labelTypes: const [],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                previewColor.value = pickedColor;
                controller.text = _colorToHex(pickedColor);
                Navigator.of(context).pop();
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingRow(
      label: label,
      description: description,
      child: Row(
        children: [
          ValueListenableBuilder<Color>(
            valueListenable: previewColor,
            builder: (context, color, _) {
              return GestureDetector(
                onTap: () => _showColorPicker(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '#009485',
              ),
              onChanged: (value) {
                final parsed = _parseHex(value);
                if (parsed != null) {
                  previewColor.value = parsed;
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: onUpdate,
            icon: const Icon(Icons.save),
            label: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
