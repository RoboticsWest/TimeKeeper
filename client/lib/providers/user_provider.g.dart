// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(usersStream)
final usersStreamProvider = UsersStreamProvider._();

final class UsersStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<StreamUsersResponse>,
          StreamUsersResponse,
          Stream<StreamUsersResponse>
        >
    with
        $FutureModifier<StreamUsersResponse>,
        $StreamProvider<StreamUsersResponse> {
  UsersStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usersStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usersStreamHash();

  @$internal
  @override
  $StreamProviderElement<StreamUsersResponse> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<StreamUsersResponse> create(Ref ref) {
    return usersStream(ref);
  }
}

String _$usersStreamHash() => r'1572fee3a306bf9bebb41dd6912ce72a17bc9aa4';

@ProviderFor(Users)
final usersProvider = UsersProvider._();

final class UsersProvider
    extends $NotifierProvider<Users, Map<String, UserResponse>> {
  UsersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usersHash();

  @$internal
  @override
  Users create() => Users();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, UserResponse> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, UserResponse>>(value),
    );
  }
}

String _$usersHash() => r'f14dd30823b21375fa560a263d674d5462e4eccb';

abstract class _$Users extends $Notifier<Map<String, UserResponse>> {
  Map<String, UserResponse> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<Map<String, UserResponse>, Map<String, UserResponse>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, UserResponse>, Map<String, UserResponse>>,
              Map<String, UserResponse>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Auto-dispose provider that bridges [usersStreamProvider] to [usersProvider].
/// Views watch this to activate the users stream.

@ProviderFor(usersSync)
final usersSyncProvider = UsersSyncProvider._();

/// Auto-dispose provider that bridges [usersStreamProvider] to [usersProvider].
/// Views watch this to activate the users stream.

final class UsersSyncProvider extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Auto-dispose provider that bridges [usersStreamProvider] to [usersProvider].
  /// Views watch this to activate the users stream.
  UsersSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usersSyncProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usersSyncHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return usersSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$usersSyncHash() => r'0fd2f91dbdcab05d2b9f44e3a36361c854e0db52';
