import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/providers/logo_provider.dart';
import 'package:time_keeper/providers/settings_provider.dart';
import 'package:time_keeper/views/setup/common/file_upload_setting.dart';
import 'package:time_keeper/views/setup/common/settings_page_layout.dart';
import 'package:time_keeper/widgets/dialogs/popup_dialog.dart';

class BrandingSetupTab extends ConsumerWidget {
  const BrandingSetupTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsPageLayout(
      title: 'Branding',
      subtitle: 'Upload the logo shown on the login and kiosk screens',
      children: [
        FileUploadSetting(
          label: 'Logo',
          description: 'Upload a logo image displayed on the login screen. Supported formats: PNG, JPG',
          allowedExtensions: const ['png', 'jpg', 'jpeg'],
          uploadButtonLabel: 'Upload',
          onUpload: (file) async {
            if (file.bytes != null) {
              final res = await ref.read(settingsServiceProvider.notifier).uploadLogo(base64Encode(file.bytes!));
              if (context.mounted) {
                PopupDialog.fromApiResult(result: res).show(context);
                if (res.success) {
                  await ref.read(logoProvider.notifier).refresh();
                }
              }
            }
          },
        ),
      ],
    );
  }
}
