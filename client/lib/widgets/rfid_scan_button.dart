import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:time_keeper/hooks/use_pcsc_scanner.dart';

/// A button that listens for an RFID card scan and writes the UID
/// into the provided [controller].
class RfidScanButton extends HookWidget {
  final TextEditingController controller;

  const RfidScanButton({super.key, required this.controller});

  static const _timeoutDuration = Duration(seconds: 30);

  @override
  Widget build(BuildContext context) {
    final listening = useState(false);
    final timerRef = useRef<Timer?>(null);

    void stopListening() {
      timerRef.value?.cancel();
      timerRef.value = null;
      listening.value = false;
    }

    usePcscScanner(
      enabled: listening.value,
      onScan: (uid) {
        controller.text = uid;
        stopListening();
      },
      keys: [listening.value],
    );

    if (listening.value) {
      return OutlinedButton.icon(
        onPressed: stopListening,
        icon: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        label: const Text('Waiting for scan...'),
      );
    }

    return OutlinedButton.icon(
      onPressed: () {
        listening.value = true;
        timerRef.value = Timer(_timeoutDuration, () {
          listening.value = false;
          timerRef.value = null;
        });
      },
      icon: const Icon(Icons.contactless),
      label: const Text('Scan RFID Card'),
    );
  }
}
