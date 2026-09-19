// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationChanges)
final notificationChangesProvider = NotificationChangesProvider._();

final class NotificationChangesProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChangeEvent<Notification>>,
          ChangeEvent<Notification>,
          Stream<ChangeEvent<Notification>>
        >
    with $FutureModifier<ChangeEvent<Notification>>, $StreamProvider<ChangeEvent<Notification>> {
  NotificationChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationChangesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationChangesHash();

  @$internal
  @override
  $StreamProviderElement<ChangeEvent<Notification>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<ChangeEvent<Notification>> create(Ref ref) {
    return notificationChanges(ref);
  }
}

String _$notificationChangesHash() => r'9e4b757110d211d50c99959386aca8e6363bf630';

@ProviderFor(Notifications)
final notificationsProvider = NotificationsProvider._();

final class NotificationsProvider extends $NotifierProvider<Notifications, Map<String, Notification>> {
  NotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsHash();

  @$internal
  @override
  Notifications create() => Notifications();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, Notification> value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<Map<String, Notification>>(value));
  }
}

String _$notificationsHash() => r'bbfdaefe48f248cb006a18738e90c4b9d7da81a0';

abstract class _$Notifications extends $Notifier<Map<String, Notification>> {
  Map<String, Notification> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, Notification>, Map<String, Notification>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, Notification>, Map<String, Notification>>,
              Map<String, Notification>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(notificationsSync)
final notificationsSyncProvider = NotificationsSyncProvider._();

final class NotificationsSyncProvider extends $FunctionalProvider<void, void, void> with $Provider<void> {
  NotificationsSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsSyncHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return notificationsSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<void>(value));
  }
}

String _$notificationsSyncHash() => r'2e071382427c4c23aef5e5a32063e88501b6f9fc';
