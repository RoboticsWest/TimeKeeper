import 'package:graphql/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/providers/graphql_client_provider.dart';
import 'package:time_keeper/providers/shared_ticker_provider.dart';
import 'package:time_keeper/utils/app_version.dart';

part 'update_check_provider.g.dart';

/// How often the client re-asks the server for its version.
///
/// The server's version only changes on deploy, so this is about how long a stale client can
/// go unnoticed rather than about freshness. Hours, not minutes: the prompt is an interruption.
const kUpdateCheckInterval = Duration(hours: 3);

const _versionInfoQuery = r'''
  query VersionInfo {
    versionInfo { version releasesUrl }
  }
''';

/// What the server reports about itself.
class ServerVersionInfo {
  final Version version;
  final String releasesUrl;

  const ServerVersionInfo({required this.version, required this.releasesUrl});
}

/// Polls the server's version on [kUpdateCheckInterval].
///
/// Unauthenticated on the server side, so this works on the login screen too. Returns null when
/// the server cannot be reached — an offline client should say nothing rather than claim to be
/// out of date.
@Riverpod(keepAlive: true)
Future<ServerVersionInfo?> serverVersionInfo(Ref ref) async {
  // Re-runs this provider on every tick.
  ref.watch(sharedTickerProvider(kUpdateCheckInterval));

  final client = ref.watch(timeKeeperGraphQLClientProvider);
  final result = await client.query(QueryOptions(document: gql(_versionInfoQuery), fetchPolicy: FetchPolicy.noCache));
  if (result.hasException || result.data == null) return null;

  final data = result.data!['versionInfo'] as Map<String, dynamic>;
  return ServerVersionInfo(
    version: Version.parse(data['version'] as String),
    releasesUrl: data['releasesUrl'] as String,
  );
}

/// The server version when this build is too old to keep using quietly, else null.
///
/// Null covers every "say nothing" case: server unreachable, versions equal, client newer
/// (a developer running ahead of the deploy), either side unknown, or a patch-only difference.
@Riverpod(keepAlive: true)
ServerVersionInfo? availableUpdate(Ref ref) {
  final info = ref.watch(serverVersionInfoProvider).value;
  if (info == null) return null;

  final client = Version.parse(kClientVersion);
  return client.isUpdateRequired(info.version) ? info : null;
}

/// Tracks the update prompt so it is shown once per check rather than on every rebuild.
///
/// Dismissing does not suppress the next check: the point is a periodic nudge. It only stops
/// the dialog reappearing the moment it is closed.
@Riverpod(keepAlive: true)
class UpdatePromptDismissal extends _$UpdatePromptDismissal {
  @override
  Version? build() => null;

  /// Records that the user dismissed the prompt for [version].
  void dismiss(Version version) => state = version;

  bool isDismissed(Version version) => state == version;
}
