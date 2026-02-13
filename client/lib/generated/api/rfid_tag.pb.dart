// This is a generated file - do not edit.
//
// Generated from api/rfid_tag.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../common/common.pbenum.dart' as $2;
import '../db/db.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class RfidTagResponse extends $pb.GeneratedMessage {
  factory RfidTagResponse({
    $core.String? id,
    $1.RfidTag? rfidTag,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (rfidTag != null) result.rfidTag = rfidTag;
    return result;
  }

  RfidTagResponse._();

  factory RfidTagResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RfidTagResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RfidTagResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$1.RfidTag>(2, _omitFieldNames ? '' : 'rfidTag',
        subBuilder: $1.RfidTag.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RfidTagResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RfidTagResponse copyWith(void Function(RfidTagResponse) updates) =>
      super.copyWith((message) => updates(message as RfidTagResponse))
          as RfidTagResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RfidTagResponse create() => RfidTagResponse._();
  @$core.override
  RfidTagResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RfidTagResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RfidTagResponse>(create);
  static RfidTagResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.RfidTag get rfidTag => $_getN(1);
  @$pb.TagNumber(2)
  set rfidTag($1.RfidTag value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasRfidTag() => $_has(1);
  @$pb.TagNumber(2)
  void clearRfidTag() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.RfidTag ensureRfidTag() => $_ensure(1);
}

class GetRfidTagsRequest extends $pb.GeneratedMessage {
  factory GetRfidTagsRequest() => create();

  GetRfidTagsRequest._();

  factory GetRfidTagsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRfidTagsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRfidTagsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRfidTagsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRfidTagsRequest copyWith(void Function(GetRfidTagsRequest) updates) =>
      super.copyWith((message) => updates(message as GetRfidTagsRequest))
          as GetRfidTagsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRfidTagsRequest create() => GetRfidTagsRequest._();
  @$core.override
  GetRfidTagsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRfidTagsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRfidTagsRequest>(create);
  static GetRfidTagsRequest? _defaultInstance;
}

class GetRfidTagsResponse extends $pb.GeneratedMessage {
  factory GetRfidTagsResponse({
    $core.Iterable<RfidTagResponse>? rfidTags,
  }) {
    final result = create();
    if (rfidTags != null) result.rfidTags.addAll(rfidTags);
    return result;
  }

  GetRfidTagsResponse._();

  factory GetRfidTagsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRfidTagsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRfidTagsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..pPM<RfidTagResponse>(1, _omitFieldNames ? '' : 'rfidTags',
        subBuilder: RfidTagResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRfidTagsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRfidTagsResponse copyWith(void Function(GetRfidTagsResponse) updates) =>
      super.copyWith((message) => updates(message as GetRfidTagsResponse))
          as GetRfidTagsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRfidTagsResponse create() => GetRfidTagsResponse._();
  @$core.override
  GetRfidTagsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRfidTagsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRfidTagsResponse>(create);
  static GetRfidTagsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<RfidTagResponse> get rfidTags => $_getList(0);
}

class StreamRfidTagsRequest extends $pb.GeneratedMessage {
  factory StreamRfidTagsRequest() => create();

  StreamRfidTagsRequest._();

  factory StreamRfidTagsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamRfidTagsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamRfidTagsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamRfidTagsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamRfidTagsRequest copyWith(
          void Function(StreamRfidTagsRequest) updates) =>
      super.copyWith((message) => updates(message as StreamRfidTagsRequest))
          as StreamRfidTagsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamRfidTagsRequest create() => StreamRfidTagsRequest._();
  @$core.override
  StreamRfidTagsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamRfidTagsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamRfidTagsRequest>(create);
  static StreamRfidTagsRequest? _defaultInstance;
}

class StreamRfidTagsResponse extends $pb.GeneratedMessage {
  factory StreamRfidTagsResponse({
    $core.Iterable<RfidTagResponse>? rfidTags,
    $2.SyncType? syncType,
  }) {
    final result = create();
    if (rfidTags != null) result.rfidTags.addAll(rfidTags);
    if (syncType != null) result.syncType = syncType;
    return result;
  }

  StreamRfidTagsResponse._();

  factory StreamRfidTagsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamRfidTagsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamRfidTagsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..pPM<RfidTagResponse>(1, _omitFieldNames ? '' : 'rfidTags',
        subBuilder: RfidTagResponse.create)
    ..aE<$2.SyncType>(2, _omitFieldNames ? '' : 'syncType',
        enumValues: $2.SyncType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamRfidTagsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamRfidTagsResponse copyWith(
          void Function(StreamRfidTagsResponse) updates) =>
      super.copyWith((message) => updates(message as StreamRfidTagsResponse))
          as StreamRfidTagsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamRfidTagsResponse create() => StreamRfidTagsResponse._();
  @$core.override
  StreamRfidTagsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamRfidTagsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamRfidTagsResponse>(create);
  static StreamRfidTagsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<RfidTagResponse> get rfidTags => $_getList(0);

  @$pb.TagNumber(2)
  $2.SyncType get syncType => $_getN(1);
  @$pb.TagNumber(2)
  set syncType($2.SyncType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSyncType() => $_has(1);
  @$pb.TagNumber(2)
  void clearSyncType() => $_clearField(2);
}

class CreateRfidTagRequest extends $pb.GeneratedMessage {
  factory CreateRfidTagRequest({
    $core.String? teamMemberId,
    $core.String? tag,
  }) {
    final result = create();
    if (teamMemberId != null) result.teamMemberId = teamMemberId;
    if (tag != null) result.tag = tag;
    return result;
  }

  CreateRfidTagRequest._();

  factory CreateRfidTagRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateRfidTagRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateRfidTagRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'teamMemberId')
    ..aOS(2, _omitFieldNames ? '' : 'tag')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateRfidTagRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateRfidTagRequest copyWith(void Function(CreateRfidTagRequest) updates) =>
      super.copyWith((message) => updates(message as CreateRfidTagRequest))
          as CreateRfidTagRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateRfidTagRequest create() => CreateRfidTagRequest._();
  @$core.override
  CreateRfidTagRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateRfidTagRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateRfidTagRequest>(create);
  static CreateRfidTagRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get teamMemberId => $_getSZ(0);
  @$pb.TagNumber(1)
  set teamMemberId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTeamMemberId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTeamMemberId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tag => $_getSZ(1);
  @$pb.TagNumber(2)
  set tag($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTag() => $_has(1);
  @$pb.TagNumber(2)
  void clearTag() => $_clearField(2);
}

class CreateRfidTagResponse extends $pb.GeneratedMessage {
  factory CreateRfidTagResponse() => create();

  CreateRfidTagResponse._();

  factory CreateRfidTagResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateRfidTagResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateRfidTagResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateRfidTagResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateRfidTagResponse copyWith(
          void Function(CreateRfidTagResponse) updates) =>
      super.copyWith((message) => updates(message as CreateRfidTagResponse))
          as CreateRfidTagResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateRfidTagResponse create() => CreateRfidTagResponse._();
  @$core.override
  CreateRfidTagResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateRfidTagResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateRfidTagResponse>(create);
  static CreateRfidTagResponse? _defaultInstance;
}

class DeleteRfidTagRequest extends $pb.GeneratedMessage {
  factory DeleteRfidTagRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  DeleteRfidTagRequest._();

  factory DeleteRfidTagRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteRfidTagRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteRfidTagRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteRfidTagRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteRfidTagRequest copyWith(void Function(DeleteRfidTagRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteRfidTagRequest))
          as DeleteRfidTagRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteRfidTagRequest create() => DeleteRfidTagRequest._();
  @$core.override
  DeleteRfidTagRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteRfidTagRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteRfidTagRequest>(create);
  static DeleteRfidTagRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class DeleteRfidTagResponse extends $pb.GeneratedMessage {
  factory DeleteRfidTagResponse() => create();

  DeleteRfidTagResponse._();

  factory DeleteRfidTagResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteRfidTagResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteRfidTagResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteRfidTagResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteRfidTagResponse copyWith(
          void Function(DeleteRfidTagResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteRfidTagResponse))
          as DeleteRfidTagResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteRfidTagResponse create() => DeleteRfidTagResponse._();
  @$core.override
  DeleteRfidTagResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteRfidTagResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteRfidTagResponse>(create);
  static DeleteRfidTagResponse? _defaultInstance;
}

class DeleteRfidTagsByMemberRequest extends $pb.GeneratedMessage {
  factory DeleteRfidTagsByMemberRequest({
    $core.String? teamMemberId,
  }) {
    final result = create();
    if (teamMemberId != null) result.teamMemberId = teamMemberId;
    return result;
  }

  DeleteRfidTagsByMemberRequest._();

  factory DeleteRfidTagsByMemberRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteRfidTagsByMemberRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteRfidTagsByMemberRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'teamMemberId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteRfidTagsByMemberRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteRfidTagsByMemberRequest copyWith(
          void Function(DeleteRfidTagsByMemberRequest) updates) =>
      super.copyWith(
              (message) => updates(message as DeleteRfidTagsByMemberRequest))
          as DeleteRfidTagsByMemberRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteRfidTagsByMemberRequest create() =>
      DeleteRfidTagsByMemberRequest._();
  @$core.override
  DeleteRfidTagsByMemberRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteRfidTagsByMemberRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteRfidTagsByMemberRequest>(create);
  static DeleteRfidTagsByMemberRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get teamMemberId => $_getSZ(0);
  @$pb.TagNumber(1)
  set teamMemberId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTeamMemberId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTeamMemberId() => $_clearField(1);
}

class DeleteRfidTagsByMemberResponse extends $pb.GeneratedMessage {
  factory DeleteRfidTagsByMemberResponse() => create();

  DeleteRfidTagsByMemberResponse._();

  factory DeleteRfidTagsByMemberResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteRfidTagsByMemberResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteRfidTagsByMemberResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteRfidTagsByMemberResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteRfidTagsByMemberResponse copyWith(
          void Function(DeleteRfidTagsByMemberResponse) updates) =>
      super.copyWith(
              (message) => updates(message as DeleteRfidTagsByMemberResponse))
          as DeleteRfidTagsByMemberResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteRfidTagsByMemberResponse create() =>
      DeleteRfidTagsByMemberResponse._();
  @$core.override
  DeleteRfidTagsByMemberResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteRfidTagsByMemberResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteRfidTagsByMemberResponse>(create);
  static DeleteRfidTagsByMemberResponse? _defaultInstance;
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
