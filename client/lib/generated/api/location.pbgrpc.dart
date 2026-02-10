// This is a generated file - do not edit.
//
// Generated from api/location.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'location.pb.dart' as $0;

export 'location.pb.dart';

@$pb.GrpcServiceName('tk.api.LocationService')
class LocationServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  LocationServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.GetLocationsResponse> getLocations(
    $0.GetLocationsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getLocations, request, options: options);
  }

  $grpc.ResponseStream<$0.StreamLocationsResponse> streamLocations(
    $0.StreamLocationsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamLocations, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.CreateLocationResponse> createLocation(
    $0.CreateLocationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createLocation, request, options: options);
  }

  $grpc.ResponseFuture<$0.UpdateLocationResponse> updateLocation(
    $0.UpdateLocationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateLocation, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeleteLocationResponse> deleteLocation(
    $0.DeleteLocationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteLocation, request, options: options);
  }

  // method descriptors

  static final _$getLocations =
      $grpc.ClientMethod<$0.GetLocationsRequest, $0.GetLocationsResponse>(
          '/tk.api.LocationService/GetLocations',
          ($0.GetLocationsRequest value) => value.writeToBuffer(),
          $0.GetLocationsResponse.fromBuffer);
  static final _$streamLocations =
      $grpc.ClientMethod<$0.StreamLocationsRequest, $0.StreamLocationsResponse>(
          '/tk.api.LocationService/StreamLocations',
          ($0.StreamLocationsRequest value) => value.writeToBuffer(),
          $0.StreamLocationsResponse.fromBuffer);
  static final _$createLocation =
      $grpc.ClientMethod<$0.CreateLocationRequest, $0.CreateLocationResponse>(
          '/tk.api.LocationService/CreateLocation',
          ($0.CreateLocationRequest value) => value.writeToBuffer(),
          $0.CreateLocationResponse.fromBuffer);
  static final _$updateLocation =
      $grpc.ClientMethod<$0.UpdateLocationRequest, $0.UpdateLocationResponse>(
          '/tk.api.LocationService/UpdateLocation',
          ($0.UpdateLocationRequest value) => value.writeToBuffer(),
          $0.UpdateLocationResponse.fromBuffer);
  static final _$deleteLocation =
      $grpc.ClientMethod<$0.DeleteLocationRequest, $0.DeleteLocationResponse>(
          '/tk.api.LocationService/DeleteLocation',
          ($0.DeleteLocationRequest value) => value.writeToBuffer(),
          $0.DeleteLocationResponse.fromBuffer);
}

@$pb.GrpcServiceName('tk.api.LocationService')
abstract class LocationServiceBase extends $grpc.Service {
  $core.String get $name => 'tk.api.LocationService';

  LocationServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.GetLocationsRequest, $0.GetLocationsResponse>(
            'GetLocations',
            getLocations_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetLocationsRequest.fromBuffer(value),
            ($0.GetLocationsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StreamLocationsRequest,
            $0.StreamLocationsResponse>(
        'StreamLocations',
        streamLocations_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.StreamLocationsRequest.fromBuffer(value),
        ($0.StreamLocationsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateLocationRequest,
            $0.CreateLocationResponse>(
        'CreateLocation',
        createLocation_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CreateLocationRequest.fromBuffer(value),
        ($0.CreateLocationResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateLocationRequest,
            $0.UpdateLocationResponse>(
        'UpdateLocation',
        updateLocation_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateLocationRequest.fromBuffer(value),
        ($0.UpdateLocationResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteLocationRequest,
            $0.DeleteLocationResponse>(
        'DeleteLocation',
        deleteLocation_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteLocationRequest.fromBuffer(value),
        ($0.DeleteLocationResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetLocationsResponse> getLocations_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetLocationsRequest> $request) async {
    return getLocations($call, await $request);
  }

  $async.Future<$0.GetLocationsResponse> getLocations(
      $grpc.ServiceCall call, $0.GetLocationsRequest request);

  $async.Stream<$0.StreamLocationsResponse> streamLocations_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.StreamLocationsRequest> $request) async* {
    yield* streamLocations($call, await $request);
  }

  $async.Stream<$0.StreamLocationsResponse> streamLocations(
      $grpc.ServiceCall call, $0.StreamLocationsRequest request);

  $async.Future<$0.CreateLocationResponse> createLocation_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CreateLocationRequest> $request) async {
    return createLocation($call, await $request);
  }

  $async.Future<$0.CreateLocationResponse> createLocation(
      $grpc.ServiceCall call, $0.CreateLocationRequest request);

  $async.Future<$0.UpdateLocationResponse> updateLocation_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UpdateLocationRequest> $request) async {
    return updateLocation($call, await $request);
  }

  $async.Future<$0.UpdateLocationResponse> updateLocation(
      $grpc.ServiceCall call, $0.UpdateLocationRequest request);

  $async.Future<$0.DeleteLocationResponse> deleteLocation_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteLocationRequest> $request) async {
    return deleteLocation($call, await $request);
  }

  $async.Future<$0.DeleteLocationResponse> deleteLocation(
      $grpc.ServiceCall call, $0.DeleteLocationRequest request);
}
