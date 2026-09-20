import 'package:flutter_test/flutter_test.dart';
import 'package:time_keeper/models/notification.dart';
import 'package:time_keeper/models/settings.dart';
import 'package:time_keeper/providers/location_page_provider.dart';
import 'package:time_keeper/providers/notification_page_provider.dart';
import 'package:time_keeper/providers/user_page_provider.dart';

void main() {
  group('LocationFilterState', () {
    test('an empty search sends no filter at all', () {
      expect(const LocationFilterState().toServerFilter(), isNull);
      expect(const LocationFilterState(search: '   ').toServerFilter(), isNull);
    });

    test('a search is trimmed before it is sent', () {
      expect(const LocationFilterState(search: '  shop  ').toServerFilter(), {'search': 'shop'});
    });
  });

  group('UserFilterState', () {
    test('an empty search sends no filter at all', () {
      expect(const UserFilterState().toServerFilter(), isNull);
    });

    test('a search is trimmed before it is sent', () {
      expect(const UserFilterState(search: ' alice ').toServerFilter(), {'search': 'alice'});
    });
  });

  group('NotificationFilterState', () {
    test('an empty filter sends nothing', () {
      expect(const NotificationFilterState().toServerFilter(), isNull);
    });

    test('a status label is swapped for the code the server stores', () {
      // The list renders `pending` as "Scheduled"; searching the label must still match.
      expect(const NotificationFilterState(search: 'Scheduled').toServerFilter(), {
        'search': NotificationStatus.pending,
      });
      expect(const NotificationFilterState(search: 'scheduled').toServerFilter(), {
        'search': NotificationStatus.pending,
      });
    });

    test('a type label is swapped for its code', () {
      expect(const NotificationFilterState(search: 'Session Start Reminder').toServerFilter(), {
        'search': NotificationType.sessionStartReminder,
      });
    });

    test('a label is only swapped on a whole-string match', () {
      // "Sched" must stay literal, or it would hijack a search for a location or member whose
      // name merely starts the same way.
      expect(const NotificationFilterState(search: 'Sched').toServerFilter(), {'search': 'Sched'});
    });

    test('a non-label search passes through untouched', () {
      expect(const NotificationFilterState(search: 'Machine Shop').toServerFilter(), {'search': 'Machine Shop'});
    });

    test('structured filters are sent alongside the search', () {
      final filter = const NotificationFilterState(
        search: 'Machine Shop',
        statuses: [NotificationStatus.pending],
        notificationTypes: [NotificationType.overtime],
      ).toServerFilter();

      expect(filter, {
        'search': 'Machine Shop',
        'notificationTypes': [NotificationType.overtime],
        'statuses': [NotificationStatus.pending],
      });
    });

    test('isEmpty accounts for the search term', () {
      expect(const NotificationFilterState().isEmpty, isTrue);
      expect(const NotificationFilterState(search: 'x').isEmpty, isFalse);
    });
  });

  group('NotificationType labels', () {
    test('every type has a label and round-trips', () {
      for (final type in NotificationType.all) {
        expect(NotificationType.label(type), isNot('Unknown'), reason: type);
      }
    });

    test('an unknown type degrades rather than throwing', () {
      expect(NotificationType.label('nope'), 'Unknown');
    });
  });

  group('Settings maintenance mode', () {
    Settings parse(Map<String, dynamic> overrides) => Settings.fromJson({
      'checkInWindowSecs': 0,
      'autoCheckoutAfterSecs': 0,
      'discordBotToken': '',
      'discordGuildId': '',
      'discordAnnouncementChannelId': '',
      'discordNotificationChannelId': '',
      'discordSelfLinkEnabled': false,
      'discordNameSyncEnabled': false,
      'discordStartReminderMins': 0,
      'discordEndReminderMins': 0,
      'discordStartReminderMessage': '',
      'discordEndReminderMessage': '',
      'discordOvertimeDmEnabled': false,
      'discordOvertimeDmMins': 0,
      'discordOvertimeDmMessage': '',
      'discordAutoCheckoutDmEnabled': false,
      'discordAutoCheckoutDmMessage': '',
      'discordCheckoutEnabled': false,
      'discordEnabled': false,
      'timezone': '',
      'leaderboardShowOvertime': false,
      'leaderboardMemberTypes': <String>[],
      'discordRsvpReactionsEnabled': false,
      'discordAutoDeleteStartReminder': false,
      'discordAutoDeleteEndReminder': false,
      'quickPinEnabled': false,
      ...overrides,
    });

    test('defaults to off when the server predates the migration', () {
      final s = parse({});
      expect(s.maintenanceMode, isFalse);
      expect(s.maintenanceMessage, '');
    });

    test('a blank message falls back to the default wording', () {
      expect(parse({'maintenanceMode': true}).maintenanceBannerText, Settings.defaultMaintenanceMessage);
      expect(
        parse({'maintenanceMode': true, 'maintenanceMessage': '   '}).maintenanceBannerText,
        Settings.defaultMaintenanceMessage,
      );
    });

    test('an operator message is used verbatim, trimmed', () {
      expect(
        parse({'maintenanceMode': true, 'maintenanceMessage': '  Upgrading the database  '}).maintenanceBannerText,
        'Upgrading the database',
      );
    });

    test('the flag round-trips', () {
      expect(parse({'maintenanceMode': true}).maintenanceMode, isTrue);
    });
  });
}
