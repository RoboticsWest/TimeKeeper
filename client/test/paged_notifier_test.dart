import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/paged_result.dart';
import 'package:time_keeper/providers/paged_notifier.dart';

/// Minimal stand-in for a generated `_$...Page` notifier: the mixin only needs a `state` pair
/// and a `fetch`, so a plain field satisfies both.
class _FakePager with PagedAsyncNotifier<int> {
  _FakePager(this.total);

  /// Total rows the "server" currently holds; mutate to simulate deletions.
  int total;
  int fetchCount = 0;

  @override
  AsyncValue<PagedResult<int>> state = const AsyncValue.loading();

  @override
  Future<PagedResult<int>> fetch(int offset, int pageSize) async {
    fetchCount++;
    final start = offset.clamp(0, total);
    final end = (offset + pageSize).clamp(0, total);
    return PagedResult<int>(
      items: [for (var i = start; i < end; i++) i],
      totalCount: total,
      offset: offset,
      limit: pageSize,
      hasMore: end < total,
    );
  }
}

void main() {
  group('PagedAsyncNotifier paging', () {
    test('walks forward and back, and stops at the end', () async {
      final pager = _FakePager(120);
      pager.setPageSize(50);
      await pager.load();
      expect(pager.currentOffset, 0);
      expect(pager.state.value!.hasMore, isTrue);

      pager.nextPage();
      await Future<void>.delayed(Duration.zero);
      expect(pager.currentOffset, 50);

      pager.nextPage();
      await Future<void>.delayed(Duration.zero);
      expect(pager.currentOffset, 100);
      expect(pager.state.value!.hasMore, isFalse, reason: 'last page');

      // Next on the last page is a no-op.
      pager.nextPage();
      await Future<void>.delayed(Duration.zero);
      expect(pager.currentOffset, 100);

      pager.previousPage();
      await Future<void>.delayed(Duration.zero);
      expect(pager.currentOffset, 50);
    });

    test('previous on the first page is a no-op', () async {
      final pager = _FakePager(10);
      await pager.load();
      pager.previousPage();
      await Future<void>.delayed(Duration.zero);
      expect(pager.currentOffset, 0);
    });

    test('a page that falls off the end is clamped back to the last real page', () async {
      final pager = _FakePager(210);
      pager.setPageSize(50);
      await pager.load();

      // Walk out to the last page (offset 200).
      for (var i = 0; i < 4; i++) {
        pager.nextPage();
        await Future<void>.delayed(Duration.zero);
      }
      expect(pager.currentOffset, 200);

      // Rows are deleted underneath us and a realtime delta refetches.
      pager.total = 150;
      await pager.load();

      // ((150 - 1) ~/ 50) * 50 == 100
      expect(pager.currentOffset, 100, reason: 'must not strand the user past the end');
      expect(pager.state.value!.items, isNotEmpty, reason: 'clamped page must have rows');
      expect(pager.state.value!.offset, 100);
      expect(pager.state.value!.totalCount, 150);
    });

    test('an empty collection clamps to zero rather than looping', () async {
      final pager = _FakePager(60);
      pager.setPageSize(50);
      await pager.load();
      pager.nextPage();
      await Future<void>.delayed(Duration.zero);
      expect(pager.currentOffset, 50);

      pager.total = 0;
      final before = pager.fetchCount;
      await pager.load();

      expect(pager.currentOffset, 50, reason: 'nothing to clamp to when the total is zero');
      expect(pager.state.value!.items, isEmpty);
      expect(pager.fetchCount - before, 1, reason: 'must not retry-loop on an empty collection');
    });

    test('changing the page size returns to the first page', () async {
      final pager = _FakePager(500);
      pager.setPageSize(50);
      await pager.load();
      pager.nextPage();
      await Future<void>.delayed(Duration.zero);
      expect(pager.currentOffset, 50);

      pager.setPageSize(100);
      await Future<void>.delayed(Duration.zero);
      expect(pager.currentOffset, 0);
      expect(pager.currentPageSize, 100);
    });
  });
}
