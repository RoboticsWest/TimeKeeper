import 'package:flutter/material.dart';
import 'package:time_keeper/models/team_member.dart';
import 'package:time_keeper/theme/series_palette.dart';
import 'package:time_keeper/widgets/tone_chip.dart';

/// Role is the one identifier in the team table that is worth a hue.
///
/// Student and mentor used to be `primary` and `secondary`, which are both blue
/// in this theme and told the two roles apart only by a shade the eye cannot
/// pick out of a dense table. They now take two slots from the categorical
/// palette that sit far apart in hue and are validated for CVD separation:
/// aqua for student, violet for mentor. Slot 0 is skipped — it is the same blue
/// as `primary`, which is all over the surrounding chrome.
const int _studentSlot = 2; // aqua
const int _mentorSlot = 6; // violet

class MemberTypeChip extends StatelessWidget {
  final TeamMemberType memberType;

  const MemberTypeChip({super.key, required this.memberType});

  @override
  Widget build(BuildContext context) {
    final isStudent = memberType == TeamMemberType.student;

    return ToneChip(
      color: seriesColorOf(context, isStudent ? _studentSlot : _mentorSlot),
      label: isStudent ? 'Student' : 'Mentor',
    );
  }
}
