import 'package:flutter/material.dart';

class TableFilter extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const TableFilter({
    super.key,
    required this.controller,
    this.hintText = 'Filter...',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            if (controller.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () => controller.clear(),
            );
          },
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
