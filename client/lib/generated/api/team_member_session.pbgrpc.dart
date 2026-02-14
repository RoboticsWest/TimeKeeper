// This is a generated file - do not edit.
//
// Generated from api/team_member_session.proto.

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

import 'team_member_session.pb.dart' as $0;

export 'team_member_session.pb.dart';

@$pb.GrpcServiceName('tk.api.TeamMemberSessionService')
class TeamMemberSessionServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  TeamMemberSessionServiceClient(super.channel,
      {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.GetTeamMemberSessionsResponse> getTeamMemberSessions(
    $0.GetTeamMemberSessionsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getTeamMemberSessions, request, options: options);
  }

  $grpc.ResponseStream<$0.StreamTeamMemberSessionsResponse>
      streamTeamMemberSessions(
    $0.StreamTeamMemberSessionsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamTeamMemberSessions, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.UpdateTeamMemberSessionResponse>
      updateTeamMemberSession(
    $0.UpdateTeamMemberSessionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateTeamMemberSession, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.DeleteTeamMemberSessionResponse>
      deleteTeamMemberSession(
    $0.DeleteTeamMemberSessionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteTeamMemberSession, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.ImportAttendanceCsvResponse> importAttendanceCsv(
    $0.ImportAttendanceCsvRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$importAttendanceCsv, request, options: options);
  }

  // method descriptors

  static final _$getTeamMemberSessions = $grpc.ClientMethod<
          $0.GetTeamMemberSessionsRequest, $0.GetTeamMemberSessionsResponse>(
      '/tk.api.TeamMemberSessionService/GetTeamMemberSessions',
      ($0.GetTeamMemberSessionsRequest value) => value.writeToBuffer(),
      $0.GetTeamMemberSessionsResponse.fromBuffer);
  static final _$streamTeamMemberSessions = $grpc.ClientMethod<
          $0.StreamTeamMemberSessionsRequest,
          $0.StreamTeamMemberSessionsResponse>(
      '/tk.api.TeamMemberSessionService/StreamTeamMemberSessions',
      ($0.StreamTeamMemberSessionsRequest value) => value.writeToBuffer(),
      $0.StreamTeamMemberSessionsResponse.fromBuffer);
  static final _$updateTeamMemberSession = $grpc.ClientMethod<
          $0.UpdateTeamMemberSessionRequest,
          $0.UpdateTeamMemberSessionResponse>(
      '/tk.api.TeamMemberSessionService/UpdateTeamMemberSession',
      ($0.UpdateTeamMemberSessionRequest value) => value.writeToBuffer(),
      $0.UpdateTeamMemberSessionResponse.fromBuffer);
  static final _$deleteTeamMemberSession = $grpc.ClientMethod<
          $0.DeleteTeamMemberSessionRequest,
          $0.DeleteTeamMemberSessionResponse>(
      '/tk.api.TeamMemberSessionService/DeleteTeamMemberSession',
      ($0.DeleteTeamMemberSessionRequest value) => value.writeToBuffer(),
      $0.DeleteTeamMemberSessionResponse.fromBuffer);
  static final _$importAttendanceCsv = $grpc.ClientMethod<
          $0.ImportAttendanceCsvRequest, $0.ImportAttendanceCsvResponse>(
      '/tk.api.TeamMemberSessionService/ImportAttendanceCsv',
      ($0.ImportAttendanceCsvRequest value) => value.writeToBuffer(),
      $0.ImportAttendanceCsvResponse.fromBuffer);
}

@$pb.GrpcServiceName('tk.api.TeamMemberSessionService')
abstract class TeamMemberSessionServiceBase extends $grpc.Service {
  $core.String get $name => 'tk.api.TeamMemberSessionService';

  TeamMemberSessionServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GetTeamMemberSessionsRequest,
            $0.GetTeamMemberSessionsResponse>(
        'GetTeamMemberSessions',
        getTeamMemberSessions_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetTeamMemberSessionsRequest.fromBuffer(value),
        ($0.GetTeamMemberSessionsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StreamTeamMemberSessionsRequest,
            $0.StreamTeamMemberSessionsResponse>(
        'StreamTeamMemberSessions',
        streamTeamMemberSessions_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.StreamTeamMemberSessionsRequest.fromBuffer(value),
        ($0.StreamTeamMemberSessionsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateTeamMemberSessionRequest,
            $0.UpdateTeamMemberSessionResponse>(
        'UpdateTeamMemberSession',
        updateTeamMemberSession_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateTeamMemberSessionRequest.fromBuffer(value),
        ($0.UpdateTeamMemberSessionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteTeamMemberSessionRequest,
            $0.DeleteTeamMemberSessionResponse>(
        'DeleteTeamMemberSession',
        deleteTeamMemberSession_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteTeamMemberSessionRequest.fromBuffer(value),
        ($0.DeleteTeamMemberSessionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ImportAttendanceCsvRequest,
            $0.ImportAttendanceCsvResponse>(
        'ImportAttendanceCsv',
        importAttendanceCsv_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ImportAttendanceCsvRequest.fromBuffer(value),
        ($0.ImportAttendanceCsvResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetTeamMemberSessionsResponse> getTeamMemberSessions_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetTeamMemberSessionsRequest> $request) async {
    return getTeamMemberSessions($call, await $request);
  }

  $async.Future<$0.GetTeamMemberSessionsResponse> getTeamMemberSessions(
      $grpc.ServiceCall call, $0.GetTeamMemberSessionsRequest request);

  $async.Stream<$0.StreamTeamMemberSessionsResponse>
      streamTeamMemberSessions_Pre($grpc.ServiceCall $call,
          $async.Future<$0.StreamTeamMemberSessionsRequest> $request) async* {
    yield* streamTeamMemberSessions($call, await $request);
  }

  $async.Stream<$0.StreamTeamMemberSessionsResponse> streamTeamMemberSessions(
      $grpc.ServiceCall call, $0.StreamTeamMemberSessionsRequest request);

  $async.Future<$0.UpdateTeamMemberSessionResponse> updateTeamMemberSession_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UpdateTeamMemberSessionRequest> $request) async {
    return updateTeamMemberSession($call, await $request);
  }

  $async.Future<$0.UpdateTeamMemberSessionResponse> updateTeamMemberSession(
      $grpc.ServiceCall call, $0.UpdateTeamMemberSessionRequest request);

  $async.Future<$0.DeleteTeamMemberSessionResponse> deleteTeamMemberSession_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteTeamMemberSessionRequest> $request) async {
    return deleteTeamMemberSession($call, await $request);
  }

  $async.Future<$0.DeleteTeamMemberSessionResponse> deleteTeamMemberSession(
      $grpc.ServiceCall call, $0.DeleteTeamMemberSessionRequest request);

  $async.Future<$0.ImportAttendanceCsvResponse> importAttendanceCsv_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ImportAttendanceCsvRequest> $request) async {
    return importAttendanceCsv($call, await $request);
  }

  $async.Future<$0.ImportAttendanceCsvResponse> importAttendanceCsv(
      $grpc.ServiceCall call, $0.ImportAttendanceCsvRequest request);
}
