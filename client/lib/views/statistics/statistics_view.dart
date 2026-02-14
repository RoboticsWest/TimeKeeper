import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/providers/entity_sync_provider.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/providers/team_member_session_provider.dart';
import 'package:time_keeper/views/statistics/statistics_attendance_chart.dart';
import 'package:time_keeper/views/statistics/statistics_day_detail.dart';
import 'package:time_keeper/views/statistics/statistics_helpers.dart';
import 'package:time_keeper/views/statistics/statistics_hours_chart.dart';
import 'package:time_keeper/views/statistics/statistics_location_chart.dart';
import 'package:time_keeper/views/statistics/statistics_member_hours_table.dart';
import 'package:time_keeper/views/statistics/statistics_overview_cards.dart';
import 'package:time_keeper/views/statistics/statistics_overtime_table.dart';

class StatisticsView extends HookConsumerWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(entitySyncProvider);
    final sessions = ref.watch(sessionsProvider);
    final teamMembers = ref.watch(teamMembersProvider);
    final locations = ref.watch(locationsProvider);
    final teamMemberSessions = ref.watch(teamMemberSessionsProvider);
    final theme = Theme.of(context);

    final selectedRange = useState(StatisticsRange.week);
    final selectedDay = useState<DateTime?>(null);

    final filtered = filterSessionsByRange(sessions, selectedRange.value);
    final memberHours = computeMemberHours(
      filtered,
      teamMembers,
      teamMemberSessions,
    );
    final dailyHours = computeDailyHours(filtered, teamMemberSessions);
    final dailyAttendance = computeDailyAttendance(teamMemberSessions);
    final locationAttendance = computeLocationAttendance(
      filtered,
      locations,
      teamMemberSessions,
    );
    final insights = computeInsights(filtered, locations, teamMemberSessions);

    final dayMemberDetails = selectedDay.value != null
        ? computeDayMemberDetails(
            selectedDay.value!,
            filtered,
            teamMembers,
            teamMemberSessions,
          )
        : <DayMemberDetail>[];

    void onDaySelected(DateTime? day) {
      selectedDay.value = day;
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.analytics, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Statistics Dashboard',
                style: theme.textTheme.headlineMedium,
              ),
              const Spacer(),
              SegmentedButton<StatisticsRange>(
                segments: StatisticsRange.values
                    .map(
                      (r) => ButtonSegment(
                        value: r,
                        label: Text(statisticsRangeLabel(r)),
                      ),
                    )
                    .toList(),
                selected: {selectedRange.value},
                onSelectionChanged: (value) {
                  selectedRange.value = value.first;
                  selectedDay.value = null;
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview cards
                  StatisticsOverviewCards(
                    filteredSessions: filtered,
                    teamMemberSessions: teamMemberSessions,
                    memberHours: memberHours,
                    insights: insights,
                  ),
                  const SizedBox(height: 24),

                  // Charts row: Hours per Day + Location pie
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: StatisticsHoursChart(
                          dailyHours: dailyHours,
                          selectedDay: selectedDay.value,
                          onDaySelected: onDaySelected,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: StatisticsLocationChart(
                          locationData: locationAttendance,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // People per day chart
                  StatisticsAttendanceChart(
                    dailyAttendance: dailyAttendance,
                    selectedDay: selectedDay.value,
                    onDaySelected: onDaySelected,
                  ),
                  const SizedBox(height: 16),

                  // Day detail panel (shown when a day is selected)
                  if (selectedDay.value != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: StatisticsDayDetail(
                        selectedDay: selectedDay.value!,
                        members: dayMemberDetails,
                        onClose: () => selectedDay.value = null,
                      ),
                    ),

                  // Attendance insights
                  AttendanceInsightsCards(insights: insights),
                  const SizedBox(height: 24),

                  // Overtime flags table
                  StatisticsOvertimeTable(memberHours: memberHours),
                  const SizedBox(height: 24),

                  // Member hours table
                  StatisticsMemberHoursTable(memberHours: memberHours),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
