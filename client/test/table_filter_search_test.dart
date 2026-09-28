import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_keeper/hooks/use_debounced_text.dart';
import 'package:time_keeper/widgets/tables/table_filter.dart';

/// What these guard: the search box has to reach the query.
///
/// Every list view built its filter from `useEffect(..., [controller.text])`, which never fires —
/// a `TextField` writing to a controller obtained from `useTextEditingController` does not rebuild
/// the widget that owns it, so the effect's key never changes. The term stayed empty, the server
/// filter stayed null, and the only way to find anybody was to raise the page size until the whole
/// table was on screen. [useDebouncedText] subscribes to the controller, which is what makes a
/// keystroke observable at all.
void main() {
  late List<String> committed;

  Widget host(TextEditingController controller) {
    return MaterialApp(
      home: Scaffold(
        body: HookBuilder(
          builder: (context) {
            final search = useDebouncedText(controller, delay: const Duration(milliseconds: 100));
            if (committed.isEmpty || committed.last != search.value) committed.add(search.value);
            return TableFilter(
              controller: controller,
              onSubmitted: search.submit,
              isPending: search.isPending,
              matchCount: 3,
            );
          },
        ),
      ),
    );
  }

  setUp(() => committed = <String>[]);

  testWidgets('typing eventually reaches the committed term', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(host(controller));

    await tester.enterText(find.byType(TextField), 'ada');
    await tester.pump();
    expect(committed.last, '', reason: 'still within the debounce');

    await tester.pump(const Duration(milliseconds: 150));
    expect(committed.last, 'ada');
  });

  testWidgets('a keystroke shows as pending until it is committed', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(host(controller));

    await tester.enterText(find.byType(TextField), 'ada');
    await tester.pump();
    expect(find.text('Searching'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('Searching'), findsNothing);
    expect(find.text('3 matches'), findsOneWidget);
  });

  testWidgets('submitting commits without waiting out the debounce', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(host(controller));

    await tester.enterText(find.byType(TextField), 'lovelace');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();
    expect(committed.last, 'lovelace');
  });

  testWidgets('a rapid burst of keystrokes commits once, with the final text', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(host(controller));

    for (final text in ['a', 'ad', 'ada']) {
      await tester.enterText(find.byType(TextField), text);
      await tester.pump(const Duration(milliseconds: 30));
    }
    await tester.pump(const Duration(milliseconds: 150));

    expect(committed, ['', 'ada'], reason: 'intermediate terms must not each start a query');
  });

  testWidgets('clearing the box commits the empty term immediately', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(host(controller));

    await tester.enterText(find.byType(TextField), 'ada');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(committed.last, 'ada');

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    expect(committed.last, '');
  });
}
