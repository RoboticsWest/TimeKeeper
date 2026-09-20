import 'package:flutter/material.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/widgets/time_until.dart';
import 'package:time_keeper/models/location.dart';
import 'package:time_keeper/models/session.dart';
import 'package:time_keeper/shapes.dart';

class SessionInfoBar extends StatelessWidget {
  final Session? currentSession;
  final bool isUpcoming;
  final Session? nextSession;
  final Map<String, Location> locations;
  final String? deviceLocationName;
  final int checkedInCount;
  final int rsvpGoingCount;
  final int rsvpNotGoingCount;
  final int uniqueSeenCount;

  const SessionInfoBar({
    super.key,
    this.currentSession,
    this.isUpcoming = false,
    this.nextSession,
    this.locations = const {},
    this.deviceLocationName,
    this.checkedInCount = 0,
    this.rsvpGoingCount = 0,
    this.rsvpNotGoingCount = 0,
    this.uniqueSeenCount = 0,
  });

  String _locationName(Session session) {
    return locations[session.locationId]?.location ?? '';
  }

  bool get hasRsvps => rsvpGoingCount + rsvpNotGoingCount > 0;

  /// The attendance denominator: the RSVP "going" count, raised by however many
  /// distinct people have actually shown up so far (a session can exceed its
  /// RSVPs). 0 until there is any expectation at all.
  int get expected => rsvpGoingCount > uniqueSeenCount ? rsvpGoingCount : uniqueSeenCount;

  Widget _statIcon(ThemeData theme, Color color, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      child: Row(
        children: [
          // Current / upcoming session
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: currentSession != null && !isUpcoming
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(kRadiusRow),
                border: currentSession == null || isUpcoming
                    ? Border.all(color: theme.colorScheme.outlineVariant, width: 1)
                    : null,
              ),
              child: currentSession != null
                  ? (isUpcoming ? _buildUpcomingSession(theme) : _buildCurrentSession(theme))
                  : _buildNoSession(theme),
            ),
          ),

          const SizedBox(width: 12),

          // Next session
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(kRadiusRow),
                border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
              ),
              child: nextSession != null ? _buildNextSession(theme) : _buildNoUpcoming(theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSession(ThemeData theme) {
    final color = theme.colorScheme.onPrimaryContainer;
    final session = currentSession!;
    final start = session.startTime;
    final end = session.endTime;
    final location = _locationName(session);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.play_circle_filled, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              'Current Session',
              style: theme.textTheme.labelLarge?.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
            if (location.isNotEmpty) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '— $location',
                  style: theme.textTheme.labelMedium?.copyWith(color: color.withValues(alpha: 0.7)),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ] else
              const Spacer(),
            const SizedBox(width: 8),
            Flexible(
              child: TimeUntil(
                time: end,
                positiveLeader: 'Ends in ',
                positiveStyle: theme.textTheme.labelLarge?.copyWith(color: color, fontWeight: FontWeight.bold),
                negativeLeader: 'OVERTIME ',
                negativeStyle: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Flexible(
              child: Text(
                '${formatDate(start)}  ${formatTime(start)} - ${formatTime(end)}',
                style: theme.textTheme.bodySmall?.copyWith(color: color.withValues(alpha: 0.7)),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    // Present now / expected: starts at the RSVP "going" count and
                    // is raised by however many distinct people actually show up,
                    // so it reads 0/5 before the session and 8/12 once 12 unique
                    // people have turned up. The numerator is who is here right now.
                    _statIcon(
                      theme,
                      color,
                      Icons.people,
                      expected > 0 ? '$checkedInCount / $expected' : '$checkedInCount',
                    ),
                    if (hasRsvps)
                      _statIcon(theme, color, Icons.event_available, '$rsvpGoingCount'),
                    if (rsvpNotGoingCount > 0)
                      _statIcon(theme, color, Icons.event_busy, '$rsvpNotGoingCount'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpcomingSession(ThemeData theme) {
    final color = theme.colorScheme.onSurfaceVariant;
    final session = currentSession!;
    final start = session.startTime;
    final end = session.endTime;
    final location = _locationName(session);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.schedule, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              'Upcoming Session',
              style: theme.textTheme.labelLarge?.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
            if (location.isNotEmpty) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '— $location',
                  style: theme.textTheme.labelMedium?.copyWith(color: color.withValues(alpha: 0.7)),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ] else
              const Spacer(),
            const SizedBox(width: 8),
            Flexible(
              child: TimeUntil(
                time: start,
                positiveLeader: 'Starts in ',
                positiveStyle: theme.textTheme.labelLarge?.copyWith(color: color, fontWeight: FontWeight.bold),
                negativeLeader: '',
                negativeStyle: theme.textTheme.labelLarge?.copyWith(color: color, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${formatDate(start)}  ${formatTime(start)} - ${formatTime(end)}',
          style: theme.textTheme.bodySmall?.copyWith(color: color.withValues(alpha: 0.7)),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildNoSession(ThemeData theme) {
    final color = theme.colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(Icons.pause_circle_filled, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            deviceLocationName != null ? 'No Active Session — $deviceLocationName' : 'No Active Session',
            style: theme.textTheme.labelLarge?.copyWith(color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildNextSession(ThemeData theme) {
    final color = theme.colorScheme.onSurfaceVariant;
    final session = nextSession!;
    final start = session.startTime;
    final end = session.endTime;
    final location = _locationName(session);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.skip_next, color: color, size: 18),
            const SizedBox(width: 8),
            Text('Next', style: theme.textTheme.labelLarge?.copyWith(color: color)),
            if (location.isNotEmpty) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '— $location',
                  style: theme.textTheme.labelMedium?.copyWith(color: color.withValues(alpha: 0.7)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${formatDate(start)}  ${formatTime(start)} - ${formatTime(end)}',
          style: theme.textTheme.bodySmall?.copyWith(color: color.withValues(alpha: 0.7)),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildNoUpcoming(ThemeData theme) {
    final color = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
    return Row(
      children: [
        Icon(Icons.skip_next, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            deviceLocationName != null ? 'No Upcoming Sessions — $deviceLocationName' : 'No Upcoming Sessions',
            style: theme.textTheme.labelLarge?.copyWith(color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
