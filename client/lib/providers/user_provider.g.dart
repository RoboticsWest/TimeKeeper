// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userChanges)
final userChangesProvider = UserChangesProvider._();

final class UserChangesProvider
    extends $FunctionalProvider<AsyncValue<ChangeEvent<User>>, ChangeEvent<User>, Stream<ChangeEvent<User>>>
    with $FutureModifier<ChangeEvent<User>>, $StreamProvider<ChangeEvent<User>> {
  UserChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userChangesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userChangesHash();

  @$internal
  @override
  $StreamProviderElement<ChangeEvent<User>> $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<ChangeEvent<User>> create(Ref ref) {
    return userChanges(ref);
  }
}

String _$userChangesHash() => r'202060cbfec6f505ec7c798f433f45175670bb26';

@ProviderFor(Users)
final usersProvider = UsersProvider._();

final class UsersProvider extends $NotifierProvider<Users, Map<String, User>> {
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
  Override overrideWithValue(Map<String, User> value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<Map<String, User>>(value));
  }
}

String _$usersHash() => r'8ccfad6a0049c31629356edbed10bb8bbd424e5a';

abstract class _$Users extends $Notifier<Map<String, User>> {
  Map<String, User> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, User>, Map<String, User>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, User>, Map<String, User>>,
              Map<String, User>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// The assignable roles, fetched once - they only change with a migration.

@ProviderFor(roles)
final rolesProvider = RolesProvider._();

/// The assignable roles, fetched once - they only change with a migration.

final class RolesProvider extends $FunctionalProvider<AsyncValue<List<Role>>, List<Role>, FutureOr<List<Role>>>
    with $FutureModifier<List<Role>>, $FutureProvider<List<Role>> {
  /// The assignable roles, fetched once - they only change with a migration.
  RolesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rolesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rolesHash();

  @$internal
  @override
  $FutureProviderElement<List<Role>> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Role>> create(Ref ref) {
    return roles(ref);
  }
}

String _$rolesHash() => r'9a162f0e13477a25038d17cbc15f92e3badd679a';

@ProviderFor(usersSync)
final usersSyncProvider = UsersSyncProvider._();

final class UsersSyncProvider extends $FunctionalProvider<void, void, void> with $Provider<void> {
  UsersSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usersSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usersSyncHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return usersSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<void>(value));
  }
}

String _$usersSyncHash() => r'f4e40e2ad2c358238e188e54f33c7785f1deb4da';
