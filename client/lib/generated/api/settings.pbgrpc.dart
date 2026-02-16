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

  /// Retrieval
  $grpc.ResponseFuture<$0.GetSettingsResponse> getSettings(
    $0.GetSettingsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getSettings, request, options: options);
  }

  /// General
  $grpc.ResponseFuture<$0.UpdateGeneralSettingsResponse> updateGeneralSettings(
    $0.UpdateGeneralSettingsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateGeneralSettings, request, options: options);
  }

  /// Branding
  $grpc.ResponseFuture<$0.UpdateBrandingSettingsResponse>
      updateBrandingSettings(
    $0.UpdateBrandingSettingsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateBrandingSettings, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.UploadLogoResponse> uploadLogo(
    $0.UploadLogoRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$uploadLogo, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetLogoResponse> getLogo(
    $0.GetLogoRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getLogo, request, options: options);
  }

  /// Leaderboard
  $grpc.ResponseFuture<$0.UpdateLeaderboardSettingsResponse>
      updateLeaderboardSettings(
    $0.UpdateLeaderboardSettingsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateLeaderboardSettings, request,
        options: options);
  }

  /// Discord
  $grpc.ResponseFuture<$0.UpdateDiscordCoreSettingsResponse>
      updateDiscordCoreSettings(
    $0.UpdateDiscordCoreSettingsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateDiscordCoreSettings, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.UpdateDiscordReminderSettingsResponse>
      updateDiscordReminderSettings(
    $0.UpdateDiscordReminderSettingsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateDiscordReminderSettings, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.UpdateDiscordBehaviorSettingsResponse>
      updateDiscordBehaviorSettings(
    $0.UpdateDiscordBehaviorSettingsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateDiscordBehaviorSettings, request,
        options: options);
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

  /// Maintenance
  $grpc.ResponseFuture<$0.PurgeDatabaseResponse> purgeDatabase(
    $0.PurgeDatabaseRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$purgeDatabase, request, options: options);
  }

  // method descriptors

  static final _$getSettings =
      $grpc.ClientMethod<$0.GetSettingsRequest, $0.GetSettingsResponse>(
          '/tk.api.SettingsService/GetSettings',
          ($0.GetSettingsRequest value) => value.writeToBuffer(),
          $0.GetSettingsResponse.fromBuffer);
  static final _$updateGeneralSettings = $grpc.ClientMethod<
          $0.UpdateGeneralSettingsRequest, $0.UpdateGeneralSettingsResponse>(
      '/tk.api.SettingsService/UpdateGeneralSettings',
      ($0.UpdateGeneralSettingsRequest value) => value.writeToBuffer(),
      $0.UpdateGeneralSettingsResponse.fromBuffer);
  static final _$updateBrandingSettings = $grpc.ClientMethod<
          $0.UpdateBrandingSettingsRequest, $0.UpdateBrandingSettingsResponse>(
      '/tk.api.SettingsService/UpdateBrandingSettings',
      ($0.UpdateBrandingSettingsRequest value) => value.writeToBuffer(),
      $0.UpdateBrandingSettingsResponse.fromBuffer);
  static final _$uploadLogo =
      $grpc.ClientMethod<$0.UploadLogoRequest, $0.UploadLogoResponse>(
          '/tk.api.SettingsService/UploadLogo',
          ($0.UploadLogoRequest value) => value.writeToBuffer(),
          $0.UploadLogoResponse.fromBuffer);
  static final _$getLogo =
      $grpc.ClientMethod<$0.GetLogoRequest, $0.GetLogoResponse>(
          '/tk.api.SettingsService/GetLogo',
          ($0.GetLogoRequest value) => value.writeToBuffer(),
          $0.GetLogoResponse.fromBuffer);
  static final _$updateLeaderboardSettings = $grpc.ClientMethod<
          $0.UpdateLeaderboardSettingsRequest,
          $0.UpdateLeaderboardSettingsResponse>(
      '/tk.api.SettingsService/UpdateLeaderboardSettings',
      ($0.UpdateLeaderboardSettingsRequest value) => value.writeToBuffer(),
      $0.UpdateLeaderboardSettingsResponse.fromBuffer);
  static final _$updateDiscordCoreSettings = $grpc.ClientMethod<
          $0.UpdateDiscordCoreSettingsRequest,
          $0.UpdateDiscordCoreSettingsResponse>(
      '/tk.api.SettingsService/UpdateDiscordCoreSettings',
      ($0.UpdateDiscordCoreSettingsRequest value) => value.writeToBuffer(),
      $0.UpdateDiscordCoreSettingsResponse.fromBuffer);
  static final _$updateDiscordReminderSettings = $grpc.ClientMethod<
          $0.UpdateDiscordReminderSettingsRequest,
          $0.UpdateDiscordReminderSettingsResponse>(
      '/tk.api.SettingsService/UpdateDiscordReminderSettings',
      ($0.UpdateDiscordReminderSettingsRequest value) => value.writeToBuffer(),
      $0.UpdateDiscordReminderSettingsResponse.fromBuffer);
  static final _$updateDiscordBehaviorSettings = $grpc.ClientMethod<
          $0.UpdateDiscordBehaviorSettingsRequest,
          $0.UpdateDiscordBehaviorSettingsResponse>(
      '/tk.api.SettingsService/UpdateDiscordBehaviorSettings',
      ($0.UpdateDiscordBehaviorSettingsRequest value) => value.writeToBuffer(),
      $0.UpdateDiscordBehaviorSettingsResponse.fromBuffer);
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
  static final _$purgeDatabase =
      $grpc.ClientMethod<$0.PurgeDatabaseRequest, $0.PurgeDatabaseResponse>(
          '/tk.api.SettingsService/PurgeDatabase',
          ($0.PurgeDatabaseRequest value) => value.writeToBuffer(),
          $0.PurgeDatabaseResponse.fromBuffer);
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
    $addMethod($grpc.ServiceMethod<$0.UpdateGeneralSettingsRequest,
            $0.UpdateGeneralSettingsResponse>(
        'UpdateGeneralSettings',
        updateGeneralSettings_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateGeneralSettingsRequest.fromBuffer(value),
        ($0.UpdateGeneralSettingsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateBrandingSettingsRequest,
            $0.UpdateBrandingSettingsResponse>(
        'UpdateBrandingSettings',
        updateBrandingSettings_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateBrandingSettingsRequest.fromBuffer(value),
        ($0.UpdateBrandingSettingsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UploadLogoRequest, $0.UploadLogoResponse>(
        'UploadLogo',
        uploadLogo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UploadLogoRequest.fromBuffer(value),
        ($0.UploadLogoResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetLogoRequest, $0.GetLogoResponse>(
        'GetLogo',
        getLogo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetLogoRequest.fromBuffer(value),
        ($0.GetLogoResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateLeaderboardSettingsRequest,
            $0.UpdateLeaderboardSettingsResponse>(
        'UpdateLeaderboardSettings',
        updateLeaderboardSettings_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateLeaderboardSettingsRequest.fromBuffer(value),
        ($0.UpdateLeaderboardSettingsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateDiscordCoreSettingsRequest,
            $0.UpdateDiscordCoreSettingsResponse>(
        'UpdateDiscordCoreSettings',
        updateDiscordCoreSettings_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateDiscordCoreSettingsRequest.fromBuffer(value),
        ($0.UpdateDiscordCoreSettingsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateDiscordReminderSettingsRequest,
            $0.UpdateDiscordReminderSettingsResponse>(
        'UpdateDiscordReminderSettings',
        updateDiscordReminderSettings_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateDiscordReminderSettingsRequest.fromBuffer(value),
        ($0.UpdateDiscordReminderSettingsResponse value) =>
            value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateDiscordBehaviorSettingsRequest,
            $0.UpdateDiscordBehaviorSettingsResponse>(
        'UpdateDiscordBehaviorSettings',
        updateDiscordBehaviorSettings_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateDiscordBehaviorSettingsRequest.fromBuffer(value),
        ($0.UpdateDiscordBehaviorSettingsResponse value) =>
            value.writeToBuffer()));
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
    $addMethod(
        $grpc.ServiceMethod<$0.PurgeDatabaseRequest, $0.PurgeDatabaseResponse>(
            'PurgeDatabase',
            purgeDatabase_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.PurgeDatabaseRequest.fromBuffer(value),
            ($0.PurgeDatabaseResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetSettingsResponse> getSettings_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetSettingsRequest> $request) async {
    return getSettings($call, await $request);
  }

  $async.Future<$0.GetSettingsResponse> getSettings(
      $grpc.ServiceCall call, $0.GetSettingsRequest request);

  $async.Future<$0.UpdateGeneralSettingsResponse> updateGeneralSettings_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UpdateGeneralSettingsRequest> $request) async {
    return updateGeneralSettings($call, await $request);
  }

  $async.Future<$0.UpdateGeneralSettingsResponse> updateGeneralSettings(
      $grpc.ServiceCall call, $0.UpdateGeneralSettingsRequest request);

  $async.Future<$0.UpdateBrandingSettingsResponse> updateBrandingSettings_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UpdateBrandingSettingsRequest> $request) async {
    return updateBrandingSettings($call, await $request);
  }

  $async.Future<$0.UpdateBrandingSettingsResponse> updateBrandingSettings(
      $grpc.ServiceCall call, $0.UpdateBrandingSettingsRequest request);

  $async.Future<$0.UploadLogoResponse> uploadLogo_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UploadLogoRequest> $request) async {
    return uploadLogo($call, await $request);
  }

  $async.Future<$0.UploadLogoResponse> uploadLogo(
      $grpc.ServiceCall call, $0.UploadLogoRequest request);

  $async.Future<$0.GetLogoResponse> getLogo_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetLogoRequest> $request) async {
    return getLogo($call, await $request);
  }

  $async.Future<$0.GetLogoResponse> getLogo(
      $grpc.ServiceCall call, $0.GetLogoRequest request);

  $async.Future<$0.UpdateLeaderboardSettingsResponse>
      updateLeaderboardSettings_Pre($grpc.ServiceCall $call,
          $async.Future<$0.UpdateLeaderboardSettingsRequest> $request) async {
    return updateLeaderboardSettings($call, await $request);
  }

  $async.Future<$0.UpdateLeaderboardSettingsResponse> updateLeaderboardSettings(
      $grpc.ServiceCall call, $0.UpdateLeaderboardSettingsRequest request);

  $async.Future<$0.UpdateDiscordCoreSettingsResponse>
      updateDiscordCoreSettings_Pre($grpc.ServiceCall $call,
          $async.Future<$0.UpdateDiscordCoreSettingsRequest> $request) async {
    return updateDiscordCoreSettings($call, await $request);
  }

  $async.Future<$0.UpdateDiscordCoreSettingsResponse> updateDiscordCoreSettings(
      $grpc.ServiceCall call, $0.UpdateDiscordCoreSettingsRequest request);

  $async.Future<$0.UpdateDiscordReminderSettingsResponse>
      updateDiscordReminderSettings_Pre(
          $grpc.ServiceCall $call,
          $async.Future<$0.UpdateDiscordReminderSettingsRequest>
              $request) async {
    return updateDiscordReminderSettings($call, await $request);
  }

  $async.Future<$0.UpdateDiscordReminderSettingsResponse>
      updateDiscordReminderSettings($grpc.ServiceCall call,
          $0.UpdateDiscordReminderSettingsRequest request);

  $async.Future<$0.UpdateDiscordBehaviorSettingsResponse>
      updateDiscordBehaviorSettings_Pre(
          $grpc.ServiceCall $call,
          $async.Future<$0.UpdateDiscordBehaviorSettingsRequest>
              $request) async {
    return updateDiscordBehaviorSettings($call, await $request);
  }

  $async.Future<$0.UpdateDiscordBehaviorSettingsResponse>
      updateDiscordBehaviorSettings($grpc.ServiceCall call,
          $0.UpdateDiscordBehaviorSettingsRequest request);

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

  $async.Future<$0.PurgeDatabaseResponse> purgeDatabase_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.PurgeDatabaseRequest> $request) async {
    return purgeDatabase($call, await $request);
  }

  $async.Future<$0.PurgeDatabaseResponse> purgeDatabase(
      $grpc.ServiceCall call, $0.PurgeDatabaseRequest request);
}
