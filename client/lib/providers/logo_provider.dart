import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/providers/health_provider.dart';
import 'package:time_keeper/providers/settings_provider.dart';

part 'logo_provider.g.dart';

/// The server-configured logo, cached in memory and refreshed whenever the
/// connection comes back up.
///
/// This is all that remains of the old "branding" concept — the
/// server-configurable primary/secondary colors were removed in favour of the
/// hand-authored theme, which needs no round-trip to render.
@Riverpod(keepAlive: true)
class LogoNotifier extends _$LogoNotifier {
  @override
  Uint8List? build() {
    ref.listen<AsyncValue<bool>>(isConnectedProvider, (prev, next) {
      final wasConnected = prev?.value ?? false;
      final isConnected = next.value ?? false;
      if (!wasConnected && isConnected) {
        _fetchLogo();
      }
    });

    return null;
  }

  Future<void> _fetchLogo() async {
    final logoBase64 = await ref.read(logoQueryProvider.future);
    final logoBytes = logoBase64 != null && logoBase64.isNotEmpty ? base64Decode(logoBase64) : null;

    if (!listEquals(state, logoBytes)) {
      state = logoBytes;
    }
  }

  Future<void> refresh() async {
    await _fetchLogo();
  }
}
