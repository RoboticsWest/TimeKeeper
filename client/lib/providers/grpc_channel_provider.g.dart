// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grpc_channel_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GrpcChannel)
final grpcChannelProvider = GrpcChannelProvider._();

final class GrpcChannelProvider
    extends $NotifierProvider<GrpcChannel, ClientChannel> {
  GrpcChannelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'grpcChannelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$grpcChannelHash();

  @$internal
  @override
  GrpcChannel create() => GrpcChannel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClientChannel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClientChannel>(value),
    );
  }
}

String _$grpcChannelHash() => r'69b5e978005418208cce780f7f4680db4ee0b9e7';

abstract class _$GrpcChannel extends $Notifier<ClientChannel> {
  ClientChannel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ClientChannel, ClientChannel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ClientChannel, ClientChannel>,
              ClientChannel,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
