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
    int holders = 3,
    int totalMembers = 12,
  }) {
    return Achievement(
      key: key,
      emoji: '⭐',
      name: name,
      how: how,
      hidden: hidden,
      earned: earned,
      holders: holders,
      totalMembers: totalMembers,
      rarityPct: totalMembers == 0 ? 0 : holders * 100 / totalMembers,
    );
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

  test('rarity bands follow the share of active members holding a badge', () {
    // Mirrors `rarity_label` on the server. If these two ever disagree, the same badge is
    // "Rare" in the app and "Uncommon" in Discord, which is worse than showing neither.
    expect(achievement(key: 'a', name: 'a', holders: 0, totalMembers: 12).rarityLabel, 'Unclaimed');
    expect(achievement(key: 'a', name: 'a', holders: 1, totalMembers: 12).rarityLabel, 'Legendary');
    expect(achievement(key: 'a', name: 'a', holders: 2, totalMembers: 12).rarityLabel, 'Rare');
    expect(achievement(key: 'a', name: 'a', holders: 5, totalMembers: 12).rarityLabel, 'Uncommon');
    expect(achievement(key: 'a', name: 'a', holders: 9, totalMembers: 12).rarityLabel, 'Common');
    expect(achievement(key: 'a', name: 'a', holders: 12, totalMembers: 12).rarityLabel, 'Everyone');
    // No team means no denominator — rating it would be inventing a number.
    expect(achievement(key: 'a', name: 'a', holders: 0, totalMembers: 0).rarityLabel, 'Unrated');
  });

  testWidgets('a badge shows how rare it is', (tester) async {
    await useDesktopSurface(tester);
    await tester.pumpWidget(
      harness([
        member(
          achievements: [achievement(key: 'a', name: 'First Steps', earned: true, holders: 1, totalMembers: 12)],
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Legendary'), findsOneWidget);
  });

  testWidgets('a secret badge does not leak its rarity either', (tester) async {
    await useDesktopSurface(tester);
    await tester.pumpWidget(
      harness([
        member(
          achievements: [
            achievement(key: 'a', name: 'First Steps', earned: true),
            achievement(key: 's', name: 'Secret Thing', hidden: true, holders: 1, totalMembers: 12),
          ],
        ),
      ]),
    );
    await tester.pumpAndSettle();

    // "one person has this" is itself a hint about what it takes.
    expect(find.text('Legendary'), findsNothing);
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
