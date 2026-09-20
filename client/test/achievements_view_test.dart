import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/accolades.dart';
import 'package:time_keeper/models/team_member.dart';
import 'package:time_keeper/providers/accolades_provider.dart';
import 'package:time_keeper/views/achievements/achievements_view.dart';

/// The achievements board.
///
/// The one behaviour worth pinning with a widget test is secrecy: a hidden achievement that has
/// not been earned must give away neither its name nor how to get it. Everything else on the
/// page is presentation, but leaking a secret is a bug you would only ever notice by looking.
void main() {
  Achievement achievement({
    required String key,
    required String name,
    bool hidden = false,
    bool earned = false,
    String how = 'Do the thing',
  }) {
    return Achievement(key: key, emoji: '⭐', name: name, how: how, hidden: hidden, earned: earned);
  }

  MemberAccolades member({
    String id = 'm1',
    String name = 'Ada Lovelace',
    TeamMemberType type = TeamMemberType.mentor,
    String title = 'The Night Owl',
    String reason = 'You have signed out at 10pm or later.',
    required List<Achievement> achievements,
  }) {
    return MemberAccolades(
      teamMemberId: id,
      name: name,
      memberType: type,
      title: title,
      titleReason: reason,
      earnedCount: achievements.where((a) => a.earned).length,
      totalCount: achievements.length,
      achievements: achievements,
    );
  }

  /// The board is a two-pane desktop layout inside scrolling lists, and the default 800x600 test
  /// surface is small enough that the lower half is never laid out — which reads as "the widget
  /// isn't there" rather than "it is below the fold". Every test here runs on a desktop-sized
  /// surface so the whole page is built.
  Future<void> useDesktopSurface(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  Widget harness(List<MemberAccolades> members) {
    return ProviderScope(
      overrides: [memberAccoladesProvider.overrideWith((ref) async => members)],
      child: const MaterialApp(home: Scaffold(body: AchievementsView())),
    );
  }

  testWidgets('shows the selected member title and their unlocked badges', (tester) async {
    await useDesktopSurface(tester);
    await tester.pumpWidget(
      harness([
        member(
          achievements: [
            achievement(key: 'a', name: 'First Steps', earned: true),
            achievement(key: 'b', name: 'Centurion'),
          ],
        ),
      ]),
    );
    await tester.pumpAndSettle();

    // Twice on purpose: once on the member's row in the list, once as the board's headline.
    expect(find.text('The Night Owl'), findsNWidgets(2));
    expect(find.text('You have signed out at 10pm or later.'), findsOneWidget);
    // Earned and unearned both render — the board is the whole catalogue, with gaps.
    expect(find.text('First Steps'), findsOneWidget);
    expect(find.text('Centurion'), findsOneWidget);
    expect(find.text('1 of 2 unlocked'), findsOneWidget);
  });

  testWidgets('an unearned hidden achievement reveals neither its name nor its condition', (tester) async {
    await useDesktopSurface(tester);
    await tester.pumpWidget(
      harness([
        member(
          achievements: [
            achievement(key: 'a', name: 'First Steps', earned: true),
            achievement(key: 'secret', name: 'Achievement Unhealthy', hidden: true, how: 'Log only overtime'),
          ],
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Achievement Unhealthy'), findsNothing, reason: 'a secret must not show its name');
    expect(find.text('Log only overtime'), findsNothing, reason: 'nor how to get it');
    expect(find.textContaining('kept secret until earned'), findsOneWidget);
  });

  testWidgets('an earned hidden achievement is revealed in full', (tester) async {
    await useDesktopSurface(tester);
    await tester.pumpWidget(
      harness([
        member(
          achievements: [achievement(key: 'secret', name: 'Achievement Unhealthy', hidden: true, earned: true)],
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Achievement Unhealthy'), findsOneWidget);
    expect(find.textContaining('kept secret'), findsNothing);
  });

  testWidgets('selecting another member switches the board', (tester) async {
    await useDesktopSurface(tester);
    await tester.pumpWidget(
      harness([
        member(
          id: 'm1',
          name: 'Ada Lovelace',
          title: 'The Untouchable',
          reason: 'Nobody is ahead of you.',
          achievements: [achievement(key: 'a', name: 'First Steps', earned: true)],
        ),
        member(
          id: 'm2',
          name: 'Grace Hopper',
          title: 'The Ghost',
          reason: 'The system keeps signing you out.',
          achievements: [achievement(key: 'a', name: 'First Steps')],
        ),
      ]),
    );
    await tester.pumpAndSettle();

    // The reason line is the one thing only the board renders, so it identifies which member the
    // board is showing without the member list's own copy of the title getting in the way.
    expect(find.text('Nobody is ahead of you.'), findsOneWidget, reason: 'opens on the most decorated member');

    await tester.tap(find.text('Grace Hopper').first);
    await tester.pumpAndSettle();

    expect(find.text('The system keeps signing you out.'), findsOneWidget);
    expect(find.text('Nobody is ahead of you.'), findsNothing);
  });
}
