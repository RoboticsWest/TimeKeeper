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
        isAutoDispose: false,
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

String _$usersStreamHash() => r'01945443933ce7ff85de037f0dc72deb83afac9a';

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

String _$usersHash() => r'cc987a48d976e7e8dc98bf281dbd3026c1ea70ec';

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
