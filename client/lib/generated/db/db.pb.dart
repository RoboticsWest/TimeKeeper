// This is a generated file - do not edit.
//
// Generated from db/db.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import '../common/common.pb.dart' as $0;
import 'db.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'db.pbenum.dart';

class Secret extends $pb.GeneratedMessage {
  factory Secret({
    $core.List<$core.int>? secretBytes,
  }) {
    final result = create();
    if (secretBytes != null) result.secretBytes = secretBytes;
    return result;
  }

  Secret._();

  factory Secret.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Secret.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Secret',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.db'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'secretBytes', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Secret clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Secret copyWith(void Function(Secret) updates) =>
      super.copyWith((message) => updates(message as Secret)) as Secret;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Secret create() => Secret._();
  @$core.override
  Secret createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Secret getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Secret>(create);
  static Secret? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get secretBytes => $_getN(0);
  @$pb.TagNumber(1)
  set secretBytes($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSecretBytes() => $_has(0);
  @$pb.TagNumber(1)
  void clearSecretBytes() => $_clearField(1);
}

class User extends $pb.GeneratedMessage {
  factory User({
    $core.String? username,
    $core.String? password,
    $core.Iterable<$0.Role>? roles,
  }) {
    final result = create();
    if (username != null) result.username = username;
    if (password != null) result.password = password;
    if (roles != null) result.roles.addAll(roles);
    return result;
  }

  User._();

  factory User.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory User.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'User',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.db'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'username')
    ..aOS(2, _omitFieldNames ? '' : 'password')
    ..pc<$0.Role>(3, _omitFieldNames ? '' : 'roles', $pb.PbFieldType.KE,
        valueOf: $0.Role.valueOf,
        enumValues: $0.Role.values,
        defaultEnumValue: $0.Role.ADMIN)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  User clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  User copyWith(void Function(User) updates) =>
      super.copyWith((message) => updates(message as User)) as User;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static User create() => User._();
  @$core.override
  User createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static User getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<User>(create);
  static User? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get username => $_getSZ(0);
  @$pb.TagNumber(1)
  set username($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUsername() => $_has(0);
  @$pb.TagNumber(1)
  void clearUsername() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get password => $_getSZ(1);
  @$pb.TagNumber(2)
  set password($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$0.Role> get roles => $_getList(2);
}

class TeamMember extends $pb.GeneratedMessage {
  factory TeamMember({
    $core.String? firstName,
    $core.String? lastName,
    TeamMemberType? memberType,
    $core.String? displayName,
    $core.String? rfidTag,
    $core.String? mobileNumber,
    $core.String? discordUsername,
  }) {
    final result = create();
    if (firstName != null) result.firstName = firstName;
    if (lastName != null) result.lastName = lastName;
    if (memberType != null) result.memberType = memberType;
    if (displayName != null) result.displayName = displayName;
    if (rfidTag != null) result.rfidTag = rfidTag;
    if (mobileNumber != null) result.mobileNumber = mobileNumber;
    if (discordUsername != null) result.discordUsername = discordUsername;
    return result;
  }

  TeamMember._();

  factory TeamMember.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TeamMember.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TeamMember',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.db'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'firstName')
    ..aOS(2, _omitFieldNames ? '' : 'lastName')
    ..aE<TeamMemberType>(3, _omitFieldNames ? '' : 'memberType',
        enumValues: TeamMemberType.values)
    ..aOS(4, _omitFieldNames ? '' : 'displayName')
    ..aOS(5, _omitFieldNames ? '' : 'rfidTag')
    ..aOS(6, _omitFieldNames ? '' : 'mobileNumber')
    ..aOS(7, _omitFieldNames ? '' : 'discordUsername')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamMember clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamMember copyWith(void Function(TeamMember) updates) =>
      super.copyWith((message) => updates(message as TeamMember)) as TeamMember;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TeamMember create() => TeamMember._();
  @$core.override
  TeamMember createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TeamMember getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TeamMember>(create);
  static TeamMember? _defaultInstance;

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
  TeamMemberType get memberType => $_getN(2);
  @$pb.TagNumber(3)
  set memberType(TeamMemberType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasMemberType() => $_has(2);
  @$pb.TagNumber(3)
  void clearMemberType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get displayName => $_getSZ(3);
  @$pb.TagNumber(4)
  set displayName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDisplayName() => $_has(3);
  @$pb.TagNumber(4)
  void clearDisplayName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get rfidTag => $_getSZ(4);
  @$pb.TagNumber(5)
  set rfidTag($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRfidTag() => $_has(4);
  @$pb.TagNumber(5)
  void clearRfidTag() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get mobileNumber => $_getSZ(5);
  @$pb.TagNumber(6)
  set mobileNumber($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMobileNumber() => $_has(5);
  @$pb.TagNumber(6)
  void clearMobileNumber() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get discordUsername => $_getSZ(6);
  @$pb.TagNumber(7)
  set discordUsername($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDiscordUsername() => $_has(6);
  @$pb.TagNumber(7)
  void clearDiscordUsername() => $_clearField(7);
}

class Location extends $pb.GeneratedMessage {
  factory Location({
    $core.String? location,
  }) {
    final result = create();
    if (location != null) result.location = location;
    return result;
  }

  Location._();

  factory Location.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Location.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Location',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.db'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'location')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Location clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Location copyWith(void Function(Location) updates) =>
      super.copyWith((message) => updates(message as Location)) as Location;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Location create() => Location._();
  @$core.override
  Location createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Location getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Location>(create);
  static Location? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get location => $_getSZ(0);
  @$pb.TagNumber(1)
  set location($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLocation() => $_has(0);
  @$pb.TagNumber(1)
  void clearLocation() => $_clearField(1);
}

class TeamMemberSession extends $pb.GeneratedMessage {
  factory TeamMemberSession({
    $core.String? teamMemberId,
    $core.String? sessionId,
    $0.Timestamp? checkInTime,
    $0.Timestamp? checkOutTime,
  }) {
    final result = create();
    if (teamMemberId != null) result.teamMemberId = teamMemberId;
    if (sessionId != null) result.sessionId = sessionId;
    if (checkInTime != null) result.checkInTime = checkInTime;
    if (checkOutTime != null) result.checkOutTime = checkOutTime;
    return result;
  }

  TeamMemberSession._();

  factory TeamMemberSession.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TeamMemberSession.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TeamMemberSession',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.db'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'teamMemberId')
    ..aOS(2, _omitFieldNames ? '' : 'sessionId')
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'checkInTime',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'checkOutTime',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamMemberSession clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TeamMemberSession copyWith(void Function(TeamMemberSession) updates) =>
      super.copyWith((message) => updates(message as TeamMemberSession))
          as TeamMemberSession;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TeamMemberSession create() => TeamMemberSession._();
  @$core.override
  TeamMemberSession createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TeamMemberSession getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TeamMemberSession>(create);
  static TeamMemberSession? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get teamMemberId => $_getSZ(0);
  @$pb.TagNumber(1)
  set teamMemberId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTeamMemberId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTeamMemberId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sessionId => $_getSZ(1);
  @$pb.TagNumber(2)
  set sessionId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSessionId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSessionId() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Timestamp get checkInTime => $_getN(2);
  @$pb.TagNumber(3)
  set checkInTime($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCheckInTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearCheckInTime() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureCheckInTime() => $_ensure(2);

  @$pb.TagNumber(4)
  $0.Timestamp get checkOutTime => $_getN(3);
  @$pb.TagNumber(4)
  set checkOutTime($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCheckOutTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearCheckOutTime() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureCheckOutTime() => $_ensure(3);
}

class Session extends $pb.GeneratedMessage {
  factory Session({
    $0.Timestamp? startTime,
    $0.Timestamp? endTime,
    $core.String? locationId,
    $core.bool? finished,
    $core.bool? startReminderSent,
    $core.bool? endReminderSent,
  }) {
    final result = create();
    if (startTime != null) result.startTime = startTime;
    if (endTime != null) result.endTime = endTime;
    if (locationId != null) result.locationId = locationId;
    if (finished != null) result.finished = finished;
    if (startReminderSent != null) result.startReminderSent = startReminderSent;
    if (endReminderSent != null) result.endReminderSent = endReminderSent;
    return result;
  }

  Session._();

  factory Session.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Session.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Session',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.db'),
      createEmptyInstance: create)
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'startTime',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'endTime',
        subBuilder: $0.Timestamp.create)
    ..aOS(3, _omitFieldNames ? '' : 'locationId')
    ..aOB(4, _omitFieldNames ? '' : 'finished')
    ..aOB(5, _omitFieldNames ? '' : 'startReminderSent')
    ..aOB(6, _omitFieldNames ? '' : 'endReminderSent')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Session clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Session copyWith(void Function(Session) updates) =>
      super.copyWith((message) => updates(message as Session)) as Session;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Session create() => Session._();
  @$core.override
  Session createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Session getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Session>(create);
  static Session? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Timestamp get startTime => $_getN(0);
  @$pb.TagNumber(1)
  set startTime($0.Timestamp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStartTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearStartTime() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Timestamp ensureStartTime() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.Timestamp get endTime => $_getN(1);
  @$pb.TagNumber(2)
  set endTime($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasEndTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearEndTime() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureEndTime() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get locationId => $_getSZ(2);
  @$pb.TagNumber(3)
  set locationId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLocationId() => $_has(2);
  @$pb.TagNumber(3)
  void clearLocationId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get finished => $_getBF(3);
  @$pb.TagNumber(4)
  set finished($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFinished() => $_has(3);
  @$pb.TagNumber(4)
  void clearFinished() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get startReminderSent => $_getBF(4);
  @$pb.TagNumber(5)
  set startReminderSent($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStartReminderSent() => $_has(4);
  @$pb.TagNumber(5)
  void clearStartReminderSent() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get endReminderSent => $_getBF(5);
  @$pb.TagNumber(6)
  set endReminderSent($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasEndReminderSent() => $_has(5);
  @$pb.TagNumber(6)
  void clearEndReminderSent() => $_clearField(6);
}

class Settings extends $pb.GeneratedMessage {
  factory Settings({
    $fixnum.Int64? nextSessionThresholdSecs,
    $core.String? discordBotToken,
    $core.String? discordGuildId,
    $core.String? discordChannelId,
    @$core.Deprecated('This field is deprecated.')
    $fixnum.Int64? discordReminderMins,
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
    if (discordReminderMins != null)
      result.discordReminderMins = discordReminderMins;
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

  Settings._();

  factory Settings.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Settings.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Settings',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.db'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'nextSessionThresholdSecs')
    ..aOS(2, _omitFieldNames ? '' : 'discordBotToken')
    ..aOS(3, _omitFieldNames ? '' : 'discordGuildId')
    ..aOS(4, _omitFieldNames ? '' : 'discordChannelId')
    ..aInt64(5, _omitFieldNames ? '' : 'discordReminderMins')
    ..aOB(6, _omitFieldNames ? '' : 'discordSelfLinkEnabled')
    ..aOB(7, _omitFieldNames ? '' : 'discordNameSyncEnabled')
    ..aInt64(8, _omitFieldNames ? '' : 'discordStartReminderMins')
    ..aInt64(9, _omitFieldNames ? '' : 'discordEndReminderMins')
    ..aOS(10, _omitFieldNames ? '' : 'discordStartReminderMessage')
    ..aOS(11, _omitFieldNames ? '' : 'discordEndReminderMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Settings clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Settings copyWith(void Function(Settings) updates) =>
      super.copyWith((message) => updates(message as Settings)) as Settings;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Settings create() => Settings._();
  @$core.override
  Settings createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Settings getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Settings>(create);
  static Settings? _defaultInstance;

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

  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(5)
  $fixnum.Int64 get discordReminderMins => $_getI64(4);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(5)
  set discordReminderMins($fixnum.Int64 value) => $_setInt64(4, value);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(5)
  $core.bool hasDiscordReminderMins() => $_has(4);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(5)
  void clearDiscordReminderMins() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get discordSelfLinkEnabled => $_getBF(5);
  @$pb.TagNumber(6)
  set discordSelfLinkEnabled($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDiscordSelfLinkEnabled() => $_has(5);
  @$pb.TagNumber(6)
  void clearDiscordSelfLinkEnabled() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get discordNameSyncEnabled => $_getBF(6);
  @$pb.TagNumber(7)
  set discordNameSyncEnabled($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDiscordNameSyncEnabled() => $_has(6);
  @$pb.TagNumber(7)
  void clearDiscordNameSyncEnabled() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get discordStartReminderMins => $_getI64(7);
  @$pb.TagNumber(8)
  set discordStartReminderMins($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDiscordStartReminderMins() => $_has(7);
  @$pb.TagNumber(8)
  void clearDiscordStartReminderMins() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get discordEndReminderMins => $_getI64(8);
  @$pb.TagNumber(9)
  set discordEndReminderMins($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDiscordEndReminderMins() => $_has(8);
  @$pb.TagNumber(9)
  void clearDiscordEndReminderMins() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get discordStartReminderMessage => $_getSZ(9);
  @$pb.TagNumber(10)
  set discordStartReminderMessage($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasDiscordStartReminderMessage() => $_has(9);
  @$pb.TagNumber(10)
  void clearDiscordStartReminderMessage() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get discordEndReminderMessage => $_getSZ(10);
  @$pb.TagNumber(11)
  set discordEndReminderMessage($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasDiscordEndReminderMessage() => $_has(10);
  @$pb.TagNumber(11)
  void clearDiscordEndReminderMessage() => $_clearField(11);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
