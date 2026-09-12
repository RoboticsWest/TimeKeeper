import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rfid_suppression_provider.g.dart';

/// Suppresses the global keyboard-wedge RFID scanner.
///
/// [useRfidScanner] attaches a `HardwareKeyboard` handler and accumulates
/// digits terminated by Enter — which is exactly what typing a PIN looks like.
/// Without this, every PIN entered at the kiosk would also fire a phantom card
/// scan. Any widget that captures digit input (the PIN pad today) holds this
/// flag for as long as it is open.
@Riverpod(keepAlive: true)
class RfidScannerSuppressed extends _$RfidScannerSuppressed {
  @override
  bool build() => false;

  void suppress() => state = true;
  void release() => state = false;
}
