import 'package:grpc/grpc.dart';
import 'package:grpc/service_api.dart' as api;

api.ClientChannel createChannel({
  required String host,
  required int port,
  required bool tls,
}) {
  final credentials = tls
      ? ChannelCredentials.secure()
      : ChannelCredentials.insecure();

  return ClientChannel(
    host,
    port: port,
    options: ChannelOptions(
      credentials: credentials,
      connectTimeout: Duration(seconds: 10),
    ),
  );
}
