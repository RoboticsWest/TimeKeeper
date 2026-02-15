import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/colors.dart';
import 'package:time_keeper/generated/api/settings.pbgrpc.dart';
import 'package:time_keeper/helpers/grpc_call_wrapper.dart';
import 'package:time_keeper/helpers/local_storage.dart';
import 'package:time_keeper/providers/health_provider.dart';
import 'package:time_keeper/providers/settings_provider.dart';
import 'package:time_keeper/utils/grpc_result.dart';

part 'branding_provider.g.dart';

const _defaultPrimaryColorHex = '#009485';
const _defaultSecondaryColorHex = '#005994';
const _defaultPrimaryColor = Color(0xFF009485);
const _defaultSecondaryColor = Color(0xFF005994);

class Branding {
  final MaterialColor primaryColor;
  final MaterialColor secondaryColor;
  final Uint8List? logoBytes;

  const Branding({
    required this.primaryColor,
    required this.secondaryColor,
    this.logoBytes,
  });

  bool isEqual(Branding other) {
    return primaryColor.toARGB32() == other.primaryColor.toARGB32() &&
        secondaryColor.toARGB32() == other.secondaryColor.toARGB32() &&
        listEquals(logoBytes, other.logoBytes);
  }
}

Color? _parseHexColor(String hex) {
  if (hex.isEmpty) return null;
  hex = hex.replaceFirst('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  final value = int.tryParse(hex, radix: 16);
  if (value == null) return null;
  return Color(value);
}

@Riverpod(keepAlive: true)
class BrandingNotifier extends _$BrandingNotifier {
  final String _primaryColorKey = 'primary_color';
  final String _secondaryColorKey = 'secondary_color';

  @override
  Branding build() {
    // Get local storage for colors
    final primaryColorHex = localStorage.getString(_primaryColorKey);
    final secondaryColorHex = localStorage.getString(_secondaryColorKey);

    final primaryColor = primaryColorHex != null
        ? _parseHexColor(primaryColorHex) ?? _defaultPrimaryColor
        : _defaultPrimaryColor;
    final secondaryColor = secondaryColorHex != null
        ? _parseHexColor(secondaryColorHex) ?? _defaultSecondaryColor
        : _defaultSecondaryColor;

    ref.listen<AsyncValue<bool>>(isConnectedProvider, (prev, next) {
      final wasConnected = prev?.value ?? false;
      final isConnected = next.value ?? false;
      if (!wasConnected && isConnected) {
        _fetchBranding();
      }
    });

    return Branding(
      primaryColor: createMaterialColor(primaryColor),
      secondaryColor: createMaterialColor(secondaryColor),
    );
  }

  Future<void> _fetchBranding() async {
    final client = ref.read(settingsServiceProvider);

    final settingsResult = await callGrpcEndpoint(
      () => client.getSettings(GetSettingsRequest()),
    );

    final logoResult = await callGrpcEndpoint(
      () => client.getLogo(GetLogoRequest()),
    );

    final (
      primaryColorHex,
      secondaryColorHex,
    ) = settingsResult is GrpcSuccess<GetSettingsResponse>
        ? (
            settingsResult.data.settings.primaryColor,
            settingsResult.data.settings.secondaryColor,
          )
        : (null, null);

    final primaryColor = primaryColorHex != null
        ? _parseHexColor(primaryColorHex)
        : null;
    final secondaryColor = secondaryColorHex != null
        ? _parseHexColor(secondaryColorHex)
        : null;

    Uint8List? logoBytes;
    if (logoResult is GrpcSuccess<GetLogoResponse> &&
        logoResult.data.logo.isNotEmpty) {
      logoBytes = Uint8List.fromList(logoResult.data.logo);
    }

    // Set local storage
    localStorage.setString(_primaryColorKey, primaryColorHex ?? '');
    localStorage.setString(_secondaryColorKey, secondaryColorHex ?? '');

    final newBranding = Branding(
      primaryColor: createMaterialColor(primaryColor ?? _defaultPrimaryColor),
      secondaryColor: createMaterialColor(
        secondaryColor ?? _defaultSecondaryColor,
      ),
      logoBytes: logoBytes,
    );

    if (!state.isEqual(newBranding)) {
      state = newBranding;
    }
  }

  Future<void> refresh() async {
    await _fetchBranding();
  }
}
