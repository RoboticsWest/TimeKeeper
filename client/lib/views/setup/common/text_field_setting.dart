import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_keeper/views/setup/common/setting_row.dart';

/// Reusable text field setting with update button
class TextFieldSetting extends StatelessWidget {
  final String label;
  final String description;
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onUpdate;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool multiline;
  final int maxLines;

  const TextFieldSetting({
    super.key,
    required this.label,
    required this.description,
    required this.controller,
    required this.hintText,
    required this.onUpdate,
    this.enabled = true,
    this.inputFormatters,
    this.keyboardType,
    this.obscureText = false,
    this.multiline = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMaxLines = multiline ? (maxLines > 1 ? maxLines : 5) : 1;
    final effectiveKeyboardType = multiline
        ? TextInputType.multiline
        : keyboardType;

    final textField = TextField(
      controller: controller,
      enabled: enabled,
      inputFormatters: inputFormatters,
      keyboardType: effectiveKeyboardType,
      obscureText: obscureText,
      maxLines: effectiveMaxLines,
      minLines: multiline ? 3 : 1,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: hintText,
        alignLabelWithHint: multiline,
      ),
    );

    final updateButton = FilledButton.icon(
      onPressed: enabled ? onUpdate : null,
      icon: const Icon(Icons.save),
      label: const Text('Update'),
    );

    return SettingRow(
      label: label,
      description: description,
      child: multiline
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                textField,
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: updateButton),
              ],
            )
          : Row(
              children: [
                Expanded(child: textField),
                const SizedBox(width: 12),
                updateButton,
              ],
            ),
    );
  }
}
