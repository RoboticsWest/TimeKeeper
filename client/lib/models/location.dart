class Location {
  final String id;
  final String location;

  Location({required this.id, required this.location});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(id: json['id'] as String, location: json['location'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id, 'location': location};
}
