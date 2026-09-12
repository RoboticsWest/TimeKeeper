class Role {
  final int id;
  final String name;
  final String? description;
  final bool isSuper;

  const Role({required this.id, required this.name, this.description, required this.isSuper});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      isSuper: json['isSuper'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'description': description, 'isSuper': isSuper};

  /// Shown in the UI - the stored names are lowercase slugs.
  String get label => name.isEmpty ? name : '${name[0].toUpperCase()}${name.substring(1)}';
}
