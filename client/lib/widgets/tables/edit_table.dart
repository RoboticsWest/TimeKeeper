import 'package:flutter/material.dart';
import 'package:time_keeper/widgets/tables/base_table.dart';

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
    Widget deleteIcon = const Icon(Icons.delete, color: Colors.red),
    Widget editIcon = const Icon(Icons.edit, color: Colors.blue),
    Widget addIcon = const Icon(Icons.add, color: Colors.green),
    super.headerDecoration,
    super.alternatingRows,
    super.evenRowColor,
    super.oddRowColor,
    super.cellPadding,
  }) : super(headers: headers, rows: editRows) {
    // Add blank columns to headers for the action buttons
    if (headers != null) {
      if (onDelete != null || editRows.any((r) => r.onDelete != null)) {
        headers.insert(0, const BaseTableCell(child: SizedBox.shrink()));
      }
      if (onEdit != null || editRows.any((r) => r.onEdit != null)) {
        headers.add(const BaseTableCell(child: SizedBox.shrink()));
      }
    }

    // Add delete and edit buttons to each row
    for (var row in editRows) {
      if (onDelete != null || row.onDelete != null) {
        row.cells.insert(
          0,
          _iconButtonCell(
            onPressed: () {
              if (row.onDelete != null) {
                row.onDelete?.call();
              } else if (onDelete != null) {
                onDelete!(editRows.indexOf(row), row.key);
              }
            },
            icon: deleteIcon,
          ),
        );
      }

      if (onEdit != null || row.onEdit != null) {
        row.cells.add(
          _iconButtonCell(
            onPressed: () {
              if (row.onEdit != null) {
                row.onEdit?.call();
              } else if (onEdit != null) {
                onEdit!(editRows.indexOf(row), row.key);
              }
            },
            icon: editIcon,
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
              _iconButtonCell(onPressed: onAdd, icon: addIcon),
              ...List.generate(lastRow.cells.length - 1, (index) {
                return BaseTableCell(
                  child: const SizedBox.shrink(),
                  flex: lastRow.cells[index].flex ?? 1,
                );
              }),
            ],
          ),
        );
      } else {
        editRows.add(
          EditTableRow(
            cells: [_iconButtonCell(icon: addIcon, onPressed: onAdd)],
          ),
        );
      }
    }
  }

  static BaseTableCell _iconButtonCell({
    void Function()? onPressed,
    required Widget icon,
  }) {
    return BaseTableCell(
      child: Center(
        child: IconButton(icon: icon, onPressed: onPressed),
      ),
    );
  }
}
