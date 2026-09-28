import 'package:flutter_test/flutter_test.dart';
import 'package:time_keeper/providers/attendance_page_provider.dart';
import 'package:time_keeper/providers/session_page_provider.dart';
import 'package:time_keeper/providers/team_member_page_provider.dart';

void main() {
  group('AttendanceFilterState.toServerFilter', () {
    test('nothing selected sends no filter at all', () {
      expect(const AttendanceFilterState().toServerFilter(), isNull);
    });

    test('a search term is passed through trimmed', () {
      expect(const AttendanceFilterState(search: '  ada  ').toServerFilter(), {'search': 'ada'});
    });

    test('a single session and location narrow accordingly', () {
      final filter = const AttendanceFilterState(sessionId: 's1', locationId: 'l2').toServerFilter();
      expect(filter, isNotNull);
      expect(filter!['sessionIds'], ['s1']);
      expect(filter['locationIds'], ['l2']);
    });

    test('member types and checked-in state map to the server fields', () {
      final filter = const AttendanceFilterState(
        memberTypes: ['mentor'],
        status: AttendanceStatusFilter.checkedIn,
      ).toServerFilter();
      expect(filter!['memberTypes'], ['mentor']);
      expect(filter['checkedInOnly'], isTrue);
    });

    test('completed maps checkedInOnly to false', () {
      final filter = const AttendanceFilterState(status: AttendanceStatusFilter.completed).toServerFilter();
      expect(filter!['checkedInOnly'], isFalse);
    });
  });

  group('SessionFilterState.toServerFilter', () {
    test('nothing selected sends no filter at all', () {
      expect(const SessionFilterState().toServerFilter(), isNull);
    });

    test('location and finished narrow accordingly', () {
      final filter = const SessionFilterState(locationId: 'loc1', finished: true).toServerFilter();
      expect(filter!['locationIds'], ['loc1']);
      expect(filter['finished'], isTrue);
    });

    test('a chosen day becomes a UTC day-range', () {
      final day = DateTime(2026, 9, 20);
      final filter = SessionFilterState(day: day).toServerFilter();
      expect(filter!['from'], DateTime(2026, 9, 20).toUtc().toIso8601String());
      expect(filter['to'], DateTime(2026, 9, 21).toUtc().toIso8601String());
    });
  });

  group('TeamMemberFilterState.toServerFilter', () {
    test('nothing selected sends no filter at all', () {
      expect(const TeamMemberFilterState().toServerFilter(), isNull);
    });

    test('search and member types map through', () {
      final filter = const TeamMemberFilterState(search: 'grace', memberTypes: ['student']).toServerFilter();
      expect(filter!['search'], 'grace');
      expect(filter['memberTypes'], ['student']);
    });

    test('discord link state maps to hasDiscord', () {
      expect(const TeamMemberFilterState(discord: DiscordLinkFilter.linked).toServerFilter()!['hasDiscord'], isTrue);
      expect(const TeamMemberFilterState(discord: DiscordLinkFilter.unlinked).toServerFilter()!['hasDiscord'], isFalse);
    });
  });
}
