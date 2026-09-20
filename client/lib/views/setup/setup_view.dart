import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/shapes.dart';
import 'package:time_keeper/theme/series_palette.dart';
import 'package:time_keeper/views/setup/branding_setup.dart';
import 'package:time_keeper/views/setup/data_setup.dart';
import 'package:time_keeper/views/setup/database_setup.dart';
import 'package:time_keeper/views/setup/integrations_setup.dart';
import 'package:time_keeper/views/setup/member_setup.dart';
import 'package:time_keeper/views/setup/session_setup.dart';
import 'package:time_keeper/views/setup/system_setup.dart';

/// One entry in the Setup section list.
class _Section {
  final String label;
  final IconData icon;

  /// Slot in the categorical palette, matching the rail's convention of a fixed
  /// per-destination color. Slot 0 (blue) is skipped — it collides with primary,
  /// which paints the selected row.
  final int colorSlot;
  final Widget Function() build;

  const _Section({required this.label, required this.icon, required this.colorSlot, required this.build});
}

/// Server configuration.
///
/// A two-pane layout rather than the previous six-tab TabBar: six full-width
/// tabs read as a toolbar rather than navigation, and a vertical list has room
/// for each section's icon and leaves the content pane a stable width.
class SetupView extends HookConsumerWidget {
  const SetupView({super.key});

  static const double _sectionListWidth = 200;

  static final List<_Section> _sections = [
    _Section(label: 'Sessions', icon: Icons.event_note, colorSlot: 1, build: SessionSetupTab.new),
    _Section(label: 'Team Members', icon: Icons.supervised_user_circle, colorSlot: 2, build: MemberSetupTab.new),
    _Section(label: 'Branding', icon: Icons.palette, colorSlot: 4, build: BrandingSetupTab.new),
    _Section(label: 'Integrations', icon: Icons.hub, colorSlot: 6, build: IntegrationsSetupTab.new),
    _Section(label: 'Data', icon: Icons.table_chart, colorSlot: 3, build: DataSetupTab.new),
    _Section(label: 'Database', icon: Icons.storage, colorSlot: 7, build: DatabaseSetupTab.new),
    _Section(label: 'System', icon: Icons.build_circle, colorSlot: 5, build: SystemSetupTab.new),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selected = useState(0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: _sectionListWidth,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            border: Border(right: BorderSide(color: theme.dividerColor)),
          ),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              for (var i = 0; i < _sections.length; i++)
                _SectionTile(section: _sections[i], isSelected: selected.value == i, onTap: () => selected.value = i),
            ],
          ),
        ),
        Expanded(child: _sections[selected.value].build()),
      ],
    );
  }
}

class _SectionTile extends StatelessWidget {
  final _Section section;
  final bool isSelected;
  final VoidCallback onTap;

  const _SectionTile({required this.section, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
        borderRadius: kBorderRadiusRow,
        child: InkWell(
          borderRadius: kBorderRadiusRow,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                Icon(section.icon, size: 20, color: seriesColor(section.colorSlot, Theme.of(context).brightness)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    section.label,
                    style: TextStyle(
                      color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
