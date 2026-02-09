import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/app.dart';
import 'package:time_keeper/helpers/local_storage.dart';
import 'package:time_keeper/utils/logger.dart';

void main() async {
  // Ensure flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  TkLogger().i('Starting TK Client...');

  // Init local storage
  await initializeLocalStorage();

  runApp(ProviderScope(child: App()));
}
