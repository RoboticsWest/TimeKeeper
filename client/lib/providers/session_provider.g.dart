// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sessionService)
final sessionServiceProvider = SessionServiceProvider._();

final class SessionServiceProvider
    extends
        $FunctionalProvider<
          SessionServiceClient,
          SessionServiceClient,
          SessionServiceClient
        >
    with $Provider<SessionServiceClient> {
  SessionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionServiceHash();

  @$internal
  @override
  $ProviderElement<SessionServiceClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SessionServiceClient create(Ref ref) {
    return sessionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionServiceClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionServiceClient>(value),
    );
  }
}

String _$sessionServiceHash() => r'98770a0f26c90f5472060e01c54ccc583fd5573e';

@ProviderFor(sessionsStream)
final sessionsStreamProvider = SessionsStreamProvider._();

final class SessionsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<StreamSessionsResponse>,
          StreamSessionsResponse,
          Stream<StreamSessionsResponse>
        >
    with
        $FutureModifier<StreamSessionsResponse>,
        $StreamProvider<StreamSessionsResponse> {
  SessionsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionsStreamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionsStreamHash();

  @$internal
  @override
  $StreamProviderElement<StreamSessionsResponse> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<StreamSessionsResponse> create(Ref ref) {
    return sessionsStream(ref);
  }
}

String _$sessionsStreamHash() => r'66491242b1b9d5156509c8c315562dc2333869cb';

@ProviderFor(Sessions)
final sessionsProvider = SessionsProvider._();

final class SessionsProvider
    extends $NotifierProvider<Sessions, Map<String, Session>> {
  SessionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionsHash();

  @$internal
  @override
  Sessions create() => Sessions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, Session> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, Session>>(value),
    );
  }
}

String _$sessionsHash() => r'016b85181a79b84edf3fe259a9e3f4aa3a929bff';

abstract class _$Sessions extends $Notifier<Map<String, Session>> {
  Map<String, Session> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, Session>, Map<String, Session>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, Session>, Map<String, Session>>,
              Map<String, Session>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
