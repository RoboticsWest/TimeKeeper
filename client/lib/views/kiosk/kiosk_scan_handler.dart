import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:time_keeper/generated/api/api.pbgrpc.dart';
import 'package:time_keeper/generated/common/common.pbenum.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/helpers/grpc_call_wrapper.dart';
import 'package:time_keeper/providers/auth_provider.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/utils/grpc_result.dart';
import 'package:time_keeper/utils/permissions.dart';
import 'package:time_keeper/views/kiosk/link_card_dialog.dart';
import 'package:time_keeper/widgets/dialogs/toast_overlay.dart';

final _log = Logger();

/// Handles a PCSC card scan by matching the UID against team members
/// and checking them in/out.
Future<void> handleKioskScan({
  required String input,
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return;

  final teamMembers = ref.read(teamMembersProvider);
  final variants = _buildUidVariants(trimmed);
  final match = _findMember(variants, teamMembers);

  if (match == null) {
    _log.w(
      'No member matched scan: $input (tried ${variants.length} variants)',
    );
    if (context.mounted) {
      final isAdmin = ref.read(rolesProvider).hasPermission(Role.ADMIN);
      if (isAdmin) {
        showLinkCardDialog(context, ref, trimmed);
      } else {
        ToastOverlay.error(
          context,
          title: 'Unrecognized',
          message: 'Unrecognized card "$trimmed", contact admin.',
        );
      }
    }
    return;
  }

  final memberId = match.key;
  final member = match.value;
  final name = member.displayName;

  _log.i('Scan matched member: $name');

  final currentLocation = ref.read(currentLocationProvider) ?? '';
  final result = await callGrpcEndpoint(
    () => ref
        .read(sessionServiceProvider)
        .checkInOut(
          CheckInOutRequest(
            teamMemberId: memberId,
            locationId: currentLocation,
          ),
        ),
  );

  if (!context.mounted) return;

  final now = DateTime.now();
  final timeStr = formatTime(now);

  switch (result) {
    case GrpcSuccess(data: final response):
      if (response.checkedIn) {
        ToastOverlay.success(
          context,
          title: 'Checked In',
          message: '$name\n$timeStr',
        );
      } else {
        ToastOverlay.warn(
          context,
          title: 'Checked Out',
          message: '$name\n$timeStr',
        );
      }
    case GrpcFailure(userMessage: final msg, statusCode: final code):
      if (code == StatusCode.notFound) {
        ToastOverlay.warn(
          context,
          title: 'No Session',
          message: '$name\nNo active session at this location.',
        );
      } else {
        ToastOverlay.error(
          context,
          title: 'Check In Failed',
          message: '$name\n$msg',
        );
      }
  }
}

/// Builds all reasonable representations of a scanned UID so we can
/// match flexibly against however the user stored it.
///
/// From a colon-separated hex input like "89:02:9E:40" we produce:
///   - 89:02:9e:40        (colon-separated, lowercase)
///   - 89 02 9e 40        (space-separated)
///   - 89029e40           (no separator)
///   - decimal BE string  (e.g. "2298650176")
///   - decimal LE string  (e.g. "1084097161")
///
/// From a decimal input like "1084097161" (keyboard RFID reader) we produce:
///   - BE hex: 40:9e:02:89  (direct byte conversion)
///   - LE hex: 89:02:9e:40  (reversed — matches PCSC format)
///   - plus space-separated and no-separator variants of both
Set<String> _buildUidVariants(String input) {
  final variants = <String>{};
  final normalized = input.trim().toLowerCase();

  // Try to extract hex bytes from the input regardless of separator
  final hexBytes = _parseHexBytes(normalized);

  if (hexBytes != null && hexBytes.isNotEmpty) {
    final hexParts = hexBytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .toList();

    variants.add(hexParts.join(':')); // 89:02:9e:40
    variants.add(hexParts.join(' ')); // 89 02 9e 40
    variants.add(hexParts.join()); // 89029e40

    // Decimal big-endian
    var be = BigInt.zero;
    for (final b in hexBytes) {
      be = (be << 8) | BigInt.from(b);
    }
    variants.add(be.toString());

    // Decimal little-endian
    var le = BigInt.zero;
    for (final b in hexBytes.reversed) {
      le = (le << 8) | BigInt.from(b);
    }
    variants.add(le.toString());
  }

  // If input looks like a plain decimal number, parse it to hex bytes
  // and add those variants too (in case user stored hex but card gave decimal).
  // We generate both BE and LE byte orders because keyboard RFID readers
  // typically output the LE decimal of the UID bytes.
  final asInt = BigInt.tryParse(normalized);
  if (asInt != null && asInt > BigInt.zero) {
    final bytes = _bigIntToBytes(asInt);
    if (bytes.isNotEmpty) {
      // Big-endian interpretation
      final hexBe = bytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .toList();
      variants.add(hexBe.join(':'));
      variants.add(hexBe.join(' '));
      variants.add(hexBe.join());

      // Little-endian (reversed) interpretation
      final hexLe = bytes.reversed
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .toList();
      variants.add(hexLe.join(':'));
      variants.add(hexLe.join(' '));
      variants.add(hexLe.join());
    }
  }

  // Always include the raw input as-is
  variants.add(normalized);

  return variants;
}

/// Try to parse hex bytes from a string with any common separator
/// (colon, space, dash, or no separator for even-length hex strings).
List<int>? _parseHexBytes(String input) {
  // Try colon, space, or dash separated
  for (final sep in [':', ' ', '-']) {
    if (input.contains(sep)) {
      final parts = input.split(sep);
      if (parts.every((p) => RegExp(r'^[0-9a-f]{1,2}$').hasMatch(p))) {
        return parts.map((p) => int.parse(p, radix: 16)).toList();
      }
      return null; // has separator but not valid hex
    }
  }

  // No separator — try as continuous hex (must be even length)
  if (input.length.isEven &&
      input.length >= 4 &&
      RegExp(r'^[0-9a-f]+$').hasMatch(input)) {
    final bytes = <int>[];
    for (var i = 0; i < input.length; i += 2) {
      bytes.add(int.parse(input.substring(i, i + 2), radix: 16));
    }
    return bytes;
  }

  return null;
}

/// Convert a BigInt to a list of bytes (big-endian, minimal length).
List<int> _bigIntToBytes(BigInt value) {
  if (value == BigInt.zero) return [0];
  final bytes = <int>[];
  var v = value;
  while (v > BigInt.zero) {
    bytes.add((v & BigInt.from(0xFF)).toInt());
    v = v >> 8;
  }
  return bytes.reversed.toList();
}

/// Tries to match any of the UID [variants] against team member RFID tags.
MapEntry<String, TeamMember>? _findMember(
  Set<String> variants,
  Map<String, TeamMember> teamMembers,
) {
  for (final entry in teamMembers.entries) {
    final rfid = entry.value.rfidTag;
    if (rfid.isNotEmpty && variants.contains(rfid.trim().toLowerCase())) {
      return entry;
    }
  }
  return null;
}
