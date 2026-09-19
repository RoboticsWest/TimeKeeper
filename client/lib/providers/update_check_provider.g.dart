// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_check_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Polls the server's version on [kUpdateCheckInterval].
///
/// Unauthenticated on the server side, so this works on the login screen too. Returns null when
/// the server cannot be reached — an offline client should say nothing rather than claim to be
/// out of date.

@ProviderFor(serverVersionInfo)
final serverVersionInfoProvider = ServerVersionInfoProvider._();

/// Polls the server's version on [kUpdateCheckInterval].
///
/// Unauthenticated on the server side, so this works on the login screen too. Returns null when
/// the server cannot be reached — an offline client should say nothing rather than claim to be
/// out of date.

final class ServerVersionInfoProvider
    extends $FunctionalProvider<AsyncValue<ServerVersionInfo?>, ServerVersionInfo?, FutureOr<ServerVersionInfo?>>
    with $FutureModifier<ServerVersionInfo?>, $FutureProvider<ServerVersionInfo?> {
  /// Polls the server's version on [kUpdateCheckInterval].
  ///
  /// Unauthenticated on the server side, so this works on the login screen too. Returns null when
  /// the server cannot be reached — an offline client should say nothing rather than claim to be
  /// out of date.
  ServerVersionInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverVersionInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverVersionInfoHash();

  @$internal
  @override
  $FutureProviderElement<ServerVersionInfo?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ServerVersionInfo?> create(Ref ref) {
    return serverVersionInfo(ref);
  }
}

String _$serverVersionInfoHash() => r'0564ef0ddcea4a04d7caec2c4fd42527a0693af6';

/// The server version when this build is too old to keep using quietly, else null.
///
/// Null covers every "say nothing" case: server unreachable, versions equal, client newer
/// (a developer running ahead of the deploy), either side unknown, or a patch-only difference.

@ProviderFor(availableUpdate)
final availableUpdateProvider = AvailableUpdateProvider._();

/// The server version when this build is too old to keep using quietly, else null.
///
/// Null covers every "say nothing" case: server unreachable, versions equal, client newer
/// (a developer running ahead of the deploy), either side unknown, or a patch-only difference.

final class AvailableUpdateProvider
    extends $FunctionalProvider<ServerVersionInfo?, ServerVersionInfo?, ServerVersionInfo?>
    with $Provider<ServerVersionInfo?> {
  /// The server version when this build is too old to keep using quietly, else null.
  ///
  /// Null covers every "say nothing" case: server unreachable, versions equal, client newer
  /// (a developer running ahead of the deploy), either side unknown, or a patch-only difference.
  AvailableUpdateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availableUpdateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availableUpdateHash();

  @$internal
  @override
  $ProviderElement<ServerVersionInfo?> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  ServerVersionInfo? create(Ref ref) {
    return availableUpdate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServerVersionInfo? value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<ServerVersionInfo?>(value));
  }
}

String _$availableUpdateHash() => r'29adeef9fc15d18f63a8518ed9d80b4fbd9f8589';

/// Tracks the update prompt so it is shown once per check rather than on every rebuild.
///
/// Dismissing does not suppress the next check: the point is a periodic nudge. It only stops
/// the dialog reappearing the moment it is closed.

@ProviderFor(UpdatePromptDismissal)
final updatePromptDismissalProvider = UpdatePromptDismissalProvider._();

/// Tracks the update prompt so it is shown once per check rather than on every rebuild.
///
/// Dismissing does not suppress the next check: the point is a periodic nudge. It only stops
/// the dialog reappearing the moment it is closed.
final class UpdatePromptDismissalProvider extends $NotifierProvider<UpdatePromptDismissal, Version?> {
  /// Tracks the update prompt so it is shown once per check rather than on every rebuild.
  ///
  /// Dismissing does not suppress the next check: the point is a periodic nudge. It only stops
  /// the dialog reappearing the moment it is closed.
  UpdatePromptDismissalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updatePromptDismissalProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updatePromptDismissalHash();

  @$internal
  @override
  UpdatePromptDismissal create() => UpdatePromptDismissal();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Version? value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<Version?>(value));
  }
}

String _$updatePromptDismissalHash() => r'021f8dc99baf180a970e58dd869c9cab05a6c799';

/// Tracks the update prompt so it is shown once per check rather than on every rebuild.
///
/// Dismissing does not suppress the next check: the point is a periodic nudge. It only stops
/// the dialog reappearing the moment it is closed.

abstract class _$UpdatePromptDismissal extends $Notifier<Version?> {
  Version? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Version?, Version?>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<Version?, Version?>, Version?, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
