// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_rsvp_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sessionRsvpService)
final sessionRsvpServiceProvider = SessionRsvpServiceProvider._();

final class SessionRsvpServiceProvider
    extends
        $FunctionalProvider<
          SessionRsvpServiceClient,
          SessionRsvpServiceClient,
          SessionRsvpServiceClient
        >
    with $Provider<SessionRsvpServiceClient> {
  SessionRsvpServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionRsvpServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionRsvpServiceHash();

  @$internal
  @override
  $ProviderElement<SessionRsvpServiceClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SessionRsvpServiceClient create(Ref ref) {
    return sessionRsvpService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionRsvpServiceClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionRsvpServiceClient>(value),
    );
  }
}

String _$sessionRsvpServiceHash() =>
    r'40b97534679c94875f885ce39f538641174b011e';

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

String _$sessionRsvpsHash() => r'9f00706ad25296303811aab025c410f896ca9c05';

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
