import 'package:flutter/material.dart';
import 'package:time_keeper/generated/common/common.pbenum.dart';

class RoleChip extends StatelessWidget {
  final Role role;

  const RoleChip({super.key, required this.role});

  Color _roleColor(ColorScheme scheme) {
    switch (role) {
      case Role.ADMIN:
        return scheme.error;
      case Role.KIOSK:
        return scheme.tertiary;
      case Role.STUDENT:
        return scheme.primary;
      case Role.MENTOR:
        return scheme.secondary;
      default:
        return scheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _roleColor(Theme.of(context).colorScheme);
    return Chip(
      label: Text(role.name, style: TextStyle(color: color, fontSize: 12)),
      side: BorderSide(color: color),
      backgroundColor: color.withValues(alpha: 0.1),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}
