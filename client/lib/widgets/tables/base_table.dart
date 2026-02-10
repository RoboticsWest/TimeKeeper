import 'package:flutter/material.dart';

class BaseTableCell {
  final Widget child;
  final int? flex;

  const BaseTableCell({required this.child, this.flex});
}

class BaseTableRow {
  final List<BaseTableCell> cells;
  final BoxDecoration? decoration;

  const BaseTableRow({required this.cells, this.decoration});
}

class BaseTable extends StatelessWidget {
  final List<BaseTableCell>? headers;
  final List<BaseTableRow> rows;
  final BoxDecoration? headerDecoration;
  final bool alternatingRows;
  final Color? evenRowColor;
  final Color? oddRowColor;
  final EdgeInsets cellPadding;

  const BaseTable({
    super.key,
    this.headers,
    required this.rows,
    this.headerDecoration,
    this.alternatingRows = false,
    this.evenRowColor,
    this.oddRowColor,
    this.cellPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  Widget cellWidget(Widget child, int flex) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: cellPadding,
        child: Center(child: child),
      ),
    );
  }

  Widget headerWidgets(BuildContext context) {
    if (headers == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Row(
      children: headers!.map((cell) {
        return cellWidget(
          DefaultTextStyle.merge(
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            child: cell.child,
          ),
          cell.flex ?? 1,
        );
      }).toList(),
    );
  }

  BoxDecoration? _rowDecoration(int index, BuildContext context) {
    if (!alternatingRows) return null;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (index.isEven) {
      return BoxDecoration(
        color:
            evenRowColor ??
            (isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.black.withValues(alpha: 0.02)),
      );
    } else {
      return BoxDecoration(
        color:
            oddRowColor ??
            (isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.black.withValues(alpha: 0.05)),
      );
    }
  }

  Widget tableRowWidget(BaseTableRow row) {
    return Row(
      children: [
        for (var cell in row.cells) cellWidget(cell.child, cell.flex ?? 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(decoration: headerDecoration, child: headerWidgets(context)),
        Flexible(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: List.generate(rows.length, (index) {
                final row = rows[index];
                return Container(
                  decoration: row.decoration ?? _rowDecoration(index, context),
                  child: tableRowWidget(row),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
