/// Matches the `team_members.member_type` CHECK constraint on the server ('student'/'mentor').
enum TeamMemberType {
  student,
  mentor;

  static TeamMemberType fromJson(String value) {
    return value == 'mentor' ? TeamMemberType.mentor : TeamMemberType.student;
  }

  String toJson() => name;
}

class TeamMember {
  final String id;
  final String firstName;
  final String lastName;
  final TeamMemberType memberType;
  final String? displayName;
  final String? mobileNumber;
  final String? discordId;

  TeamMember({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.memberType,
    this.displayName,
    this.mobileNumber,
    this.discordId,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      memberType: TeamMemberType.fromJson(json['memberType'] as String),
      displayName: json['displayName'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      discordId: json['discordId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'memberType': memberType.toJson(),
    'displayName': displayName,
    'mobileNumber': mobileNumber,
    'discordId': discordId,
  };
}
