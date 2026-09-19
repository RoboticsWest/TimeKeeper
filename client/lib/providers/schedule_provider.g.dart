// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ScheduleService)
final scheduleServiceProvider = ScheduleServiceProvider._();

final class ScheduleServiceProvider extends $NotifierProvider<ScheduleService, void> {
  ScheduleServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scheduleServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scheduleServiceHash();

  @$internal
  @override
  ScheduleService create() => ScheduleService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<void>(value));
  }
}

String _$scheduleServiceHash() => r'4930d5c6380c21c50dcc894f7715ead6d86550ed';

abstract class _$ScheduleService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<void, void>, void, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
