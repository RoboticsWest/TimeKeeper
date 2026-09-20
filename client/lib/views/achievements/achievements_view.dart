import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/accolades.dart';
import 'package:time_keeper/providers/accolades_provider.dart';
import 'package:time_keeper/shapes.dart';
import 'package:time_keeper/theme/series_palette.dart';
import 'package:time_keeper/views/achievements/achievement_badge.dart';
import 'package:time_keeper/views/team/member_type_chip.dart';
import 'package:time_keeper/widgets/dashboard/panel.dart';

/// Titles and achievements for the whole team.
///
/// Kept as its own page rather than folded into the team table on purpose: the roster is a
/// working tool for adding and editing people, and hanging sixty-seven badges off its rows
/// would bury the columns that make it useful. Here the whole catalogue is the subject, and a
/// member is chosen to view it through.
///
/// Nothing on this page is stored. Titles and achievements are derived from attendance every
/// time they are asked for, which is why a badge can appear the moment somebody earns it
/// without anything having to be written, backfilled or announced.
class AchievementsView extends HookConsumerWidget {
  const AchievementsView({super.key});

  /// Below this the member list and the board stack instead of sitting side by side.
  static const double _wide = 1000;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accolades = ref.watch(memberAccoladesProvider);
    final selectedId = useState<String?>(null);

    return accolades.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Failed to load achievements: $error')),
      data: (members) {
        if (members.isEmpty) {
          return const Center(child: Text('No team members yet.'));
        }

        // Default to the most decorated member, so the page opens on a full board rather than an
        // empty prompt. `firstWhere` guards a selection whose member has since been deleted.
        final selected = members.firstWhere((m) => m.teamMemberId == selectedId.value, orElse: () => members.first);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final memberList = _MemberList(
                members: members,
                selectedId: selected.teamMemberId,
                onSelect: (id) => selectedId.value = id,
              );
              final board = _MemberBoard(member: selected);

              if (constraints.maxWidth < _wide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 220, child: memberList),
                    const SizedBox(height: 16),
                    Expanded(child: board),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(width: 340, child: memberList),
                  const SizedBox(width: 16),
                  Expanded(child: board),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

/// The roster, ranked by how much of the catalogue each member holds.
class _MemberList extends StatelessWidget {
  final List<MemberAccolades> members;
  final String selectedId;
  final ValueChanged<String> onSelect;

  const _MemberList({required this.members, required this.selectedId, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return DashboardPanel(
      title: 'Team',
      subtitle: '${members.length} members',
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: members.length,
        itemBuilder: (context, i) => _MemberTile(
          member: members[i],
          selected: members[i].teamMemberId == selectedId,
          onTap: () => onSelect(members[i].teamMemberId),
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final MemberAccolades member;
  final bool selected;
  final VoidCallback onTap;

  const _MemberTile({required this.member, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: kBorderRadiusRow,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary.withValues(alpha: 0.10) : null,
          borderRadius: kBorderRadiusRow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    member.name,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${member.earnedCount}/${member.totalCount}',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                MemberTypeChip(memberType: member.memberType),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    member.title,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: member.completion,
                minHeight: 4,
                backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One member's title and their whole board — earned first, then what is left to get.
class _MemberBoard extends StatelessWidget {
  final MemberAccolades member;

  const _MemberBoard({required this.member});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final earned = member.earned;
    final locked = member.locked;
    final secretCount = member.secretCount;

    return DashboardPanel(
      title: member.name,
      subtitle: '${member.earnedCount} of ${member.totalCount} unlocked',
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _TitleCard(member: member),
          const SizedBox(height: 20),
          _SectionHeading(label: 'Unlocked', count: earned.length),
          const SizedBox(height: 10),
          if (earned.isEmpty)
            Text(
              'Nothing yet. The first check-in earns one.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            )
          else
            _BadgeWrap(achievements: earned),
          const SizedBox(height: 24),
          _SectionHeading(label: 'Still to get', count: locked.length),
          const SizedBox(height: 10),
          _BadgeWrap(achievements: locked),
          if (secretCount > 0) ...[
            const SizedBox(height: 12),
            Text(
              '…and $secretCount kept secret until earned.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The member's title, given the weight of a headline — it is the one line of this page that is
/// about the person rather than the collection.
class _TitleCard extends StatelessWidget {
  final MemberAccolades member;

  const _TitleCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: theme.brightness == Brightness.dark ? 0.14 : 0.08),
        borderRadius: kBorderRadiusCard,
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(member.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            member.titleReason,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String label;
  final int count;

  const _SectionHeading({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Text('$count', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _BadgeWrap extends StatelessWidget {
  final List<Achievement> achievements;

  const _BadgeWrap({required this.achievements});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < achievements.length; i++)
          AchievementBadge(
            achievement: achievements[i],
            // Cycling the categorical palette gives the board variety without assigning meaning
            // to any one hue — the colour here says "earned", not "this kind of achievement".
            color: seriesColorOf(context, i),
          ),
      ],
    );
  }
}
