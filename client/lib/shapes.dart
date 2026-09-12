import 'package:flutter/widgets.dart';

/// Corner radii for the app. Two values only — anything else is a mistake.
///
/// Rows, controls, inputs and chips are [kRadiusRow]; cards and panels are
/// [kRadiusCard]. Keeping the set this small is what makes the UI read as
/// dense and deliberate rather than soft.
const double kRadiusRow = 4;
const double kRadiusCard = 6;

const BorderRadius kBorderRadiusRow = BorderRadius.all(Radius.circular(kRadiusRow));
const BorderRadius kBorderRadiusCard = BorderRadius.all(Radius.circular(kRadiusCard));
