// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rfid_tag_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(rfidTagChanges)
final rfidTagChangesProvider = RfidTagChangesProvider._();

final class RfidTagChangesProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChangeEvent<RfidTag>>,
          ChangeEvent<RfidTag>,
          Stream<ChangeEvent<RfidTag>>
        >
    with
        $FutureModifier<ChangeEvent<RfidTag>>,
        $StreamProvider<ChangeEvent<RfidTag>> {
  RfidTagChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rfidTagChangesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rfidTagChangesHash();

  @$internal
  @override
  $StreamProviderElement<ChangeEvent<RfidTag>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ChangeEvent<RfidTag>> create(Ref ref) {
    return rfidTagChanges(ref);
  }
}

String _$rfidTagChangesHash() => r'cc04948f4f520a7413d2ca43dc97dbdea7c6584e';

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

String _$rfidTagsHash() => r'd29a6030bdf15bd814ca282e7aada40a2019e65a';

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

@ProviderFor(rfidTagsSync)
final rfidTagsSyncProvider = RfidTagsSyncProvider._();

final class RfidTagsSyncProvider extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  RfidTagsSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rfidTagsSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rfidTagsSyncHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return rfidTagsSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$rfidTagsSyncHash() => r'91f21816580bdbd8fcfc4d4d1367796fde2cc331';

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
