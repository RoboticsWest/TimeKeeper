import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/rfid_suppression_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/shapes.dart';
import 'package:time_keeper/utils/api_result.dart';
import 'package:time_keeper/views/kiosk/kiosk_scan_handler.dart';

/// Numeric keypad for quick PIN sign-in.
///
/// The PIN is resolved server-side, so nothing here knows or can check a PIN
/// locally — this collects digits and reports whatever the server says.
class PinEntryDialog extends HookConsumerWidget {
  const PinEntryDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const PinEntryDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pin = useState('');
    final submitting = useState(false);
    final error = useState<String?>(null);

    // The keyboard-wedge RFID scanner would otherwise read these digits as a
    // card scan, since it also terminates on Enter.
    useEffect(() {
      final notifier = ref.read(rfidScannerSuppressedProvider.notifier);
      notifier.suppress();
      return notifier.release;
    }, const []);

    Future<void> submit() async {
      if (pin.value.isEmpty || submitting.value) return;
      submitting.value = true;
      error.value = null;

      final locationId = ref.read(currentLocationProvider) ?? '';
      final result = await ref
          .read(sessionCheckInOutProvider.notifier)
          .checkInOutByPin(pin.value, locationId);

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
          pin.value = '';
          error.value = msg;
      }
    }

    void append(String digit) {
      if (submitting.value) return;
      error.value = null;
      pin.value = pin.value + digit;
    }

    void backspace() {
      if (submitting.value || pin.value.isEmpty) return;
      error.value = null;
      pin.value = pin.value.substring(0, pin.value.length - 1);
    }

    // Accept a real keyboard too — many kiosks have one attached.
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): submit,
        const SingleActivator(LogicalKeyboardKey.numpadEnter): submit,
        const SingleActivator(LogicalKeyboardKey.backspace): backspace,
        const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.of(context).pop(),
      },
      child: Focus(
        autofocus: true,
        child: AlertDialog(
          title: const Text('Enter your PIN'),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PinDisplay(length: pin.value.length),
                const SizedBox(height: 8),
                SizedBox(
                  height: 32,
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
                _Keypad(
                  onDigit: append,
                  onBackspace: backspace,
                  onSubmit: submit,
                  enabled: !submitting.value,
                  canSubmit: pin.value.isNotEmpty,
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
        ),
      ),
    );
  }
}

/// Masked PIN readout. Shows one dot per entered digit — PINs are variable
/// length, so there are no empty placeholder slots to fill.
class _PinDisplay extends StatelessWidget {
  final int length;

  const _PinDisplay({required this.length});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: kBorderRadiusRow,
        border: Border.all(color: theme.dividerColor),
      ),
      child: length == 0
          ? Text('••••', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 20))
          : Wrap(
              spacing: 8,
              children: [
                for (var i = 0; i < length; i++)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
    );
  }
}

class _Keypad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onSubmit;
  final bool enabled;
  final bool canSubmit;

  const _Keypad({
    required this.onDigit,
    required this.onBackspace,
    required this.onSubmit,
    required this.enabled,
    required this.canSubmit,
  });

  @override
  Widget build(BuildContext context) {
    Widget key(Widget child, VoidCallback? onPressed) => SizedBox(
      height: 56,
      child: OutlinedButton(onPressed: enabled ? onPressed : null, child: child),
    );

    Widget digit(String value) =>
        key(Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)), () => onDigit(value));

    return Column(
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                for (final value in row) ...[
                  Expanded(child: digit(value)),
                  if (value != row.last) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        Row(
          children: [
            Expanded(child: key(const Icon(Icons.backspace_outlined, size: 20), onBackspace)),
            const SizedBox(width: 8),
            Expanded(child: digit('0')),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: enabled && canSubmit ? onSubmit : null,
                  child: const Icon(Icons.check, size: 22),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
