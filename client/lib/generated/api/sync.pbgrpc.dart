// This is a generated file - do not edit.
//
// Generated from api/sync.proto.

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

import 'sync.pb.dart' as $0;

export 'sync.pb.dart';

@$pb.GrpcServiceName('tk.api.SyncService')
class SyncServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  SyncServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseStream<$0.StreamEntitiesResponse> streamEntities(
    $0.StreamEntitiesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamEntities, $async.Stream.fromIterable([request]),
        options: options);
  }

  // method descriptors

  static final _$streamEntities =
      $grpc.ClientMethod<$0.StreamEntitiesRequest, $0.StreamEntitiesResponse>(
          '/tk.api.SyncService/StreamEntities',
          ($0.StreamEntitiesRequest value) => value.writeToBuffer(),
          $0.StreamEntitiesResponse.fromBuffer);
}

@$pb.GrpcServiceName('tk.api.SyncService')
abstract class SyncServiceBase extends $grpc.Service {
  $core.String get $name => 'tk.api.SyncService';

  SyncServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.StreamEntitiesRequest,
            $0.StreamEntitiesResponse>(
        'StreamEntities',
        streamEntities_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.StreamEntitiesRequest.fromBuffer(value),
        ($0.StreamEntitiesResponse value) => value.writeToBuffer()));
  }

  $async.Stream<$0.StreamEntitiesResponse> streamEntities_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.StreamEntitiesRequest> $request) async* {
    yield* streamEntities($call, await $request);
  }

  $async.Stream<$0.StreamEntitiesResponse> streamEntities(
      $grpc.ServiceCall call, $0.StreamEntitiesRequest request);
}
