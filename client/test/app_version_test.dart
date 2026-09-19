import 'package:flutter_test/flutter_test.dart';
import 'package:time_keeper/utils/app_version.dart';

/// Mirrors `server/src/version.rs`'s tests. The two implementations have to agree, because the
/// client decides whether to prompt using its own copy of the rule.
void main() {
  group('Version.parse', () {
    test('parses a plain triple', () {
      expect(Version.parse('3.0.2'), const Version(3, 0, 2));
    });

    test('tolerates a v prefix and a build suffix', () {
      expect(Version.parse('v3.0.2'), const Version(3, 0, 2));
      expect(Version.parse('1.0.0+1'), const Version(1, 0, 0));
      expect(Version.parse('3.1.0-rc1'), const Version(3, 1, 0));
    });

    test('garbage parses as unknown', () {
      expect(Version.parse('not-a-version'), Version.unknown);
      expect(Version.parse(''), Version.unknown);
    });

    test('a short version fills missing parts with zero', () {
      expect(Version.parse('3'), const Version(3, 0, 0));
      expect(Version.parse('3.1'), const Version(3, 1, 0));
    });
  });

  group('isUpdateRequired', () {
    test('a minor bump requires an update', () {
      expect(const Version(3, 0, 2).isUpdateRequired(const Version(3, 1, 0)), isTrue);
    });

    test('a major bump requires an update', () {
      expect(const Version(3, 9, 9).isUpdateRequired(const Version(4, 0, 0)), isTrue);
    });

    /// The whole point of the major/minor rule: a typo fix must not nag every desktop.
    test('a patch bump does not', () {
      expect(const Version(3, 0, 2).isUpdateRequired(const Version(3, 0, 3)), isFalse);
      expect(const Version(3, 0, 0).isUpdateRequired(const Version(3, 0, 9)), isFalse);
    });

    test('an equal or older server never prompts', () {
      expect(const Version(3, 0, 2).isUpdateRequired(const Version(3, 0, 2)), isFalse);
      expect(const Version(3, 1, 0).isUpdateRequired(const Version(3, 0, 2)), isFalse);
      expect(const Version(4, 0, 0).isUpdateRequired(const Version(3, 9, 9)), isFalse);
    });

    /// A locally built client has no meaningful version; so does a server built without
    /// vars.yml. Neither should produce a prompt.
    test('an unknown version on either side never prompts', () {
      expect(Version.unknown.isUpdateRequired(const Version(3, 0, 2)), isFalse);
      expect(const Version(3, 0, 2).isUpdateRequired(Version.unknown), isFalse);
    });

    test('a locally built client reports the unknown sentinel', () {
      // No --dart-define in a plain `flutter test`, so this exercises the default.
      expect(Version.parse(kClientVersion), Version.unknown);
    });
  });
}
