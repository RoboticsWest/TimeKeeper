// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_page_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A paged, filtered slice of sessions for the table mode of the Sessions view. The calendar and
/// stats still read the whole set from the collection providers.

@ProviderFor(SessionPage)
final sessionPageProvider = SessionPageProvider._();

/// A paged, filtered slice of sessions for the table mode of the Sessions view. The calendar and
/// stats still read the whole set from the collection providers.
final class SessionPageProvider
    extends $AsyncNotifierProvider<SessionPage, PagedResult<Session>> {
  /// A paged, filtered slice of sessions for the table mode of the Sessions view. The calendar and
  /// stats still read the whole set from the collection providers.
  SessionPageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionPageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionPageHash();

  @$internal
  @override
  SessionPage create() => SessionPage();
}

String _$sessionPageHash() => r'01d31eb4342528a30215690e44001743fc17f8c6';

/// A paged, filtered slice of sessions for the table mode of the Sessions view. The calendar and
/// stats still read the whole set from the collection providers.

abstract class _$SessionPage extends $AsyncNotifier<PagedResult<Session>> {
  FutureOr<PagedResult<Session>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<PagedResult<Session>>, PagedResult<Session>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PagedResult<Session>>,
                PagedResult<Session>
              >,
              AsyncValue<PagedResult<Session>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
