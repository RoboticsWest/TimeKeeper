// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Token)
final tokenProvider = TokenProvider._();

final class TokenProvider extends $NotifierProvider<Token, String?> {
  TokenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenHash();

  @$internal
  @override
  Token create() => Token();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$tokenHash() => r'417412ee1a3b9982f5454a22f48671832629a6ef';

abstract class _$Token extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(Username)
final usernameProvider = UsernameProvider._();

final class UsernameProvider extends $NotifierProvider<Username, String?> {
  UsernameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usernameProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usernameHash();

  @$internal
  @override
  Username create() => Username();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$usernameHash() => r'6f440800238e9bf2bfdd1380de34f206ffa172b7';

abstract class _$Username extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Decoded straight from the current JWT's `permissions` claim - not independently stored, so it
/// always reflects whatever token is currently active.

@ProviderFor(permissions)
final permissionsProvider = PermissionsProvider._();

/// Decoded straight from the current JWT's `permissions` claim - not independently stored, so it
/// always reflects whatever token is currently active.

final class PermissionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  /// Decoded straight from the current JWT's `permissions` claim - not independently stored, so it
  /// always reflects whatever token is currently active.
  PermissionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'permissionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$permissionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return permissions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$permissionsHash() => r'802768b1b9bcc3ec64307314d042c4b20012e164';

@ProviderFor(UserService)
final userServiceProvider = UserServiceProvider._();

final class UserServiceProvider extends $NotifierProvider<UserService, void> {
  UserServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userServiceHash();

  @$internal
  @override
  UserService create() => UserService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$userServiceHash() => r'8ea2606ff6897c13c9d53571ff25b850e4d41da2';

abstract class _$UserService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(isLoggedIn)
final isLoggedInProvider = IsLoggedInProvider._();

final class IsLoggedInProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  IsLoggedInProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isLoggedInProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isLoggedInHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isLoggedIn(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isLoggedInHash() => r'55854175bbde37cc8bbce06e9d85b2e4f6cb5a39';

/// UI-gating helper mirroring the server's `require_permission` checks - not a security boundary,
/// just controls what the client shows/hides. The server independently enforces every request.

@ProviderFor(isAdmin)
final isAdminProvider = IsAdminProvider._();

/// UI-gating helper mirroring the server's `require_permission` checks - not a security boundary,
/// just controls what the client shows/hides. The server independently enforces every request.

final class IsAdminProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// UI-gating helper mirroring the server's `require_permission` checks - not a security boundary,
  /// just controls what the client shows/hides. The server independently enforces every request.
  IsAdminProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAdminProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAdminHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isAdmin(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAdminHash() => r'5803756c1ba5fd04583763711279322aedcd7295';

/// Whether the current token grants any permission at all (vs. being unauthenticated) - used to
/// gate the main navigation rail and RFID scanning.

@ProviderFor(hasAnyPermission)
final hasAnyPermissionProvider = HasAnyPermissionProvider._();

/// Whether the current token grants any permission at all (vs. being unauthenticated) - used to
/// gate the main navigation rail and RFID scanning.

final class HasAnyPermissionProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the current token grants any permission at all (vs. being unauthenticated) - used to
  /// gate the main navigation rail and RFID scanning.
  HasAnyPermissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasAnyPermissionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasAnyPermissionHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return hasAnyPermission(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hasAnyPermissionHash() => r'69b4b944406fe0aed44ae28af7802fd2d004268e';
