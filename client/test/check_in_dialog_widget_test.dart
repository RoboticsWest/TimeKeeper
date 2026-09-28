import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/location.dart';
import 'package:time_keeper/models/session.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/providers/settings_provider.dart';
import 'package:time_keeper/views/team/check_in_dialog.dart';

/// The roster's check-in dialog.
///
/// Its job is to answer "where?" before a check-in, which the roster previously took from the
/// device's kiosk location — unset on an admin's machine, sent as an empty string, rejected as a
/// malformed UUID. Offering the choice is only an improvement if the offer is honest, so what is
/// pinned here is that a location with a session on now is selectable and one without is not.
class _FakeLocations extends Locations {
  _FakeLocations(this.seed);
  final Map<String, Location> seed;

  @override
  Map<String, Location> build() => seed;
}

class _FakeSessions extends Sessions {
  _FakeSessions(this.seed);
  final Map<String, Session> seed;

  @override
  Map<String, Session> build() => seed;
}

void main() {
  const shop = 'loc-shop';
  const bay = 'loc-bay';

  final locations = {shop: Location(id: shop, location: 'Machine Shop'), bay: Location(id: bay, location: 'Pit Bay')};

  Map<String, Session> sessionsAt(String locationId) {
    final now = DateTime.now();
    return {
      's1': Session(
        id: 's1',
        startTime: now.subtract(const Duration(hours: 1)),
        endTime: now.add(const Duration(hours: 2)),
        locationId: locationId,
        finished: false,
      ),
    };
  }

  Widget harness(Map<String, Session> sessions) {
    return ProviderScope(
      overrides: [
        locationsProvider.overrideWith(() => _FakeLocations(locations)),
        sessionsProvider.overrideWith(() => _FakeSessions(sessions)),
        // Both sync bridges only exist to attach subscriptions.
        locationsSyncProvider.overrideWithValue(null),
        sessionsSyncProvider.overrideWithValue(null),
        // Null is a valid value here; the dialog then uses the server's default window.
        settingsQueryProvider.overrideWith((ref) async => null),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) => ElevatedButton(
              onPressed: () => showCheckInDialog(context, ref, memberId: 'm1', memberName: 'Ada Lovelace'),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> open(WidgetTester tester, Map<String, Session> sessions) async {
    await tester.pumpWidget(harness(sessions));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('lists every location and names the session a check-in would join', (tester) async {
    await open(tester, sessionsAt(shop));

    expect(find.text('Machine Shop'), findsOneWidget);
    expect(find.text('Pit Bay'), findsOneWidget);
    expect(find.textContaining('today,'), findsOneWidget, reason: 'the running session is named');
    expect(find.text('No session right now'), findsOneWidget, reason: 'the other location says so');
  });

  testWidgets('a location with no session cannot be chosen', (tester) async {
    await open(tester, sessionsAt(shop));

    final bayTile = tester.widget<ListTile>(find.ancestor(of: find.text('Pit Bay'), matching: find.byType(ListTile)));
    expect(bayTile.onTap, isNull);

    final shopTile = tester.widget<ListTile>(
      find.ancestor(of: find.text('Machine Shop'), matching: find.byType(ListTile)),
    );
    expect(shopTile.onTap, isNotNull);
  });

  testWidgets('with nothing running it explains why rather than showing an empty list', (tester) async {
    await open(tester, const {});

    expect(find.textContaining('No session is running at any location'), findsOneWidget);
    expect(find.text('No session right now'), findsNWidgets(2));
  });

  testWidgets('the member being checked in is named in the prompt', (tester) async {
    await open(tester, sessionsAt(shop));

    expect(find.text('Check In — Ada Lovelace'), findsOneWidget);
    expect(find.text('Where is Ada Lovelace checking in?'), findsOneWidget);
  });
}
