import 'dart:convert';

import 'package:time_keeper/helpers/local_storage.dart';
import 'package:time_keeper/models/change_event.dart';

/// Helper for storing and retrieving collections of JSON-serializable models.
///
/// Each item is stored individually (as JSON) with a prefixed key, making updates efficient. An
/// index tracks all IDs in the collection.
class CollectionStorage<T> {
  final String tableName;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  CollectionStorage({required this.tableName, required this.fromJson, required this.toJson});

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
      return fromJson(jsonDecode(encoded) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Save a single item
  Future<void> set(String id, T item) async {
    await localStorage.setString(_itemKey(id), jsonEncode(toJson(item)));

    final ids = localStorage.getStringList(_idsKey) ?? [];
    if (!ids.contains(id)) {
      ids.add(id);
      await localStorage.setStringList(_idsKey, ids);
    }
  }

  /// Remove a single item
  Future<void> remove(String id) async {
    await localStorage.remove(_itemKey(id));

    final ids = localStorage.getStringList(_idsKey) ?? [];
    ids.remove(id);
    await localStorage.setStringList(_idsKey, ids);
  }

  /// Get list of all IDs
  List<String> getIds() {
    return localStorage.getStringList(_idsKey) ?? [];
  }

  /// Replaces the entire local collection with a fresh snapshot (e.g. from the initial GraphQL
  /// query on load), clearing stale entries not present in [items]. Returns the new full map.
  Map<String, T> seedFromList(List<T> items, String Function(T) getId) {
    final incoming = <String, T>{for (final item in items) getId(item): item};

    for (final id in getIds()) {
      if (!incoming.containsKey(id)) {
        remove(id);
      }
    }

    for (final entry in incoming.entries) {
      set(entry.key, entry.value);
    }

    return incoming;
  }

  /// Applies one incremental change (from a `*Changes` GraphQL subscription) to both local
  /// storage and the given state map, returning the updated map.
  Map<String, T> applyChange(ChangeEvent<T> change, Map<String, T> currentState) {
    if (change.data != null) {
      set(change.id, change.data as T);
      return {...currentState, change.id: change.data as T};
    } else {
      remove(change.id);
      final newState = {...currentState};
      newState.remove(change.id);
      return newState;
    }
  }
}
