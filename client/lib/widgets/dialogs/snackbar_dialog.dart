import 'package:flutter/material.dart';
import 'package:time_keeper/colors.dart';
import 'package:time_keeper/utils/api_result.dart';
import 'package:time_keeper/widgets/dialogs/base_dialog.dart';

class SnackBarDialog extends BaseDialog {
  final String message;
  final DialogType type;

  SnackBarDialog({required this.message, required this.type});

  factory SnackBarDialog.info({required String message}) {
    return SnackBarDialog(message: message, type: DialogType.info);
  }

  factory SnackBarDialog.success({required String message}) {
    return SnackBarDialog(message: message, type: DialogType.success);
  }

  factory SnackBarDialog.error({required String message}) {
    return SnackBarDialog(message: message, type: DialogType.error);
  }

  factory SnackBarDialog.warn({required String message}) {
    return SnackBarDialog(message: message, type: DialogType.warn);
  }

  static SnackBarDialog fromApiResult({required ApiCallResult result}) {
    if (result.success) {
      return SnackBarDialog.success(message: 'Success');
    }
    return SnackBarDialog.error(message: result.message ?? 'An error occurred');
  }

  @override
  void show(BuildContext context) {
    Color color;
    switch (type) {
      case DialogType.error:
        color = supportErrorColor;
        break;
      case DialogType.info:
        color = supportInfoColor;
        break;
      case DialogType.warn:
        color = supportWarningColor;
        break;
      case DialogType.success:
        color = supportSuccessColor;
        break;
    }

    final messenger = ScaffoldMessenger.of(context);
    // Clear any existing snackbars before showing new one
    messenger.clearSnackBars();
    messenger.showSnackBar(SnackBar(backgroundColor: color, content: Text(message)));
  }
}
