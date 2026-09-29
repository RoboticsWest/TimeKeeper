import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/providers/team_member_session_provider.dart';

part 'aggregate_revision_provider.g.dart';

/// How long the data has to stay quiet before the aggregates are recomputed.
///
/// Long enough that a bulk operation — a CSV import, a "Clear All", a room full of members
/// tagging in at the start of a session — lands as one recomputation rather than thousands.
const _quietPeriod = Duration(seconds: 2);

/// A counter that advances when the data behind the *server-computed* aggregates changes.
///
/// The leaderboard and the achievements board are recomputed server-side from the whole
/// attendance history, so they cannot be patched from a change delta the way an id-keyed
/// collection can — any change invalidates the whole answer. They used to express that by
/// watching the collection providers themselves, which was wrong twice over:
///
///   * A collection's state changes when its *initial fetch lands*, not only when the data
///     changes. Watching three of them meant the aggregate query fired once immediately and then
///     again as each collection arrived — four full recomputations of the same answer on every
///     visit to the page, each one a multi-table pass on the server. Under that load the last of
///     them could exceed the pool's connection timeout, and the error surfaced as an empty list:
///     "No team members yet" on a page that had just spent thirty seconds loading.
///   * Every realtime delta also changes that state, so a burst of them meant one full
///     recomputation per row touched.
///
/// Watching the change *streams* instead fixes the first (a query landing is not a change event)
/// and debouncing fixes the second.
@Riverpod(keepAlive: true)
class AggregateRevision extends _$AggregateRevision {
  Timer? _debounce;

  @override
  int build() {
    void bump(Object? previous, Object? next) {
      _debounce?.cancel();
      _debounce = Timer(_quietPeriod, () => state++);
    }

    // The three tables every server-side aggregate is derived from. Locations are deliberately
    // absent: renaming one changes no hours and no badges.
    ref.listen(teamMemberSessionChangesProvider, bump);
    ref.listen(teamMemberChangesProvider, bump);
    ref.listen(sessionChangesProvider, bump);

    ref.onDispose(() => _debounce?.cancel());
    return 0;
  }
}
