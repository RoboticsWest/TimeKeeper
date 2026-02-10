import 'package:protobuf/protobuf.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/generated/common/common.pbenum.dart';
import 'package:time_keeper/helpers/local_storage.dart';
import 'package:time_keeper/helpers/protobuf_helper.dart';

/// Helper for storing and retrieving collections of protobuf messages.
///
/// Each item is stored individually with a prefixed key, making updates
/// efficient. An index tracks all IDs in the collection.
class CollectionStorage<T extends GeneratedMessage> {
  final String tableName;
  final T Function(List<int>) fromBuffer;

  CollectionStorage({required this.tableName, required this.fromBuffer});

  String get _idsKey => '${tableName}_ids';
  String _itemKey(String id) => '${tableName}_$id';

  Map<String, T> getAll() {
    final ids = localStorage.getStringList(_idsKey) ?? [];
    final items = <String, T>{};

    for (final id in ids) {
      final item = get(id);
      if (item != null) {
        items[id] = item;
      }
    }

    return items;
  }

  /// Get a single item by ID
  T? get(String id) {
    final encoded = localStorage.getString(_itemKey(id));
    if (encoded == null) return null;

    try {
      return ProtobufHelper.decode(encoded, fromBuffer);
    } catch (e) {
      return null;
    }
  }

  /// Save a single item
  Future<void> set(String id, T item) async {
    final encoded = ProtobufHelper.encode(item);
    await localStorage.setString(_itemKey(id), encoded);

    // Add to index if not already present
    final ids = localStorage.getStringList(_idsKey) ?? [];
    if (!ids.contains(id)) {
      ids.add(id);
      await localStorage.setStringList(_idsKey, ids);
    }
  }

  /// Save multiple items
  Future<void> setAll(Map<String, T> items) async {
    final ids = <String>[];

    for (final entry in items.entries) {
      final encoded = ProtobufHelper.encode(entry.value);
      await localStorage.setString(_itemKey(entry.key), encoded);
      ids.add(entry.key);
    }

    await localStorage.setStringList(_idsKey, ids);
  }

  /// Remove a single item
  Future<void> remove(String id) async {
    await localStorage.remove(_itemKey(id));

    final ids = localStorage.getStringList(_idsKey) ?? [];
    ids.remove(id);
    await localStorage.setStringList(_idsKey, ids);
  }

  /// Clear all items in this collection
  Future<void> clear() async {
    final ids = localStorage.getStringList(_idsKey) ?? [];

    // Remove all individual items
    for (final id in ids) {
      await localStorage.remove(_itemKey(id));
    }

    // Clear the index
    await localStorage.remove(_idsKey);
  }

  /// Get list of all IDs
  List<String> getIds() {
    return localStorage.getStringList(_idsKey) ?? [];
  }

  /// Check if an item exists
  bool exists(String id) {
    final ids = localStorage.getStringList(_idsKey) ?? [];
    return ids.contains(id);
  }

  /// Process stream updates, handling both upserts and deletes.
  ///
  /// Takes an iterable of response items and callbacks:
  /// - hasItem: Returns true if the response item contains data (false = delete)
  /// - getId: Extracts the ID from a response item
  /// - getItem: Extracts the data from a response item
  ///
  /// Returns a record of (updates, deletedIds).
  ({Map<String, T> updates, Set<String> deletedIds}) processStreamUpdates<R>(
    Iterable<R> responseItems, {
    required bool Function(R) hasItem,
    required String Function(R) getId,
    required T Function(R) getItem,
  }) {
    final updates = <String, T>{};
    final deletedIds = <String>{};

    for (final responseItem in responseItems) {
      final id = getId(responseItem);
      if (hasItem(responseItem)) {
        final item = getItem(responseItem);
        set(id, item);
        updates[id] = item;
      } else {
        remove(id);
        deletedIds.add(id);
      }
    }

    return (updates: updates, deletedIds: deletedIds);
  }

  /// Replaces the entire collection with the given items.
  ///
  /// Clears stale entries that are not in [items] and saves the new data.
  /// Returns the new full map.
  Map<String, T> replaceAll<R>(
    Iterable<R> responseItems, {
    required bool Function(R) hasItem,
    required String Function(R) getId,
    required T Function(R) getItem,
  }) {
    final incoming = <String, T>{};

    for (final responseItem in responseItems) {
      if (hasItem(responseItem)) {
        incoming[getId(responseItem)] = getItem(responseItem);
      }
    }

    // Remove stale entries not present in the server snapshot
    final existingIds = getIds();
    for (final id in existingIds) {
      if (!incoming.containsKey(id)) {
        remove(id);
      }
    }

    // Save all incoming items
    for (final entry in incoming.entries) {
      set(entry.key, entry.value);
    }

    return incoming;
  }

  /// Sets up a listener for stream updates that automatically syncs storage and provider state.
  ///
  /// Uses the server-provided [SyncType] to determine behavior:
  /// - [SyncType.FULL]: Replace the entire local collection with the server snapshot.
  /// - [SyncType.PARTIAL]: Merge incremental updates and remove deleted items.
  ///
  /// State management is handled internally — callers just provide [getState] and [setState].
  void bindToStream<StreamResponse, ResponseItem>({
    required Ref ref,
    required ProviderListenable<AsyncValue<StreamResponse>> streamProvider,
    required Iterable<ResponseItem> Function(StreamResponse) extractItems,
    required SyncType Function(StreamResponse) getSyncType,
    required bool Function(ResponseItem) hasItem,
    required String Function(ResponseItem) getId,
    required T Function(ResponseItem) getItem,
    required Map<String, T> Function() getState,
    required void Function(Map<String, T>) setState,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    ref.listen(streamProvider, (previous, next) {
      next.when(
        data: (response) {
          final items = extractItems(response);
          final syncType = getSyncType(response);

          if (syncType == SyncType.FULL) {
            final fullState = replaceAll(
              items,
              hasItem: hasItem,
              getId: getId,
              getItem: getItem,
            );
            setState(fullState);
          } else {
            final (:updates, :deletedIds) = processStreamUpdates(
              items,
              hasItem: hasItem,
              getId: getId,
              getItem: getItem,
            );
            if (updates.isNotEmpty || deletedIds.isNotEmpty) {
              final newState = {...getState(), ...updates};
              newState.removeWhere((id, _) => deletedIds.contains(id));
              setState(newState);
            }
          }
        },
        loading: () {},
        error: (error, stack) {
          if (onError != null) {
            onError(error, stack);
          }
        },
      );
    });
  }
}
