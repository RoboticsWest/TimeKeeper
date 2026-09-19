/// Maximum quick PIN length.
///
/// Mirrors the `team_members_quick_pin_length` CHECK constraint (migration 0009) and the
/// server-side validation, so the three agree.
const kMaxQuickPinLength = 50;

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

  /// Quick sign-in PIN. Null for callers without team_members write access —
  /// the server omits it rather than erroring, so read-only kiosks can share
  /// this model.
  final String? quickPin;

  TeamMember({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.memberType,
    this.displayName,
    this.mobileNumber,
    this.discordId,
    this.quickPin,
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
      quickPin: json['quickPin'] as String?,
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
    'quickPin': quickPin,
  };
}
