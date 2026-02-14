// This is a generated file - do not edit.
//
// Generated from api/team_member_session.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../common/common.pb.dart' as $2;
import '../db/db.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class TeamMemberSessionResponse extends $pb.GeneratedMessage {
  factory TeamMemberSessionResponse({
    $core.String? id,
    $1.TeamMemberSession? teamMemberSession,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (teamMemberSession != null) result.teamMemberSession = teamMemberSession;
    return result;
  }

  TeamMemberSessionResponse._();

  factory TeamMemberSessionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TeamMemberSessionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TeamMemberSessionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$1.TeamMemberSession>(2, _omitFieldNames ? '' : 'teamMemberSession',
        subBuilder: $1.TeamMemberSession.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamMemberSessionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamMemberSessionResponse copyWith(
          void Function(TeamMemberSessionResponse) updates) =>
      super.copyWith((message) => updates(message as TeamMemberSessionResponse))
          as TeamMemberSessionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TeamMemberSessionResponse create() => TeamMemberSessionResponse._();
  @$core.override
  TeamMemberSessionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TeamMemberSessionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TeamMemberSessionResponse>(create);
  static TeamMemberSessionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.TeamMemberSession get teamMemberSession => $_getN(1);
  @$pb.TagNumber(2)
  set teamMemberSession($1.TeamMemberSession value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTeamMemberSession() => $_has(1);
  @$pb.TagNumber(2)
  void clearTeamMemberSession() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.TeamMemberSession ensureTeamMemberSession() => $_ensure(1);
}

class GetTeamMemberSessionsRequest extends $pb.GeneratedMessage {
  factory GetTeamMemberSessionsRequest() => create();

  GetTeamMemberSessionsRequest._();

  factory GetTeamMemberSessionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTeamMemberSessionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTeamMemberSessionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTeamMemberSessionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTeamMemberSessionsRequest copyWith(
          void Function(GetTeamMemberSessionsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetTeamMemberSessionsRequest))
          as GetTeamMemberSessionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTeamMemberSessionsRequest create() =>
      GetTeamMemberSessionsRequest._();
  @$core.override
  GetTeamMemberSessionsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTeamMemberSessionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTeamMemberSessionsRequest>(create);
  static GetTeamMemberSessionsRequest? _defaultInstance;
}

class GetTeamMemberSessionsResponse extends $pb.GeneratedMessage {
  factory GetTeamMemberSessionsResponse({
    $core.Iterable<TeamMemberSessionResponse>? teamMemberSessions,
  }) {
    final result = create();
    if (teamMemberSessions != null)
      result.teamMemberSessions.addAll(teamMemberSessions);
    return result;
  }

  GetTeamMemberSessionsResponse._();

  factory GetTeamMemberSessionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTeamMemberSessionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTeamMemberSessionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..pPM<TeamMemberSessionResponse>(
        1, _omitFieldNames ? '' : 'teamMemberSessions',
        subBuilder: TeamMemberSessionResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTeamMemberSessionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTeamMemberSessionsResponse copyWith(
          void Function(GetTeamMemberSessionsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetTeamMemberSessionsResponse))
          as GetTeamMemberSessionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTeamMemberSessionsResponse create() =>
      GetTeamMemberSessionsResponse._();
  @$core.override
  GetTeamMemberSessionsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTeamMemberSessionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTeamMemberSessionsResponse>(create);
  static GetTeamMemberSessionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TeamMemberSessionResponse> get teamMemberSessions => $_getList(0);
}

class StreamTeamMemberSessionsRequest extends $pb.GeneratedMessage {
  factory StreamTeamMemberSessionsRequest() => create();

  StreamTeamMemberSessionsRequest._();

  factory StreamTeamMemberSessionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamTeamMemberSessionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamTeamMemberSessionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamTeamMemberSessionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamTeamMemberSessionsRequest copyWith(
          void Function(StreamTeamMemberSessionsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as StreamTeamMemberSessionsRequest))
          as StreamTeamMemberSessionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamTeamMemberSessionsRequest create() =>
      StreamTeamMemberSessionsRequest._();
  @$core.override
  StreamTeamMemberSessionsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamTeamMemberSessionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamTeamMemberSessionsRequest>(
          create);
  static StreamTeamMemberSessionsRequest? _defaultInstance;
}

class StreamTeamMemberSessionsResponse extends $pb.GeneratedMessage {
  factory StreamTeamMemberSessionsResponse({
    $core.Iterable<TeamMemberSessionResponse>? teamMemberSessions,
    $2.SyncType? syncType,
  }) {
    final result = create();
    if (teamMemberSessions != null)
      result.teamMemberSessions.addAll(teamMemberSessions);
    if (syncType != null) result.syncType = syncType;
    return result;
  }

  StreamTeamMemberSessionsResponse._();

  factory StreamTeamMemberSessionsResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamTeamMemberSessionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamTeamMemberSessionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..pPM<TeamMemberSessionResponse>(
        1, _omitFieldNames ? '' : 'teamMemberSessions',
        subBuilder: TeamMemberSessionResponse.create)
    ..aE<$2.SyncType>(2, _omitFieldNames ? '' : 'syncType',
        enumValues: $2.SyncType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamTeamMemberSessionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamTeamMemberSessionsResponse copyWith(
          void Function(StreamTeamMemberSessionsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as StreamTeamMemberSessionsResponse))
          as StreamTeamMemberSessionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamTeamMemberSessionsResponse create() =>
      StreamTeamMemberSessionsResponse._();
  @$core.override
  StreamTeamMemberSessionsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamTeamMemberSessionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamTeamMemberSessionsResponse>(
          create);
  static StreamTeamMemberSessionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TeamMemberSessionResponse> get teamMemberSessions => $_getList(0);

  @$pb.TagNumber(2)
  $2.SyncType get syncType => $_getN(1);
  @$pb.TagNumber(2)
  set syncType($2.SyncType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSyncType() => $_has(1);
  @$pb.TagNumber(2)
  void clearSyncType() => $_clearField(2);
}

class UpdateTeamMemberSessionRequest extends $pb.GeneratedMessage {
  factory UpdateTeamMemberSessionRequest({
    $core.String? id,
    $2.Timestamp? checkInTime,
    $2.Timestamp? checkOutTime,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (checkInTime != null) result.checkInTime = checkInTime;
    if (checkOutTime != null) result.checkOutTime = checkOutTime;
    return result;
  }

  UpdateTeamMemberSessionRequest._();

  factory UpdateTeamMemberSessionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateTeamMemberSessionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateTeamMemberSessionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$2.Timestamp>(2, _omitFieldNames ? '' : 'checkInTime',
        subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(3, _omitFieldNames ? '' : 'checkOutTime',
        subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateTeamMemberSessionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateTeamMemberSessionRequest copyWith(
          void Function(UpdateTeamMemberSessionRequest) updates) =>
      super.copyWith(
              (message) => updates(message as UpdateTeamMemberSessionRequest))
          as UpdateTeamMemberSessionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateTeamMemberSessionRequest create() =>
      UpdateTeamMemberSessionRequest._();
  @$core.override
  UpdateTeamMemberSessionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateTeamMemberSessionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateTeamMemberSessionRequest>(create);
  static UpdateTeamMemberSessionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $2.Timestamp get checkInTime => $_getN(1);
  @$pb.TagNumber(2)
  set checkInTime($2.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCheckInTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearCheckInTime() => $_clearField(2);
  @$pb.TagNumber(2)
  $2.Timestamp ensureCheckInTime() => $_ensure(1);

  @$pb.TagNumber(3)
  $2.Timestamp get checkOutTime => $_getN(2);
  @$pb.TagNumber(3)
  set checkOutTime($2.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCheckOutTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearCheckOutTime() => $_clearField(3);
  @$pb.TagNumber(3)
  $2.Timestamp ensureCheckOutTime() => $_ensure(2);
}

class UpdateTeamMemberSessionResponse extends $pb.GeneratedMessage {
  factory UpdateTeamMemberSessionResponse() => create();

  UpdateTeamMemberSessionResponse._();

  factory UpdateTeamMemberSessionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateTeamMemberSessionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateTeamMemberSessionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateTeamMemberSessionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateTeamMemberSessionResponse copyWith(
          void Function(UpdateTeamMemberSessionResponse) updates) =>
      super.copyWith(
              (message) => updates(message as UpdateTeamMemberSessionResponse))
          as UpdateTeamMemberSessionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateTeamMemberSessionResponse create() =>
      UpdateTeamMemberSessionResponse._();
  @$core.override
  UpdateTeamMemberSessionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateTeamMemberSessionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateTeamMemberSessionResponse>(
          create);
  static UpdateTeamMemberSessionResponse? _defaultInstance;
}

class DeleteTeamMemberSessionRequest extends $pb.GeneratedMessage {
  factory DeleteTeamMemberSessionRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  DeleteTeamMemberSessionRequest._();

  factory DeleteTeamMemberSessionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteTeamMemberSessionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteTeamMemberSessionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTeamMemberSessionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTeamMemberSessionRequest copyWith(
          void Function(DeleteTeamMemberSessionRequest) updates) =>
      super.copyWith(
              (message) => updates(message as DeleteTeamMemberSessionRequest))
          as DeleteTeamMemberSessionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteTeamMemberSessionRequest create() =>
      DeleteTeamMemberSessionRequest._();
  @$core.override
  DeleteTeamMemberSessionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteTeamMemberSessionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteTeamMemberSessionRequest>(create);
  static DeleteTeamMemberSessionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class DeleteTeamMemberSessionResponse extends $pb.GeneratedMessage {
  factory DeleteTeamMemberSessionResponse() => create();

  DeleteTeamMemberSessionResponse._();

  factory DeleteTeamMemberSessionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteTeamMemberSessionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteTeamMemberSessionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTeamMemberSessionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTeamMemberSessionResponse copyWith(
          void Function(DeleteTeamMemberSessionResponse) updates) =>
      super.copyWith(
              (message) => updates(message as DeleteTeamMemberSessionResponse))
          as DeleteTeamMemberSessionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteTeamMemberSessionResponse create() =>
      DeleteTeamMemberSessionResponse._();
  @$core.override
  DeleteTeamMemberSessionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteTeamMemberSessionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteTeamMemberSessionResponse>(
          create);
  static DeleteTeamMemberSessionResponse? _defaultInstance;
}

class ImportAttendanceCsvRequest extends $pb.GeneratedMessage {
  factory ImportAttendanceCsvRequest({
    $core.List<$core.int>? csvData,
  }) {
    final result = create();
    if (csvData != null) result.csvData = csvData;
    return result;
  }

  ImportAttendanceCsvRequest._();

  factory ImportAttendanceCsvRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImportAttendanceCsvRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportAttendanceCsvRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'csvData', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportAttendanceCsvRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportAttendanceCsvRequest copyWith(
          void Function(ImportAttendanceCsvRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ImportAttendanceCsvRequest))
          as ImportAttendanceCsvRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportAttendanceCsvRequest create() => ImportAttendanceCsvRequest._();
  @$core.override
  ImportAttendanceCsvRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ImportAttendanceCsvRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportAttendanceCsvRequest>(create);
  static ImportAttendanceCsvRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get csvData => $_getN(0);
  @$pb.TagNumber(1)
  set csvData($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCsvData() => $_has(0);
  @$pb.TagNumber(1)
  void clearCsvData() => $_clearField(1);
}

class ImportAttendanceCsvResponse extends $pb.GeneratedMessage {
  factory ImportAttendanceCsvResponse() => create();

  ImportAttendanceCsvResponse._();

  factory ImportAttendanceCsvResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImportAttendanceCsvResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImportAttendanceCsvResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportAttendanceCsvResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportAttendanceCsvResponse copyWith(
          void Function(ImportAttendanceCsvResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ImportAttendanceCsvResponse))
          as ImportAttendanceCsvResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportAttendanceCsvResponse create() =>
      ImportAttendanceCsvResponse._();
  @$core.override
  ImportAttendanceCsvResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ImportAttendanceCsvResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportAttendanceCsvResponse>(create);
  static ImportAttendanceCsvResponse? _defaultInstance;
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
