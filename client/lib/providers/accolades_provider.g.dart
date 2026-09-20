// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accolades_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every member's title and achievement collection, most decorated first.
///
/// Like the leaderboard this is an aggregate rather than an id-keyed collection, so it cannot be
/// patched from a change delta — any attendance or roster change invalidates the whole thing.
/// Watching those collections is what makes a badge appear the moment somebody earns it rather
/// than whenever the page next happens to be rebuilt.

@ProviderFor(memberAccolades)
final memberAccoladesProvider = MemberAccoladesProvider._();

/// Every member's title and achievement collection, most decorated first.
///
/// Like the leaderboard this is an aggregate rather than an id-keyed collection, so it cannot be
/// patched from a change delta — any attendance or roster change invalidates the whole thing.
/// Watching those collections is what makes a badge appear the moment somebody earns it rather
/// than whenever the page next happens to be rebuilt.

final class MemberAccoladesProvider
    extends
        $FunctionalProvider<AsyncValue<List<MemberAccolades>>, List<MemberAccolades>, FutureOr<List<MemberAccolades>>>
    with $FutureModifier<List<MemberAccolades>>, $FutureProvider<List<MemberAccolades>> {
  /// Every member's title and achievement collection, most decorated first.
  ///
  /// Like the leaderboard this is an aggregate rather than an id-keyed collection, so it cannot be
  /// patched from a change delta — any attendance or roster change invalidates the whole thing.
  /// Watching those collections is what makes a badge appear the moment somebody earns it rather
  /// than whenever the page next happens to be rebuilt.
  MemberAccoladesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memberAccoladesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memberAccoladesHash();

  @$internal
  @override
  $FutureProviderElement<List<MemberAccolades>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<MemberAccolades>> create(Ref ref) {
    return memberAccolades(ref);
  }
}

String _$memberAccoladesHash() => r'4670824ac8eacbb7c17017e4fcaecf0fec37dcd2';
