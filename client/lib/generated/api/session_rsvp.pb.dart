// This is a generated file - do not edit.
//
// Generated from api/session_rsvp.proto.

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

class SessionRsvpResponse extends $pb.GeneratedMessage {
  factory SessionRsvpResponse({
    $core.String? id,
    $1.SessionRsvp? rsvp,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (rsvp != null) result.rsvp = rsvp;
    return result;
  }

  SessionRsvpResponse._();

  factory SessionRsvpResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SessionRsvpResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SessionRsvpResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$1.SessionRsvp>(2, _omitFieldNames ? '' : 'rsvp',
        subBuilder: $1.SessionRsvp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionRsvpResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionRsvpResponse copyWith(void Function(SessionRsvpResponse) updates) =>
      super.copyWith((message) => updates(message as SessionRsvpResponse))
          as SessionRsvpResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SessionRsvpResponse create() => SessionRsvpResponse._();
  @$core.override
  SessionRsvpResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SessionRsvpResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SessionRsvpResponse>(create);
  static SessionRsvpResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.SessionRsvp get rsvp => $_getN(1);
  @$pb.TagNumber(2)
  set rsvp($1.SessionRsvp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasRsvp() => $_has(1);
  @$pb.TagNumber(2)
  void clearRsvp() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.SessionRsvp ensureRsvp() => $_ensure(1);
}

class GetSessionRsvpsRequest extends $pb.GeneratedMessage {
  factory GetSessionRsvpsRequest() => create();

  GetSessionRsvpsRequest._();

  factory GetSessionRsvpsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSessionRsvpsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSessionRsvpsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSessionRsvpsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSessionRsvpsRequest copyWith(
          void Function(GetSessionRsvpsRequest) updates) =>
      super.copyWith((message) => updates(message as GetSessionRsvpsRequest))
          as GetSessionRsvpsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSessionRsvpsRequest create() => GetSessionRsvpsRequest._();
  @$core.override
  GetSessionRsvpsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSessionRsvpsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSessionRsvpsRequest>(create);
  static GetSessionRsvpsRequest? _defaultInstance;
}

class GetSessionRsvpsResponse extends $pb.GeneratedMessage {
  factory GetSessionRsvpsResponse({
    $core.Iterable<SessionRsvpResponse>? rsvps,
  }) {
    final result = create();
    if (rsvps != null) result.rsvps.addAll(rsvps);
    return result;
  }

  GetSessionRsvpsResponse._();

  factory GetSessionRsvpsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSessionRsvpsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSessionRsvpsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..pPM<SessionRsvpResponse>(1, _omitFieldNames ? '' : 'rsvps',
        subBuilder: SessionRsvpResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSessionRsvpsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSessionRsvpsResponse copyWith(
          void Function(GetSessionRsvpsResponse) updates) =>
      super.copyWith((message) => updates(message as GetSessionRsvpsResponse))
          as GetSessionRsvpsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSessionRsvpsResponse create() => GetSessionRsvpsResponse._();
  @$core.override
  GetSessionRsvpsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSessionRsvpsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSessionRsvpsResponse>(create);
  static GetSessionRsvpsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SessionRsvpResponse> get rsvps => $_getList(0);
}

class StreamSessionRsvpsRequest extends $pb.GeneratedMessage {
  factory StreamSessionRsvpsRequest() => create();

  StreamSessionRsvpsRequest._();

  factory StreamSessionRsvpsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamSessionRsvpsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamSessionRsvpsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamSessionRsvpsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamSessionRsvpsRequest copyWith(
          void Function(StreamSessionRsvpsRequest) updates) =>
      super.copyWith((message) => updates(message as StreamSessionRsvpsRequest))
          as StreamSessionRsvpsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamSessionRsvpsRequest create() => StreamSessionRsvpsRequest._();
  @$core.override
  StreamSessionRsvpsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamSessionRsvpsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamSessionRsvpsRequest>(create);
  static StreamSessionRsvpsRequest? _defaultInstance;
}

class StreamSessionRsvpsResponse extends $pb.GeneratedMessage {
  factory StreamSessionRsvpsResponse({
    $core.Iterable<SessionRsvpResponse>? rsvps,
    $2.SyncType? syncType,
  }) {
    final result = create();
    if (rsvps != null) result.rsvps.addAll(rsvps);
    if (syncType != null) result.syncType = syncType;
    return result;
  }

  StreamSessionRsvpsResponse._();

  factory StreamSessionRsvpsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamSessionRsvpsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamSessionRsvpsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..pPM<SessionRsvpResponse>(1, _omitFieldNames ? '' : 'rsvps',
        subBuilder: SessionRsvpResponse.create)
    ..aE<$2.SyncType>(2, _omitFieldNames ? '' : 'syncType',
        enumValues: $2.SyncType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamSessionRsvpsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamSessionRsvpsResponse copyWith(
          void Function(StreamSessionRsvpsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as StreamSessionRsvpsResponse))
          as StreamSessionRsvpsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamSessionRsvpsResponse create() => StreamSessionRsvpsResponse._();
  @$core.override
  StreamSessionRsvpsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamSessionRsvpsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamSessionRsvpsResponse>(create);
  static StreamSessionRsvpsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SessionRsvpResponse> get rsvps => $_getList(0);

  @$pb.TagNumber(2)
  $2.SyncType get syncType => $_getN(1);
  @$pb.TagNumber(2)
  set syncType($2.SyncType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSyncType() => $_has(1);
  @$pb.TagNumber(2)
  void clearSyncType() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
