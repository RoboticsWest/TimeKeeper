/// The client's own version, and the rule for deciding it is too old.
///
/// There is no OTA update path worth having for a Flutter desktop binary — replacing a running
/// executable in place is fragile and differs on every platform. So the client does not update
/// itself: it compares its version against the server's and, when the server is meaningfully
/// newer, points the user at the release page.
library;

/// This build's version.
///
/// Injected at build time with `--dart-define=TK_VERSION=<version>` from `vars.yml`, which is
/// the same value CI tags the release with and the same one the server reports. `pubspec.yaml`
/// deliberately is not the source: it is not kept in step with the release version.
///
/// The `0.0.0` fallback means "locally built, version unknown", and [Version.isUpdateRequired]
/// never prompts on it — nagging a developer about their own debug build is pure noise.
const String kClientVersion = String.fromEnvironment('TK_VERSION', defaultValue: '0.0.0');

/// A `major.minor.patch` triple. Mirrors `server/src/version.rs`, including the rule that a
/// patch difference does not warrant a prompt.
class Version implements Comparable<Version> {
  final int major;
  final int minor;
  final int patch;

  const Version(this.major, this.minor, this.patch);

  static const unknown = Version(0, 0, 0);

  /// Anything unparseable becomes [unknown], which never prompts.
  factory Version.parse(String text) {
    // Tolerate a leading "v" and a trailing build suffix ("1.0.0+1", "3.0.2-rc1").
    final cleaned = text.trim().replaceFirst(RegExp(r'^v'), '');
    final core = cleaned.split(RegExp(r'[+-]')).first;
    final parts = core.split('.');
    int at(int i) => i < parts.length ? (int.tryParse(parts[i]) ?? 0) : 0;
    return Version(at(0), at(1), at(2));
  }

  bool get isUnknown => major == 0 && minor == 0 && patch == 0;

  /// Whether [server] is a major/minor release ahead of this build.
  ///
  /// Patch differences deliberately do not count: a patch bump is routinely a server-side fix
  /// that needs no client reinstall, and prompting every desktop in the building about it
  /// teaches people to dismiss the dialog without reading it.
  bool isUpdateRequired(Version server) {
    if (isUnknown || server.isUnknown) return false;
    if (server.major != major) return server.major > major;
    return server.minor > minor;
  }

  @override
  int compareTo(Version other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    return patch.compareTo(other.patch);
  }

  @override
  bool operator ==(Object other) =>
      other is Version && other.major == major && other.minor == minor && other.patch == patch;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => '$major.$minor.$patch';
}
