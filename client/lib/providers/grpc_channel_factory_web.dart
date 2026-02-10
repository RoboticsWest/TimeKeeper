import 'package:grpc/grpc_web.dart';
import 'package:grpc/service_api.dart' as api;

api.ClientChannel createChannel({
  required String host,
  required int port,
  required bool tls,
}) {
  final protocol = tls ? 'https' : 'http';
  return GrpcWebClientChannel.xhr(Uri.parse('$protocol://$host:$port'));
}
