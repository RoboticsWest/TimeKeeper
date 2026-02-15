// This is a generated file - do not edit.
//
// Generated from api/session_rsvp.proto.

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

import 'session_rsvp.pb.dart' as $0;

export 'session_rsvp.pb.dart';

@$pb.GrpcServiceName('tk.api.SessionRsvpService')
class SessionRsvpServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  SessionRsvpServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.GetSessionRsvpsResponse> getSessionRsvps(
    $0.GetSessionRsvpsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getSessionRsvps, request, options: options);
  }

  $grpc.ResponseStream<$0.StreamSessionRsvpsResponse> streamSessionRsvps(
    $0.StreamSessionRsvpsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamSessionRsvps, $async.Stream.fromIterable([request]),
        options: options);
  }

  // method descriptors

  static final _$getSessionRsvps =
      $grpc.ClientMethod<$0.GetSessionRsvpsRequest, $0.GetSessionRsvpsResponse>(
          '/tk.api.SessionRsvpService/GetSessionRsvps',
          ($0.GetSessionRsvpsRequest value) => value.writeToBuffer(),
          $0.GetSessionRsvpsResponse.fromBuffer);
  static final _$streamSessionRsvps = $grpc.ClientMethod<
          $0.StreamSessionRsvpsRequest, $0.StreamSessionRsvpsResponse>(
      '/tk.api.SessionRsvpService/StreamSessionRsvps',
      ($0.StreamSessionRsvpsRequest value) => value.writeToBuffer(),
      $0.StreamSessionRsvpsResponse.fromBuffer);
}

@$pb.GrpcServiceName('tk.api.SessionRsvpService')
abstract class SessionRsvpServiceBase extends $grpc.Service {
  $core.String get $name => 'tk.api.SessionRsvpService';

  SessionRsvpServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GetSessionRsvpsRequest,
            $0.GetSessionRsvpsResponse>(
        'GetSessionRsvps',
        getSessionRsvps_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetSessionRsvpsRequest.fromBuffer(value),
        ($0.GetSessionRsvpsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StreamSessionRsvpsRequest,
            $0.StreamSessionRsvpsResponse>(
        'StreamSessionRsvps',
        streamSessionRsvps_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.StreamSessionRsvpsRequest.fromBuffer(value),
        ($0.StreamSessionRsvpsResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetSessionRsvpsResponse> getSessionRsvps_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetSessionRsvpsRequest> $request) async {
    return getSessionRsvps($call, await $request);
  }

  $async.Future<$0.GetSessionRsvpsResponse> getSessionRsvps(
      $grpc.ServiceCall call, $0.GetSessionRsvpsRequest request);

  $async.Stream<$0.StreamSessionRsvpsResponse> streamSessionRsvps_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.StreamSessionRsvpsRequest> $request) async* {
    yield* streamSessionRsvps($call, await $request);
  }

  $async.Stream<$0.StreamSessionRsvpsResponse> streamSessionRsvps(
      $grpc.ServiceCall call, $0.StreamSessionRsvpsRequest request);
}
