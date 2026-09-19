import 'package:flutter/material.dart';

class BaseTableCell {
  final Widget child;
  final int? flex;

  /// A fixed column width, in logical pixels. Takes precedence over [flex] —
  /// use it for columns whose content never grows, such as an icon button.
  final double? width;

  const BaseTableCell({required this.child, this.flex, this.width});
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

  /// Width given to one unit of [BaseTableCell.flex] before the table gives up
  /// on fitting and scrolls horizontally instead.
  ///
  /// Flex columns divide whatever width they are handed, with no floor, so on a
  /// narrow window an eight-column table squeezed every cell to a few dozen
  /// pixels: header labels wrapped one character per line ("Loca / tion"),
  /// chips clipped mid-word and buttons overflowed their cells. Scrolling is
  /// the honest answer — a table with this many columns genuinely does not fit
  /// a phone-width pane, and shrinking it further only destroys it.
  final double minFlexWidth;

  const BaseTable({
    super.key,
    this.headers,
    required this.rows,
    this.headerDecoration,
    this.alternatingRows = false,
    this.evenRowColor,
    this.oddRowColor,
    this.cellPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    this.minFlexWidth = 120,
  });

  Widget cellWidget(BaseTableCell cell) {
    final content = Padding(
      padding: cellPadding,
      child: Center(child: cell.child),
    );

    if (cell.width != null) {
      return SizedBox(width: cell.width, child: content);
    }
    return Expanded(flex: cell.flex ?? 1, child: content);
  }

  Widget headerWidgets(BuildContext context) {
    if (headers == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Row(
      children: headers!.map((cell) {
        return cellWidget(
          BaseTableCell(
            flex: cell.flex,
            width: cell.width,
            child: DefaultTextStyle.merge(
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              child: cell.child,
            ),
          ),
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
        color: evenRowColor ?? (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02)),
      );
    } else {
      return BoxDecoration(
        color: oddRowColor ?? (isDark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.05)),
      );
    }
  }

  Widget tableRowWidget(BaseTableRow row) {
    return Row(children: [for (final cell in row.cells) cellWidget(cell)]);
  }

  /// The width below which the table scrolls instead of squeezing: every fixed
  /// column at its stated width, plus [minFlexWidth] per flex unit.
  double _naturalWidth() {
    final template = headers ?? (rows.isEmpty ? null : rows.first.cells);
    if (template == null) return 0;

    var total = 0.0;
    for (final cell in template) {
      total += cell.width ?? (cell.flex ?? 1) * minFlexWidth;
    }
    return total;
  }

  Widget _table(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final natural = _naturalWidth();
        if (!constraints.maxWidth.isFinite || constraints.maxWidth >= natural) {
          return _table(context);
        }
        return _HorizontalOverflow(width: natural, child: _table(context));
      },
    );
  }
}

/// Scrolls [child] sideways at a fixed [width]. Separate widget only because
/// an interactive [Scrollbar] needs a controller, and [BaseTable] is stateless
/// so that [EditTable] can keep extending it.
class _HorizontalOverflow extends StatefulWidget {
  final double width;
  final Widget child;

  const _HorizontalOverflow({required this.width, required this.child});

  @override
  State<_HorizontalOverflow> createState() => _HorizontalOverflowState();
}

class _HorizontalOverflowState extends State<_HorizontalOverflow> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controller,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        // Leaves room for the always-visible scrollbar so it never sits on top
        // of the last row.
        padding: const EdgeInsets.only(bottom: 10),
        child: SizedBox(width: widget.width, child: widget.child),
      ),
    );
  }
}
