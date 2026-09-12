import 'package:flutter/material.dart';
import 'package:time_keeper/shapes.dart';

/// The shared table-header bar: a flat [ColorScheme.surfaceContainerHigh] fill
/// with a single-pixel bottom rule, squared off except for the card's own top
/// corners.
///
/// This replaces the rounded, `secondary`-colored bar that was copy-pasted
/// across a dozen views. A saturated header bar forced white header text, which
/// then had to be spelled out at every cell; a flat header lets the labels use
/// ordinary `onSurface` ink and reads as part of the table rather than a banner
/// sitting on top of it.
BoxDecoration tableHeaderDecoration(BuildContext context) {
  final theme = Theme.of(context);
  return BoxDecoration(
    color: theme.colorScheme.surfaceContainerHigh,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusCard)),
    border: Border(bottom: BorderSide(color: theme.dividerColor)),
  );
}

class TableHeaderText extends StatelessWidget {
  final String text;
  const TableHeaderText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      // A header is a label, not prose. If the column is still too tight after
      // the table's minimum width, clip it — never wrap a word down the column.
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 12,
        letterSpacing: 0.2,
      ),
    );
  }
}
