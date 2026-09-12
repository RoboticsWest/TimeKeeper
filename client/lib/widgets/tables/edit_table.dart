import 'package:flutter/material.dart';
import 'package:time_keeper/widgets/tables/base_table.dart';

/// Action columns hold a single [_TableActionIconButton], so they take a fixed
/// width rather than a share of the row. Giving them flex made them as wide as a
/// data column and, on narrow layouts, stole space from columns that needed it.
/// The width leaves room for the row's cell padding on each side.
const double _actionColumnWidth = 56;

enum _TableAction { add, edit, delete }

/// Compact, colour-coded action button that fits entirely inside its action
/// column. The button is tightly sized and its splash radius clipped so the
/// hover/ripple can never overflow the cell and get cut off at the row edge.
class _TableActionIconButton extends StatelessWidget {
  final _TableAction action;
  final VoidCallback? onPressed;

  const _TableActionIconButton({required this.action, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLight = !isDark;

    final (icon, color) = switch (action) {
      _TableAction.add => (
        Icons.add,
        isLight ? Colors.green.shade700 : Colors.green.shade300,
      ),
      _TableAction.edit => (
        Icons.edit,
        isLight ? Colors.blue.shade700 : Colors.blue.shade300,
      ),
      _TableAction.delete => (Icons.delete, theme.colorScheme.error),
    };
    final tooltip = switch (action) {
      _TableAction.add => 'Add',
      _TableAction.edit => 'Edit',
      _TableAction.delete => 'Delete',
    };

    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 18),
      constraints: const BoxConstraints.tightFor(width: 28, height: 28),
      padding: EdgeInsets.zero,
      splashRadius: 14,
      style: IconButton.styleFrom(
        foregroundColor: color,
        hoverColor: color.withValues(alpha: 0.12),
        highlightColor: color.withValues(alpha: 0.16),
        disabledForegroundColor: theme.colorScheme.outline,
      ),
    );
  }
}

class EditTableRow extends BaseTableRow {
  final Key? key;
  final void Function()? onDelete;
  final void Function()? onEdit;

  EditTableRow({
    this.key,
    required super.cells,
    super.decoration,
    this.onDelete,
    this.onEdit,
  });
}

class EditTable extends BaseTable {
  final List<EditTableRow> editRows;
  final void Function(int index, Key? key)? onDelete;
  final void Function(int index, Key? key)? onEdit;
  final void Function()? onAdd;

  EditTable({
    super.key,
    List<BaseTableCell>? headers,
    required this.editRows,
    this.onDelete,
    this.onEdit,
    this.onAdd,
    super.headerDecoration,
    super.alternatingRows,
    super.evenRowColor,
    super.oddRowColor,
    super.cellPadding,
  }) : super(headers: headers, rows: editRows) {
    // Add blank columns to headers for the action buttons
    if (headers != null) {
      if (onDelete != null || editRows.any((r) => r.onDelete != null)) {
        headers.insert(0, const BaseTableCell(child: SizedBox.shrink(), width: _actionColumnWidth));
      }
      if (onEdit != null || editRows.any((r) => r.onEdit != null)) {
        headers.add(const BaseTableCell(child: SizedBox.shrink(), width: _actionColumnWidth));
      }
    }

    // Add delete and edit buttons to each row
    for (var row in editRows) {
      if (onDelete != null || row.onDelete != null) {
        row.cells.insert(
          0,
          _iconButtonCell(
            action: _TableAction.delete,
            onPressed: () {
              if (row.onDelete != null) {
                row.onDelete?.call();
              } else if (onDelete != null) {
                onDelete!(editRows.indexOf(row), row.key);
              }
            },
          ),
        );
      }

      if (onEdit != null || row.onEdit != null) {
        row.cells.add(
          _iconButtonCell(
            action: _TableAction.edit,
            onPressed: () {
              if (row.onEdit != null) {
                row.onEdit?.call();
              } else if (onEdit != null) {
                onEdit!(editRows.indexOf(row), row.key);
              }
            },
          ),
        );
      }
    }

    // Add a final row with the add button
    if (onAdd != null) {
      final lastRow = editRows.lastOrNull;

      if (lastRow != null) {
        editRows.add(
          EditTableRow(
            cells: [
              _iconButtonCell(action: _TableAction.add, onPressed: onAdd),
              ...List.generate(lastRow.cells.length - 1, (index) {
                final template = lastRow.cells[index + 1];
                return BaseTableCell(
                  child: const SizedBox.shrink(),
                  flex: template.flex ?? 1,
                  width: template.width,
                );
              }),
            ],
          ),
        );
      } else {
        editRows.add(
          EditTableRow(
            cells: [_iconButtonCell(action: _TableAction.add, onPressed: onAdd)],
          ),
        );
      }
    }
  }

  static BaseTableCell _iconButtonCell({
    required _TableAction action,
    required void Function()? onPressed,
  }) {
    return BaseTableCell(
      width: _actionColumnWidth,
      child: Center(
        child: _TableActionIconButton(action: action, onPressed: onPressed),
      ),
    );
  }
}
