// This is a generated file - do not edit.
//
// Generated from api/settings.proto.

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

import 'settings.pb.dart' as $0;

export 'settings.pb.dart';

@$pb.GrpcServiceName('tk.api.SettingsService')
class SettingsServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  SettingsServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.GetSettingsResponse> getSettings(
    $0.GetSettingsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getSettings, request, options: options);
  }

  $grpc.ResponseFuture<$0.UpdateSettingsResponse> updateSettings(
    $0.UpdateSettingsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateSettings, request, options: options);
  }

  $grpc.ResponseFuture<$0.PurgeDatabaseResponse> purgeDatabase(
    $0.PurgeDatabaseRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$purgeDatabase, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetDiscordRolesResponse> getDiscordRoles(
    $0.GetDiscordRolesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getDiscordRoles, request, options: options);
  }

  $grpc.ResponseFuture<$0.ImportDiscordMembersResponse> importDiscordMembers(
    $0.ImportDiscordMembersRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$importDiscordMembers, request, options: options);
  }

  // method descriptors

  static final _$getSettings =
      $grpc.ClientMethod<$0.GetSettingsRequest, $0.GetSettingsResponse>(
          '/tk.api.SettingsService/GetSettings',
          ($0.GetSettingsRequest value) => value.writeToBuffer(),
          $0.GetSettingsResponse.fromBuffer);
  static final _$updateSettings =
      $grpc.ClientMethod<$0.UpdateSettingsRequest, $0.UpdateSettingsResponse>(
          '/tk.api.SettingsService/UpdateSettings',
          ($0.UpdateSettingsRequest value) => value.writeToBuffer(),
          $0.UpdateSettingsResponse.fromBuffer);
  static final _$purgeDatabase =
      $grpc.ClientMethod<$0.PurgeDatabaseRequest, $0.PurgeDatabaseResponse>(
          '/tk.api.SettingsService/PurgeDatabase',
          ($0.PurgeDatabaseRequest value) => value.writeToBuffer(),
          $0.PurgeDatabaseResponse.fromBuffer);
  static final _$getDiscordRoles =
      $grpc.ClientMethod<$0.GetDiscordRolesRequest, $0.GetDiscordRolesResponse>(
          '/tk.api.SettingsService/GetDiscordRoles',
          ($0.GetDiscordRolesRequest value) => value.writeToBuffer(),
          $0.GetDiscordRolesResponse.fromBuffer);
  static final _$importDiscordMembers = $grpc.ClientMethod<
          $0.ImportDiscordMembersRequest, $0.ImportDiscordMembersResponse>(
      '/tk.api.SettingsService/ImportDiscordMembers',
      ($0.ImportDiscordMembersRequest value) => value.writeToBuffer(),
      $0.ImportDiscordMembersResponse.fromBuffer);
}

@$pb.GrpcServiceName('tk.api.SettingsService')
abstract class SettingsServiceBase extends $grpc.Service {
  $core.String get $name => 'tk.api.SettingsService';

  SettingsServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.GetSettingsRequest, $0.GetSettingsResponse>(
            'GetSettings',
            getSettings_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetSettingsRequest.fromBuffer(value),
            ($0.GetSettingsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateSettingsRequest,
            $0.UpdateSettingsResponse>(
        'UpdateSettings',
        updateSettings_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateSettingsRequest.fromBuffer(value),
        ($0.UpdateSettingsResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.PurgeDatabaseRequest, $0.PurgeDatabaseResponse>(
            'PurgeDatabase',
            purgeDatabase_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.PurgeDatabaseRequest.fromBuffer(value),
            ($0.PurgeDatabaseResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetDiscordRolesRequest,
            $0.GetDiscordRolesResponse>(
        'GetDiscordRoles',
        getDiscordRoles_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetDiscordRolesRequest.fromBuffer(value),
        ($0.GetDiscordRolesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ImportDiscordMembersRequest,
            $0.ImportDiscordMembersResponse>(
        'ImportDiscordMembers',
        importDiscordMembers_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ImportDiscordMembersRequest.fromBuffer(value),
        ($0.ImportDiscordMembersResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetSettingsResponse> getSettings_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetSettingsRequest> $request) async {
    return getSettings($call, await $request);
  }

  $async.Future<$0.GetSettingsResponse> getSettings(
      $grpc.ServiceCall call, $0.GetSettingsRequest request);

  $async.Future<$0.UpdateSettingsResponse> updateSettings_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UpdateSettingsRequest> $request) async {
    return updateSettings($call, await $request);
  }

  $async.Future<$0.UpdateSettingsResponse> updateSettings(
      $grpc.ServiceCall call, $0.UpdateSettingsRequest request);

  $async.Future<$0.PurgeDatabaseResponse> purgeDatabase_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.PurgeDatabaseRequest> $request) async {
    return purgeDatabase($call, await $request);
  }

  $async.Future<$0.PurgeDatabaseResponse> purgeDatabase(
      $grpc.ServiceCall call, $0.PurgeDatabaseRequest request);

  $async.Future<$0.GetDiscordRolesResponse> getDiscordRoles_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetDiscordRolesRequest> $request) async {
    return getDiscordRoles($call, await $request);
  }

  $async.Future<$0.GetDiscordRolesResponse> getDiscordRoles(
      $grpc.ServiceCall call, $0.GetDiscordRolesRequest request);

  $async.Future<$0.ImportDiscordMembersResponse> importDiscordMembers_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ImportDiscordMembersRequest> $request) async {
    return importDiscordMembers($call, await $request);
  }

  $async.Future<$0.ImportDiscordMembersResponse> importDiscordMembers(
      $grpc.ServiceCall call, $0.ImportDiscordMembersRequest request);
}
