import 'package:flutter/material.dart';
import 'package:time_keeper/views/setup/common/setting_row.dart';

/// Reusable dropdown setting with update button
class DropdownSetting<T> extends StatelessWidget {
  final String label;
  final String description;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final VoidCallback onUpdate;

  const DropdownSetting({
    super.key,
    required this.label,
    required this.description,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.onUpdate,
  });

  /// [DropdownButton] asserts that its value is present in [items]. The
  /// settings page can pass a value before its options have loaded (or one
  /// that no longer exists), so fall back to a null selection — for
  /// `DropdownSetting<String?>` that maps to the "None" item.
  bool _contains(Object? candidate) => items.any((item) => item.value == candidate);

  @override
  Widget build(BuildContext context) {
    return SettingRow(
      label: label,
      description: description,
      child: Row(
        children: [
          Expanded(
            child: InputDecorator(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  value: _contains(value) ? value : null,
                  isExpanded: true,
                  items: items,
                  onChanged: onChanged,
                  selectedItemBuilder: (context) => items.map((item) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        (item.child is Text) ? (item.child as Text).data ?? '' : '',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(onPressed: onUpdate, icon: const Icon(Icons.save), label: const Text('Update')),
        ],
      ),
    );
  }
}
