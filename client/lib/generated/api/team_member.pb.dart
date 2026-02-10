// This is a generated file - do not edit.
//
// Generated from api/team_member.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../db/db.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class UploadStudentCsvRequest extends $pb.GeneratedMessage {
  factory UploadStudentCsvRequest({
    $core.List<$core.int>? csvData,
  }) {
    final result = create();
    if (csvData != null) result.csvData = csvData;
    return result;
  }

  UploadStudentCsvRequest._();

  factory UploadStudentCsvRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UploadStudentCsvRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UploadStudentCsvRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'csvData', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadStudentCsvRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadStudentCsvRequest copyWith(
          void Function(UploadStudentCsvRequest) updates) =>
      super.copyWith((message) => updates(message as UploadStudentCsvRequest))
          as UploadStudentCsvRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UploadStudentCsvRequest create() => UploadStudentCsvRequest._();
  @$core.override
  UploadStudentCsvRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UploadStudentCsvRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UploadStudentCsvRequest>(create);
  static UploadStudentCsvRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get csvData => $_getN(0);
  @$pb.TagNumber(1)
  set csvData($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCsvData() => $_has(0);
  @$pb.TagNumber(1)
  void clearCsvData() => $_clearField(1);
}

class UploadStudentCsvResponse extends $pb.GeneratedMessage {
  factory UploadStudentCsvResponse() => create();

  UploadStudentCsvResponse._();

  factory UploadStudentCsvResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UploadStudentCsvResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UploadStudentCsvResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadStudentCsvResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadStudentCsvResponse copyWith(
          void Function(UploadStudentCsvResponse) updates) =>
      super.copyWith((message) => updates(message as UploadStudentCsvResponse))
          as UploadStudentCsvResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UploadStudentCsvResponse create() => UploadStudentCsvResponse._();
  @$core.override
  UploadStudentCsvResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UploadStudentCsvResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UploadStudentCsvResponse>(create);
  static UploadStudentCsvResponse? _defaultInstance;
}

class UploadMentorCsvRequest extends $pb.GeneratedMessage {
  factory UploadMentorCsvRequest({
    $core.List<$core.int>? csvData,
  }) {
    final result = create();
    if (csvData != null) result.csvData = csvData;
    return result;
  }

  UploadMentorCsvRequest._();

  factory UploadMentorCsvRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UploadMentorCsvRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UploadMentorCsvRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'csvData', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadMentorCsvRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadMentorCsvRequest copyWith(
          void Function(UploadMentorCsvRequest) updates) =>
      super.copyWith((message) => updates(message as UploadMentorCsvRequest))
          as UploadMentorCsvRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UploadMentorCsvRequest create() => UploadMentorCsvRequest._();
  @$core.override
  UploadMentorCsvRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UploadMentorCsvRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UploadMentorCsvRequest>(create);
  static UploadMentorCsvRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get csvData => $_getN(0);
  @$pb.TagNumber(1)
  set csvData($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCsvData() => $_has(0);
  @$pb.TagNumber(1)
  void clearCsvData() => $_clearField(1);
}

class UploadMentorCsvResponse extends $pb.GeneratedMessage {
  factory UploadMentorCsvResponse() => create();

  UploadMentorCsvResponse._();

  factory UploadMentorCsvResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UploadMentorCsvResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UploadMentorCsvResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadMentorCsvResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadMentorCsvResponse copyWith(
          void Function(UploadMentorCsvResponse) updates) =>
      super.copyWith((message) => updates(message as UploadMentorCsvResponse))
          as UploadMentorCsvResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UploadMentorCsvResponse create() => UploadMentorCsvResponse._();
  @$core.override
  UploadMentorCsvResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UploadMentorCsvResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UploadMentorCsvResponse>(create);
  static UploadMentorCsvResponse? _defaultInstance;
}

class TeamMemberResponse extends $pb.GeneratedMessage {
  factory TeamMemberResponse({
    $core.String? id,
    $1.TeamMember? teamMember,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (teamMember != null) result.teamMember = teamMember;
    return result;
  }

  TeamMemberResponse._();

  factory TeamMemberResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TeamMemberResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TeamMemberResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$1.TeamMember>(2, _omitFieldNames ? '' : 'teamMember',
        subBuilder: $1.TeamMember.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamMemberResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamMemberResponse copyWith(void Function(TeamMemberResponse) updates) =>
      super.copyWith((message) => updates(message as TeamMemberResponse))
          as TeamMemberResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TeamMemberResponse create() => TeamMemberResponse._();
  @$core.override
  TeamMemberResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TeamMemberResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TeamMemberResponse>(create);
  static TeamMemberResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.TeamMember get teamMember => $_getN(1);
  @$pb.TagNumber(2)
  set teamMember($1.TeamMember value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTeamMember() => $_has(1);
  @$pb.TagNumber(2)
  void clearTeamMember() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.TeamMember ensureTeamMember() => $_ensure(1);
}

class GetTeamMembersRequest extends $pb.GeneratedMessage {
  factory GetTeamMembersRequest() => create();

  GetTeamMembersRequest._();

  factory GetTeamMembersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTeamMembersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTeamMembersRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTeamMembersRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTeamMembersRequest copyWith(
          void Function(GetTeamMembersRequest) updates) =>
      super.copyWith((message) => updates(message as GetTeamMembersRequest))
          as GetTeamMembersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTeamMembersRequest create() => GetTeamMembersRequest._();
  @$core.override
  GetTeamMembersRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTeamMembersRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTeamMembersRequest>(create);
  static GetTeamMembersRequest? _defaultInstance;
}

class GetTeamMembersResponse extends $pb.GeneratedMessage {
  factory GetTeamMembersResponse({
    $core.Iterable<TeamMemberResponse>? teamMembers,
  }) {
    final result = create();
    if (teamMembers != null) result.teamMembers.addAll(teamMembers);
    return result;
  }

  GetTeamMembersResponse._();

  factory GetTeamMembersResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTeamMembersResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTeamMembersResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..pPM<TeamMemberResponse>(1, _omitFieldNames ? '' : 'teamMembers',
        subBuilder: TeamMemberResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTeamMembersResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTeamMembersResponse copyWith(
          void Function(GetTeamMembersResponse) updates) =>
      super.copyWith((message) => updates(message as GetTeamMembersResponse))
          as GetTeamMembersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTeamMembersResponse create() => GetTeamMembersResponse._();
  @$core.override
  GetTeamMembersResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTeamMembersResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTeamMembersResponse>(create);
  static GetTeamMembersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TeamMemberResponse> get teamMembers => $_getList(0);
}

class GetStudentsRequest extends $pb.GeneratedMessage {
  factory GetStudentsRequest() => create();

  GetStudentsRequest._();

  factory GetStudentsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetStudentsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetStudentsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStudentsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStudentsRequest copyWith(void Function(GetStudentsRequest) updates) =>
      super.copyWith((message) => updates(message as GetStudentsRequest))
          as GetStudentsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetStudentsRequest create() => GetStudentsRequest._();
  @$core.override
  GetStudentsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetStudentsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetStudentsRequest>(create);
  static GetStudentsRequest? _defaultInstance;
}

class GetStudentsResponse extends $pb.GeneratedMessage {
  factory GetStudentsResponse({
    $core.Iterable<TeamMemberResponse>? students,
  }) {
    final result = create();
    if (students != null) result.students.addAll(students);
    return result;
  }

  GetStudentsResponse._();

  factory GetStudentsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetStudentsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetStudentsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..pPM<TeamMemberResponse>(1, _omitFieldNames ? '' : 'students',
        subBuilder: TeamMemberResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStudentsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStudentsResponse copyWith(void Function(GetStudentsResponse) updates) =>
      super.copyWith((message) => updates(message as GetStudentsResponse))
          as GetStudentsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetStudentsResponse create() => GetStudentsResponse._();
  @$core.override
  GetStudentsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetStudentsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetStudentsResponse>(create);
  static GetStudentsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TeamMemberResponse> get students => $_getList(0);
}

class GetMentorsRequest extends $pb.GeneratedMessage {
  factory GetMentorsRequest() => create();

  GetMentorsRequest._();

  factory GetMentorsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMentorsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMentorsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMentorsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMentorsRequest copyWith(void Function(GetMentorsRequest) updates) =>
      super.copyWith((message) => updates(message as GetMentorsRequest))
          as GetMentorsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMentorsRequest create() => GetMentorsRequest._();
  @$core.override
  GetMentorsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMentorsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMentorsRequest>(create);
  static GetMentorsRequest? _defaultInstance;
}

class GetMentorsResponse extends $pb.GeneratedMessage {
  factory GetMentorsResponse({
    $core.Iterable<TeamMemberResponse>? mentors,
  }) {
    final result = create();
    if (mentors != null) result.mentors.addAll(mentors);
    return result;
  }

  GetMentorsResponse._();

  factory GetMentorsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMentorsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMentorsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..pPM<TeamMemberResponse>(1, _omitFieldNames ? '' : 'mentors',
        subBuilder: TeamMemberResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMentorsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMentorsResponse copyWith(void Function(GetMentorsResponse) updates) =>
      super.copyWith((message) => updates(message as GetMentorsResponse))
          as GetMentorsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMentorsResponse create() => GetMentorsResponse._();
  @$core.override
  GetMentorsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMentorsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMentorsResponse>(create);
  static GetMentorsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TeamMemberResponse> get mentors => $_getList(0);
}

class StreamTeamMembersRequest extends $pb.GeneratedMessage {
  factory StreamTeamMembersRequest() => create();

  StreamTeamMembersRequest._();

  factory StreamTeamMembersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamTeamMembersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamTeamMembersRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamTeamMembersRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamTeamMembersRequest copyWith(
          void Function(StreamTeamMembersRequest) updates) =>
      super.copyWith((message) => updates(message as StreamTeamMembersRequest))
          as StreamTeamMembersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamTeamMembersRequest create() => StreamTeamMembersRequest._();
  @$core.override
  StreamTeamMembersRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamTeamMembersRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamTeamMembersRequest>(create);
  static StreamTeamMembersRequest? _defaultInstance;
}

class StreamTeamMembersResponse extends $pb.GeneratedMessage {
  factory StreamTeamMembersResponse({
    $core.Iterable<TeamMemberResponse>? teamMembers,
  }) {
    final result = create();
    if (teamMembers != null) result.teamMembers.addAll(teamMembers);
    return result;
  }

  StreamTeamMembersResponse._();

  factory StreamTeamMembersResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamTeamMembersResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamTeamMembersResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..pPM<TeamMemberResponse>(1, _omitFieldNames ? '' : 'teamMembers',
        subBuilder: TeamMemberResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamTeamMembersResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamTeamMembersResponse copyWith(
          void Function(StreamTeamMembersResponse) updates) =>
      super.copyWith((message) => updates(message as StreamTeamMembersResponse))
          as StreamTeamMembersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamTeamMembersResponse create() => StreamTeamMembersResponse._();
  @$core.override
  StreamTeamMembersResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamTeamMembersResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamTeamMembersResponse>(create);
  static StreamTeamMembersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TeamMemberResponse> get teamMembers => $_getList(0);
}

class StreamStudentsRequest extends $pb.GeneratedMessage {
  factory StreamStudentsRequest() => create();

  StreamStudentsRequest._();

  factory StreamStudentsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamStudentsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamStudentsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamStudentsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamStudentsRequest copyWith(
          void Function(StreamStudentsRequest) updates) =>
      super.copyWith((message) => updates(message as StreamStudentsRequest))
          as StreamStudentsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamStudentsRequest create() => StreamStudentsRequest._();
  @$core.override
  StreamStudentsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamStudentsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamStudentsRequest>(create);
  static StreamStudentsRequest? _defaultInstance;
}

class StreamStudentsResponse extends $pb.GeneratedMessage {
  factory StreamStudentsResponse({
    $core.Iterable<TeamMemberResponse>? students,
  }) {
    final result = create();
    if (students != null) result.students.addAll(students);
    return result;
  }

  StreamStudentsResponse._();

  factory StreamStudentsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamStudentsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamStudentsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..pPM<TeamMemberResponse>(1, _omitFieldNames ? '' : 'students',
        subBuilder: TeamMemberResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamStudentsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamStudentsResponse copyWith(
          void Function(StreamStudentsResponse) updates) =>
      super.copyWith((message) => updates(message as StreamStudentsResponse))
          as StreamStudentsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamStudentsResponse create() => StreamStudentsResponse._();
  @$core.override
  StreamStudentsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamStudentsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamStudentsResponse>(create);
  static StreamStudentsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TeamMemberResponse> get students => $_getList(0);
}

class StreamMentorsRequest extends $pb.GeneratedMessage {
  factory StreamMentorsRequest() => create();

  StreamMentorsRequest._();

  factory StreamMentorsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamMentorsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamMentorsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamMentorsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamMentorsRequest copyWith(void Function(StreamMentorsRequest) updates) =>
      super.copyWith((message) => updates(message as StreamMentorsRequest))
          as StreamMentorsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamMentorsRequest create() => StreamMentorsRequest._();
  @$core.override
  StreamMentorsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamMentorsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamMentorsRequest>(create);
  static StreamMentorsRequest? _defaultInstance;
}

class StreamMentorsResponse extends $pb.GeneratedMessage {
  factory StreamMentorsResponse({
    $core.Iterable<TeamMemberResponse>? mentors,
  }) {
    final result = create();
    if (mentors != null) result.mentors.addAll(mentors);
    return result;
  }

  StreamMentorsResponse._();

  factory StreamMentorsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamMentorsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamMentorsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..pPM<TeamMemberResponse>(1, _omitFieldNames ? '' : 'mentors',
        subBuilder: TeamMemberResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamMentorsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamMentorsResponse copyWith(
          void Function(StreamMentorsResponse) updates) =>
      super.copyWith((message) => updates(message as StreamMentorsResponse))
          as StreamMentorsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamMentorsResponse create() => StreamMentorsResponse._();
  @$core.override
  StreamMentorsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamMentorsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamMentorsResponse>(create);
  static StreamMentorsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TeamMemberResponse> get mentors => $_getList(0);
}

class CreateTeamMemberRequest extends $pb.GeneratedMessage {
  factory CreateTeamMemberRequest({
    $core.String? firstName,
    $core.String? lastName,
    $1.TeamMemberType? memberType,
    $core.String? alias,
    $core.String? secondaryAlias,
  }) {
    final result = create();
    if (firstName != null) result.firstName = firstName;
    if (lastName != null) result.lastName = lastName;
    if (memberType != null) result.memberType = memberType;
    if (alias != null) result.alias = alias;
    if (secondaryAlias != null) result.secondaryAlias = secondaryAlias;
    return result;
  }

  CreateTeamMemberRequest._();

  factory CreateTeamMemberRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateTeamMemberRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateTeamMemberRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'firstName')
    ..aOS(2, _omitFieldNames ? '' : 'lastName')
    ..aE<$1.TeamMemberType>(3, _omitFieldNames ? '' : 'memberType',
        enumValues: $1.TeamMemberType.values)
    ..aOS(4, _omitFieldNames ? '' : 'alias')
    ..aOS(5, _omitFieldNames ? '' : 'secondaryAlias')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTeamMemberRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTeamMemberRequest copyWith(
          void Function(CreateTeamMemberRequest) updates) =>
      super.copyWith((message) => updates(message as CreateTeamMemberRequest))
          as CreateTeamMemberRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateTeamMemberRequest create() => CreateTeamMemberRequest._();
  @$core.override
  CreateTeamMemberRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateTeamMemberRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateTeamMemberRequest>(create);
  static CreateTeamMemberRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get firstName => $_getSZ(0);
  @$pb.TagNumber(1)
  set firstName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFirstName() => $_has(0);
  @$pb.TagNumber(1)
  void clearFirstName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get lastName => $_getSZ(1);
  @$pb.TagNumber(2)
  set lastName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLastName() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastName() => $_clearField(2);

  @$pb.TagNumber(3)
  $1.TeamMemberType get memberType => $_getN(2);
  @$pb.TagNumber(3)
  set memberType($1.TeamMemberType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasMemberType() => $_has(2);
  @$pb.TagNumber(3)
  void clearMemberType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get alias => $_getSZ(3);
  @$pb.TagNumber(4)
  set alias($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAlias() => $_has(3);
  @$pb.TagNumber(4)
  void clearAlias() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get secondaryAlias => $_getSZ(4);
  @$pb.TagNumber(5)
  set secondaryAlias($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSecondaryAlias() => $_has(4);
  @$pb.TagNumber(5)
  void clearSecondaryAlias() => $_clearField(5);
}

class CreateTeamMemberResponse extends $pb.GeneratedMessage {
  factory CreateTeamMemberResponse() => create();

  CreateTeamMemberResponse._();

  factory CreateTeamMemberResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateTeamMemberResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateTeamMemberResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTeamMemberResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTeamMemberResponse copyWith(
          void Function(CreateTeamMemberResponse) updates) =>
      super.copyWith((message) => updates(message as CreateTeamMemberResponse))
          as CreateTeamMemberResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateTeamMemberResponse create() => CreateTeamMemberResponse._();
  @$core.override
  CreateTeamMemberResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateTeamMemberResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateTeamMemberResponse>(create);
  static CreateTeamMemberResponse? _defaultInstance;
}

class UpdateTeamMemberRequest extends $pb.GeneratedMessage {
  factory UpdateTeamMemberRequest({
    $core.String? id,
    $core.String? firstName,
    $core.String? lastName,
    $1.TeamMemberType? memberType,
    $core.String? alias,
    $core.String? secondaryAlias,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (firstName != null) result.firstName = firstName;
    if (lastName != null) result.lastName = lastName;
    if (memberType != null) result.memberType = memberType;
    if (alias != null) result.alias = alias;
    if (secondaryAlias != null) result.secondaryAlias = secondaryAlias;
    return result;
  }

  UpdateTeamMemberRequest._();

  factory UpdateTeamMemberRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateTeamMemberRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateTeamMemberRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'firstName')
    ..aOS(3, _omitFieldNames ? '' : 'lastName')
    ..aE<$1.TeamMemberType>(4, _omitFieldNames ? '' : 'memberType',
        enumValues: $1.TeamMemberType.values)
    ..aOS(5, _omitFieldNames ? '' : 'alias')
    ..aOS(6, _omitFieldNames ? '' : 'secondaryAlias')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateTeamMemberRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateTeamMemberRequest copyWith(
          void Function(UpdateTeamMemberRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateTeamMemberRequest))
          as UpdateTeamMemberRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateTeamMemberRequest create() => UpdateTeamMemberRequest._();
  @$core.override
  UpdateTeamMemberRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateTeamMemberRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateTeamMemberRequest>(create);
  static UpdateTeamMemberRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get firstName => $_getSZ(1);
  @$pb.TagNumber(2)
  set firstName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFirstName() => $_has(1);
  @$pb.TagNumber(2)
  void clearFirstName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get lastName => $_getSZ(2);
  @$pb.TagNumber(3)
  set lastName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLastName() => $_has(2);
  @$pb.TagNumber(3)
  void clearLastName() => $_clearField(3);

  @$pb.TagNumber(4)
  $1.TeamMemberType get memberType => $_getN(3);
  @$pb.TagNumber(4)
  set memberType($1.TeamMemberType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasMemberType() => $_has(3);
  @$pb.TagNumber(4)
  void clearMemberType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get alias => $_getSZ(4);
  @$pb.TagNumber(5)
  set alias($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAlias() => $_has(4);
  @$pb.TagNumber(5)
  void clearAlias() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get secondaryAlias => $_getSZ(5);
  @$pb.TagNumber(6)
  set secondaryAlias($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSecondaryAlias() => $_has(5);
  @$pb.TagNumber(6)
  void clearSecondaryAlias() => $_clearField(6);
}

class UpdateTeamMemberResponse extends $pb.GeneratedMessage {
  factory UpdateTeamMemberResponse() => create();

  UpdateTeamMemberResponse._();

  factory UpdateTeamMemberResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateTeamMemberResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateTeamMemberResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateTeamMemberResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateTeamMemberResponse copyWith(
          void Function(UpdateTeamMemberResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateTeamMemberResponse))
          as UpdateTeamMemberResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateTeamMemberResponse create() => UpdateTeamMemberResponse._();
  @$core.override
  UpdateTeamMemberResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateTeamMemberResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateTeamMemberResponse>(create);
  static UpdateTeamMemberResponse? _defaultInstance;
}

class DeleteTeamMemberRequest extends $pb.GeneratedMessage {
  factory DeleteTeamMemberRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  DeleteTeamMemberRequest._();

  factory DeleteTeamMemberRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteTeamMemberRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteTeamMemberRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTeamMemberRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTeamMemberRequest copyWith(
          void Function(DeleteTeamMemberRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteTeamMemberRequest))
          as DeleteTeamMemberRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteTeamMemberRequest create() => DeleteTeamMemberRequest._();
  @$core.override
  DeleteTeamMemberRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteTeamMemberRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteTeamMemberRequest>(create);
  static DeleteTeamMemberRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class DeleteTeamMemberResponse extends $pb.GeneratedMessage {
  factory DeleteTeamMemberResponse() => create();

  DeleteTeamMemberResponse._();

  factory DeleteTeamMemberResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteTeamMemberResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteTeamMemberResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTeamMemberResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTeamMemberResponse copyWith(
          void Function(DeleteTeamMemberResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteTeamMemberResponse))
          as DeleteTeamMemberResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteTeamMemberResponse create() => DeleteTeamMemberResponse._();
  @$core.override
  DeleteTeamMemberResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteTeamMemberResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteTeamMemberResponse>(create);
  static DeleteTeamMemberResponse? _defaultInstance;
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
