import 'package:flutter/material.dart';
import 'package:time_keeper/models/role.dart';
import 'package:time_keeper/theme/series_palette.dart';
import 'package:time_keeper/widgets/tone_chip.dart';

/// Fixed slots so a role keeps the same hue everywhere it appears, rather than
/// one that shifts with its position in a list. Slot 0 is skipped - it is the
/// same blue as `primary`, which is already all over the surrounding chrome.
const Map<String, int> _roleSlots = {
  'admin': 3,
  'kiosk': 5,
};

/// Anything added later still gets a stable colour, just not a curated one.
int _slotFor(Role role) => _roleSlots[role.name] ?? (role.name.hashCode.abs() % (seriesColorCount - 1)) + 1;

class RoleChip extends StatelessWidget {
  final Role role;

  const RoleChip({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return ToneChip(color: seriesColorOf(context, _slotFor(role)), label: role.label);
  }
}

/// The role list for one user. These are login roles, not team membership -
/// student/mentor live on `team_members` and never have an account here.
///
/// A user with no roles can sign in but do nothing, which is worth saying
/// outright rather than showing an empty cell.
class RoleChips extends StatelessWidget {
  final List<Role> roles;

  const RoleChips({super.key, required this.roles});

  @override
  Widget build(BuildContext context) {
    if (roles.isEmpty) {
      return Text(
        'No access',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: roles.map((r) => RoleChip(role: r)).toList(),
    );
  }
}
