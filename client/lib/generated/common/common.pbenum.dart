// This is a generated file - do not edit.
//
// Generated from common/common.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Role extends $pb.ProtobufEnum {
  static const Role ADMIN = Role._(0, _omitEnumNames ? '' : 'ADMIN');
  static const Role KIOSK = Role._(1, _omitEnumNames ? '' : 'KIOSK');
  static const Role STUDENT = Role._(2, _omitEnumNames ? '' : 'STUDENT');
  static const Role MENTOR = Role._(3, _omitEnumNames ? '' : 'MENTOR');

  static const $core.List<Role> values = <Role>[
    ADMIN,
    KIOSK,
    STUDENT,
    MENTOR,
  ];

  static final $core.List<Role?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static Role? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Role._(super.value, super.name);
}

class SyncType extends $pb.ProtobufEnum {
  static const SyncType FULL = SyncType._(0, _omitEnumNames ? '' : 'FULL');
  static const SyncType PARTIAL =
      SyncType._(1, _omitEnumNames ? '' : 'PARTIAL');

  static const $core.List<SyncType> values = <SyncType>[
    FULL,
    PARTIAL,
  ];

  static final $core.List<SyncType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static SyncType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SyncType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
