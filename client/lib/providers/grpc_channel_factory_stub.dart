import 'package:grpc/service_api.dart';

ClientChannel createChannel({
  required String host,
  required int port,
  required bool tls,
}) {
  throw UnsupportedError(
    'Cannot create a channel without dart:io or dart:js_interop',
  );
}
