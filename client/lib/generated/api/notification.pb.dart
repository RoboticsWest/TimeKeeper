// This is a generated file - do not edit.
//
// Generated from api/notification.proto.

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

class NotificationResponse extends $pb.GeneratedMessage {
  factory NotificationResponse({
    $core.String? id,
    $1.Notification? notification,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (notification != null) result.notification = notification;
    return result;
  }

  NotificationResponse._();

  factory NotificationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NotificationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NotificationResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$1.Notification>(2, _omitFieldNames ? '' : 'notification',
        subBuilder: $1.Notification.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NotificationResponse copyWith(void Function(NotificationResponse) updates) =>
      super.copyWith((message) => updates(message as NotificationResponse))
          as NotificationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NotificationResponse create() => NotificationResponse._();
  @$core.override
  NotificationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NotificationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NotificationResponse>(create);
  static NotificationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.Notification get notification => $_getN(1);
  @$pb.TagNumber(2)
  set notification($1.Notification value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasNotification() => $_has(1);
  @$pb.TagNumber(2)
  void clearNotification() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.Notification ensureNotification() => $_ensure(1);
}

class GetNotificationsRequest extends $pb.GeneratedMessage {
  factory GetNotificationsRequest() => create();

  GetNotificationsRequest._();

  factory GetNotificationsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetNotificationsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetNotificationsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNotificationsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNotificationsRequest copyWith(
          void Function(GetNotificationsRequest) updates) =>
      super.copyWith((message) => updates(message as GetNotificationsRequest))
          as GetNotificationsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNotificationsRequest create() => GetNotificationsRequest._();
  @$core.override
  GetNotificationsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetNotificationsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNotificationsRequest>(create);
  static GetNotificationsRequest? _defaultInstance;
}

class GetNotificationsResponse extends $pb.GeneratedMessage {
  factory GetNotificationsResponse({
    $core.Iterable<NotificationResponse>? notifications,
  }) {
    final result = create();
    if (notifications != null) result.notifications.addAll(notifications);
    return result;
  }

  GetNotificationsResponse._();

  factory GetNotificationsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetNotificationsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetNotificationsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..pPM<NotificationResponse>(1, _omitFieldNames ? '' : 'notifications',
        subBuilder: NotificationResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNotificationsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNotificationsResponse copyWith(
          void Function(GetNotificationsResponse) updates) =>
      super.copyWith((message) => updates(message as GetNotificationsResponse))
          as GetNotificationsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNotificationsResponse create() => GetNotificationsResponse._();
  @$core.override
  GetNotificationsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetNotificationsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNotificationsResponse>(create);
  static GetNotificationsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<NotificationResponse> get notifications => $_getList(0);
}

class StreamNotificationsRequest extends $pb.GeneratedMessage {
  factory StreamNotificationsRequest() => create();

  StreamNotificationsRequest._();

  factory StreamNotificationsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamNotificationsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamNotificationsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamNotificationsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamNotificationsRequest copyWith(
          void Function(StreamNotificationsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as StreamNotificationsRequest))
          as StreamNotificationsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamNotificationsRequest create() => StreamNotificationsRequest._();
  @$core.override
  StreamNotificationsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamNotificationsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamNotificationsRequest>(create);
  static StreamNotificationsRequest? _defaultInstance;
}

class StreamNotificationsResponse extends $pb.GeneratedMessage {
  factory StreamNotificationsResponse({
    $core.Iterable<NotificationResponse>? notifications,
    $2.SyncType? syncType,
  }) {
    final result = create();
    if (notifications != null) result.notifications.addAll(notifications);
    if (syncType != null) result.syncType = syncType;
    return result;
  }

  StreamNotificationsResponse._();

  factory StreamNotificationsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamNotificationsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamNotificationsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..pPM<NotificationResponse>(1, _omitFieldNames ? '' : 'notifications',
        subBuilder: NotificationResponse.create)
    ..aE<$2.SyncType>(2, _omitFieldNames ? '' : 'syncType',
        enumValues: $2.SyncType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamNotificationsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamNotificationsResponse copyWith(
          void Function(StreamNotificationsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as StreamNotificationsResponse))
          as StreamNotificationsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamNotificationsResponse create() =>
      StreamNotificationsResponse._();
  @$core.override
  StreamNotificationsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamNotificationsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamNotificationsResponse>(create);
  static StreamNotificationsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<NotificationResponse> get notifications => $_getList(0);

  @$pb.TagNumber(2)
  $2.SyncType get syncType => $_getN(1);
  @$pb.TagNumber(2)
  set syncType($2.SyncType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSyncType() => $_has(1);
  @$pb.TagNumber(2)
  void clearSyncType() => $_clearField(2);
}

class CreateNotificationRequest extends $pb.GeneratedMessage {
  factory CreateNotificationRequest({
    $1.NotificationType? notificationType,
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

  CreateNotificationRequest._();

  factory CreateNotificationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateNotificationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateNotificationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aE<$1.NotificationType>(1, _omitFieldNames ? '' : 'notificationType',
        enumValues: $1.NotificationType.values)
    ..aOS(2, _omitFieldNames ? '' : 'sessionId')
    ..aOS(3, _omitFieldNames ? '' : 'teamMemberId')
    ..aOB(4, _omitFieldNames ? '' : 'sent')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateNotificationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateNotificationRequest copyWith(
          void Function(CreateNotificationRequest) updates) =>
      super.copyWith((message) => updates(message as CreateNotificationRequest))
          as CreateNotificationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateNotificationRequest create() => CreateNotificationRequest._();
  @$core.override
  CreateNotificationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateNotificationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateNotificationRequest>(create);
  static CreateNotificationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $1.NotificationType get notificationType => $_getN(0);
  @$pb.TagNumber(1)
  set notificationType($1.NotificationType value) => $_setField(1, value);
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

class CreateNotificationResponse extends $pb.GeneratedMessage {
  factory CreateNotificationResponse() => create();

  CreateNotificationResponse._();

  factory CreateNotificationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateNotificationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateNotificationResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateNotificationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateNotificationResponse copyWith(
          void Function(CreateNotificationResponse) updates) =>
      super.copyWith(
              (message) => updates(message as CreateNotificationResponse))
          as CreateNotificationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateNotificationResponse create() => CreateNotificationResponse._();
  @$core.override
  CreateNotificationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateNotificationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateNotificationResponse>(create);
  static CreateNotificationResponse? _defaultInstance;
}

class UpdateNotificationRequest extends $pb.GeneratedMessage {
  factory UpdateNotificationRequest({
    $core.String? id,
    $1.NotificationType? notificationType,
    $core.String? sessionId,
    $core.String? teamMemberId,
    $core.bool? sent,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (notificationType != null) result.notificationType = notificationType;
    if (sessionId != null) result.sessionId = sessionId;
    if (teamMemberId != null) result.teamMemberId = teamMemberId;
    if (sent != null) result.sent = sent;
    return result;
  }

  UpdateNotificationRequest._();

  factory UpdateNotificationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateNotificationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateNotificationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aE<$1.NotificationType>(2, _omitFieldNames ? '' : 'notificationType',
        enumValues: $1.NotificationType.values)
    ..aOS(3, _omitFieldNames ? '' : 'sessionId')
    ..aOS(4, _omitFieldNames ? '' : 'teamMemberId')
    ..aOB(5, _omitFieldNames ? '' : 'sent')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateNotificationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateNotificationRequest copyWith(
          void Function(UpdateNotificationRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateNotificationRequest))
          as UpdateNotificationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateNotificationRequest create() => UpdateNotificationRequest._();
  @$core.override
  UpdateNotificationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateNotificationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateNotificationRequest>(create);
  static UpdateNotificationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.NotificationType get notificationType => $_getN(1);
  @$pb.TagNumber(2)
  set notificationType($1.NotificationType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasNotificationType() => $_has(1);
  @$pb.TagNumber(2)
  void clearNotificationType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get sessionId => $_getSZ(2);
  @$pb.TagNumber(3)
  set sessionId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSessionId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSessionId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get teamMemberId => $_getSZ(3);
  @$pb.TagNumber(4)
  set teamMemberId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTeamMemberId() => $_has(3);
  @$pb.TagNumber(4)
  void clearTeamMemberId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get sent => $_getBF(4);
  @$pb.TagNumber(5)
  set sent($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSent() => $_has(4);
  @$pb.TagNumber(5)
  void clearSent() => $_clearField(5);
}

class UpdateNotificationResponse extends $pb.GeneratedMessage {
  factory UpdateNotificationResponse() => create();

  UpdateNotificationResponse._();

  factory UpdateNotificationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateNotificationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateNotificationResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateNotificationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateNotificationResponse copyWith(
          void Function(UpdateNotificationResponse) updates) =>
      super.copyWith(
              (message) => updates(message as UpdateNotificationResponse))
          as UpdateNotificationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateNotificationResponse create() => UpdateNotificationResponse._();
  @$core.override
  UpdateNotificationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateNotificationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateNotificationResponse>(create);
  static UpdateNotificationResponse? _defaultInstance;
}

class DeleteNotificationRequest extends $pb.GeneratedMessage {
  factory DeleteNotificationRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  DeleteNotificationRequest._();

  factory DeleteNotificationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteNotificationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteNotificationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteNotificationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteNotificationRequest copyWith(
          void Function(DeleteNotificationRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteNotificationRequest))
          as DeleteNotificationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteNotificationRequest create() => DeleteNotificationRequest._();
  @$core.override
  DeleteNotificationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteNotificationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteNotificationRequest>(create);
  static DeleteNotificationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class DeleteNotificationResponse extends $pb.GeneratedMessage {
  factory DeleteNotificationResponse() => create();

  DeleteNotificationResponse._();

  factory DeleteNotificationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteNotificationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteNotificationResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteNotificationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteNotificationResponse copyWith(
          void Function(DeleteNotificationResponse) updates) =>
      super.copyWith(
              (message) => updates(message as DeleteNotificationResponse))
          as DeleteNotificationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteNotificationResponse create() => DeleteNotificationResponse._();
  @$core.override
  DeleteNotificationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteNotificationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteNotificationResponse>(create);
  static DeleteNotificationResponse? _defaultInstance;
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
