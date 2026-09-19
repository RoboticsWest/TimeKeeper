import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/router/router.dart';
import 'package:time_keeper/providers/update_check_provider.dart';
import 'package:time_keeper/utils/app_version.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';

/// Watches for a newer server version and prompts once per check.
///
/// Wrapped around the app rather than placed on a page: an out-of-date client is out of date
/// everywhere, and the check has to work on the login screen too.
///
/// There is no auto-update. Downloading and swapping a running binary is fragile on all three
/// desktop platforms and would need a privileged helper on some of them, so this hands the user
/// a link and gets out of the way.
class UpdateAvailableGate extends ConsumerStatefulWidget {
  final Widget child;

  const UpdateAvailableGate({super.key, required this.child});

  @override
  ConsumerState<UpdateAvailableGate> createState() => _UpdateAvailableGateState();
}

class _UpdateAvailableGateState extends ConsumerState<UpdateAvailableGate> {
  bool _showing = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(availableUpdateProvider, (previous, next) {
      if (next == null || _showing) return;
      if (ref.read(updatePromptDismissalProvider.notifier).isDismissed(next.version)) return;
      // Off the build/listener frame: showDialog cannot run during a rebuild.
      WidgetsBinding.instance.addPostFrameCallback((_) => _prompt(next));
    });

    return widget.child;
  }

  Future<void> _prompt(ServerVersionInfo info) async {
    // The gate wraps the router's navigator rather than living inside it, so its own context
    // has no Navigator ancestor. Go through the router's key instead.
    final navigator = rootNavigatorKey.currentState;
    if (!mounted || _showing || navigator == null) return;

    setState(() => _showing = true);
    try {
      await showUpdateAvailableDialog(navigator.context, ref, info);
    } finally {
      if (mounted) setState(() => _showing = false);
    }
  }
}

/// The prompt itself. Dismissible — an out-of-date client still works, it is just behind.
Future<void> showUpdateAvailableDialog(BuildContext context, WidgetRef ref, ServerVersionInfo info) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.system_update_alt),
      title: const Text('A newer TimeKeeper is available'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This client is version $kClientVersion and the server is running ${info.version}. '
            'Some features may not work correctly until you update.',
          ),
          const SizedBox(height: 16),
          Text('Download the latest release:', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          // Selectable rather than a launched link: opening a browser needs a plugin, and a
          // kiosk machine may not have one at all. Copy-and-paste always works.
          SelectableText(info.releasesUrl, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(updatePromptDismissalProvider.notifier).dismiss(info.version);
            Navigator.of(context).pop();
          },
          child: const Text('Later'),
        ),
        FilledButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: info.releasesUrl));
            ref.read(updatePromptDismissalProvider.notifier).dismiss(info.version);
            if (context.mounted) {
              Navigator.of(context).pop();
              SnackBarDialog.success(message: 'Download link copied to clipboard').show(context);
            }
          },
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('Copy link'),
        ),
      ],
    ),
  );
}
