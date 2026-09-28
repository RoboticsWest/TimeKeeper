import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/location.dart';
import 'package:time_keeper/models/session.dart';
import 'package:time_keeper/models/team_member.dart';
import 'package:time_keeper/models/team_member_session.dart';
import 'package:time_keeper/helpers/session_helper.dart';
import 'package:time_keeper/hooks/use_debounced_text.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/rfid_tag_provider.dart';
import 'package:time_keeper/providers/session_provider.dart' show sessionsProvider, sessionsSyncProvider;
import 'package:time_keeper/providers/team_member_page_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/providers/team_member_session_provider.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/views/team/check_in_dialog.dart';
import 'package:time_keeper/views/team/check_in_out_button.dart';
import 'package:time_keeper/views/team/member_type_chip.dart';
import 'package:time_keeper/views/team/team_member_dialog.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';
import 'package:time_keeper/widgets/tables/base_table.dart';
import 'package:time_keeper/widgets/tables/edit_table.dart';
import 'package:time_keeper/widgets/tables/header_text.dart';
import 'package:time_keeper/widgets/tables/no_rows_notice.dart';
import 'package:time_keeper/widgets/tables/pagination_bar.dart';
import 'package:time_keeper/widgets/tables/table_filter.dart';
import 'package:time_keeper/colors.dart';

class TeamView extends HookConsumerWidget {
  const TeamView({super.key});

  void _showClearDialog(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String description,
    required List<String> ids,
  }) {
    if (ids.isEmpty) {
      SnackBarDialog.info(message: 'No members to delete').show(context);
      return;
    }

    ConfirmDialog.warn(
      title: title,
      message: Text(
        'Are you sure you want to delete $description? '
        '(${ids.length} ${ids.length == 1 ? 'member' : 'members'})',
      ),
      confirmText: 'Delete',
      onConfirmAsync: () async {
        final notifier = ref.read(teamMembersProvider.notifier);
        for (final id in ids) {
          await notifier.delete(id);
        }
      },
      showResultDialog: true,
      successMessage: Text('Deleted ${ids.length} members'),
    ).show(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(teamMembersSyncProvider);
    ref.watch(teamMemberSessionsSyncProvider);
    ref.watch(sessionsSyncProvider);
    ref.watch(locationsSyncProvider);
    final teamMembers = ref.watch(teamMembersProvider);
    final teamMemberSessions = ref.watch(teamMemberSessionsProvider);
    // Only used to name the session a checkout would close.
    final sessions = ref.watch(sessionsProvider);
    final locations = ref.watch(locationsProvider);
    final theme = Theme.of(context);

    // The roster itself is paged server-side.
    final page = ref.watch(teamMemberPageProvider);
    final notifier = ref.read(teamMemberPageProvider.notifier);
    final currentPage = page.value;

    // --- Filter state ---------------------------------------------------------------
    final filterController = useTextEditingController();
    final search = useDebouncedText(filterController);
    final memberType = useState('all');
    final discord = useState(DiscordLinkFilter.all);

    // Push every filter change to the paged provider, restarting at page one. The search term
    // comes from `useDebouncedText`, which subscribes to the controller — keying this effect on
    // `filterController.text` directly looks right but never fires, because a `TextField` writing
    // to its controller does not rebuild this widget.
    useEffect(() {
      notifier.setFilter(
        TeamMemberFilterState(
          search: search.value,
          memberTypes: memberType.value == 'all' ? const [] : [memberType.value],
          discord: discord.value,
        ),
      );
      return null;
    }, [search.value, memberType.value, discord.value]);

    final refreshing = useState(false);
    Future<void> refreshMembers() async {
      refreshing.value = true;
      await notifier.refresh();
      refreshing.value = false;
    }

    final hasActiveFilters =
        search.value.trim().isNotEmpty || memberType.value != 'all' || discord.value != DiscordLinkFilter.all;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Team Members', style: theme.textTheme.headlineMedium),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ClearButton(
                    label: 'Clear Students',
                    icon: Icons.school,
                    color: supportWarningColor.shade700,
                    onPressed: () => _showClearDialog(
                      context,
                      ref,
                      title: 'Clear Students',
                      description: 'all students',
                      ids: teamMembers.entries
                          .where((e) => e.value.memberType == TeamMemberType.student)
                          .map((e) => e.key)
                          .toList(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ClearButton(
                    label: 'Clear Mentors',
                    icon: Icons.person,
                    color: supportWarningColor.shade700,
                    onPressed: () => _showClearDialog(
                      context,
                      ref,
                      title: 'Clear Mentors',
                      description: 'all mentors',
                      ids: teamMembers.entries
                          .where((e) => e.value.memberType == TeamMemberType.mentor)
                          .map((e) => e.key)
                          .toList(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ClearButton(
                    label: 'Clear All',
                    icon: Icons.delete_sweep,
                    color: theme.colorScheme.error,
                    onPressed: () => _showClearDialog(
                      context,
                      ref,
                      title: 'Clear All Members',
                      description: 'all team members',
                      ids: teamMembers.keys.toList(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Refresh team members',
                    onPressed: refreshing.value ? null : refreshMembers,
                    icon: refreshing.value
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'all', label: Text('All')),
                  ButtonSegment(value: 'student', label: Text('Students')),
                  ButtonSegment(value: 'mentor', label: Text('Mentors')),
                ],
                selected: {memberType.value},
                onSelectionChanged: (value) => memberType.value = value.first,
              ),
              SegmentedButton<DiscordLinkFilter>(
                segments: const [
                  ButtonSegment(value: DiscordLinkFilter.all, label: Text('All links')),
                  ButtonSegment(value: DiscordLinkFilter.linked, label: Text('Linked')),
                  ButtonSegment(value: DiscordLinkFilter.unlinked, label: Text('Unlinked')),
                ],
                selected: {discord.value},
                onSelectionChanged: (value) => discord.value = value.first,
              ),
              if (hasActiveFilters)
                IconButton(
                  onPressed: () {
                    filterController.clear();
                    search.submit();
                    memberType.value = 'all';
                    discord.value = DiscordLinkFilter.all;
                  },
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear filters',
                ),
            ],
          ),
          const SizedBox(height: 12),
          TableFilter(
            controller: filterController,
            hintText: 'Search by first, last or display name...',
            onSubmitted: search.submit,
            isPending: search.isPending,
            matchCount: currentPage?.totalCount,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: currentPage == null
                ? _LoadingOrError(page: page, onRetry: notifier.refresh)
                : EditTable(
                    alternatingRows: true,
                    headers: [
                      BaseTableCell(child: TableHeaderText('First Name'), flex: 2),
                      BaseTableCell(child: TableHeaderText('Last Name'), flex: 2),
                      BaseTableCell(child: TableHeaderText('Type'), flex: 1),
                      BaseTableCell(child: TableHeaderText('Display Name'), flex: 3),
                      BaseTableCell(child: TableHeaderText('RFID Tags'), flex: 1),
                      BaseTableCell(child: TableHeaderText('Discord'), flex: 2),
                      BaseTableCell(child: TableHeaderText('PIN'), flex: 1),
                      BaseTableCell(child: TableHeaderText('Attendance'), flex: 1),
                    ],
                    headerDecoration: tableHeaderDecoration(context),
                    editRows: currentPage.items.map((member) {
                      final id = member.id;
                      final checkedIn = isMemberCheckedIn(id, teamMemberSessions.values);
                      final memberLabel = member.displayLabel;
                      final memberTags = ref.watch(rfidTagsByMemberProvider(id));
                      final tagDisplay = memberTags.isEmpty ? '—' : memberTags.values.map((t) => t.tag).join(', ');

                      return EditTableRow(
                        key: ValueKey(id),
                        onEdit: () => showTeamMemberDialog(
                          context,
                          ref,
                          id: id,
                          existingFirstName: member.firstName,
                          existingLastName: member.lastName,
                          existingMemberType: member.memberType,
                          existingDisplayName: member.displayName,
                          existingDiscordId: member.discordId,
                          existingQuickPin: member.quickPin,
                        ),
                        onDelete: () => showDeleteTeamMemberDialog(context, ref, id: id, name: memberLabel),
                        cells: [
                          BaseTableCell(child: Text(member.firstName), flex: 2),
                          BaseTableCell(child: Text(member.lastName), flex: 2),
                          BaseTableCell(child: MemberTypeChip(memberType: member.memberType), flex: 1),
                          BaseTableCell(child: Text(member.displayName ?? '—'), flex: 3),
                          BaseTableCell(child: Text(tagDisplay), flex: 1),
                          BaseTableCell(child: Text(member.discordId ?? '—'), flex: 2),
                          BaseTableCell(child: Text(member.quickPin ?? '—'), flex: 1),
                          BaseTableCell(
                            child: CheckInOutButton(
                              checkedIn: checkedIn,
                              // Checking in asks where; checking out only confirms, because the
                              // open visit already knows which session it belongs to.
                              onPressed: () => checkedIn
                                  ? showCheckOutDialog(
                                      context,
                                      ref,
                                      memberId: id,
                                      memberName: memberLabel,
                                      whereLabel: _openVisitLabel(id, teamMemberSessions, sessions, locations),
                                    )
                                  : showCheckInDialog(context, ref, memberId: id, memberName: memberLabel),
                            ),
                            flex: 1,
                          ),
                        ],
                      );
                    }).toList(),
                    onAdd: () => showTeamMemberDialog(context, ref),
                  ),
          ),
          if (currentPage != null && currentPage.items.isEmpty)
            NoRowsNotice(
              noun: 'team members',
              filtered: hasActiveFilters,
              onClearFilters: () {
                filterController.clear();
                search.submit();
                memberType.value = 'all';
                discord.value = DiscordLinkFilter.all;
              },
            ),
          if (currentPage != null)
            PaginationBar(
              totalCount: currentPage.totalCount,
              offset: currentPage.offset,
              pageSize: notifier.currentPageSize,
              hasMore: currentPage.hasMore,
              onPageSizeChanged: notifier.setPageSize,
              onPrevious: notifier.previousPage,
              onNext: notifier.nextPage,
              onFirst: notifier.firstPage,
              onLast: notifier.lastPage,
            ),
        ],
      ),
    );
  }
}

/// Names the session a checkout would close ("the Machine Shop session (6:00 PM – 9:00 PM)"), so
/// the confirmation says what is about to happen rather than just "check out".
String _openVisitLabel(
  String memberId,
  Map<String, TeamMemberSession> teamMemberSessions,
  Map<String, Session> sessions,
  Map<String, Location> locations,
) {
  final visit = openVisitOf(memberId, teamMemberSessions);
  final session = visit == null ? null : sessions[visit.value.sessionId];
  if (session == null) return 'their current session';

  final location = locations[session.locationId]?.location;
  final times = '${formatTime(session.startTime)} \u2013 ${formatTime(session.endTime)}';
  return location == null ? 'their session ($times)' : 'the $location session ($times)';
}

/// Replaces the table area while a fresh page is loading or has failed.
class _LoadingOrError<T> extends StatelessWidget {
  final AsyncValue<T> page;
  final Future<void> Function() onRetry;

  const _LoadingOrError({required this.page, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (page.hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Could not load team members', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}

class _ClearButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ClearButton({required this.label, required this.icon, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(side: BorderSide(color: color)),
    );
  }
}
