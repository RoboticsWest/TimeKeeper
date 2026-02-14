import 'package:flutter/material.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/utils/time.dart';
import 'package:time_keeper/widgets/time_until.dart';

class SessionInfoBar extends StatelessWidget {
  final Session? currentSession;
  final Session? nextSession;
  final Map<String, Location> locations;
  final String? deviceLocationName;
  final int checkedInCount;
  final int totalMembers;

  const SessionInfoBar({
    super.key,
    this.currentSession,
    this.nextSession,
    this.locations = const {},
    this.deviceLocationName,
    this.checkedInCount = 0,
    this.totalMembers = 0,
  });

  String _locationName(Session session) {
    return locations[session.locationId]?.location ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      child: Row(
        children: [
          // Current session
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: currentSession != null
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: currentSession != null
                  ? _buildCurrentSession(theme)
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
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              child: nextSession != null
                  ? _buildNextSession(theme)
                  : _buildNoUpcoming(theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSession(ThemeData theme) {
    final color = theme.colorScheme.onPrimaryContainer;
    final session = currentSession!;
    final start = session.startTime.toDateTime();
    final end = session.endTime.toDateTime();
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
              style: theme.textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (location.isNotEmpty) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '— $location',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: color.withValues(alpha: 0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ] else
              const Spacer(),
            TimeUntil(
              time: end,
              positiveLeader: '',
              positiveStyle: theme.textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              negativeLeader: 'OVERTIME ',
              negativeStyle: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              '${formatDate(start)}  ${formatTime(start)} - ${formatTime(end)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: color.withValues(alpha: 0.7),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 12),
            Icon(Icons.people, size: 14, color: color.withValues(alpha: 0.7)),
            const SizedBox(width: 4),
            Text(
              '$checkedInCount / $totalMembers',
              style: theme.textTheme.bodySmall?.copyWith(
                color: color.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
            deviceLocationName != null
                ? 'No Active Session — $deviceLocationName'
                : 'No Active Session',
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
    final start = session.startTime.toDateTime();
    final end = session.endTime.toDateTime();
    final location = _locationName(session);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.skip_next, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              'Next',
              style: theme.textTheme.labelLarge?.copyWith(color: color),
            ),
            if (location.isNotEmpty) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '— $location',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: color.withValues(alpha: 0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${formatDate(start)}  ${formatTime(start)} - ${formatTime(end)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: color.withValues(alpha: 0.7),
          ),
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
            deviceLocationName != null
                ? 'No Upcoming Sessions — $deviceLocationName'
                : 'No Upcoming Sessions',
            style: theme.textTheme.labelLarge?.copyWith(color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
