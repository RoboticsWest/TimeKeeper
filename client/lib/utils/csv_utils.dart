import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

/// Escape a CSV field: wrap in quotes if it contains commas, quotes, or newlines.
String escapeCsvField(String field) {
  if (field.contains(',') || field.contains('"') || field.contains('\n')) {
    return '"${field.replaceAll('"', '""')}"';
  }
  return field;
}

/// Build a CSV string from headers and rows.
String buildCsv(List<String> headers, List<List<String>> rows) {
  final buffer = StringBuffer();
  buffer.writeln(headers.map(escapeCsvField).join(','));
  for (final row in rows) {
    buffer.writeln(row.map(escapeCsvField).join(','));
  }
  return buffer.toString();
}

/// Format a DateTime as RFC 3339 with local timezone offset.
String formatRfc3339(DateTime dt) {
  final local = dt.toLocal();
  final offset = local.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final hours = offset.inHours.abs().toString().padLeft(2, '0');
  final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
  final iso = local.toIso8601String();
  // Remove any trailing 'Z' or existing offset, append our offset
  final base = iso
      .replaceAll('Z', '')
      .replaceAll(RegExp(r'[+-]\d{2}:\d{2}$'), '');
  return '$base$sign$hours:$minutes';
}

/// Save a CSV string to disk using file picker save dialog.
/// Returns true if saved successfully.
Future<bool> saveCsvFile(String csv, String defaultFileName) async {
  final bytes = utf8.encode(csv);

  final path = await FilePicker.platform.saveFile(
    dialogTitle: 'Save CSV',
    fileName: defaultFileName,
    type: FileType.custom,
    allowedExtensions: ['csv'],
    bytes: kIsWeb ? Uint8List.fromList(bytes) : null,
  );

  if (path == null) return false;

  // On non-web platforms, write the file
  if (!kIsWeb) {
    final file = File(path);
    await file.writeAsBytes(bytes);
  }

  return true;
}

/// Pick a CSV file and parse it into a list of row maps.
/// Returns null if the user cancels the file picker.
Future<List<Map<String, String>>?> pickAndParseCsvFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv'],
    withData: true,
  );

  if (result == null || result.files.isEmpty) return null;

  final bytes = result.files.first.bytes;
  if (bytes == null) return null;

  final content = utf8.decode(bytes);
  final lines = const LineSplitter()
      .convert(content)
      .where((line) => line.trim().isNotEmpty)
      .toList();

  if (lines.isEmpty) return [];

  final headers = lines.first.split(',').map((h) => h.trim()).toList();
  final rows = <Map<String, String>>[];

  for (var i = 1; i < lines.length; i++) {
    final fields = lines[i].split(',').map((f) => f.trim()).toList();
    final row = <String, String>{};
    for (var j = 0; j < headers.length; j++) {
      row[headers[j]] = j < fields.length ? fields[j] : '';
    }
    rows.add(row);
  }

  return rows;
}
