import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:time_keeper/helpers/local_storage.dart';

part 'scan_debounce_provider.g.dart';

@Riverpod(keepAlive: true)
class ScanDebounceMins extends _$ScanDebounceMins {
  static const String _key = 'scan_debounce_mins';

  void setMins(int mins) {
    localStorage.setInt(_key, mins);
    state = mins;
  }

  @override
  int build() {
    return localStorage.getInt(_key) ?? 0;
  }
}
