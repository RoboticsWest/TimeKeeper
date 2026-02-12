import 'package:logger/logger.dart';

final _log = Logger();

class PcscScanner {
  final void Function(String scannedUid) onScan;
  final void Function(String message)? onError;

  PcscScanner({required this.onScan, this.onError});

  Future<void> start() async {
    _log.w('PCSC scanning is not supported on this platform');
  }

  void dispose() {}
}
