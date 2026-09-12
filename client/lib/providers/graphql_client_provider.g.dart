// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'graphql_client_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TimeKeeperGraphQLClient)
final timeKeeperGraphQLClientProvider = TimeKeeperGraphQLClientProvider._();

final class TimeKeeperGraphQLClientProvider
    extends $NotifierProvider<TimeKeeperGraphQLClient, GraphQLClient> {
  TimeKeeperGraphQLClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timeKeeperGraphQLClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timeKeeperGraphQLClientHash();

  @$internal
  @override
  TimeKeeperGraphQLClient create() => TimeKeeperGraphQLClient();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GraphQLClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GraphQLClient>(value),
    );
  }
}

String _$timeKeeperGraphQLClientHash() =>
    r'5601e9e32f9443e8b3f67a28dc2824165b599401';

abstract class _$TimeKeeperGraphQLClient extends $Notifier<GraphQLClient> {
  GraphQLClient build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<GraphQLClient, GraphQLClient>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GraphQLClient, GraphQLClient>,
              GraphQLClient,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
