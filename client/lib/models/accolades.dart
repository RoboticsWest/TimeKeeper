import 'package:time_keeper/models/team_member.dart';

/// One achievement, and whether the member being viewed holds it.
///
/// The catalogue is defined server-side and sent whole, earned flags and all, so the client
/// never has to know a single rule. Adding an achievement on the server makes it appear here
/// with no client change at all.
class Achievement {
  /// Stable identifier. Safe to compare on; [name] is presentation and may be reworded.
  final String key;

  /// A standard Unicode emoji. Never a custom server emoji, which would only render for Nitro
  /// subscribers — the same constraint that shaped the Discord side.
  final String emoji;
  final String name;

  /// How it is earned. Shown whether or not it is held — it is what makes a locked one worth
  /// looking at.
  final String how;

  /// Hidden ones are a surprise: they must not reveal their name or condition until earned.
  final bool hidden;
  final bool earned;

  /// How many team members hold this one, and out of how many are actually in use.
  final int holders;
  final int totalMembers;

  /// Share of the members actually in use holding this, 0-100.
  final double rarityPct;

  Achievement({
    required this.key,
    required this.emoji,
    required this.name,
    required this.how,
    required this.hidden,
    required this.earned,
    required this.holders,
    required this.totalMembers,
    required this.rarityPct,
  });

  /// Whether this one should still be kept secret from the viewer.
  bool get isSecret => hidden && !earned;

  /// A one-word band for how hard this is to hold.
  ///
  /// Bands rather than a bare percentage because a percentage means little without the team
  /// size — on a dozen active members every figure is a multiple of eight. Mirrors
  /// `rarity_label` on the server so Discord and the app never describe the same badge
  /// differently.
  String get rarityLabel {
    if (totalMembers == 0) return 'Unrated';
    if (rarityPct <= 0) return 'Unclaimed';
    if (rarityPct < 10) return 'Legendary';
    if (rarityPct < 25) return 'Rare';
    if (rarityPct < 50) return 'Uncommon';
    if (rarityPct < 90) return 'Common';
    return 'Everyone';
  }

  /// "Rare · 17% of active members" — the band alone is vague, the figure alone is meaningless.
  String get rarityText =>
      totalMembers == 0 ? rarityLabel : '$rarityLabel \u00b7 ${rarityPct.round()}% of active members';

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      key: json['key'] as String,
      emoji: json['emoji'] as String,
      name: json['name'] as String,
      how: json['how'] as String,
      hidden: json['hidden'] as bool,
      earned: json['earned'] as bool,
      holders: (json['holders'] as num).toInt(),
      totalMembers: (json['totalMembers'] as num).toInt(),
      rarityPct: (json['rarityPct'] as num).toDouble(),
    );
  }
}

/// A member's title and their whole collection.
class MemberAccolades {
  final String teamMemberId;
  final String name;
  final TeamMemberType memberType;

  /// Derived fresh on every request and stored nowhere, so it can change as the member does.
  final String title;
  final String titleReason;
  final int earnedCount;
  final int totalCount;

  /// The entire catalogue in its declared order — held and unheld alike.
  final List<Achievement> achievements;

  MemberAccolades({
    required this.teamMemberId,
    required this.name,
    required this.memberType,
    required this.title,
    required this.titleReason,
    required this.earnedCount,
    required this.totalCount,
    required this.achievements,
  });

  List<Achievement> get earned => achievements.where((a) => a.earned).toList();

  /// Unheld achievements, with the secret ones withheld rather than teased.
  List<Achievement> get locked => achievements.where((a) => !a.earned && !a.hidden).toList();

  /// How many unheld achievements are secret, so the UI can say "and N more, kept secret"
  /// without naming any of them.
  int get secretCount => achievements.where((a) => a.isSecret).length;

  double get completion => totalCount == 0 ? 0 : earnedCount / totalCount;

  factory MemberAccolades.fromJson(Map<String, dynamic> json) {
    return MemberAccolades(
      teamMemberId: json['teamMemberId'] as String,
      name: json['name'] as String,
      memberType: TeamMemberType.fromJson(json['memberType'] as String),
      title: json['title'] as String,
      titleReason: json['titleReason'] as String,
      earnedCount: (json['earnedCount'] as num).toInt(),
      totalCount: (json['totalCount'] as num).toInt(),
      achievements: (json['achievements'] as List<dynamic>)
          .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
