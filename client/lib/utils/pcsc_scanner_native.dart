import 'dart:async';
import 'dart:typed_data';
import 'package:async/async.dart';
import 'package:dart_pcsc/dart_pcsc.dart';
import 'package:logger/logger.dart';

final _log = Logger();

String _hexColon(List<int> bytes) => bytes
    .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
    .join(':');

class PcscScanner {
  final void Function(String scannedUid) onScan;
  final void Function(String message)? onError;

  bool _running = false;
  Context? _context;
  CancelableOperation<List<String>>? _pendingWait;

  /// APDU command to read UID from most ISO 14443 cards.
  static final _getUidCommand = Uint8List.fromList([
    0xFF,
    0xCA,
    0x00,
    0x00,
    0x00,
  ]);

  /// Debounce: ignore the same UID within this window.
  static const _debounceDuration = Duration(seconds: 3);
  String? _lastUid;
  DateTime? _lastScanTime;

  PcscScanner({required this.onScan, this.onError});

  Future<void> start() async {
    _running = true;
    _log.i('[PCSC] Scanner starting');

    while (_running) {
      try {
        await _scanLoop();
      } catch (e) {
        if (!_running) break;
        _log.e('[PCSC] Scan loop error, retrying in 2s: $e');
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }
  }

  Future<void> _scanLoop() async {
    final context = Context(Scope.user);
    _context = context;

    try {
      await context.establish();

      final readers = await context.listReaders();
      if (readers.isEmpty) {
        _log.w('[PCSC] No readers found, retrying in 3s');
        await context.release();
        _context = null;
        await Future<void>.delayed(const Duration(seconds: 3));
        return;
      }

      _log.i('[PCSC] Using reader: "${readers.first}"');
      final reader = readers.first;

      while (_running) {
        final waitOp = context.waitForCard([reader]);
        _pendingWait = waitOp;
        final readersWithCard = await waitOp.valueOrCancellation(null);
        _pendingWait = null;

        if (readersWithCard == null || !_running) break;

        Card? card;
        try {
          card = await context.connect(
            readersWithCard.first,
            ShareMode.shared,
            Protocol.any,
          );

          var response = await card.transmit(_getUidCommand);

          // Retry once on bad status — the reader may not be fully
          // ready on the first scan after launch.
          if (response.length >= 2) {
            final sw1 = response[response.length - 2];
            if (sw1 != 0x90) {
              _log.w('[PCSC] Bad status on first attempt, retrying...');
              await card.disconnect(Disposition.resetCard);
              card = null;
              await Future<void>.delayed(const Duration(milliseconds: 200));
              card = await context.connect(
                readersWithCard.first,
                ShareMode.shared,
                Protocol.any,
              );
              response = await card.transmit(_getUidCommand);
            }
          }

          if (response.length >= 2) {
            final sw1 = response[response.length - 2];
            final sw2 = response[response.length - 1];
            final uid = response.sublist(0, response.length - 2);

            if (sw1 == 0x90 && sw2 == 0x00 && uid.isNotEmpty) {
              final hexUid = _hexColon(uid);

              _log.i('[PCSC] Card UID: $hexUid (${uid.length} bytes)');

              // Debounce: skip if same card scanned within window
              final now = DateTime.now();
              if (hexUid != _lastUid ||
                  _lastScanTime == null ||
                  now.difference(_lastScanTime!) > _debounceDuration) {
                _lastUid = hexUid;
                _lastScanTime = now;
                onScan(hexUid);
              }
            } else {
              _log.w(
                '[PCSC] Card error status: '
                '${sw1.toRadixString(16).padLeft(2, '0')} '
                '${sw2.toRadixString(16).padLeft(2, '0')}',
              );
              onError?.call('Could not read card. Please try again.');
            }
          }
        } catch (e) {
          _log.e('[PCSC] Error reading card: $e');
          onError?.call('Could not read card. Please try again.');
        } finally {
          if (card != null) {
            try {
              await card.disconnect(Disposition.resetCard);
            } catch (_) {}
          }
        }

        if (_running) {
          await Future<void>.delayed(const Duration(seconds: 2));
        }
      }
    } finally {
      try {
        await context.release();
      } catch (_) {}
      _context = null;
    }
  }

  void dispose() {
    _log.i('[PCSC] Scanner disposing');
    _running = false;
    try {
      _pendingWait?.cancel();
    } catch (_) {}
    _pendingWait = null;
    final ctx = _context;
    _context = null;
    if (ctx != null) {
      try {
        ctx.release().catchError((_) {});
      } catch (_) {}
    }
  }
}
