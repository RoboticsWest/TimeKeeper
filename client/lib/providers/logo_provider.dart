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

    // An admin replacing the logo used to change it only on their own machine: every other
    // client kept whatever it fetched when it last reconnected. The push carries the new
    // value, so there is nothing to re-fetch.
    ref.listen<AsyncValue<String?>>(logoChangesProvider, (previous, next) {
      next.whenData(_applyLogo);
    });

    return null;
  }

  void _applyLogo(String? logoBase64) {
    final logoBytes = logoBase64 != null && logoBase64.isNotEmpty ? base64Decode(logoBase64) : null;
    if (!listEquals(state, logoBytes)) {
      state = logoBytes;
    }
  }

  Future<void> _fetchLogo() async {
    _applyLogo(await ref.read(logoQueryProvider.future));
  }

  Future<void> refresh() async {
    await _fetchLogo();
  }
}
