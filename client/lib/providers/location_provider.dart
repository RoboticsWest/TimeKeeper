import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/generated/api/location.pbgrpc.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/helpers/auth_interceptor.dart';
import 'package:time_keeper/helpers/collection_storage.dart';
import 'package:time_keeper/helpers/local_storage.dart';
import 'package:time_keeper/helpers/reconnecting_stream.dart';
import 'package:time_keeper/providers/auth_provider.dart';
import 'package:time_keeper/providers/grpc_channel_provider.dart';

part 'location_provider.g.dart';

@Riverpod(keepAlive: true)
LocationServiceClient locationService(Ref ref) {
  final channel = ref.watch(grpcChannelProvider);
  final token = ref.watch(tokenProvider);
  final options = authCallOptions(token);

  return LocationServiceClient(channel, options: options);
}

@Riverpod(keepAlive: true)
Stream<StreamLocationsResponse> locationsStream(Ref ref) {
  final reconnectingStream = ReconnectingStream<StreamLocationsResponse>(
    () async {
      final client = ref.read(locationServiceProvider);
      return client.streamLocations(StreamLocationsRequest());
    },
  );

  ref.onDispose(reconnectingStream.close);
  return reconnectingStream.stream;
}

@Riverpod(keepAlive: true)
class Locations extends _$Locations {
  late final CollectionStorage<Location> _storage;

  @override
  Map<String, Location> build() {
    _storage = CollectionStorage(
      tableName: 'locations',
      fromBuffer: Location.fromBuffer,
    );

    final localLocations = _storage.getAll();

    _storage.bindToStream(
      ref: ref,
      streamProvider: locationsStreamProvider,
      extractItems: (response) => response.locations,
      getSyncType: (response) => response.syncType,
      hasItem: (item) => item.hasLocation(),
      getId: (item) => item.id,
      getItem: (item) => item.location,
      onSync: (fullState) => state = fullState,
      onUpdate: (updates) => state = {...state, ...updates},
    );

    return localLocations;
  }
}

@Riverpod(keepAlive: true)
class CurrentLocation extends _$CurrentLocation {
  static const String _key = 'current_location_id';

  void setLocation(String? locationId) {
    if (locationId == null) {
      localStorage.remove(_key);
    } else {
      localStorage.setString(_key, locationId);
    }
    state = locationId;
  }

  @override
  String? build() {
    if (localStorage.containsKey(_key)) {
      return localStorage.getString(_key);
    }
    return null;
  }
}
