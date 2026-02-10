import 'package:grpc/service_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/providers/network_config_provider.dart';
import 'package:time_keeper/utils/logger.dart';

import 'grpc_channel_factory_stub.dart'
    if (dart.library.io) 'grpc_channel_factory_native.dart'
    if (dart.library.js_interop) 'grpc_channel_factory_web.dart';

part 'grpc_channel_provider.g.dart';

@Riverpod(keepAlive: true)
class GrpcChannel extends _$GrpcChannel {
  void reconnect() {
    logger.i('Reconnecting gRPC channel on next access...');
    ref.invalidateSelf();
  }

  @override
  ClientChannel build() {
    final serverIp = ref.watch(serverIpProvider);
    final apiPort = ref.watch(serverApiPortProvider);
    final tls = ref.watch(tlsProvider);

    final channel = createChannel(host: serverIp, port: apiPort, tls: tls);

    ref.onDispose(() {
      channel.shutdown();
    });

    logger.i('gRPC channel created: $serverIp:$apiPort (TLS: $tls)');
    return channel;
  }
}
