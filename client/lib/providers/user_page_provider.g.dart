// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_page_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A paged, filtered slice of the admin users table, ordered by username.
///
/// The built-in `admin` account is excluded server-side, inside the same query that produces the
/// count, so the pager's total always matches what it can actually render.

@ProviderFor(UserPage)
final userPageProvider = UserPageProvider._();

/// A paged, filtered slice of the admin users table, ordered by username.
///
/// The built-in `admin` account is excluded server-side, inside the same query that produces the
/// count, so the pager's total always matches what it can actually render.
final class UserPageProvider extends $AsyncNotifierProvider<UserPage, PagedResult<User>> {
  /// A paged, filtered slice of the admin users table, ordered by username.
  ///
  /// The built-in `admin` account is excluded server-side, inside the same query that produces the
  /// count, so the pager's total always matches what it can actually render.
  UserPageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userPageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userPageHash();

  @$internal
  @override
  UserPage create() => UserPage();
}

String _$userPageHash() => r'e9d6cd2d603b2851ecd22b25c326982ac57b3cf6';

/// A paged, filtered slice of the admin users table, ordered by username.
///
/// The built-in `admin` account is excluded server-side, inside the same query that produces the
/// count, so the pager's total always matches what it can actually render.

abstract class _$UserPage extends $AsyncNotifier<PagedResult<User>> {
  FutureOr<PagedResult<User>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PagedResult<User>>, PagedResult<User>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PagedResult<User>>, PagedResult<User>>,
              AsyncValue<PagedResult<User>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
