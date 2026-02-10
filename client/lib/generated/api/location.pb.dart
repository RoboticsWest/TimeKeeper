// This is a generated file - do not edit.
//
// Generated from api/location.proto.

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

class LocationResponse extends $pb.GeneratedMessage {
  factory LocationResponse({
    $core.String? id,
    $1.Location? location,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (location != null) result.location = location;
    return result;
  }

  LocationResponse._();

  factory LocationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LocationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LocationResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$1.Location>(2, _omitFieldNames ? '' : 'location',
        subBuilder: $1.Location.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LocationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LocationResponse copyWith(void Function(LocationResponse) updates) =>
      super.copyWith((message) => updates(message as LocationResponse))
          as LocationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LocationResponse create() => LocationResponse._();
  @$core.override
  LocationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LocationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LocationResponse>(create);
  static LocationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.Location get location => $_getN(1);
  @$pb.TagNumber(2)
  set location($1.Location value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasLocation() => $_has(1);
  @$pb.TagNumber(2)
  void clearLocation() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.Location ensureLocation() => $_ensure(1);
}

class GetLocationsRequest extends $pb.GeneratedMessage {
  factory GetLocationsRequest() => create();

  GetLocationsRequest._();

  factory GetLocationsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetLocationsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLocationsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLocationsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLocationsRequest copyWith(void Function(GetLocationsRequest) updates) =>
      super.copyWith((message) => updates(message as GetLocationsRequest))
          as GetLocationsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetLocationsRequest create() => GetLocationsRequest._();
  @$core.override
  GetLocationsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetLocationsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetLocationsRequest>(create);
  static GetLocationsRequest? _defaultInstance;
}

class GetLocationsResponse extends $pb.GeneratedMessage {
  factory GetLocationsResponse({
    $core.Iterable<LocationResponse>? locations,
  }) {
    final result = create();
    if (locations != null) result.locations.addAll(locations);
    return result;
  }

  GetLocationsResponse._();

  factory GetLocationsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetLocationsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLocationsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..pPM<LocationResponse>(1, _omitFieldNames ? '' : 'locations',
        subBuilder: LocationResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLocationsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLocationsResponse copyWith(void Function(GetLocationsResponse) updates) =>
      super.copyWith((message) => updates(message as GetLocationsResponse))
          as GetLocationsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetLocationsResponse create() => GetLocationsResponse._();
  @$core.override
  GetLocationsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetLocationsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetLocationsResponse>(create);
  static GetLocationsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<LocationResponse> get locations => $_getList(0);
}

class StreamLocationsRequest extends $pb.GeneratedMessage {
  factory StreamLocationsRequest() => create();

  StreamLocationsRequest._();

  factory StreamLocationsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamLocationsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamLocationsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamLocationsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamLocationsRequest copyWith(
          void Function(StreamLocationsRequest) updates) =>
      super.copyWith((message) => updates(message as StreamLocationsRequest))
          as StreamLocationsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamLocationsRequest create() => StreamLocationsRequest._();
  @$core.override
  StreamLocationsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamLocationsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamLocationsRequest>(create);
  static StreamLocationsRequest? _defaultInstance;
}

class StreamLocationsResponse extends $pb.GeneratedMessage {
  factory StreamLocationsResponse({
    $core.Iterable<LocationResponse>? locations,
  }) {
    final result = create();
    if (locations != null) result.locations.addAll(locations);
    return result;
  }

  StreamLocationsResponse._();

  factory StreamLocationsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamLocationsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamLocationsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tk.api'),
      createEmptyInstance: create)
    ..pPM<LocationResponse>(1, _omitFieldNames ? '' : 'locations',
        subBuilder: LocationResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamLocationsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamLocationsResponse copyWith(
          void Function(StreamLocationsResponse) updates) =>
      super.copyWith((message) => updates(message as StreamLocationsResponse))
          as StreamLocationsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamLocationsResponse create() => StreamLocationsResponse._();
  @$core.override
  StreamLocationsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StreamLocationsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamLocationsResponse>(create);
  static StreamLocationsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<LocationResponse> get locations => $_getList(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
