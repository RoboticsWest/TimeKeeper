import 'package:flutter/material.dart';
import 'package:time_keeper/models/session.dart';
import 'package:time_keeper/colors.dart';

enum SessionStatus { current, overtime, upcoming, finished }

SessionStatus getSessionStatus(Session session) {
  if (session.finished) return SessionStatus.finished;

  final now = DateTime.now();
  final start = session.startTime;
  final end = session.endTime;

  if (now.isBefore(start)) return SessionStatus.upcoming;
  if (now.isAfter(end)) return SessionStatus.overtime;
  return SessionStatus.current;
}

/// Status colors come from the reserved support palette, never the categorical
/// series palette — "overtime" must not be mistakable for "series 4".
Color statusColor(SessionStatus status) {
  switch (status) {
    case SessionStatus.current:
      return supportSuccessColor.shade700;
    case SessionStatus.overtime:
      return supportErrorColor;
    case SessionStatus.upcoming:
      return supportInfoColor;
    case SessionStatus.finished:
      return neutralColor.shade400;
  }
}

String statusLabel(SessionStatus status) {
  switch (status) {
    case SessionStatus.current:
      return 'Current';
    case SessionStatus.overtime:
      return 'OVERTIME';
    case SessionStatus.upcoming:
      return 'Upcoming';
    case SessionStatus.finished:
      return 'Finished';
  }
}

/// Newest scheduled start first, with the id breaking ties.
///
/// The same total order the server's `sessionPage` uses, so a list built in Dart and a list paged
/// from SQL cannot disagree about what "newest first" means — they did, which is why switching the
/// Sessions view between calendar and table looked like it reshuffled the rows.
int compareSessionEntriesNewestFirst(MapEntry<String, Session> a, MapEntry<String, Session> b) {
  final byStart = b.value.startTime.compareTo(a.value.startTime);
  return byStart != 0 ? byStart : b.key.compareTo(a.key);
}

/// Picker order: current/overtime first, then upcoming (soonest first), then finished (newest
/// first).
///
/// For *choosing* a session — the Attendance and Notifications dropdowns — rather than for
/// reading a list; what is happening now is what the operator is nearly always reaching for. Use
/// [compareSessionEntriesNewestFirst] for anything that renders as a list of rows.
int compareSessionEntries(MapEntry<String, Session> a, MapEntry<String, Session> b) {
  final aStatus = getSessionStatus(a.value);
  final bStatus = getSessionStatus(b.value);

  const order = {
    SessionStatus.current: 0,
    SessionStatus.overtime: 0,
    SessionStatus.upcoming: 1,
    SessionStatus.finished: 2,
  };

  final statusCmp = order[aStatus]!.compareTo(order[bStatus]!);
  if (statusCmp != 0) return statusCmp;

  final aTime = a.value.startTime;
  final bTime = b.value.startTime;

  // Upcoming: soonest first. Current/Overtime/Finished: newest first.
  if (aStatus == SessionStatus.upcoming) {
    return aTime.compareTo(bTime);
  }
  return bTime.compareTo(aTime);
}
