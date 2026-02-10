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

  $grpc.ResponseFuture<$0.CreateSessionResponse> createSession(
    $0.CreateSessionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createSession, request, options: options);
  }

  $grpc.ResponseFuture<$0.UpdateSessionResponse> updateSession(
    $0.UpdateSessionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateSession, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeleteSessionResponse> deleteSession(
    $0.DeleteSessionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteSession, request, options: options);
  }

  $grpc.ResponseFuture<$0.CheckInOutResponse> checkInOut(
    $0.CheckInOutRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$checkInOut, request, options: options);
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
  static final _$createSession =
      $grpc.ClientMethod<$0.CreateSessionRequest, $0.CreateSessionResponse>(
          '/tk.api.SessionService/CreateSession',
          ($0.CreateSessionRequest value) => value.writeToBuffer(),
          $0.CreateSessionResponse.fromBuffer);
  static final _$updateSession =
      $grpc.ClientMethod<$0.UpdateSessionRequest, $0.UpdateSessionResponse>(
          '/tk.api.SessionService/UpdateSession',
          ($0.UpdateSessionRequest value) => value.writeToBuffer(),
          $0.UpdateSessionResponse.fromBuffer);
  static final _$deleteSession =
      $grpc.ClientMethod<$0.DeleteSessionRequest, $0.DeleteSessionResponse>(
          '/tk.api.SessionService/DeleteSession',
          ($0.DeleteSessionRequest value) => value.writeToBuffer(),
          $0.DeleteSessionResponse.fromBuffer);
  static final _$checkInOut =
      $grpc.ClientMethod<$0.CheckInOutRequest, $0.CheckInOutResponse>(
          '/tk.api.SessionService/CheckInOut',
          ($0.CheckInOutRequest value) => value.writeToBuffer(),
          $0.CheckInOutResponse.fromBuffer);
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
    $addMethod(
        $grpc.ServiceMethod<$0.CreateSessionRequest, $0.CreateSessionResponse>(
            'CreateSession',
            createSession_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.CreateSessionRequest.fromBuffer(value),
            ($0.CreateSessionResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.UpdateSessionRequest, $0.UpdateSessionResponse>(
            'UpdateSession',
            updateSession_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.UpdateSessionRequest.fromBuffer(value),
            ($0.UpdateSessionResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.DeleteSessionRequest, $0.DeleteSessionResponse>(
            'DeleteSession',
            deleteSession_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.DeleteSessionRequest.fromBuffer(value),
            ($0.DeleteSessionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CheckInOutRequest, $0.CheckInOutResponse>(
        'CheckInOut',
        checkInOut_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CheckInOutRequest.fromBuffer(value),
        ($0.CheckInOutResponse value) => value.writeToBuffer()));
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

  $async.Future<$0.CreateSessionResponse> createSession_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CreateSessionRequest> $request) async {
    return createSession($call, await $request);
  }

  $async.Future<$0.CreateSessionResponse> createSession(
      $grpc.ServiceCall call, $0.CreateSessionRequest request);

  $async.Future<$0.UpdateSessionResponse> updateSession_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UpdateSessionRequest> $request) async {
    return updateSession($call, await $request);
  }

  $async.Future<$0.UpdateSessionResponse> updateSession(
      $grpc.ServiceCall call, $0.UpdateSessionRequest request);

  $async.Future<$0.DeleteSessionResponse> deleteSession_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteSessionRequest> $request) async {
    return deleteSession($call, await $request);
  }

  $async.Future<$0.DeleteSessionResponse> deleteSession(
      $grpc.ServiceCall call, $0.DeleteSessionRequest request);

  $async.Future<$0.CheckInOutResponse> checkInOut_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CheckInOutRequest> $request) async {
    return checkInOut($call, await $request);
  }

  $async.Future<$0.CheckInOutResponse> checkInOut(
      $grpc.ServiceCall call, $0.CheckInOutRequest request);
}
