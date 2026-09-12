import 'package:flutter/material.dart';
import 'package:time_keeper/widgets/tables/header_text.dart';

/// One column of a [DataGrid].
class GridColumn<T> {
  final String label;
  final int flex;
  final Alignment alignment;

  /// Cell content for a row.
  final Widget Function(T row) cell;

  /// Comparator for this column. Null makes the column unsortable.
  final int Function(T a, T b)? compare;

  const GridColumn({
    required this.label,
    required this.cell,
    this.flex = 1,
    this.alignment = Alignment.centerLeft,
    this.compare,
  });
}

/// A dense, sortable, lazily built table.
///
/// Built fresh rather than extending `BaseTable`, which centers every cell, has
/// no sort affordance and builds all rows eagerly — none of which suit a grid
/// that may hold every member on the team. `BaseTable` is untouched and still
/// serves its other callers.
class DataGrid<T> extends StatefulWidget {
  final List<GridColumn<T>> columns;
  final List<T> rows;

  /// Index into [columns] to sort by initially. Null leaves [rows] in the order given.
  final int? initialSortColumn;
  final bool initialSortAscending;
  final double rowHeight;
  final String emptyMessage;

  const DataGrid({
    super.key,
    required this.columns,
    required this.rows,
    this.initialSortColumn,
    this.initialSortAscending = false,
    this.rowHeight = 32,
    this.emptyMessage = 'No rows',
  });

  @override
  State<DataGrid<T>> createState() => _DataGridState<T>();
}

class _DataGridState<T> extends State<DataGrid<T>> {
  int? _sortColumn;
  late bool _ascending;

  @override
  void initState() {
    super.initState();
    _sortColumn = widget.initialSortColumn;
    _ascending = widget.initialSortAscending;
  }

  List<T> get _sorted {
    final column = _sortColumn;
    if (column == null) return widget.rows;
    final compare = widget.columns[column].compare;
    if (compare == null) return widget.rows;

    final rows = List<T>.of(widget.rows);
    rows.sort((a, b) => _ascending ? compare(a, b) : compare(b, a));
    return rows;
  }

  void _toggleSort(int index) {
    if (widget.columns[index].compare == null) return;
    setState(() {
      if (_sortColumn == index) {
        _ascending = !_ascending;
      } else {
        _sortColumn = index;
        _ascending = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = _sorted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 28,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            border: Border(bottom: BorderSide(color: theme.dividerColor)),
          ),
          child: Row(
            children: [
              for (var i = 0; i < widget.columns.length; i++)
                Expanded(
                  flex: widget.columns[i].flex,
                  child: InkWell(
                    onTap: widget.columns[i].compare == null ? null : () => _toggleSort(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Align(
                        alignment: widget.columns[i].alignment,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(child: TableHeaderText(widget.columns[i].label)),
                            if (_sortColumn == i)
                              Icon(
                                _ascending ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                size: 16,
                                color: theme.colorScheme.onSurface,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: rows.isEmpty
              ? Center(
                  child: Text(
                    widget.emptyMessage,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                  ),
                )
              : ListView.builder(
                  itemCount: rows.length,
                  itemExtent: widget.rowHeight,
                  itemBuilder: (context, index) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: index.isOdd
                            ? theme.colorScheme.surfaceContainerLow
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          for (final column in widget.columns)
                            Expanded(
                              flex: column.flex,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Align(
                                  alignment: column.alignment,
                                  child: DefaultTextStyle.merge(
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    child: column.cell(rows[index]),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
