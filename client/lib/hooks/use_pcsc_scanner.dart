import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:time_keeper/utils/pcsc_scanner.dart';

/// A hook that manages a [PcscScanner] lifecycle.
///
/// When [enabled] is true, the scanner starts listening for cards.
/// When [enabled] becomes false (or the widget disposes), the scanner
/// is cleaned up automatically.
void usePcscScanner({
  required void Function(String uid) onScan,
  void Function(String message)? onError,
  bool enabled = true,
  List<Object?> keys = const [],
}) {
  final onScanRef = useRef<void Function(String)>(onScan);
  final onErrorRef = useRef<void Function(String)?>(onError);
  onScanRef.value = onScan;
  onErrorRef.value = onError;

  useEffect(() {
    if (!enabled) return null;

    final scanner = PcscScanner(
      onScan: (uid) => onScanRef.value(uid),
      onError: (msg) => onErrorRef.value?.call(msg),
    );

    scanner.start();

    return scanner.dispose;
  }, [enabled, ...keys]);
}
