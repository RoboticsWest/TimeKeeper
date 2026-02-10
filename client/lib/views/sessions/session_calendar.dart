import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/models/session_status.dart';
import 'package:time_keeper/utils/time.dart';

class SessionCalendar extends HookWidget {
  final Map<String, Session> sessions;
  final DateTime? selectedDate;
  final void Function(DateTime date) onDateSelected;

  const SessionCalendar({
    super.key,
    required this.sessions,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final focusedDay = useState(selectedDate ?? now);

    // Build event map: normalized date -> list of sessions
    final eventMap = <DateTime, List<Session>>{};
    for (final session in sessions.values) {
      final dt = session.startTime.toDateTime();
      final key = DateTime(dt.year, dt.month, dt.day);
      eventMap.putIfAbsent(key, () => []).add(session);
    }

    List<Session> getEventsForDay(DateTime day) {
      final key = DateTime(day.year, day.month, day.day);
      return eventMap[key] ?? [];
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TableCalendar<Session>(
        firstDay: DateTime(2020),
        lastDay: DateTime(2030),
        focusedDay: focusedDay.value,
        selectedDayPredicate: (day) =>
            selectedDate != null && isSameDay(selectedDate, day),
        eventLoader: getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        onDaySelected: (selected, focused) {
          focusedDay.value = focused;
          onDateSelected(selected);
        },
        onPageChanged: (focused) {
          focusedDay.value = focused;
        },

        // Styling
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: theme.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: theme.colorScheme.onSurface,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurface,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: theme.textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          weekendStyle: theme.textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          todayDecoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
          selectedDecoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
          markersMaxCount: 3,
          markerSize: 6,
          markersAlignment: Alignment.bottomCenter,
          markerMargin: const EdgeInsets.symmetric(horizontal: 1),
        ),

        // Custom marker builder for session status colors
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return null;
            return Positioned(
              bottom: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: events.take(3).map((session) {
                  final status = getSessionStatus(session);
                  return Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: statusColor(status),
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}
