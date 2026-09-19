// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sessionChanges)
final sessionChangesProvider = SessionChangesProvider._();

final class SessionChangesProvider
    extends $FunctionalProvider<AsyncValue<ChangeEvent<Session>>, ChangeEvent<Session>, Stream<ChangeEvent<Session>>>
    with $FutureModifier<ChangeEvent<Session>>, $StreamProvider<ChangeEvent<Session>> {
  SessionChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionChangesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionChangesHash();

  @$internal
  @override
  $StreamProviderElement<ChangeEvent<Session>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<ChangeEvent<Session>> create(Ref ref) {
    return sessionChanges(ref);
  }
}

String _$sessionChangesHash() => r'6f4d879aa536883ab6676d85ada36110134394f7';

@ProviderFor(Sessions)
final sessionsProvider = SessionsProvider._();

final class SessionsProvider extends $NotifierProvider<Sessions, Map<String, Session>> {
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
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<Map<String, Session>>(value));
  }
}

String _$sessionsHash() => r'cc5065c71aa673663db173348cc6a6cea547e3cb';

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

@ProviderFor(sessionsSync)
final sessionsSyncProvider = SessionsSyncProvider._();

final class SessionsSyncProvider extends $FunctionalProvider<void, void, void> with $Provider<void> {
  SessionsSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionsSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionsSyncHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return sessionsSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<void>(value));
  }
}

String _$sessionsSyncHash() => r'c7e9abf8cdefc71c513cd1dd374cf4de102e9598';

/// Kiosk RFID check-in/out. Returns `true` if the member is now checked in, `false` if checked out.

@ProviderFor(SessionCheckInOut)
final sessionCheckInOutProvider = SessionCheckInOutProvider._();

/// Kiosk RFID check-in/out. Returns `true` if the member is now checked in, `false` if checked out.
final class SessionCheckInOutProvider extends $NotifierProvider<SessionCheckInOut, void> {
  /// Kiosk RFID check-in/out. Returns `true` if the member is now checked in, `false` if checked out.
  SessionCheckInOutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionCheckInOutProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionCheckInOutHash();

  @$internal
  @override
  SessionCheckInOut create() => SessionCheckInOut();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<void>(value));
  }
}

String _$sessionCheckInOutHash() => r'6131d6ea6e8f33ca65853cb7e477676104a94349';

/// Kiosk RFID check-in/out. Returns `true` if the member is now checked in, `false` if checked out.

abstract class _$SessionCheckInOut extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<void, void>, void, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
