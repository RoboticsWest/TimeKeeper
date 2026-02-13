// This is a generated file - do not edit.
//
// Generated from api/rfid_tag.proto.

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

import 'rfid_tag.pb.dart' as $0;

export 'rfid_tag.pb.dart';

@$pb.GrpcServiceName('tk.api.RfidTagService')
class RfidTagServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  RfidTagServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.GetRfidTagsResponse> getRfidTags(
    $0.GetRfidTagsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getRfidTags, request, options: options);
  }

  $grpc.ResponseStream<$0.StreamRfidTagsResponse> streamRfidTags(
    $0.StreamRfidTagsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamRfidTags, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.CreateRfidTagResponse> createRfidTag(
    $0.CreateRfidTagRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createRfidTag, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeleteRfidTagResponse> deleteRfidTag(
    $0.DeleteRfidTagRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteRfidTag, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeleteRfidTagsByMemberResponse>
      deleteRfidTagsByMember(
    $0.DeleteRfidTagsByMemberRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteRfidTagsByMember, request,
        options: options);
  }

  // method descriptors

  static final _$getRfidTags =
      $grpc.ClientMethod<$0.GetRfidTagsRequest, $0.GetRfidTagsResponse>(
          '/tk.api.RfidTagService/GetRfidTags',
          ($0.GetRfidTagsRequest value) => value.writeToBuffer(),
          $0.GetRfidTagsResponse.fromBuffer);
  static final _$streamRfidTags =
      $grpc.ClientMethod<$0.StreamRfidTagsRequest, $0.StreamRfidTagsResponse>(
          '/tk.api.RfidTagService/StreamRfidTags',
          ($0.StreamRfidTagsRequest value) => value.writeToBuffer(),
          $0.StreamRfidTagsResponse.fromBuffer);
  static final _$createRfidTag =
      $grpc.ClientMethod<$0.CreateRfidTagRequest, $0.CreateRfidTagResponse>(
          '/tk.api.RfidTagService/CreateRfidTag',
          ($0.CreateRfidTagRequest value) => value.writeToBuffer(),
          $0.CreateRfidTagResponse.fromBuffer);
  static final _$deleteRfidTag =
      $grpc.ClientMethod<$0.DeleteRfidTagRequest, $0.DeleteRfidTagResponse>(
          '/tk.api.RfidTagService/DeleteRfidTag',
          ($0.DeleteRfidTagRequest value) => value.writeToBuffer(),
          $0.DeleteRfidTagResponse.fromBuffer);
  static final _$deleteRfidTagsByMember = $grpc.ClientMethod<
          $0.DeleteRfidTagsByMemberRequest, $0.DeleteRfidTagsByMemberResponse>(
      '/tk.api.RfidTagService/DeleteRfidTagsByMember',
      ($0.DeleteRfidTagsByMemberRequest value) => value.writeToBuffer(),
      $0.DeleteRfidTagsByMemberResponse.fromBuffer);
}

@$pb.GrpcServiceName('tk.api.RfidTagService')
abstract class RfidTagServiceBase extends $grpc.Service {
  $core.String get $name => 'tk.api.RfidTagService';

  RfidTagServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.GetRfidTagsRequest, $0.GetRfidTagsResponse>(
            'GetRfidTags',
            getRfidTags_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetRfidTagsRequest.fromBuffer(value),
            ($0.GetRfidTagsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StreamRfidTagsRequest,
            $0.StreamRfidTagsResponse>(
        'StreamRfidTags',
        streamRfidTags_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.StreamRfidTagsRequest.fromBuffer(value),
        ($0.StreamRfidTagsResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.CreateRfidTagRequest, $0.CreateRfidTagResponse>(
            'CreateRfidTag',
            createRfidTag_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.CreateRfidTagRequest.fromBuffer(value),
            ($0.CreateRfidTagResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.DeleteRfidTagRequest, $0.DeleteRfidTagResponse>(
            'DeleteRfidTag',
            deleteRfidTag_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.DeleteRfidTagRequest.fromBuffer(value),
            ($0.DeleteRfidTagResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteRfidTagsByMemberRequest,
            $0.DeleteRfidTagsByMemberResponse>(
        'DeleteRfidTagsByMember',
        deleteRfidTagsByMember_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteRfidTagsByMemberRequest.fromBuffer(value),
        ($0.DeleteRfidTagsByMemberResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetRfidTagsResponse> getRfidTags_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetRfidTagsRequest> $request) async {
    return getRfidTags($call, await $request);
  }

  $async.Future<$0.GetRfidTagsResponse> getRfidTags(
      $grpc.ServiceCall call, $0.GetRfidTagsRequest request);

  $async.Stream<$0.StreamRfidTagsResponse> streamRfidTags_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.StreamRfidTagsRequest> $request) async* {
    yield* streamRfidTags($call, await $request);
  }

  $async.Stream<$0.StreamRfidTagsResponse> streamRfidTags(
      $grpc.ServiceCall call, $0.StreamRfidTagsRequest request);

  $async.Future<$0.CreateRfidTagResponse> createRfidTag_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CreateRfidTagRequest> $request) async {
    return createRfidTag($call, await $request);
  }

  $async.Future<$0.CreateRfidTagResponse> createRfidTag(
      $grpc.ServiceCall call, $0.CreateRfidTagRequest request);

  $async.Future<$0.DeleteRfidTagResponse> deleteRfidTag_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteRfidTagRequest> $request) async {
    return deleteRfidTag($call, await $request);
  }

  $async.Future<$0.DeleteRfidTagResponse> deleteRfidTag(
      $grpc.ServiceCall call, $0.DeleteRfidTagRequest request);

  $async.Future<$0.DeleteRfidTagsByMemberResponse> deleteRfidTagsByMember_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteRfidTagsByMemberRequest> $request) async {
    return deleteRfidTagsByMember($call, await $request);
  }

  $async.Future<$0.DeleteRfidTagsByMemberResponse> deleteRfidTagsByMember(
      $grpc.ServiceCall call, $0.DeleteRfidTagsByMemberRequest request);
}
