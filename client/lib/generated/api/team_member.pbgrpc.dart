// This is a generated file - do not edit.
//
// Generated from api/team_member.proto.

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

import 'team_member.pb.dart' as $0;

export 'team_member.pb.dart';

@$pb.GrpcServiceName('tk.api.TeamMemberService')
class TeamMemberServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  TeamMemberServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.UploadStudentCsvResponse> uploadStudentCsv(
    $0.UploadStudentCsvRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$uploadStudentCsv, request, options: options);
  }

  $grpc.ResponseFuture<$0.UploadMentorCsvResponse> uploadMentorCsv(
    $0.UploadMentorCsvRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$uploadMentorCsv, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetTeamMembersResponse> getTeamMembers(
    $0.GetTeamMembersRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getTeamMembers, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetStudentsResponse> getStudents(
    $0.GetStudentsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getStudents, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetMentorsResponse> getMentors(
    $0.GetMentorsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getMentors, request, options: options);
  }

  $grpc.ResponseStream<$0.StreamTeamMembersResponse> streamTeamMembers(
    $0.StreamTeamMembersRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamTeamMembers, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseStream<$0.StreamStudentsResponse> streamStudents(
    $0.StreamStudentsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamStudents, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseStream<$0.StreamMentorsResponse> streamMentors(
    $0.StreamMentorsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamMentors, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.CreateTeamMemberResponse> createTeamMember(
    $0.CreateTeamMemberRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createTeamMember, request, options: options);
  }

  $grpc.ResponseFuture<$0.UpdateTeamMemberResponse> updateTeamMember(
    $0.UpdateTeamMemberRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateTeamMember, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeleteTeamMemberResponse> deleteTeamMember(
    $0.DeleteTeamMemberRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteTeamMember, request, options: options);
  }

  // method descriptors

  static final _$uploadStudentCsv = $grpc.ClientMethod<
          $0.UploadStudentCsvRequest, $0.UploadStudentCsvResponse>(
      '/tk.api.TeamMemberService/UploadStudentCsv',
      ($0.UploadStudentCsvRequest value) => value.writeToBuffer(),
      $0.UploadStudentCsvResponse.fromBuffer);
  static final _$uploadMentorCsv =
      $grpc.ClientMethod<$0.UploadMentorCsvRequest, $0.UploadMentorCsvResponse>(
          '/tk.api.TeamMemberService/UploadMentorCsv',
          ($0.UploadMentorCsvRequest value) => value.writeToBuffer(),
          $0.UploadMentorCsvResponse.fromBuffer);
  static final _$getTeamMembers =
      $grpc.ClientMethod<$0.GetTeamMembersRequest, $0.GetTeamMembersResponse>(
          '/tk.api.TeamMemberService/GetTeamMembers',
          ($0.GetTeamMembersRequest value) => value.writeToBuffer(),
          $0.GetTeamMembersResponse.fromBuffer);
  static final _$getStudents =
      $grpc.ClientMethod<$0.GetStudentsRequest, $0.GetStudentsResponse>(
          '/tk.api.TeamMemberService/GetStudents',
          ($0.GetStudentsRequest value) => value.writeToBuffer(),
          $0.GetStudentsResponse.fromBuffer);
  static final _$getMentors =
      $grpc.ClientMethod<$0.GetMentorsRequest, $0.GetMentorsResponse>(
          '/tk.api.TeamMemberService/GetMentors',
          ($0.GetMentorsRequest value) => value.writeToBuffer(),
          $0.GetMentorsResponse.fromBuffer);
  static final _$streamTeamMembers = $grpc.ClientMethod<
          $0.StreamTeamMembersRequest, $0.StreamTeamMembersResponse>(
      '/tk.api.TeamMemberService/StreamTeamMembers',
      ($0.StreamTeamMembersRequest value) => value.writeToBuffer(),
      $0.StreamTeamMembersResponse.fromBuffer);
  static final _$streamStudents =
      $grpc.ClientMethod<$0.StreamStudentsRequest, $0.StreamStudentsResponse>(
          '/tk.api.TeamMemberService/StreamStudents',
          ($0.StreamStudentsRequest value) => value.writeToBuffer(),
          $0.StreamStudentsResponse.fromBuffer);
  static final _$streamMentors =
      $grpc.ClientMethod<$0.StreamMentorsRequest, $0.StreamMentorsResponse>(
          '/tk.api.TeamMemberService/StreamMentors',
          ($0.StreamMentorsRequest value) => value.writeToBuffer(),
          $0.StreamMentorsResponse.fromBuffer);
  static final _$createTeamMember = $grpc.ClientMethod<
          $0.CreateTeamMemberRequest, $0.CreateTeamMemberResponse>(
      '/tk.api.TeamMemberService/CreateTeamMember',
      ($0.CreateTeamMemberRequest value) => value.writeToBuffer(),
      $0.CreateTeamMemberResponse.fromBuffer);
  static final _$updateTeamMember = $grpc.ClientMethod<
          $0.UpdateTeamMemberRequest, $0.UpdateTeamMemberResponse>(
      '/tk.api.TeamMemberService/UpdateTeamMember',
      ($0.UpdateTeamMemberRequest value) => value.writeToBuffer(),
      $0.UpdateTeamMemberResponse.fromBuffer);
  static final _$deleteTeamMember = $grpc.ClientMethod<
          $0.DeleteTeamMemberRequest, $0.DeleteTeamMemberResponse>(
      '/tk.api.TeamMemberService/DeleteTeamMember',
      ($0.DeleteTeamMemberRequest value) => value.writeToBuffer(),
      $0.DeleteTeamMemberResponse.fromBuffer);
}

@$pb.GrpcServiceName('tk.api.TeamMemberService')
abstract class TeamMemberServiceBase extends $grpc.Service {
  $core.String get $name => 'tk.api.TeamMemberService';

  TeamMemberServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.UploadStudentCsvRequest,
            $0.UploadStudentCsvResponse>(
        'UploadStudentCsv',
        uploadStudentCsv_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UploadStudentCsvRequest.fromBuffer(value),
        ($0.UploadStudentCsvResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UploadMentorCsvRequest,
            $0.UploadMentorCsvResponse>(
        'UploadMentorCsv',
        uploadMentorCsv_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UploadMentorCsvRequest.fromBuffer(value),
        ($0.UploadMentorCsvResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetTeamMembersRequest,
            $0.GetTeamMembersResponse>(
        'GetTeamMembers',
        getTeamMembers_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetTeamMembersRequest.fromBuffer(value),
        ($0.GetTeamMembersResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetStudentsRequest, $0.GetStudentsResponse>(
            'GetStudents',
            getStudents_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetStudentsRequest.fromBuffer(value),
            ($0.GetStudentsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetMentorsRequest, $0.GetMentorsResponse>(
        'GetMentors',
        getMentors_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetMentorsRequest.fromBuffer(value),
        ($0.GetMentorsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StreamTeamMembersRequest,
            $0.StreamTeamMembersResponse>(
        'StreamTeamMembers',
        streamTeamMembers_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.StreamTeamMembersRequest.fromBuffer(value),
        ($0.StreamTeamMembersResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StreamStudentsRequest,
            $0.StreamStudentsResponse>(
        'StreamStudents',
        streamStudents_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.StreamStudentsRequest.fromBuffer(value),
        ($0.StreamStudentsResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.StreamMentorsRequest, $0.StreamMentorsResponse>(
            'StreamMentors',
            streamMentors_Pre,
            false,
            true,
            ($core.List<$core.int> value) =>
                $0.StreamMentorsRequest.fromBuffer(value),
            ($0.StreamMentorsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateTeamMemberRequest,
            $0.CreateTeamMemberResponse>(
        'CreateTeamMember',
        createTeamMember_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CreateTeamMemberRequest.fromBuffer(value),
        ($0.CreateTeamMemberResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateTeamMemberRequest,
            $0.UpdateTeamMemberResponse>(
        'UpdateTeamMember',
        updateTeamMember_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateTeamMemberRequest.fromBuffer(value),
        ($0.UpdateTeamMemberResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteTeamMemberRequest,
            $0.DeleteTeamMemberResponse>(
        'DeleteTeamMember',
        deleteTeamMember_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteTeamMemberRequest.fromBuffer(value),
        ($0.DeleteTeamMemberResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.UploadStudentCsvResponse> uploadStudentCsv_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UploadStudentCsvRequest> $request) async {
    return uploadStudentCsv($call, await $request);
  }

  $async.Future<$0.UploadStudentCsvResponse> uploadStudentCsv(
      $grpc.ServiceCall call, $0.UploadStudentCsvRequest request);

  $async.Future<$0.UploadMentorCsvResponse> uploadMentorCsv_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UploadMentorCsvRequest> $request) async {
    return uploadMentorCsv($call, await $request);
  }

  $async.Future<$0.UploadMentorCsvResponse> uploadMentorCsv(
      $grpc.ServiceCall call, $0.UploadMentorCsvRequest request);

  $async.Future<$0.GetTeamMembersResponse> getTeamMembers_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetTeamMembersRequest> $request) async {
    return getTeamMembers($call, await $request);
  }

  $async.Future<$0.GetTeamMembersResponse> getTeamMembers(
      $grpc.ServiceCall call, $0.GetTeamMembersRequest request);

  $async.Future<$0.GetStudentsResponse> getStudents_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetStudentsRequest> $request) async {
    return getStudents($call, await $request);
  }

  $async.Future<$0.GetStudentsResponse> getStudents(
      $grpc.ServiceCall call, $0.GetStudentsRequest request);

  $async.Future<$0.GetMentorsResponse> getMentors_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetMentorsRequest> $request) async {
    return getMentors($call, await $request);
  }

  $async.Future<$0.GetMentorsResponse> getMentors(
      $grpc.ServiceCall call, $0.GetMentorsRequest request);

  $async.Stream<$0.StreamTeamMembersResponse> streamTeamMembers_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.StreamTeamMembersRequest> $request) async* {
    yield* streamTeamMembers($call, await $request);
  }

  $async.Stream<$0.StreamTeamMembersResponse> streamTeamMembers(
      $grpc.ServiceCall call, $0.StreamTeamMembersRequest request);

  $async.Stream<$0.StreamStudentsResponse> streamStudents_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.StreamStudentsRequest> $request) async* {
    yield* streamStudents($call, await $request);
  }

  $async.Stream<$0.StreamStudentsResponse> streamStudents(
      $grpc.ServiceCall call, $0.StreamStudentsRequest request);

  $async.Stream<$0.StreamMentorsResponse> streamMentors_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.StreamMentorsRequest> $request) async* {
    yield* streamMentors($call, await $request);
  }

  $async.Stream<$0.StreamMentorsResponse> streamMentors(
      $grpc.ServiceCall call, $0.StreamMentorsRequest request);

  $async.Future<$0.CreateTeamMemberResponse> createTeamMember_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CreateTeamMemberRequest> $request) async {
    return createTeamMember($call, await $request);
  }

  $async.Future<$0.CreateTeamMemberResponse> createTeamMember(
      $grpc.ServiceCall call, $0.CreateTeamMemberRequest request);

  $async.Future<$0.UpdateTeamMemberResponse> updateTeamMember_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UpdateTeamMemberRequest> $request) async {
    return updateTeamMember($call, await $request);
  }

  $async.Future<$0.UpdateTeamMemberResponse> updateTeamMember(
      $grpc.ServiceCall call, $0.UpdateTeamMemberRequest request);

  $async.Future<$0.DeleteTeamMemberResponse> deleteTeamMember_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteTeamMemberRequest> $request) async {
    return deleteTeamMember($call, await $request);
  }

  $async.Future<$0.DeleteTeamMemberResponse> deleteTeamMember(
      $grpc.ServiceCall call, $0.DeleteTeamMemberRequest request);
}
