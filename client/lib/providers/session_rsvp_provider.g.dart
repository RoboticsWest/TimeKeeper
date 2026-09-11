// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_rsvp_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sessionRsvpChanges)
final sessionRsvpChangesProvider = SessionRsvpChangesProvider._();

final class SessionRsvpChangesProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChangeEvent<SessionRsvp>>,
          ChangeEvent<SessionRsvp>,
          Stream<ChangeEvent<SessionRsvp>>
        >
    with
        $FutureModifier<ChangeEvent<SessionRsvp>>,
        $StreamProvider<ChangeEvent<SessionRsvp>> {
  SessionRsvpChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionRsvpChangesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionRsvpChangesHash();

  @$internal
  @override
  $StreamProviderElement<ChangeEvent<SessionRsvp>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ChangeEvent<SessionRsvp>> create(Ref ref) {
    return sessionRsvpChanges(ref);
  }
}

String _$sessionRsvpChangesHash() =>
    r'0477c1e0a5132d01ab7046700ae502f33e8e6e54';

@ProviderFor(SessionRsvps)
final sessionRsvpsProvider = SessionRsvpsProvider._();

final class SessionRsvpsProvider
    extends $NotifierProvider<SessionRsvps, Map<String, SessionRsvp>> {
  SessionRsvpsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionRsvpsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionRsvpsHash();

  @$internal
  @override
  SessionRsvps create() => SessionRsvps();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, SessionRsvp> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, SessionRsvp>>(value),
    );
  }
}

String _$sessionRsvpsHash() => r'f7a759a8ee971482c8c073648468fe0f8221647c';

abstract class _$SessionRsvps extends $Notifier<Map<String, SessionRsvp>> {
  Map<String, SessionRsvp> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<Map<String, SessionRsvp>, Map<String, SessionRsvp>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, SessionRsvp>, Map<String, SessionRsvp>>,
              Map<String, SessionRsvp>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(sessionRsvpsSync)
final sessionRsvpsSyncProvider = SessionRsvpsSyncProvider._();

final class SessionRsvpsSyncProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  SessionRsvpsSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionRsvpsSyncProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionRsvpsSyncHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return sessionRsvpsSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$sessionRsvpsSyncHash() => r'01d3d4ed7e9315b917bed0cad64a8c67a0acc5f4';
