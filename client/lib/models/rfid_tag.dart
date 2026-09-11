class RfidTag {
  final String id;
  final String teamMemberId;
  final String tag;

  RfidTag({required this.id, required this.teamMemberId, required this.tag});

  factory RfidTag.fromJson(Map<String, dynamic> json) {
    return RfidTag(id: json['id'] as String, teamMemberId: json['teamMemberId'] as String, tag: json['tag'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id, 'teamMemberId': teamMemberId, 'tag': tag};
}
