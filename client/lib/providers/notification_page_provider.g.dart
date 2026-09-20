// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_page_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A paged, filtered slice of the notifications table, newest-scheduled first.
///
/// Notifications accumulate a few rows per session, so this grows with the season the same way
/// attendance does; filtering and paging happen in SQL.

@ProviderFor(NotificationPage)
final notificationPageProvider = NotificationPageProvider._();

/// A paged, filtered slice of the notifications table, newest-scheduled first.
///
/// Notifications accumulate a few rows per session, so this grows with the season the same way
/// attendance does; filtering and paging happen in SQL.
final class NotificationPageProvider extends $AsyncNotifierProvider<NotificationPage, PagedResult<Notification>> {
  /// A paged, filtered slice of the notifications table, newest-scheduled first.
  ///
  /// Notifications accumulate a few rows per session, so this grows with the season the same way
  /// attendance does; filtering and paging happen in SQL.
  NotificationPageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPageHash();

  @$internal
  @override
  NotificationPage create() => NotificationPage();
}

String _$notificationPageHash() => r'30c5444cce9085ab8cd0c8d9c891ccfc7075991c';

/// A paged, filtered slice of the notifications table, newest-scheduled first.
///
/// Notifications accumulate a few rows per session, so this grows with the season the same way
/// attendance does; filtering and paging happen in SQL.

abstract class _$NotificationPage extends $AsyncNotifier<PagedResult<Notification>> {
  FutureOr<PagedResult<Notification>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PagedResult<Notification>>, PagedResult<Notification>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PagedResult<Notification>>, PagedResult<Notification>>,
              AsyncValue<PagedResult<Notification>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
