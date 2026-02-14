import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// A dropdown-like field that opens a dialog with a search box and
/// scrollable list. Items are displayed in the exact order provided.
class SearchableDropdown extends StatelessWidget {
  final String label;
  final List<({String key, String label})> items;
  final String? selectedKey;
  final ValueChanged<String> onSelected;

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.items,
    this.selectedKey,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final selectedLabel =
        items
            .where((item) => item.key == selectedKey)
            .map((item) => item.label)
            .firstOrNull ??
        '';

    return InkWell(
      onTap: () async {
        final result = await showDialog<String>(
          context: context,
          builder: (context) => _SearchDialog(
            title: label,
            items: items,
            selectedKey: selectedKey,
          ),
        );
        if (result != null) {
          onSelected(result);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          selectedLabel,
          overflow: TextOverflow.ellipsis,
          style: selectedLabel.isEmpty
              ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).hintColor,
                )
              : null,
        ),
      ),
    );
  }
}

class _SearchDialog extends HookWidget {
  final String title;
  final List<({String key, String label})> items;
  final String? selectedKey;

  const _SearchDialog({
    required this.title,
    required this.items,
    this.selectedKey,
  });

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final searchText = useState('');

    final filtered = searchText.value.isEmpty
        ? items
        : items
              .where(
                (item) => item.label.toLowerCase().contains(
                  searchText.value.toLowerCase(),
                ),
              )
              .toList();

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 400),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (value) => searchText.value = value,
              ),
              const SizedBox(height: 8),
              Flexible(
                child: filtered.isEmpty
                    ? const Center(child: Text('No results'))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final isSelected = item.key == selectedKey;
                          return ListTile(
                            dense: true,
                            selected: isSelected,
                            title: Text(item.label),
                            trailing: isSelected
                                ? const Icon(Icons.check, size: 18)
                                : null,
                            onTap: () => Navigator.of(context).pop(item.key),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
