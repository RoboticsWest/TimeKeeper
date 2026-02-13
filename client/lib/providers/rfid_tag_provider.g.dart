// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rfid_tag_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(rfidTagService)
final rfidTagServiceProvider = RfidTagServiceProvider._();

final class RfidTagServiceProvider
    extends
        $FunctionalProvider<
          RfidTagServiceClient,
          RfidTagServiceClient,
          RfidTagServiceClient
        >
    with $Provider<RfidTagServiceClient> {
  RfidTagServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rfidTagServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rfidTagServiceHash();

  @$internal
  @override
  $ProviderElement<RfidTagServiceClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RfidTagServiceClient create(Ref ref) {
    return rfidTagService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RfidTagServiceClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RfidTagServiceClient>(value),
    );
  }
}

String _$rfidTagServiceHash() => r'cc13184c89749caeccc45c33f996ec55f1711918';

@ProviderFor(rfidTagsStream)
final rfidTagsStreamProvider = RfidTagsStreamProvider._();

final class RfidTagsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<StreamRfidTagsResponse>,
          StreamRfidTagsResponse,
          Stream<StreamRfidTagsResponse>
        >
    with
        $FutureModifier<StreamRfidTagsResponse>,
        $StreamProvider<StreamRfidTagsResponse> {
  RfidTagsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rfidTagsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rfidTagsStreamHash();

  @$internal
  @override
  $StreamProviderElement<StreamRfidTagsResponse> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<StreamRfidTagsResponse> create(Ref ref) {
    return rfidTagsStream(ref);
  }
}

String _$rfidTagsStreamHash() => r'8b49900ecb3a39e428eec35aa4953f074c4a81b1';

@ProviderFor(RfidTags)
final rfidTagsProvider = RfidTagsProvider._();

final class RfidTagsProvider
    extends $NotifierProvider<RfidTags, Map<String, RfidTag>> {
  RfidTagsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rfidTagsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rfidTagsHash();

  @$internal
  @override
  RfidTags create() => RfidTags();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, RfidTag> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, RfidTag>>(value),
    );
  }
}

String _$rfidTagsHash() => r'25fce69832cd01e7f2a5ed4bb562e5c7a4406e2f';

abstract class _$RfidTags extends $Notifier<Map<String, RfidTag>> {
  Map<String, RfidTag> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, RfidTag>, Map<String, RfidTag>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, RfidTag>, Map<String, RfidTag>>,
              Map<String, RfidTag>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(rfidTagsByMember)
final rfidTagsByMemberProvider = RfidTagsByMemberFamily._();

final class RfidTagsByMemberProvider
    extends
        $FunctionalProvider<
          Map<String, RfidTag>,
          Map<String, RfidTag>,
          Map<String, RfidTag>
        >
    with $Provider<Map<String, RfidTag>> {
  RfidTagsByMemberProvider._({
    required RfidTagsByMemberFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'rfidTagsByMemberProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$rfidTagsByMemberHash();

  @override
  String toString() {
    return r'rfidTagsByMemberProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Map<String, RfidTag>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, RfidTag> create(Ref ref) {
    final argument = this.argument as String;
    return rfidTagsByMember(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, RfidTag> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, RfidTag>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RfidTagsByMemberProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$rfidTagsByMemberHash() => r'fe9f1878874bc31d787bd614f9d364a23318e19a';

final class RfidTagsByMemberFamily extends $Family
    with $FunctionalFamilyOverride<Map<String, RfidTag>, String> {
  RfidTagsByMemberFamily._()
    : super(
        retry: null,
        name: r'rfidTagsByMemberProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  RfidTagsByMemberProvider call(String memberId) =>
      RfidTagsByMemberProvider._(argument: memberId, from: this);

  @override
  String toString() => r'rfidTagsByMemberProvider';
}
