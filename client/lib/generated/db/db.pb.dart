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
    $core.String? mobileNumber,
    $core.String? discordUsername,
  }) {
    final result = create();
    if (firstName != null) result.firstName = firstName;
    if (lastName != null) result.lastName = lastName;
    if (memberType != null) result.memberType = memberType;
    if (displayName != null) result.displayName = displayName;
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
    ..aOS(5, _omitFieldNames ? '' : 'mobileNumber')
    ..aOS(6, _omitFieldNames ? '' : 'discordUsername')
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
  $core.String get mobileNumber => $_getSZ(4);
  @$pb.TagNumber(5)
  set mobileNumber($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMobileNumber() => $_has(4);
  @$pb.TagNumber(5)
  void clearMobileNumber() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get discordUsername => $_getSZ(5);
  @$pb.TagNumber(6)
  set discordUsername($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDiscordUsername() => $_has(5);
  @$pb.TagNumber(6)
  void clearDiscordUsername() => $_clearField(6);
}

class RfidTag extends $pb.GeneratedMessage {
  factory RfidTag({
    $core.String? teamMemberId,
    $core.String? tag,
  }) {
    final result = create();
    if (teamMemberId != null) result.teamMemberId = teamMemberId;
    if (tag != null) result.tag = tag;
    return result;
  }

  RfidTag._();

  factory RfidTag.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RfidTag.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RfidTag',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.db'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'teamMemberId')
    ..aOS(2, _omitFieldNames ? '' : 'tag')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RfidTag clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RfidTag copyWith(void Function(RfidTag) updates) =>
      super.copyWith((message) => updates(message as RfidTag)) as RfidTag;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RfidTag create() => RfidTag._();
  @$core.override
  RfidTag createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RfidTag getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RfidTag>(create);
  static RfidTag? _defaultInstance;

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
  }) {
    final result = create();
    if (startTime != null) result.startTime = startTime;
    if (endTime != null) result.endTime = endTime;
    if (locationId != null) result.locationId = locationId;
    if (finished != null) result.finished = finished;
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
}

class Notification extends $pb.GeneratedMessage {
  factory Notification({
    NotificationType? notificationType,
    $core.String? sessionId,
    $core.String? teamMemberId,
    $core.bool? sent,
  }) {
    final result = create();
    if (notificationType != null) result.notificationType = notificationType;
    if (sessionId != null) result.sessionId = sessionId;
    if (teamMemberId != null) result.teamMemberId = teamMemberId;
    if (sent != null) result.sent = sent;
    return result;
  }

  Notification._();

  factory Notification.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Notification.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Notification',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.db'),
      createEmptyInstance: create)
    ..aE<NotificationType>(1, _omitFieldNames ? '' : 'notificationType',
        enumValues: NotificationType.values)
    ..aOS(2, _omitFieldNames ? '' : 'sessionId')
    ..aOS(3, _omitFieldNames ? '' : 'teamMemberId')
    ..aOB(4, _omitFieldNames ? '' : 'sent')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification copyWith(void Function(Notification) updates) =>
      super.copyWith((message) => updates(message as Notification))
          as Notification;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Notification create() => Notification._();
  @$core.override
  Notification createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Notification getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Notification>(create);
  static Notification? _defaultInstance;

  @$pb.TagNumber(1)
  NotificationType get notificationType => $_getN(0);
  @$pb.TagNumber(1)
  set notificationType(NotificationType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasNotificationType() => $_has(0);
  @$pb.TagNumber(1)
  void clearNotificationType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sessionId => $_getSZ(1);
  @$pb.TagNumber(2)
  set sessionId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSessionId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSessionId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get teamMemberId => $_getSZ(2);
  @$pb.TagNumber(3)
  set teamMemberId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTeamMemberId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTeamMemberId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get sent => $_getBF(3);
  @$pb.TagNumber(4)
  set sent($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSent() => $_has(3);
  @$pb.TagNumber(4)
  void clearSent() => $_clearField(4);
}

class Logo extends $pb.GeneratedMessage {
  factory Logo({
    $core.List<$core.int>? data,
  }) {
    final result = create();
    if (data != null) result.data = data;
    return result;
  }

  Logo._();

  factory Logo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Logo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Logo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.db'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Logo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Logo copyWith(void Function(Logo) updates) =>
      super.copyWith((message) => updates(message as Logo)) as Logo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Logo create() => Logo._();
  @$core.override
  Logo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Logo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Logo>(create);
  static Logo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
}

class Settings extends $pb.GeneratedMessage {
  factory Settings({
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
    $core.bool? discordOvertimeDmEnabled,
    $fixnum.Int64? discordOvertimeDmMins,
    $core.String? discordOvertimeDmMessage,
    $core.bool? discordAutoCheckoutDmEnabled,
    $core.String? discordAutoCheckoutDmMessage,
    $core.bool? discordCheckoutEnabled,
    $core.bool? discordEnabled,
    $core.String? timezone,
    $core.String? primaryColor,
    $core.String? secondaryColor,
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
    if (discordEnabled != null) result.discordEnabled = discordEnabled;
    if (timezone != null) result.timezone = timezone;
    if (primaryColor != null) result.primaryColor = primaryColor;
    if (secondaryColor != null) result.secondaryColor = secondaryColor;
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
    ..aOB(5, _omitFieldNames ? '' : 'discordSelfLinkEnabled')
    ..aOB(6, _omitFieldNames ? '' : 'discordNameSyncEnabled')
    ..aInt64(7, _omitFieldNames ? '' : 'discordStartReminderMins')
    ..aInt64(8, _omitFieldNames ? '' : 'discordEndReminderMins')
    ..aOS(9, _omitFieldNames ? '' : 'discordStartReminderMessage')
    ..aOS(10, _omitFieldNames ? '' : 'discordEndReminderMessage')
    ..aOB(11, _omitFieldNames ? '' : 'discordOvertimeDmEnabled')
    ..aInt64(12, _omitFieldNames ? '' : 'discordOvertimeDmMins')
    ..aOS(13, _omitFieldNames ? '' : 'discordOvertimeDmMessage')
    ..aOB(14, _omitFieldNames ? '' : 'discordAutoCheckoutDmEnabled')
    ..aOS(15, _omitFieldNames ? '' : 'discordAutoCheckoutDmMessage')
    ..aOB(16, _omitFieldNames ? '' : 'discordCheckoutEnabled')
    ..aOB(17, _omitFieldNames ? '' : 'discordEnabled')
    ..aOS(18, _omitFieldNames ? '' : 'timezone')
    ..aOS(19, _omitFieldNames ? '' : 'primaryColor')
    ..aOS(20, _omitFieldNames ? '' : 'secondaryColor')
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

  @$pb.TagNumber(11)
  $core.bool get discordOvertimeDmEnabled => $_getBF(10);
  @$pb.TagNumber(11)
  set discordOvertimeDmEnabled($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasDiscordOvertimeDmEnabled() => $_has(10);
  @$pb.TagNumber(11)
  void clearDiscordOvertimeDmEnabled() => $_clearField(11);

  @$pb.TagNumber(12)
  $fixnum.Int64 get discordOvertimeDmMins => $_getI64(11);
  @$pb.TagNumber(12)
  set discordOvertimeDmMins($fixnum.Int64 value) => $_setInt64(11, value);
  @$pb.TagNumber(12)
  $core.bool hasDiscordOvertimeDmMins() => $_has(11);
  @$pb.TagNumber(12)
  void clearDiscordOvertimeDmMins() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get discordOvertimeDmMessage => $_getSZ(12);
  @$pb.TagNumber(13)
  set discordOvertimeDmMessage($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasDiscordOvertimeDmMessage() => $_has(12);
  @$pb.TagNumber(13)
  void clearDiscordOvertimeDmMessage() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.bool get discordAutoCheckoutDmEnabled => $_getBF(13);
  @$pb.TagNumber(14)
  set discordAutoCheckoutDmEnabled($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(14)
  $core.bool hasDiscordAutoCheckoutDmEnabled() => $_has(13);
  @$pb.TagNumber(14)
  void clearDiscordAutoCheckoutDmEnabled() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get discordAutoCheckoutDmMessage => $_getSZ(14);
  @$pb.TagNumber(15)
  set discordAutoCheckoutDmMessage($core.String value) =>
      $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasDiscordAutoCheckoutDmMessage() => $_has(14);
  @$pb.TagNumber(15)
  void clearDiscordAutoCheckoutDmMessage() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.bool get discordCheckoutEnabled => $_getBF(15);
  @$pb.TagNumber(16)
  set discordCheckoutEnabled($core.bool value) => $_setBool(15, value);
  @$pb.TagNumber(16)
  $core.bool hasDiscordCheckoutEnabled() => $_has(15);
  @$pb.TagNumber(16)
  void clearDiscordCheckoutEnabled() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.bool get discordEnabled => $_getBF(16);
  @$pb.TagNumber(17)
  set discordEnabled($core.bool value) => $_setBool(16, value);
  @$pb.TagNumber(17)
  $core.bool hasDiscordEnabled() => $_has(16);
  @$pb.TagNumber(17)
  void clearDiscordEnabled() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.String get timezone => $_getSZ(17);
  @$pb.TagNumber(18)
  set timezone($core.String value) => $_setString(17, value);
  @$pb.TagNumber(18)
  $core.bool hasTimezone() => $_has(17);
  @$pb.TagNumber(18)
  void clearTimezone() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.String get primaryColor => $_getSZ(18);
  @$pb.TagNumber(19)
  set primaryColor($core.String value) => $_setString(18, value);
  @$pb.TagNumber(19)
  $core.bool hasPrimaryColor() => $_has(18);
  @$pb.TagNumber(19)
  void clearPrimaryColor() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.String get secondaryColor => $_getSZ(19);
  @$pb.TagNumber(20)
  set secondaryColor($core.String value) => $_setString(19, value);
  @$pb.TagNumber(20)
  $core.bool hasSecondaryColor() => $_has(19);
  @$pb.TagNumber(20)
  void clearSecondaryColor() => $_clearField(20);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
