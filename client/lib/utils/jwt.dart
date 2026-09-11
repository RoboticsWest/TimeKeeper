import 'dart:convert';

/// Decodes the `permissions` claim (a list of `"<resource>:<level>"` strings) out of a JWT's
/// payload, without verifying the signature - this is purely for UI gating (show/hide
/// admin-only screens); the server independently enforces every mutation/query regardless of
/// what the client thinks it can do.
List<String> decodeJwtPermissions(String? token) {
  if (token == null || token.isEmpty) return [];

  final parts = token.split('.');
  if (parts.length != 3) return [];

  try {
    final normalized = base64Url.normalize(parts[1]);
    final payload = jsonDecode(utf8.decode(base64Url.decode(normalized))) as Map<String, dynamic>;
    final permissions = payload['permissions'];
    if (permissions is List) {
      return permissions.cast<String>();
    }
    return [];
  } catch (_) {
    return [];
  }
}
