// This is a generated file - do not edit.
//
// Generated from api/session.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'session.pb.dart' as $0;

export 'session.pb.dart';

@$pb.GrpcServiceName('tk.api.SessionService')
class SessionServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  SessionServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.GetSessionsResponse> getSessions(
    $0.GetSessionsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getSessions, request, options: options);
  }

  $grpc.ResponseStream<$0.StreamSessionsResponse> streamSessions(
    $0.StreamSessionsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamSessions, $async.Stream.fromIterable([request]),
        options: options);
  }

  // method descriptors

  static final _$getSessions =
      $grpc.ClientMethod<$0.GetSessionsRequest, $0.GetSessionsResponse>(
          '/tk.api.SessionService/GetSessions',
          ($0.GetSessionsRequest value) => value.writeToBuffer(),
          $0.GetSessionsResponse.fromBuffer);
  static final _$streamSessions =
      $grpc.ClientMethod<$0.StreamSessionsRequest, $0.StreamSessionsResponse>(
          '/tk.api.SessionService/StreamSessions',
          ($0.StreamSessionsRequest value) => value.writeToBuffer(),
          $0.StreamSessionsResponse.fromBuffer);
}

@$pb.GrpcServiceName('tk.api.SessionService')
abstract class SessionServiceBase extends $grpc.Service {
  $core.String get $name => 'tk.api.SessionService';

  SessionServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.GetSessionsRequest, $0.GetSessionsResponse>(
            'GetSessions',
            getSessions_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetSessionsRequest.fromBuffer(value),
            ($0.GetSessionsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StreamSessionsRequest,
            $0.StreamSessionsResponse>(
        'StreamSessions',
        streamSessions_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.StreamSessionsRequest.fromBuffer(value),
        ($0.StreamSessionsResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetSessionsResponse> getSessions_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetSessionsRequest> $request) async {
    return getSessions($call, await $request);
  }

  $async.Future<$0.GetSessionsResponse> getSessions(
      $grpc.ServiceCall call, $0.GetSessionsRequest request);

  $async.Stream<$0.StreamSessionsResponse> streamSessions_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.StreamSessionsRequest> $request) async* {
    yield* streamSessions($call, await $request);
  }

  $async.Stream<$0.StreamSessionsResponse> streamSessions(
      $grpc.ServiceCall call, $0.StreamSessionsRequest request);
}
