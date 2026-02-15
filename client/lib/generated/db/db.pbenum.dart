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

import 'package:protobuf/protobuf.dart' as $pb;

class TeamMemberType extends $pb.ProtobufEnum {
  static const TeamMemberType STUDENT =
      TeamMemberType._(0, _omitEnumNames ? '' : 'STUDENT');
  static const TeamMemberType MENTOR =
      TeamMemberType._(1, _omitEnumNames ? '' : 'MENTOR');

  static const $core.List<TeamMemberType> values = <TeamMemberType>[
    STUDENT,
    MENTOR,
  ];

  static final $core.List<TeamMemberType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static TeamMemberType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TeamMemberType._(super.value, super.name);
}

class NotificationType extends $pb.ProtobufEnum {
  static const NotificationType SESSION_START_REMINDER =
      NotificationType._(0, _omitEnumNames ? '' : 'SESSION_START_REMINDER');
  static const NotificationType SESSION_END_REMINDER =
      NotificationType._(1, _omitEnumNames ? '' : 'SESSION_END_REMINDER');
  static const NotificationType OVERTIME =
      NotificationType._(2, _omitEnumNames ? '' : 'OVERTIME');
  static const NotificationType AUTO_CHECKOUT =
      NotificationType._(3, _omitEnumNames ? '' : 'AUTO_CHECKOUT');

  static const $core.List<NotificationType> values = <NotificationType>[
    SESSION_START_REMINDER,
    SESSION_END_REMINDER,
    OVERTIME,
    AUTO_CHECKOUT,
  ];

  static final $core.List<NotificationType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static NotificationType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const NotificationType._(super.value, super.name);
}

class RsvpStatus extends $pb.ProtobufEnum {
  static const RsvpStatus GOING =
      RsvpStatus._(0, _omitEnumNames ? '' : 'GOING');
  static const RsvpStatus NOT_GOING =
      RsvpStatus._(1, _omitEnumNames ? '' : 'NOT_GOING');

  static const $core.List<RsvpStatus> values = <RsvpStatus>[
    GOING,
    NOT_GOING,
  ];

  static final $core.List<RsvpStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static RsvpStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const RsvpStatus._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
