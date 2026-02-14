// This is a generated file - do not edit.
//
// Generated from api/settings.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import '../db/db.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class GetSettingsRequest extends $pb.GeneratedMessage {
  factory GetSettingsRequest() => create();

  GetSettingsRequest._();

  factory GetSettingsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSettingsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSettingsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSettingsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSettingsRequest copyWith(void Function(GetSettingsRequest) updates) =>
      super.copyWith((message) => updates(message as GetSettingsRequest))
          as GetSettingsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSettingsRequest create() => GetSettingsRequest._();
  @$core.override
  GetSettingsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSettingsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSettingsRequest>(create);
  static GetSettingsRequest? _defaultInstance;
}

class GetSettingsResponse extends $pb.GeneratedMessage {
  factory GetSettingsResponse({
    $1.Settings? settings,
  }) {
    final result = create();
    if (settings != null) result.settings = settings;
    return result;
  }

  GetSettingsResponse._();

  factory GetSettingsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSettingsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSettingsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aOM<$1.Settings>(1, _omitFieldNames ? '' : 'settings',
        subBuilder: $1.Settings.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSettingsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSettingsResponse copyWith(void Function(GetSettingsResponse) updates) =>
      super.copyWith((message) => updates(message as GetSettingsResponse))
          as GetSettingsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSettingsResponse create() => GetSettingsResponse._();
  @$core.override
  GetSettingsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSettingsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSettingsResponse>(create);
  static GetSettingsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Settings get settings => $_getN(0);
  @$pb.TagNumber(1)
  set settings($1.Settings value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSettings() => $_has(0);
  @$pb.TagNumber(1)
  void clearSettings() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Settings ensureSettings() => $_ensure(0);
}

class UpdateSettingsRequest extends $pb.GeneratedMessage {
  factory UpdateSettingsRequest({
    $fixnum.Int64? nextSessionThresholdSecs,
    $core.String? discordBotToken,
    $core.String? discordGuildId,
    $core.String? discordChannelId,
    $core.bool? discordSelfLinkEnabled,
    $core.bool? discordNameSyncEnabled,
    $fixnum.Int64? discordStartReminderMins,
    $fixnum.Int64? discordEndReminderMins,
    $core.String? discordStartReminderMessage,
    $core.String? discordEndReminderMessage,
  }) {
    final result = create();
    if (nextSessionThresholdSecs != null)
      result.nextSessionThresholdSecs = nextSessionThresholdSecs;
    if (discordBotToken != null) result.discordBotToken = discordBotToken;
    if (discordGuildId != null) result.discordGuildId = discordGuildId;
    if (discordChannelId != null) result.discordChannelId = discordChannelId;
    if (discordSelfLinkEnabled != null)
      result.discordSelfLinkEnabled = discordSelfLinkEnabled;
    if (discordNameSyncEnabled != null)
      result.discordNameSyncEnabled = discordNameSyncEnabled;
    if (discordStartReminderMins != null)
      result.discordStartReminderMins = discordStartReminderMins;
    if (discordEndReminderMins != null)
      result.discordEndReminderMins = discordEndReminderMins;
    if (discordStartReminderMessage != null)
      result.discordStartReminderMessage = discordStartReminderMessage;
    if (discordEndReminderMessage != null)
      result.discordEndReminderMessage = discordEndReminderMessage;
    return result;
  }

  UpdateSettingsRequest._();

  factory UpdateSettingsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateSettingsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateSettingsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'nextSessionThresholdSecs')
    ..aOS(2, _omitFieldNames ? '' : 'discordBotToken')
    ..aOS(3, _omitFieldNames ? '' : 'discordGuildId')
    ..aOS(4, _omitFieldNames ? '' : 'discordChannelId')
    ..aOB(5, _omitFieldNames ? '' : 'discordSelfLinkEnabled')
    ..aOB(6, _omitFieldNames ? '' : 'discordNameSyncEnabled')
    ..aInt64(7, _omitFieldNames ? '' : 'discordStartReminderMins')
    ..aInt64(8, _omitFieldNames ? '' : 'discordEndReminderMins')
    ..aOS(9, _omitFieldNames ? '' : 'discordStartReminderMessage')
    ..aOS(10, _omitFieldNames ? '' : 'discordEndReminderMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateSettingsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateSettingsRequest copyWith(
          void Function(UpdateSettingsRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateSettingsRequest))
          as UpdateSettingsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateSettingsRequest create() => UpdateSettingsRequest._();
  @$core.override
  UpdateSettingsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateSettingsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateSettingsRequest>(create);
  static UpdateSettingsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get nextSessionThresholdSecs => $_getI64(0);
  @$pb.TagNumber(1)
  set nextSessionThresholdSecs($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNextSessionThresholdSecs() => $_has(0);
  @$pb.TagNumber(1)
  void clearNextSessionThresholdSecs() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get discordBotToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set discordBotToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDiscordBotToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearDiscordBotToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get discordGuildId => $_getSZ(2);
  @$pb.TagNumber(3)
  set discordGuildId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDiscordGuildId() => $_has(2);
  @$pb.TagNumber(3)
  void clearDiscordGuildId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get discordChannelId => $_getSZ(3);
  @$pb.TagNumber(4)
  set discordChannelId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDiscordChannelId() => $_has(3);
  @$pb.TagNumber(4)
  void clearDiscordChannelId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get discordSelfLinkEnabled => $_getBF(4);
  @$pb.TagNumber(5)
  set discordSelfLinkEnabled($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDiscordSelfLinkEnabled() => $_has(4);
  @$pb.TagNumber(5)
  void clearDiscordSelfLinkEnabled() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get discordNameSyncEnabled => $_getBF(5);
  @$pb.TagNumber(6)
  set discordNameSyncEnabled($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDiscordNameSyncEnabled() => $_has(5);
  @$pb.TagNumber(6)
  void clearDiscordNameSyncEnabled() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get discordStartReminderMins => $_getI64(6);
  @$pb.TagNumber(7)
  set discordStartReminderMins($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDiscordStartReminderMins() => $_has(6);
  @$pb.TagNumber(7)
  void clearDiscordStartReminderMins() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get discordEndReminderMins => $_getI64(7);
  @$pb.TagNumber(8)
  set discordEndReminderMins($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDiscordEndReminderMins() => $_has(7);
  @$pb.TagNumber(8)
  void clearDiscordEndReminderMins() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get discordStartReminderMessage => $_getSZ(8);
  @$pb.TagNumber(9)
  set discordStartReminderMessage($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDiscordStartReminderMessage() => $_has(8);
  @$pb.TagNumber(9)
  void clearDiscordStartReminderMessage() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get discordEndReminderMessage => $_getSZ(9);
  @$pb.TagNumber(10)
  set discordEndReminderMessage($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasDiscordEndReminderMessage() => $_has(9);
  @$pb.TagNumber(10)
  void clearDiscordEndReminderMessage() => $_clearField(10);
}

class UpdateSettingsResponse extends $pb.GeneratedMessage {
  factory UpdateSettingsResponse() => create();

  UpdateSettingsResponse._();

  factory UpdateSettingsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateSettingsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateSettingsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateSettingsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateSettingsResponse copyWith(
          void Function(UpdateSettingsResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateSettingsResponse))
          as UpdateSettingsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateSettingsResponse create() => UpdateSettingsResponse._();
  @$core.override
  UpdateSettingsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateSettingsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateSettingsResponse>(create);
  static UpdateSettingsResponse? _defaultInstance;
}

class PurgeDatabaseRequest extends $pb.GeneratedMessage {
  factory PurgeDatabaseRequest() => create();

  PurgeDatabaseRequest._();

  factory PurgeDatabaseRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PurgeDatabaseRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PurgeDatabaseRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurgeDatabaseRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurgeDatabaseRequest copyWith(void Function(PurgeDatabaseRequest) updates) =>
      super.copyWith((message) => updates(message as PurgeDatabaseRequest))
          as PurgeDatabaseRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PurgeDatabaseRequest create() => PurgeDatabaseRequest._();
  @$core.override
  PurgeDatabaseRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PurgeDatabaseRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PurgeDatabaseRequest>(create);
  static PurgeDatabaseRequest? _defaultInstance;
}

class PurgeDatabaseResponse extends $pb.GeneratedMessage {
  factory PurgeDatabaseResponse() => create();

  PurgeDatabaseResponse._();

  factory PurgeDatabaseResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PurgeDatabaseResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PurgeDatabaseResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurgeDatabaseResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PurgeDatabaseResponse copyWith(
          void Function(PurgeDatabaseResponse) updates) =>
      super.copyWith((message) => updates(message as PurgeDatabaseResponse))
          as PurgeDatabaseResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PurgeDatabaseResponse create() => PurgeDatabaseResponse._();
  @$core.override
  PurgeDatabaseResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PurgeDatabaseResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PurgeDatabaseResponse>(create);
  static PurgeDatabaseResponse? _defaultInstance;
}

class DiscordRole extends $pb.GeneratedMessage {
  factory DiscordRole({
    $core.String? id,
    $core.String? name,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    return result;
  }

  DiscordRole._();

  factory DiscordRole.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DiscordRole.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DiscordRole',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiscordRole clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiscordRole copyWith(void Function(DiscordRole) updates) =>
      super.copyWith((message) => updates(message as DiscordRole))
          as DiscordRole;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DiscordRole create() => DiscordRole._();
  @$core.override
  DiscordRole createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DiscordRole getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DiscordRole>(create);
  static DiscordRole? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);
}

class GetDiscordRolesRequest extends $pb.GeneratedMessage {
  factory GetDiscordRolesRequest() => create();

  GetDiscordRolesRequest._();

  factory GetDiscordRolesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDiscordRolesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDiscordRolesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDiscordRolesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDiscordRolesRequest copyWith(
          void Function(GetDiscordRolesRequest) updates) =>
      super.copyWith((message) => updates(message as GetDiscordRolesRequest))
          as GetDiscordRolesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDiscordRolesRequest create() => GetDiscordRolesRequest._();
  @$core.override
  GetDiscordRolesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDiscordRolesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDiscordRolesRequest>(create);
  static GetDiscordRolesRequest? _defaultInstance;
}

class GetDiscordRolesResponse extends $pb.GeneratedMessage {
  factory GetDiscordRolesResponse({
    $core.Iterable<DiscordRole>? roles,
  }) {
    final result = create();
    if (roles != null) result.roles.addAll(roles);
    return result;
  }

  GetDiscordRolesResponse._();

  factory GetDiscordRolesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDiscordRolesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDiscordRolesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..pPM<DiscordRole>(1, _omitFieldNames ? '' : 'roles',
        subBuilder: DiscordRole.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDiscordRolesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDiscordRolesResponse copyWith(
          void Function(GetDiscordRolesResponse) updates) =>
      super.copyWith((message) => updates(message as GetDiscordRolesResponse))
          as GetDiscordRolesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDiscordRolesResponse create() => GetDiscordRolesResponse._();
  @$core.override
  GetDiscordRolesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDiscordRolesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDiscordRolesResponse>(create);
  static GetDiscordRolesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<DiscordRole> get roles => $_getList(0);
}

class ImportDiscordMembersRequest extends $pb.GeneratedMessage {
  factory ImportDiscordMembersRequest({
    $core.String? roleId,
    $1.TeamMemberType? memberType,
  }) {
    final result = create();
    if (roleId != null) result.roleId = roleId;
    if (memberType != null) result.memberType = memberType;
    return result;
  }

  ImportDiscordMembersRequest._();

  factory ImportDiscordMembersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImportDiscordMembersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportDiscordMembersRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'roleId')
    ..aE<$1.TeamMemberType>(2, _omitFieldNames ? '' : 'memberType',
        enumValues: $1.TeamMemberType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportDiscordMembersRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportDiscordMembersRequest copyWith(
          void Function(ImportDiscordMembersRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ImportDiscordMembersRequest))
          as ImportDiscordMembersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportDiscordMembersRequest create() =>
      ImportDiscordMembersRequest._();
  @$core.override
  ImportDiscordMembersRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ImportDiscordMembersRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportDiscordMembersRequest>(create);
  static ImportDiscordMembersRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get roleId => $_getSZ(0);
  @$pb.TagNumber(1)
  set roleId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRoleId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoleId() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.TeamMemberType get memberType => $_getN(1);
  @$pb.TagNumber(2)
  set memberType($1.TeamMemberType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMemberType() => $_has(1);
  @$pb.TagNumber(2)
  void clearMemberType() => $_clearField(2);
}

class ImportDiscordMembersResponse extends $pb.GeneratedMessage {
  factory ImportDiscordMembersResponse({
    $core.int? imported,
    $core.int? linked,
    $core.int? alreadyLinked,
  }) {
    final result = create();
    if (imported != null) result.imported = imported;
    if (linked != null) result.linked = linked;
    if (alreadyLinked != null) result.alreadyLinked = alreadyLinked;
    return result;
  }

  ImportDiscordMembersResponse._();

  factory ImportDiscordMembersResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImportDiscordMembersResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportDiscordMembersResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'imported')
    ..aI(2, _omitFieldNames ? '' : 'linked')
    ..aI(3, _omitFieldNames ? '' : 'alreadyLinked')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportDiscordMembersResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportDiscordMembersResponse copyWith(
          void Function(ImportDiscordMembersResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ImportDiscordMembersResponse))
          as ImportDiscordMembersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportDiscordMembersResponse create() =>
      ImportDiscordMembersResponse._();
  @$core.override
  ImportDiscordMembersResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ImportDiscordMembersResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportDiscordMembersResponse>(create);
  static ImportDiscordMembersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get imported => $_getIZ(0);
  @$pb.TagNumber(1)
  set imported($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasImported() => $_has(0);
  @$pb.TagNumber(1)
  void clearImported() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get linked => $_getIZ(1);
  @$pb.TagNumber(2)
  set linked($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLinked() => $_has(1);
  @$pb.TagNumber(2)
  void clearLinked() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get alreadyLinked => $_getIZ(2);
  @$pb.TagNumber(3)
  set alreadyLinked($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAlreadyLinked() => $_has(2);
  @$pb.TagNumber(3)
  void clearAlreadyLinked() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
