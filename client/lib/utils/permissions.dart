/// Mirrors the server's `permission_level` enum - ordered so `write` implies `read` and `delete`
/// implies `write` (ceiling semantics), matching `database/migrations/0001_init/up.sql`.
enum PermissionLevel implements Comparable<PermissionLevel> {
  read,
  write,
  delete;

  @override
  int compareTo(PermissionLevel other) => index.compareTo(other.index);
}

/// Checks whether a decoded JWT `permissions` claim list (`"<resource>:<level>"` strings) grants
/// at least [required] on [resource].
bool hasPermission(List<String> permissions, String resource, PermissionLevel required) {
  for (final claim in permissions) {
    final parts = claim.split(':');
    if (parts.length != 2 || parts[0] != resource) continue;

    final level = PermissionLevel.values.where((l) => l.name == parts[1]).firstOrNull;
    if (level != null && level.compareTo(required) >= 0) {
      return true;
    }
  }
  return false;
}
