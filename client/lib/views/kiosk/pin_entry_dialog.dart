import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/rfid_suppression_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/utils/api_result.dart';
import 'package:time_keeper/views/kiosk/kiosk_scan_handler.dart';

/// PIN sign-in through a plain text field.
///
/// No on-screen keypad: touch devices surface their own keyboard when the
/// field is focused and a real keyboard works as-is. The PIN is resolved
/// server-side, so nothing here knows or can check a PIN locally — this just
/// collects the digits and reports whatever the server says.
class PinEntryDialog extends HookConsumerWidget {
  const PinEntryDialog({super.key});

  /// Opens the dialog, holding the RFID suppression flag for exactly as long
  /// as the dialog is up.
  ///
  /// The suppression used to be a `useEffect` inside [build]. flutter_hooks
  /// runs effects while the tree is still building, and Riverpod rejects a
  /// state write from there — opening the dialog threw "Tried to modify a
  /// provider while the widget tree was building" and rendered the red error
  /// screen instead of the field. Owning the flag around the dialog's future
  /// keeps the write in a plain callback, and `finally` releases it whether
  /// the dialog was submitted, dismissed or thrown out of.
  static Future<void> show(BuildContext context, WidgetRef ref) async {
    // The keyboard-wedge RFID scanner would otherwise read the PIN digits as a
    // card scan, since it also terminates on Enter.
    final notifier = ref.read(rfidScannerSuppressedProvider.notifier);
    notifier.suppress();
    try {
      await showDialog<void>(
        context: context,
        builder: (_) => const PinEntryDialog(),
      );
    } finally {
      notifier.release();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = useTextEditingController();
    final submitting = useState(false);
    final error = useState<String?>(null);

    Future<void> submit() async {
      final pin = controller.text;
      if (pin.isEmpty || submitting.value) return;

      final locationId = ref.read(currentLocationProvider);
      if (locationId == null || locationId.isEmpty) {
        error.value = kNoDeviceLocationMessage;
        return;
      }

      submitting.value = true;
      error.value = null;
      final result = await ref
          .read(sessionCheckInOutProvider.notifier)
          .checkInOutByPin(pin, locationId);

      if (!context.mounted) return;

      switch (result) {
        case ApiSuccess(data: final outcome):
          final member = ref.read(teamMembersProvider)[outcome.teamMemberId];
          Navigator.of(context).pop();
          showCheckInOutResult(
            context: context,
            name: member?.displayName,
            result: ApiSuccess(outcome.checkedIn),
          );
        case ApiFailure(userMessage: final msg):
          submitting.value = false;
          controller.clear();
          error.value = msg;
      }
    }

    return AlertDialog(
      title: const Text('Enter your PIN'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              obscureText: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              enabled: !submitting.value,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: 'PIN',
                prefixIcon: Icon(Icons.pin_outlined),
              ),
              onChanged: (_) => error.value = null,
              onSubmitted: (_) => submit(),
            ),
            const SizedBox(height: 8),
            // Reserves a line so the dialog doesn't jump when an error appears,
            // but grows for the longer ones rather than clipping.
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 32, minWidth: double.infinity),
              child: error.value == null
                  ? null
                  : Center(
                      child: Text(
                        error.value!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
                      ),
                    ),
            ),
            const SizedBox(height: 4),
            ListenableBuilder(
              listenable: controller,
              builder: (context, _) => FilledButton.icon(
                onPressed: submitting.value || controller.text.isEmpty
                    ? null
                    : submit,
                icon: const Icon(Icons.check, size: 20),
                label: const Text('Check In / Out'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: submitting.value ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
