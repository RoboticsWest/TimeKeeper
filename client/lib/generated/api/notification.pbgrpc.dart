// This is a generated file - do not edit.
//
// Generated from api/notification.proto.

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

import 'notification.pb.dart' as $0;

export 'notification.pb.dart';

@$pb.GrpcServiceName('tk.api.NotificationService')
class NotificationServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  NotificationServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.GetNotificationsResponse> getNotifications(
    $0.GetNotificationsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getNotifications, request, options: options);
  }

  $grpc.ResponseStream<$0.StreamNotificationsResponse> streamNotifications(
    $0.StreamNotificationsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamNotifications, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.CreateNotificationResponse> createNotification(
    $0.CreateNotificationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createNotification, request, options: options);
  }

  $grpc.ResponseFuture<$0.UpdateNotificationResponse> updateNotification(
    $0.UpdateNotificationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateNotification, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeleteNotificationResponse> deleteNotification(
    $0.DeleteNotificationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteNotification, request, options: options);
  }

  // method descriptors

  static final _$getNotifications = $grpc.ClientMethod<
          $0.GetNotificationsRequest, $0.GetNotificationsResponse>(
      '/tk.api.NotificationService/GetNotifications',
      ($0.GetNotificationsRequest value) => value.writeToBuffer(),
      $0.GetNotificationsResponse.fromBuffer);
  static final _$streamNotifications = $grpc.ClientMethod<
          $0.StreamNotificationsRequest, $0.StreamNotificationsResponse>(
      '/tk.api.NotificationService/StreamNotifications',
      ($0.StreamNotificationsRequest value) => value.writeToBuffer(),
      $0.StreamNotificationsResponse.fromBuffer);
  static final _$createNotification = $grpc.ClientMethod<
          $0.CreateNotificationRequest, $0.CreateNotificationResponse>(
      '/tk.api.NotificationService/CreateNotification',
      ($0.CreateNotificationRequest value) => value.writeToBuffer(),
      $0.CreateNotificationResponse.fromBuffer);
  static final _$updateNotification = $grpc.ClientMethod<
          $0.UpdateNotificationRequest, $0.UpdateNotificationResponse>(
      '/tk.api.NotificationService/UpdateNotification',
      ($0.UpdateNotificationRequest value) => value.writeToBuffer(),
      $0.UpdateNotificationResponse.fromBuffer);
  static final _$deleteNotification = $grpc.ClientMethod<
          $0.DeleteNotificationRequest, $0.DeleteNotificationResponse>(
      '/tk.api.NotificationService/DeleteNotification',
      ($0.DeleteNotificationRequest value) => value.writeToBuffer(),
      $0.DeleteNotificationResponse.fromBuffer);
}

@$pb.GrpcServiceName('tk.api.NotificationService')
abstract class NotificationServiceBase extends $grpc.Service {
  $core.String get $name => 'tk.api.NotificationService';

  NotificationServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GetNotificationsRequest,
            $0.GetNotificationsResponse>(
        'GetNotifications',
        getNotifications_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetNotificationsRequest.fromBuffer(value),
        ($0.GetNotificationsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StreamNotificationsRequest,
            $0.StreamNotificationsResponse>(
        'StreamNotifications',
        streamNotifications_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.StreamNotificationsRequest.fromBuffer(value),
        ($0.StreamNotificationsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateNotificationRequest,
            $0.CreateNotificationResponse>(
        'CreateNotification',
        createNotification_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CreateNotificationRequest.fromBuffer(value),
        ($0.CreateNotificationResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateNotificationRequest,
            $0.UpdateNotificationResponse>(
        'UpdateNotification',
        updateNotification_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateNotificationRequest.fromBuffer(value),
        ($0.UpdateNotificationResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteNotificationRequest,
            $0.DeleteNotificationResponse>(
        'DeleteNotification',
        deleteNotification_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteNotificationRequest.fromBuffer(value),
        ($0.DeleteNotificationResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetNotificationsResponse> getNotifications_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetNotificationsRequest> $request) async {
    return getNotifications($call, await $request);
  }

  $async.Future<$0.GetNotificationsResponse> getNotifications(
      $grpc.ServiceCall call, $0.GetNotificationsRequest request);

  $async.Stream<$0.StreamNotificationsResponse> streamNotifications_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.StreamNotificationsRequest> $request) async* {
    yield* streamNotifications($call, await $request);
  }

  $async.Stream<$0.StreamNotificationsResponse> streamNotifications(
      $grpc.ServiceCall call, $0.StreamNotificationsRequest request);

  $async.Future<$0.CreateNotificationResponse> createNotification_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CreateNotificationRequest> $request) async {
    return createNotification($call, await $request);
  }

  $async.Future<$0.CreateNotificationResponse> createNotification(
      $grpc.ServiceCall call, $0.CreateNotificationRequest request);

  $async.Future<$0.UpdateNotificationResponse> updateNotification_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UpdateNotificationRequest> $request) async {
    return updateNotification($call, await $request);
  }

  $async.Future<$0.UpdateNotificationResponse> updateNotification(
      $grpc.ServiceCall call, $0.UpdateNotificationRequest request);

  $async.Future<$0.DeleteNotificationResponse> deleteNotification_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteNotificationRequest> $request) async {
    return deleteNotification($call, await $request);
  }

  $async.Future<$0.DeleteNotificationResponse> deleteNotification(
      $grpc.ServiceCall call, $0.DeleteNotificationRequest request);
}
