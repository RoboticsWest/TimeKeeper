import 'package:time_keeper/models/role.dart';

class User {
  final String id;
  final String username;
  final List<Role> roles;

  User({required this.id, required this.username, this.roles = const []});

  factory User.fromJson(Map<String, dynamic> json) {
    final roles = json['roles'] as List<dynamic>?;
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      roles: roles == null ? const [] : roles.map((r) => Role.fromJson(r as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'roles': roles.map((r) => r.toJson()).toList(),
  };
}
