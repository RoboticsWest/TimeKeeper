import 'package:time_keeper/models/team_member.dart';

class HoursBucket {
  final double regularSecs;
  final double overtimeSecs;

  HoursBucket({required this.regularSecs, required this.overtimeSecs});

  factory HoursBucket.fromJson(Map<String, dynamic> json) {
    return HoursBucket(
      regularSecs: (json['regularSecs'] as num).toDouble(),
      overtimeSecs: (json['overtimeSecs'] as num).toDouble(),
    );
  }
}

class LeaderboardEntry {
  final String teamMemberId;
  final TeamMember teamMember;
  final HoursBucket activeSession;
  final HoursBucket thisWeek;
  final HoursBucket allTime;
  final double totalSecs;

  LeaderboardEntry({
    required this.teamMemberId,
    required this.teamMember,
    required this.activeSession,
    required this.thisWeek,
    required this.allTime,
    required this.totalSecs,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      teamMemberId: json['teamMemberId'] as String,
      teamMember: TeamMember.fromJson(json['teamMember'] as Map<String, dynamic>),
      activeSession: HoursBucket.fromJson(json['activeSession'] as Map<String, dynamic>),
      thisWeek: HoursBucket.fromJson(json['thisWeek'] as Map<String, dynamic>),
      allTime: HoursBucket.fromJson(json['allTime'] as Map<String, dynamic>),
      totalSecs: (json['totalSecs'] as num).toDouble(),
    );
  }
}
