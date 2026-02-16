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

class UpdateGeneralSettingsRequest extends $pb.GeneratedMessage {
  factory UpdateGeneralSettingsRequest({
    $fixnum.Int64? nextSessionThresholdSecs,
    $core.String? timezone,
  }) {
    final result = create();
    if (nextSessionThresholdSecs != null)
      result.nextSessionThresholdSecs = nextSessionThresholdSecs;
    if (timezone != null) result.timezone = timezone;
    return result;
  }

  UpdateGeneralSettingsRequest._();

  factory UpdateGeneralSettingsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateGeneralSettingsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateGeneralSettingsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'nextSessionThresholdSecs')
    ..aOS(2, _omitFieldNames ? '' : 'timezone')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateGeneralSettingsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateGeneralSettingsRequest copyWith(
          void Function(UpdateGeneralSettingsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as UpdateGeneralSettingsRequest))
          as UpdateGeneralSettingsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateGeneralSettingsRequest create() =>
      UpdateGeneralSettingsRequest._();
  @$core.override
  UpdateGeneralSettingsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateGeneralSettingsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateGeneralSettingsRequest>(create);
  static UpdateGeneralSettingsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get nextSessionThresholdSecs => $_getI64(0);
  @$pb.TagNumber(1)
  set nextSessionThresholdSecs($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNextSessionThresholdSecs() => $_has(0);
  @$pb.TagNumber(1)
  void clearNextSessionThresholdSecs() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get timezone => $_getSZ(1);
  @$pb.TagNumber(2)
  set timezone($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTimezone() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimezone() => $_clearField(2);
}

class UpdateGeneralSettingsResponse extends $pb.GeneratedMessage {
  factory UpdateGeneralSettingsResponse() => create();

  UpdateGeneralSettingsResponse._();

  factory UpdateGeneralSettingsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateGeneralSettingsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateGeneralSettingsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateGeneralSettingsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateGeneralSettingsResponse copyWith(
          void Function(UpdateGeneralSettingsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as UpdateGeneralSettingsResponse))
          as UpdateGeneralSettingsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateGeneralSettingsResponse create() =>
      UpdateGeneralSettingsResponse._();
  @$core.override
  UpdateGeneralSettingsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateGeneralSettingsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateGeneralSettingsResponse>(create);
  static UpdateGeneralSettingsResponse? _defaultInstance;
}

class UpdateBrandingSettingsRequest extends $pb.GeneratedMessage {
  factory UpdateBrandingSettingsRequest({
    $core.String? primaryColor,
    $core.String? secondaryColor,
  }) {
    final result = create();
    if (primaryColor != null) result.primaryColor = primaryColor;
    if (secondaryColor != null) result.secondaryColor = secondaryColor;
    return result;
  }

  UpdateBrandingSettingsRequest._();

  factory UpdateBrandingSettingsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateBrandingSettingsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateBrandingSettingsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'primaryColor')
    ..aOS(2, _omitFieldNames ? '' : 'secondaryColor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateBrandingSettingsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateBrandingSettingsRequest copyWith(
          void Function(UpdateBrandingSettingsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as UpdateBrandingSettingsRequest))
          as UpdateBrandingSettingsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateBrandingSettingsRequest create() =>
      UpdateBrandingSettingsRequest._();
  @$core.override
  UpdateBrandingSettingsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateBrandingSettingsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateBrandingSettingsRequest>(create);
  static UpdateBrandingSettingsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get primaryColor => $_getSZ(0);
  @$pb.TagNumber(1)
  set primaryColor($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPrimaryColor() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrimaryColor() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get secondaryColor => $_getSZ(1);
  @$pb.TagNumber(2)
  set secondaryColor($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSecondaryColor() => $_has(1);
  @$pb.TagNumber(2)
  void clearSecondaryColor() => $_clearField(2);
}

class UpdateBrandingSettingsResponse extends $pb.GeneratedMessage {
  factory UpdateBrandingSettingsResponse() => create();

  UpdateBrandingSettingsResponse._();

  factory UpdateBrandingSettingsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateBrandingSettingsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateBrandingSettingsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateBrandingSettingsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateBrandingSettingsResponse copyWith(
          void Function(UpdateBrandingSettingsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as UpdateBrandingSettingsResponse))
          as UpdateBrandingSettingsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateBrandingSettingsResponse create() =>
      UpdateBrandingSettingsResponse._();
  @$core.override
  UpdateBrandingSettingsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateBrandingSettingsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateBrandingSettingsResponse>(create);
  static UpdateBrandingSettingsResponse? _defaultInstance;
}

class UploadLogoRequest extends $pb.GeneratedMessage {
  factory UploadLogoRequest({
    $core.List<$core.int>? logo,
  }) {
    final result = create();
    if (logo != null) result.logo = logo;
    return result;
  }

  UploadLogoRequest._();

  factory UploadLogoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UploadLogoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UploadLogoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'logo', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadLogoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadLogoRequest copyWith(void Function(UploadLogoRequest) updates) =>
      super.copyWith((message) => updates(message as UploadLogoRequest))
          as UploadLogoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UploadLogoRequest create() => UploadLogoRequest._();
  @$core.override
  UploadLogoRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UploadLogoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UploadLogoRequest>(create);
  static UploadLogoRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get logo => $_getN(0);
  @$pb.TagNumber(1)
  set logo($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLogo() => $_has(0);
  @$pb.TagNumber(1)
  void clearLogo() => $_clearField(1);
}

class UploadLogoResponse extends $pb.GeneratedMessage {
  factory UploadLogoResponse() => create();

  UploadLogoResponse._();

  factory UploadLogoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UploadLogoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UploadLogoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadLogoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadLogoResponse copyWith(void Function(UploadLogoResponse) updates) =>
      super.copyWith((message) => updates(message as UploadLogoResponse))
          as UploadLogoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UploadLogoResponse create() => UploadLogoResponse._();
  @$core.override
  UploadLogoResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UploadLogoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UploadLogoResponse>(create);
  static UploadLogoResponse? _defaultInstance;
}

class GetLogoRequest extends $pb.GeneratedMessage {
  factory GetLogoRequest() => create();

  GetLogoRequest._();

  factory GetLogoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetLogoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLogoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLogoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLogoRequest copyWith(void Function(GetLogoRequest) updates) =>
      super.copyWith((message) => updates(message as GetLogoRequest))
          as GetLogoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetLogoRequest create() => GetLogoRequest._();
  @$core.override
  GetLogoRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetLogoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetLogoRequest>(create);
  static GetLogoRequest? _defaultInstance;
}

class GetLogoResponse extends $pb.GeneratedMessage {
  factory GetLogoResponse({
    $core.List<$core.int>? logo,
  }) {
    final result = create();
    if (logo != null) result.logo = logo;
    return result;
  }

  GetLogoResponse._();

  factory GetLogoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetLogoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLogoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'logo', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLogoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLogoResponse copyWith(void Function(GetLogoResponse) updates) =>
      super.copyWith((message) => updates(message as GetLogoResponse))
          as GetLogoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetLogoResponse create() => GetLogoResponse._();
  @$core.override
  GetLogoResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetLogoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetLogoResponse>(create);
  static GetLogoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get logo => $_getN(0);
  @$pb.TagNumber(1)
  set logo($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLogo() => $_has(0);
  @$pb.TagNumber(1)
  void clearLogo() => $_clearField(1);
}

class UpdateLeaderboardSettingsRequest extends $pb.GeneratedMessage {
  factory UpdateLeaderboardSettingsRequest({
    $core.bool? leaderboardShowOvertime,
    $core.Iterable<$1.TeamMemberType>? leaderboardMemberTypes,
  }) {
    final result = create();
    if (leaderboardShowOvertime != null)
      result.leaderboardShowOvertime = leaderboardShowOvertime;
    if (leaderboardMemberTypes != null)
      result.leaderboardMemberTypes.addAll(leaderboardMemberTypes);
    return result;
  }

  UpdateLeaderboardSettingsRequest._();

  factory UpdateLeaderboardSettingsRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateLeaderboardSettingsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateLeaderboardSettingsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'leaderboardShowOvertime')
    ..pc<$1.TeamMemberType>(
        2, _omitFieldNames ? '' : 'leaderboardMemberTypes', $pb.PbFieldType.KE,
        valueOf: $1.TeamMemberType.valueOf,
        enumValues: $1.TeamMemberType.values,
        defaultEnumValue: $1.TeamMemberType.STUDENT)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateLeaderboardSettingsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateLeaderboardSettingsRequest copyWith(
          void Function(UpdateLeaderboardSettingsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as UpdateLeaderboardSettingsRequest))
          as UpdateLeaderboardSettingsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateLeaderboardSettingsRequest create() =>
      UpdateLeaderboardSettingsRequest._();
  @$core.override
  UpdateLeaderboardSettingsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateLeaderboardSettingsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateLeaderboardSettingsRequest>(
          create);
  static UpdateLeaderboardSettingsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get leaderboardShowOvertime => $_getBF(0);
  @$pb.TagNumber(1)
  set leaderboardShowOvertime($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLeaderboardShowOvertime() => $_has(0);
  @$pb.TagNumber(1)
  void clearLeaderboardShowOvertime() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$1.TeamMemberType> get leaderboardMemberTypes => $_getList(1);
}

class UpdateLeaderboardSettingsResponse extends $pb.GeneratedMessage {
  factory UpdateLeaderboardSettingsResponse() => create();

  UpdateLeaderboardSettingsResponse._();

  factory UpdateLeaderboardSettingsResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateLeaderboardSettingsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateLeaderboardSettingsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateLeaderboardSettingsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateLeaderboardSettingsResponse copyWith(
          void Function(UpdateLeaderboardSettingsResponse) updates) =>
      super.copyWith((message) =>
              updates(message as UpdateLeaderboardSettingsResponse))
          as UpdateLeaderboardSettingsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateLeaderboardSettingsResponse create() =>
      UpdateLeaderboardSettingsResponse._();
  @$core.override
  UpdateLeaderboardSettingsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateLeaderboardSettingsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateLeaderboardSettingsResponse>(
          create);
  static UpdateLeaderboardSettingsResponse? _defaultInstance;
}

class UpdateDiscordCoreSettingsRequest extends $pb.GeneratedMessage {
  factory UpdateDiscordCoreSettingsRequest({
    $core.bool? discordEnabled,
    $core.String? discordBotToken,
    $core.String? discordGuildId,
    $core.String? discordAnnouncementChannelId,
    $core.String? discordNotificationChannelId,
  }) {
    final result = create();
    if (discordEnabled != null) result.discordEnabled = discordEnabled;
    if (discordBotToken != null) result.discordBotToken = discordBotToken;
    if (discordGuildId != null) result.discordGuildId = discordGuildId;
    if (discordAnnouncementChannelId != null)
      result.discordAnnouncementChannelId = discordAnnouncementChannelId;
    if (discordNotificationChannelId != null)
      result.discordNotificationChannelId = discordNotificationChannelId;
    return result;
  }

  UpdateDiscordCoreSettingsRequest._();

  factory UpdateDiscordCoreSettingsRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateDiscordCoreSettingsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateDiscordCoreSettingsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'discordEnabled')
    ..aOS(2, _omitFieldNames ? '' : 'discordBotToken')
    ..aOS(3, _omitFieldNames ? '' : 'discordGuildId')
    ..aOS(4, _omitFieldNames ? '' : 'discordAnnouncementChannelId')
    ..aOS(5, _omitFieldNames ? '' : 'discordNotificationChannelId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateDiscordCoreSettingsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateDiscordCoreSettingsRequest copyWith(
          void Function(UpdateDiscordCoreSettingsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as UpdateDiscordCoreSettingsRequest))
          as UpdateDiscordCoreSettingsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateDiscordCoreSettingsRequest create() =>
      UpdateDiscordCoreSettingsRequest._();
  @$core.override
  UpdateDiscordCoreSettingsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateDiscordCoreSettingsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateDiscordCoreSettingsRequest>(
          create);
  static UpdateDiscordCoreSettingsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get discordEnabled => $_getBF(0);
  @$pb.TagNumber(1)
  set discordEnabled($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDiscordEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearDiscordEnabled() => $_clearField(1);

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
  $core.String get discordAnnouncementChannelId => $_getSZ(3);
  @$pb.TagNumber(4)
  set discordAnnouncementChannelId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDiscordAnnouncementChannelId() => $_has(3);
  @$pb.TagNumber(4)
  void clearDiscordAnnouncementChannelId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get discordNotificationChannelId => $_getSZ(4);
  @$pb.TagNumber(5)
  set discordNotificationChannelId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDiscordNotificationChannelId() => $_has(4);
  @$pb.TagNumber(5)
  void clearDiscordNotificationChannelId() => $_clearField(5);
}

class UpdateDiscordCoreSettingsResponse extends $pb.GeneratedMessage {
  factory UpdateDiscordCoreSettingsResponse() => create();

  UpdateDiscordCoreSettingsResponse._();

  factory UpdateDiscordCoreSettingsResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateDiscordCoreSettingsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateDiscordCoreSettingsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateDiscordCoreSettingsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateDiscordCoreSettingsResponse copyWith(
          void Function(UpdateDiscordCoreSettingsResponse) updates) =>
      super.copyWith((message) =>
              updates(message as UpdateDiscordCoreSettingsResponse))
          as UpdateDiscordCoreSettingsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateDiscordCoreSettingsResponse create() =>
      UpdateDiscordCoreSettingsResponse._();
  @$core.override
  UpdateDiscordCoreSettingsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateDiscordCoreSettingsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateDiscordCoreSettingsResponse>(
          create);
  static UpdateDiscordCoreSettingsResponse? _defaultInstance;
}

class UpdateDiscordReminderSettingsRequest extends $pb.GeneratedMessage {
  factory UpdateDiscordReminderSettingsRequest({
    $fixnum.Int64? discordStartReminderMins,
    $fixnum.Int64? discordEndReminderMins,
    $core.String? discordStartReminderMessage,
    $core.String? discordEndReminderMessage,
  }) {
    final result = create();
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

  UpdateDiscordReminderSettingsRequest._();

  factory UpdateDiscordReminderSettingsRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateDiscordReminderSettingsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateDiscordReminderSettingsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'discordStartReminderMins')
    ..aInt64(2, _omitFieldNames ? '' : 'discordEndReminderMins')
    ..aOS(3, _omitFieldNames ? '' : 'discordStartReminderMessage')
    ..aOS(4, _omitFieldNames ? '' : 'discordEndReminderMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateDiscordReminderSettingsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateDiscordReminderSettingsRequest copyWith(
          void Function(UpdateDiscordReminderSettingsRequest) updates) =>
      super.copyWith((message) =>
              updates(message as UpdateDiscordReminderSettingsRequest))
          as UpdateDiscordReminderSettingsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateDiscordReminderSettingsRequest create() =>
      UpdateDiscordReminderSettingsRequest._();
  @$core.override
  UpdateDiscordReminderSettingsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateDiscordReminderSettingsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          UpdateDiscordReminderSettingsRequest>(create);
  static UpdateDiscordReminderSettingsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get discordStartReminderMins => $_getI64(0);
  @$pb.TagNumber(1)
  set discordStartReminderMins($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDiscordStartReminderMins() => $_has(0);
  @$pb.TagNumber(1)
  void clearDiscordStartReminderMins() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get discordEndReminderMins => $_getI64(1);
  @$pb.TagNumber(2)
  set discordEndReminderMins($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDiscordEndReminderMins() => $_has(1);
  @$pb.TagNumber(2)
  void clearDiscordEndReminderMins() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get discordStartReminderMessage => $_getSZ(2);
  @$pb.TagNumber(3)
  set discordStartReminderMessage($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDiscordStartReminderMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearDiscordStartReminderMessage() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get discordEndReminderMessage => $_getSZ(3);
  @$pb.TagNumber(4)
  set discordEndReminderMessage($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDiscordEndReminderMessage() => $_has(3);
  @$pb.TagNumber(4)
  void clearDiscordEndReminderMessage() => $_clearField(4);
}

class UpdateDiscordReminderSettingsResponse extends $pb.GeneratedMessage {
  factory UpdateDiscordReminderSettingsResponse() => create();

  UpdateDiscordReminderSettingsResponse._();

  factory UpdateDiscordReminderSettingsResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateDiscordReminderSettingsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateDiscordReminderSettingsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateDiscordReminderSettingsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateDiscordReminderSettingsResponse copyWith(
          void Function(UpdateDiscordReminderSettingsResponse) updates) =>
      super.copyWith((message) =>
              updates(message as UpdateDiscordReminderSettingsResponse))
          as UpdateDiscordReminderSettingsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateDiscordReminderSettingsResponse create() =>
      UpdateDiscordReminderSettingsResponse._();
  @$core.override
  UpdateDiscordReminderSettingsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateDiscordReminderSettingsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          UpdateDiscordReminderSettingsResponse>(create);
  static UpdateDiscordReminderSettingsResponse? _defaultInstance;
}

class UpdateDiscordBehaviorSettingsRequest extends $pb.GeneratedMessage {
  factory UpdateDiscordBehaviorSettingsRequest({
    $core.bool? discordSelfLinkEnabled,
    $core.bool? discordNameSyncEnabled,
    $core.bool? discordOvertimeDmEnabled,
    $fixnum.Int64? discordOvertimeDmMins,
    $core.String? discordOvertimeDmMessage,
    $core.bool? discordAutoCheckoutDmEnabled,
    $core.String? discordAutoCheckoutDmMessage,
    $core.bool? discordCheckoutEnabled,
    $core.bool? discordRsvpReactionsEnabled,
  }) {
    final result = create();
    if (discordSelfLinkEnabled != null)
      result.discordSelfLinkEnabled = discordSelfLinkEnabled;
    if (discordNameSyncEnabled != null)
      result.discordNameSyncEnabled = discordNameSyncEnabled;
    if (discordOvertimeDmEnabled != null)
      result.discordOvertimeDmEnabled = discordOvertimeDmEnabled;
    if (discordOvertimeDmMins != null)
      result.discordOvertimeDmMins = discordOvertimeDmMins;
    if (discordOvertimeDmMessage != null)
      result.discordOvertimeDmMessage = discordOvertimeDmMessage;
    if (discordAutoCheckoutDmEnabled != null)
      result.discordAutoCheckoutDmEnabled = discordAutoCheckoutDmEnabled;
    if (discordAutoCheckoutDmMessage != null)
      result.discordAutoCheckoutDmMessage = discordAutoCheckoutDmMessage;
    if (discordCheckoutEnabled != null)
      result.discordCheckoutEnabled = discordCheckoutEnabled;
    if (discordRsvpReactionsEnabled != null)
      result.discordRsvpReactionsEnabled = discordRsvpReactionsEnabled;
    return result;
  }

  UpdateDiscordBehaviorSettingsRequest._();

  factory UpdateDiscordBehaviorSettingsRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateDiscordBehaviorSettingsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateDiscordBehaviorSettingsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'discordSelfLinkEnabled')
    ..aOB(2, _omitFieldNames ? '' : 'discordNameSyncEnabled')
    ..aOB(3, _omitFieldNames ? '' : 'discordOvertimeDmEnabled')
    ..aInt64(4, _omitFieldNames ? '' : 'discordOvertimeDmMins')
    ..aOS(5, _omitFieldNames ? '' : 'discordOvertimeDmMessage')
    ..aOB(6, _omitFieldNames ? '' : 'discordAutoCheckoutDmEnabled')
    ..aOS(7, _omitFieldNames ? '' : 'discordAutoCheckoutDmMessage')
    ..aOB(8, _omitFieldNames ? '' : 'discordCheckoutEnabled')
    ..aOB(9, _omitFieldNames ? '' : 'discordRsvpReactionsEnabled')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateDiscordBehaviorSettingsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateDiscordBehaviorSettingsRequest copyWith(
          void Function(UpdateDiscordBehaviorSettingsRequest) updates) =>
      super.copyWith((message) =>
              updates(message as UpdateDiscordBehaviorSettingsRequest))
          as UpdateDiscordBehaviorSettingsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateDiscordBehaviorSettingsRequest create() =>
      UpdateDiscordBehaviorSettingsRequest._();
  @$core.override
  UpdateDiscordBehaviorSettingsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateDiscordBehaviorSettingsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          UpdateDiscordBehaviorSettingsRequest>(create);
  static UpdateDiscordBehaviorSettingsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get discordSelfLinkEnabled => $_getBF(0);
  @$pb.TagNumber(1)
  set discordSelfLinkEnabled($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDiscordSelfLinkEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearDiscordSelfLinkEnabled() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get discordNameSyncEnabled => $_getBF(1);
  @$pb.TagNumber(2)
  set discordNameSyncEnabled($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDiscordNameSyncEnabled() => $_has(1);
  @$pb.TagNumber(2)
  void clearDiscordNameSyncEnabled() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get discordOvertimeDmEnabled => $_getBF(2);
  @$pb.TagNumber(3)
  set discordOvertimeDmEnabled($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDiscordOvertimeDmEnabled() => $_has(2);
  @$pb.TagNumber(3)
  void clearDiscordOvertimeDmEnabled() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get discordOvertimeDmMins => $_getI64(3);
  @$pb.TagNumber(4)
  set discordOvertimeDmMins($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDiscordOvertimeDmMins() => $_has(3);
  @$pb.TagNumber(4)
  void clearDiscordOvertimeDmMins() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get discordOvertimeDmMessage => $_getSZ(4);
  @$pb.TagNumber(5)
  set discordOvertimeDmMessage($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDiscordOvertimeDmMessage() => $_has(4);
  @$pb.TagNumber(5)
  void clearDiscordOvertimeDmMessage() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get discordAutoCheckoutDmEnabled => $_getBF(5);
  @$pb.TagNumber(6)
  set discordAutoCheckoutDmEnabled($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDiscordAutoCheckoutDmEnabled() => $_has(5);
  @$pb.TagNumber(6)
  void clearDiscordAutoCheckoutDmEnabled() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get discordAutoCheckoutDmMessage => $_getSZ(6);
  @$pb.TagNumber(7)
  set discordAutoCheckoutDmMessage($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDiscordAutoCheckoutDmMessage() => $_has(6);
  @$pb.TagNumber(7)
  void clearDiscordAutoCheckoutDmMessage() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get discordCheckoutEnabled => $_getBF(7);
  @$pb.TagNumber(8)
  set discordCheckoutEnabled($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDiscordCheckoutEnabled() => $_has(7);
  @$pb.TagNumber(8)
  void clearDiscordCheckoutEnabled() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get discordRsvpReactionsEnabled => $_getBF(8);
  @$pb.TagNumber(9)
  set discordRsvpReactionsEnabled($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDiscordRsvpReactionsEnabled() => $_has(8);
  @$pb.TagNumber(9)
  void clearDiscordRsvpReactionsEnabled() => $_clearField(9);
}

class UpdateDiscordBehaviorSettingsResponse extends $pb.GeneratedMessage {
  factory UpdateDiscordBehaviorSettingsResponse() => create();

  UpdateDiscordBehaviorSettingsResponse._();

  factory UpdateDiscordBehaviorSettingsResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateDiscordBehaviorSettingsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateDiscordBehaviorSettingsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateDiscordBehaviorSettingsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateDiscordBehaviorSettingsResponse copyWith(
          void Function(UpdateDiscordBehaviorSettingsResponse) updates) =>
      super.copyWith((message) =>
              updates(message as UpdateDiscordBehaviorSettingsResponse))
          as UpdateDiscordBehaviorSettingsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateDiscordBehaviorSettingsResponse create() =>
      UpdateDiscordBehaviorSettingsResponse._();
  @$core.override
  UpdateDiscordBehaviorSettingsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateDiscordBehaviorSettingsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          UpdateDiscordBehaviorSettingsResponse>(create);
  static UpdateDiscordBehaviorSettingsResponse? _defaultInstance;
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

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
