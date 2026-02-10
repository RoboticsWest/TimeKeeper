import 'dart:async';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

final _log = Logger();

class RfidScanBuffer {
  final void Function(String scannedInput) onScan;

  String _buffer = '';
  Timer? _timeout;

  static const _timeoutDuration = Duration(milliseconds: 500);

  RfidScanBuffer({required this.onScan});

  bool handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    final key = event.logicalKey;

    // Enter key = end of scan
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      if (_buffer.isNotEmpty) {
        final input = _buffer.trim();
        _clear();
        _log.d('RFID scan received: $input');
        onScan(input);
      }
      return false;
    }

    // Accumulate character input
    final char = event.character;
    if (char != null && char.isNotEmpty) {
      _buffer += char;
      _resetTimeout();
      return false;
    }

    return false;
  }

  void _resetTimeout() {
    _timeout?.cancel();
    _timeout = Timer(_timeoutDuration, () {
      if (_buffer.isNotEmpty) {
        _log.t('RFID buffer timeout, clearing: $_buffer');
        _buffer = '';
      }
    });
  }

  void _clear() {
    _buffer = '';
    _timeout?.cancel();
    _timeout = null;
  }

  void dispose() {
    _clear();
  }
}
