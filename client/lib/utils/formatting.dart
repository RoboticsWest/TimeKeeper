/// Date, time and duration formatting.
///
/// These all live in `time_utils.dart` now, next to the UTC-to-local parsing
/// they depend on — keeping the formatters in a separate file from the parsing
/// rule is what let UTC values reach the screen unconverted in the first place.
/// This re-export keeps the existing `utils/formatting.dart` imports working.
library;

export 'package:time_keeper/utils/time_utils.dart';
