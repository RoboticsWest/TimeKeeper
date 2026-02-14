// This is a generated file - do not edit.
//
// Generated from api/sync.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../common/common.pbenum.dart' as $7;
import 'location.pb.dart' as $2;
import 'notification.pb.dart' as $6;
import 'rfid_tag.pb.dart' as $5;
import 'session.pb.dart' as $1;
import 'team_member.pb.dart' as $3;
import 'team_member_session.pb.dart' as $4;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class StreamEntitiesRequest extends $pb.GeneratedMessage {
  factory StreamEntitiesRequest() => create();

  StreamEntitiesRequest._();

  factory StreamEntitiesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamEntitiesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamEntitiesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamEntitiesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamEntitiesRequest copyWith(
          void Function(StreamEntitiesRequest) updates) =>
      super.copyWith((message) => updates(message as StreamEntitiesRequest))
          as StreamEntitiesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamEntitiesRequest create() => StreamEntitiesRequest._();
  @$core.override
  StreamEntitiesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamEntitiesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamEntitiesRequest>(create);
  static StreamEntitiesRequest? _defaultInstance;
}

enum StreamEntitiesResponse_Payload {
  sessions,
  locations,
  teamMembers,
  teamMemberSessions,
  rfidTags,
  notifications,
  notSet
}

class StreamEntitiesResponse extends $pb.GeneratedMessage {
  factory StreamEntitiesResponse({
    $7.SyncType? syncType,
    $1.StreamSessionsResponse? sessions,
    $2.StreamLocationsResponse? locations,
    $3.StreamTeamMembersResponse? teamMembers,
    $4.StreamTeamMemberSessionsResponse? teamMemberSessions,
    $5.StreamRfidTagsResponse? rfidTags,
    $6.StreamNotificationsResponse? notifications,
  }) {
    final result = create();
    if (syncType != null) result.syncType = syncType;
    if (sessions != null) result.sessions = sessions;
    if (locations != null) result.locations = locations;
    if (teamMembers != null) result.teamMembers = teamMembers;
    if (teamMemberSessions != null)
      result.teamMemberSessions = teamMemberSessions;
    if (rfidTags != null) result.rfidTags = rfidTags;
    if (notifications != null) result.notifications = notifications;
    return result;
  }

  StreamEntitiesResponse._();

  factory StreamEntitiesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamEntitiesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, StreamEntitiesResponse_Payload>
      _StreamEntitiesResponse_PayloadByTag = {
    2: StreamEntitiesResponse_Payload.sessions,
    3: StreamEntitiesResponse_Payload.locations,
    4: StreamEntitiesResponse_Payload.teamMembers,
    5: StreamEntitiesResponse_Payload.teamMemberSessions,
    6: StreamEntitiesResponse_Payload.rfidTags,
    7: StreamEntitiesResponse_Payload.notifications,
    0: StreamEntitiesResponse_Payload.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamEntitiesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..oo(0, [2, 3, 4, 5, 6, 7])
    ..aE<$7.SyncType>(1, _omitFieldNames ? '' : 'syncType',
        enumValues: $7.SyncType.values)
    ..aOM<$1.StreamSessionsResponse>(2, _omitFieldNames ? '' : 'sessions',
        subBuilder: $1.StreamSessionsResponse.create)
    ..aOM<$2.StreamLocationsResponse>(3, _omitFieldNames ? '' : 'locations',
        subBuilder: $2.StreamLocationsResponse.create)
    ..aOM<$3.StreamTeamMembersResponse>(4, _omitFieldNames ? '' : 'teamMembers',
        subBuilder: $3.StreamTeamMembersResponse.create)
    ..aOM<$4.StreamTeamMemberSessionsResponse>(
        5, _omitFieldNames ? '' : 'teamMemberSessions',
        subBuilder: $4.StreamTeamMemberSessionsResponse.create)
    ..aOM<$5.StreamRfidTagsResponse>(6, _omitFieldNames ? '' : 'rfidTags',
        subBuilder: $5.StreamRfidTagsResponse.create)
    ..aOM<$6.StreamNotificationsResponse>(
        7, _omitFieldNames ? '' : 'notifications',
        subBuilder: $6.StreamNotificationsResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamEntitiesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamEntitiesResponse copyWith(
          void Function(StreamEntitiesResponse) updates) =>
      super.copyWith((message) => updates(message as StreamEntitiesResponse))
          as StreamEntitiesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamEntitiesResponse create() => StreamEntitiesResponse._();
  @$core.override
  StreamEntitiesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamEntitiesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamEntitiesResponse>(create);
  static StreamEntitiesResponse? _defaultInstance;

  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  StreamEntitiesResponse_Payload whichPayload() =>
      _StreamEntitiesResponse_PayloadByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  void clearPayload() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $7.SyncType get syncType => $_getN(0);
  @$pb.TagNumber(1)
  set syncType($7.SyncType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSyncType() => $_has(0);
  @$pb.TagNumber(1)
  void clearSyncType() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.StreamSessionsResponse get sessions => $_getN(1);
  @$pb.TagNumber(2)
  set sessions($1.StreamSessionsResponse value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSessions() => $_has(1);
  @$pb.TagNumber(2)
  void clearSessions() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.StreamSessionsResponse ensureSessions() => $_ensure(1);

  @$pb.TagNumber(3)
  $2.StreamLocationsResponse get locations => $_getN(2);
  @$pb.TagNumber(3)
  set locations($2.StreamLocationsResponse value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasLocations() => $_has(2);
  @$pb.TagNumber(3)
  void clearLocations() => $_clearField(3);
  @$pb.TagNumber(3)
  $2.StreamLocationsResponse ensureLocations() => $_ensure(2);

  @$pb.TagNumber(4)
  $3.StreamTeamMembersResponse get teamMembers => $_getN(3);
  @$pb.TagNumber(4)
  set teamMembers($3.StreamTeamMembersResponse value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasTeamMembers() => $_has(3);
  @$pb.TagNumber(4)
  void clearTeamMembers() => $_clearField(4);
  @$pb.TagNumber(4)
  $3.StreamTeamMembersResponse ensureTeamMembers() => $_ensure(3);

  @$pb.TagNumber(5)
  $4.StreamTeamMemberSessionsResponse get teamMemberSessions => $_getN(4);
  @$pb.TagNumber(5)
  set teamMemberSessions($4.StreamTeamMemberSessionsResponse value) =>
      $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasTeamMemberSessions() => $_has(4);
  @$pb.TagNumber(5)
  void clearTeamMemberSessions() => $_clearField(5);
  @$pb.TagNumber(5)
  $4.StreamTeamMemberSessionsResponse ensureTeamMemberSessions() => $_ensure(4);

  @$pb.TagNumber(6)
  $5.StreamRfidTagsResponse get rfidTags => $_getN(5);
  @$pb.TagNumber(6)
  set rfidTags($5.StreamRfidTagsResponse value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasRfidTags() => $_has(5);
  @$pb.TagNumber(6)
  void clearRfidTags() => $_clearField(6);
  @$pb.TagNumber(6)
  $5.StreamRfidTagsResponse ensureRfidTags() => $_ensure(5);

  @$pb.TagNumber(7)
  $6.StreamNotificationsResponse get notifications => $_getN(6);
  @$pb.TagNumber(7)
  set notifications($6.StreamNotificationsResponse value) =>
      $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasNotifications() => $_has(6);
  @$pb.TagNumber(7)
  void clearNotifications() => $_clearField(7);
  @$pb.TagNumber(7)
  $6.StreamNotificationsResponse ensureNotifications() => $_ensure(6);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
