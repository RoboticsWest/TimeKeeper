// This is a generated file - do not edit.
//
// Generated from api/stats.proto.

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

class HoursBucket extends $pb.GeneratedMessage {
  factory HoursBucket({
    $core.double? regularSecs,
    $core.double? overtimeSecs,
  }) {
    final result = create();
    if (regularSecs != null) result.regularSecs = regularSecs;
    if (overtimeSecs != null) result.overtimeSecs = overtimeSecs;
    return result;
  }

  HoursBucket._();

  factory HoursBucket.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HoursBucket.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HoursBucket',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'regularSecs')
    ..aD(2, _omitFieldNames ? '' : 'overtimeSecs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HoursBucket clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HoursBucket copyWith(void Function(HoursBucket) updates) =>
      super.copyWith((message) => updates(message as HoursBucket))
          as HoursBucket;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HoursBucket create() => HoursBucket._();
  @$core.override
  HoursBucket createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HoursBucket getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HoursBucket>(create);
  static HoursBucket? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get regularSecs => $_getN(0);
  @$pb.TagNumber(1)
  set regularSecs($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRegularSecs() => $_has(0);
  @$pb.TagNumber(1)
  void clearRegularSecs() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get overtimeSecs => $_getN(1);
  @$pb.TagNumber(2)
  set overtimeSecs($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOvertimeSecs() => $_has(1);
  @$pb.TagNumber(2)
  void clearOvertimeSecs() => $_clearField(2);
}

class LeaderboardEntry extends $pb.GeneratedMessage {
  factory LeaderboardEntry({
    $core.String? teamMemberId,
    $1.TeamMember? teamMember,
    HoursBucket? activeSession,
    HoursBucket? thisWeek,
    HoursBucket? allTime,
    $core.double? totalSecs,
  }) {
    final result = create();
    if (teamMemberId != null) result.teamMemberId = teamMemberId;
    if (teamMember != null) result.teamMember = teamMember;
    if (activeSession != null) result.activeSession = activeSession;
    if (thisWeek != null) result.thisWeek = thisWeek;
    if (allTime != null) result.allTime = allTime;
    if (totalSecs != null) result.totalSecs = totalSecs;
    return result;
  }

  LeaderboardEntry._();

  factory LeaderboardEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LeaderboardEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LeaderboardEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'teamMemberId')
    ..aOM<$1.TeamMember>(2, _omitFieldNames ? '' : 'teamMember',
        subBuilder: $1.TeamMember.create)
    ..aOM<HoursBucket>(3, _omitFieldNames ? '' : 'activeSession',
        subBuilder: HoursBucket.create)
    ..aOM<HoursBucket>(4, _omitFieldNames ? '' : 'thisWeek',
        subBuilder: HoursBucket.create)
    ..aOM<HoursBucket>(5, _omitFieldNames ? '' : 'allTime',
        subBuilder: HoursBucket.create)
    ..aD(6, _omitFieldNames ? '' : 'totalSecs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeaderboardEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeaderboardEntry copyWith(void Function(LeaderboardEntry) updates) =>
      super.copyWith((message) => updates(message as LeaderboardEntry))
          as LeaderboardEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LeaderboardEntry create() => LeaderboardEntry._();
  @$core.override
  LeaderboardEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LeaderboardEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LeaderboardEntry>(create);
  static LeaderboardEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get teamMemberId => $_getSZ(0);
  @$pb.TagNumber(1)
  set teamMemberId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTeamMemberId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTeamMemberId() => $_clearField(1);

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

  @$pb.TagNumber(3)
  HoursBucket get activeSession => $_getN(2);
  @$pb.TagNumber(3)
  set activeSession(HoursBucket value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasActiveSession() => $_has(2);
  @$pb.TagNumber(3)
  void clearActiveSession() => $_clearField(3);
  @$pb.TagNumber(3)
  HoursBucket ensureActiveSession() => $_ensure(2);

  @$pb.TagNumber(4)
  HoursBucket get thisWeek => $_getN(3);
  @$pb.TagNumber(4)
  set thisWeek(HoursBucket value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasThisWeek() => $_has(3);
  @$pb.TagNumber(4)
  void clearThisWeek() => $_clearField(4);
  @$pb.TagNumber(4)
  HoursBucket ensureThisWeek() => $_ensure(3);

  @$pb.TagNumber(5)
  HoursBucket get allTime => $_getN(4);
  @$pb.TagNumber(5)
  set allTime(HoursBucket value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasAllTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearAllTime() => $_clearField(5);
  @$pb.TagNumber(5)
  HoursBucket ensureAllTime() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.double get totalSecs => $_getN(5);
  @$pb.TagNumber(6)
  set totalSecs($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTotalSecs() => $_has(5);
  @$pb.TagNumber(6)
  void clearTotalSecs() => $_clearField(6);
}

class GetLeaderboardRequest extends $pb.GeneratedMessage {
  factory GetLeaderboardRequest() => create();

  GetLeaderboardRequest._();

  factory GetLeaderboardRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetLeaderboardRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLeaderboardRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLeaderboardRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLeaderboardRequest copyWith(
          void Function(GetLeaderboardRequest) updates) =>
      super.copyWith((message) => updates(message as GetLeaderboardRequest))
          as GetLeaderboardRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetLeaderboardRequest create() => GetLeaderboardRequest._();
  @$core.override
  GetLeaderboardRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetLeaderboardRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetLeaderboardRequest>(create);
  static GetLeaderboardRequest? _defaultInstance;
}

class GetLeaderboardResponse extends $pb.GeneratedMessage {
  factory GetLeaderboardResponse({
    $core.Iterable<LeaderboardEntry>? entries,
  }) {
    final result = create();
    if (entries != null) result.entries.addAll(entries);
    return result;
  }

  GetLeaderboardResponse._();

  factory GetLeaderboardResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetLeaderboardResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLeaderboardResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..pPM<LeaderboardEntry>(1, _omitFieldNames ? '' : 'entries',
        subBuilder: LeaderboardEntry.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLeaderboardResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLeaderboardResponse copyWith(
          void Function(GetLeaderboardResponse) updates) =>
      super.copyWith((message) => updates(message as GetLeaderboardResponse))
          as GetLeaderboardResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetLeaderboardResponse create() => GetLeaderboardResponse._();
  @$core.override
  GetLeaderboardResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetLeaderboardResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetLeaderboardResponse>(create);
  static GetLeaderboardResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<LeaderboardEntry> get entries => $_getList(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
