// This is a generated file - do not edit.
//
// Generated from api/user.proto.

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

import 'user.pb.dart' as $0;

export 'user.pb.dart';

@$pb.GrpcServiceName('tk.api.UserService')
class UserServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  UserServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.LoginResponse> login(
    $0.LoginRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$login, request, options: options);
  }

  $grpc.ResponseFuture<$0.ValidateTokenResponse> validateToken(
    $0.ValidateTokenRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$validateToken, request, options: options);
  }

  $grpc.ResponseFuture<$0.UpdateAdminPasswordResponse> updateAdminPassword(
    $0.UpdateAdminPasswordRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateAdminPassword, request, options: options);
  }

  $grpc.ResponseStream<$0.StreamUsersResponse> streamUsers(
    $0.StreamUsersRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamUsers, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.CreateUserResponse> createUser(
    $0.CreateUserRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createUser, request, options: options);
  }

  $grpc.ResponseFuture<$0.UpdateUserResponse> updateUser(
    $0.UpdateUserRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateUser, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeleteUserResponse> deleteUser(
    $0.DeleteUserRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteUser, request, options: options);
  }

  // method descriptors

  static final _$login = $grpc.ClientMethod<$0.LoginRequest, $0.LoginResponse>(
      '/tk.api.UserService/Login',
      ($0.LoginRequest value) => value.writeToBuffer(),
      $0.LoginResponse.fromBuffer);
  static final _$validateToken =
      $grpc.ClientMethod<$0.ValidateTokenRequest, $0.ValidateTokenResponse>(
          '/tk.api.UserService/ValidateToken',
          ($0.ValidateTokenRequest value) => value.writeToBuffer(),
          $0.ValidateTokenResponse.fromBuffer);
  static final _$updateAdminPassword = $grpc.ClientMethod<
          $0.UpdateAdminPasswordRequest, $0.UpdateAdminPasswordResponse>(
      '/tk.api.UserService/UpdateAdminPassword',
      ($0.UpdateAdminPasswordRequest value) => value.writeToBuffer(),
      $0.UpdateAdminPasswordResponse.fromBuffer);
  static final _$streamUsers =
      $grpc.ClientMethod<$0.StreamUsersRequest, $0.StreamUsersResponse>(
          '/tk.api.UserService/StreamUsers',
          ($0.StreamUsersRequest value) => value.writeToBuffer(),
          $0.StreamUsersResponse.fromBuffer);
  static final _$createUser =
      $grpc.ClientMethod<$0.CreateUserRequest, $0.CreateUserResponse>(
          '/tk.api.UserService/CreateUser',
          ($0.CreateUserRequest value) => value.writeToBuffer(),
          $0.CreateUserResponse.fromBuffer);
  static final _$updateUser =
      $grpc.ClientMethod<$0.UpdateUserRequest, $0.UpdateUserResponse>(
          '/tk.api.UserService/UpdateUser',
          ($0.UpdateUserRequest value) => value.writeToBuffer(),
          $0.UpdateUserResponse.fromBuffer);
  static final _$deleteUser =
      $grpc.ClientMethod<$0.DeleteUserRequest, $0.DeleteUserResponse>(
          '/tk.api.UserService/DeleteUser',
          ($0.DeleteUserRequest value) => value.writeToBuffer(),
          $0.DeleteUserResponse.fromBuffer);
}

@$pb.GrpcServiceName('tk.api.UserService')
abstract class UserServiceBase extends $grpc.Service {
  $core.String get $name => 'tk.api.UserService';

  UserServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.LoginRequest, $0.LoginResponse>(
        'Login',
        login_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LoginRequest.fromBuffer(value),
        ($0.LoginResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ValidateTokenRequest, $0.ValidateTokenResponse>(
            'ValidateToken',
            validateToken_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ValidateTokenRequest.fromBuffer(value),
            ($0.ValidateTokenResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateAdminPasswordRequest,
            $0.UpdateAdminPasswordResponse>(
        'UpdateAdminPassword',
        updateAdminPassword_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateAdminPasswordRequest.fromBuffer(value),
        ($0.UpdateAdminPasswordResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.StreamUsersRequest, $0.StreamUsersResponse>(
            'StreamUsers',
            streamUsers_Pre,
            false,
            true,
            ($core.List<$core.int> value) =>
                $0.StreamUsersRequest.fromBuffer(value),
            ($0.StreamUsersResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateUserRequest, $0.CreateUserResponse>(
        'CreateUser',
        createUser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CreateUserRequest.fromBuffer(value),
        ($0.CreateUserResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateUserRequest, $0.UpdateUserResponse>(
        'UpdateUser',
        updateUser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UpdateUserRequest.fromBuffer(value),
        ($0.UpdateUserResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteUserRequest, $0.DeleteUserResponse>(
        'DeleteUser',
        deleteUser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DeleteUserRequest.fromBuffer(value),
        ($0.DeleteUserResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.LoginResponse> login_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.LoginRequest> $request) async {
    return login($call, await $request);
  }

  $async.Future<$0.LoginResponse> login(
      $grpc.ServiceCall call, $0.LoginRequest request);

  $async.Future<$0.ValidateTokenResponse> validateToken_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ValidateTokenRequest> $request) async {
    return validateToken($call, await $request);
  }

  $async.Future<$0.ValidateTokenResponse> validateToken(
      $grpc.ServiceCall call, $0.ValidateTokenRequest request);

  $async.Future<$0.UpdateAdminPasswordResponse> updateAdminPassword_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UpdateAdminPasswordRequest> $request) async {
    return updateAdminPassword($call, await $request);
  }

  $async.Future<$0.UpdateAdminPasswordResponse> updateAdminPassword(
      $grpc.ServiceCall call, $0.UpdateAdminPasswordRequest request);

  $async.Stream<$0.StreamUsersResponse> streamUsers_Pre($grpc.ServiceCall $call,
      $async.Future<$0.StreamUsersRequest> $request) async* {
    yield* streamUsers($call, await $request);
  }

  $async.Stream<$0.StreamUsersResponse> streamUsers(
      $grpc.ServiceCall call, $0.StreamUsersRequest request);

  $async.Future<$0.CreateUserResponse> createUser_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CreateUserRequest> $request) async {
    return createUser($call, await $request);
  }

  $async.Future<$0.CreateUserResponse> createUser(
      $grpc.ServiceCall call, $0.CreateUserRequest request);

  $async.Future<$0.UpdateUserResponse> updateUser_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdateUserRequest> $request) async {
    return updateUser($call, await $request);
  }

  $async.Future<$0.UpdateUserResponse> updateUser(
      $grpc.ServiceCall call, $0.UpdateUserRequest request);

  $async.Future<$0.DeleteUserResponse> deleteUser_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DeleteUserRequest> $request) async {
    return deleteUser($call, await $request);
  }

  $async.Future<$0.DeleteUserResponse> deleteUser(
      $grpc.ServiceCall call, $0.DeleteUserRequest request);
}
