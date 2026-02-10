import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/generated/api/stats.pbgrpc.dart';
import 'package:time_keeper/helpers/auth_interceptor.dart';
import 'package:time_keeper/providers/auth_provider.dart';
import 'package:time_keeper/providers/grpc_channel_provider.dart';

part 'stats_provider.g.dart';

@Riverpod(keepAlive: true)
StatsServiceClient statsService(Ref ref) {
  final channel = ref.watch(grpcChannelProvider);
  final token = ref.watch(tokenProvider);
  final options = authCallOptions(token);

  return StatsServiceClient(channel, options: options);
}

@riverpod
Future<GetLeaderboardResponse> leaderboard(Ref ref) async {
  final client = ref.watch(statsServiceProvider);
  return client.getLeaderboard(GetLeaderboardRequest());
}
