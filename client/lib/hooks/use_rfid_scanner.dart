import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:time_keeper/utils/pcsc_scanner.dart';
import 'package:time_keeper/utils/rfid_scanner.dart';

/// Unified RFID scanning hook that listens for input from both
/// PCSC smart card readers (native only) and keyboard-emulating
/// RFID readers (all platforms including web).
///
/// Both sources feed into the same [onScan] callback. Whichever
/// device produces a scan first will trigger the callback.
void useRfidScanner({
  required void Function(String uid) onScan,
  void Function(String message)? onError,
  bool enabled = true,
  List<Object?> keys = const [],
}) {
  final onScanRef = useRef<void Function(String)>(onScan);
  final onErrorRef = useRef<void Function(String)?>(onError);
  onScanRef.value = onScan;
  onErrorRef.value = onError;

  // PCSC smart card reader (native platforms only, stub on web)
  useEffect(() {
    if (!enabled) return null;

    final scanner = PcscScanner(
      onScan: (uid) => onScanRef.value(uid),
      onError: (msg) => onErrorRef.value?.call(msg),
    );

    scanner.start();

    return scanner.dispose;
  }, [enabled, ...keys]);

  // Keyboard-emulating RFID reader (all platforms)
  useEffect(() {
    if (!enabled) return null;

    final buffer = RfidScanBuffer(onScan: (input) => onScanRef.value(input));

    bool onKeyEvent(KeyEvent event) {
      buffer.handleKeyEvent(event);
      // Always return false so other key handlers still work
      return false;
    }

    HardwareKeyboard.instance.addHandler(onKeyEvent);

    return () {
      HardwareKeyboard.instance.removeHandler(onKeyEvent);
      buffer.dispose();
    };
  }, [enabled, ...keys]);
}
