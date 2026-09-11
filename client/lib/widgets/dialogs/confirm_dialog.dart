import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:time_keeper/utils/api_result.dart';
import 'package:time_keeper/widgets/dialogs/base_dialog.dart';
import 'package:time_keeper/widgets/dialogs/popup_dialog.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';

class ConfirmDialog extends BaseDialog {
  final PopupDialog _popupDialog;

  ConfirmDialog({
    required String title,
    required Widget message,
    required DialogType type,
    VoidCallback? onConfirm,
    Future<void> Function()? onConfirmAsync,
    Future<ApiCallResult> Function()? onConfirmAsyncApi,
    VoidCallback? onCancel,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool showResultDialog = false,
    Widget? successMessage,
  }) : _popupDialog = PopupDialog(
         title: title,
         message: message,
         type: type,
         actions: _buildActions(
           onConfirm: onConfirm,
           onConfirmAsync: onConfirmAsync,
           onConfirmAsyncApi: onConfirmAsyncApi,
           onCancel: onCancel,
           confirmText: confirmText,
           cancelText: cancelText,
           showResultDialog: showResultDialog,
           successMessage: successMessage,
         ),
       );

  @override
  void show(BuildContext context) {
    _popupDialog.show(context);
  }

  factory ConfirmDialog.info({
    required String title,
    required Widget message,
    VoidCallback? onConfirm,
    Future<void> Function()? onConfirmAsync,
    Future<ApiCallResult> Function()? onConfirmAsyncApi,
    VoidCallback? onCancel,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool showResultDialog = false,
    Widget? successMessage,
  }) {
    return ConfirmDialog(
      title: title,
      message: message,
      type: DialogType.info,
      onConfirm: onConfirm,
      onConfirmAsync: onConfirmAsync,
      onConfirmAsyncApi: onConfirmAsyncApi,
      onCancel: onCancel,
      confirmText: confirmText,
      cancelText: cancelText,
      showResultDialog: showResultDialog,
      successMessage: successMessage,
    );
  }

  factory ConfirmDialog.warn({
    required String title,
    required Widget message,
    VoidCallback? onConfirm,
    Future<void> Function()? onConfirmAsync,
    Future<ApiCallResult> Function()? onConfirmAsyncApi,
    VoidCallback? onCancel,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool showResultDialog = false,
    Widget? successMessage,
  }) {
    return ConfirmDialog(
      title: title,
      message: message,
      type: DialogType.warn,
      onConfirm: onConfirm,
      onConfirmAsync: onConfirmAsync,
      onConfirmAsyncApi: onConfirmAsyncApi,
      onCancel: onCancel,
      confirmText: confirmText,
      cancelText: cancelText,
      showResultDialog: showResultDialog,
      successMessage: successMessage,
    );
  }

  factory ConfirmDialog.error({
    required String title,
    required Widget message,
    VoidCallback? onConfirm,
    Future<void> Function()? onConfirmAsync,
    Future<ApiCallResult> Function()? onConfirmAsyncApi,
    VoidCallback? onCancel,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool showResultDialog = false,
    Widget? successMessage,
  }) {
    return ConfirmDialog(
      title: title,
      message: message,
      type: DialogType.error,
      onConfirm: onConfirm,
      onConfirmAsync: onConfirmAsync,
      onConfirmAsyncApi: onConfirmAsyncApi,
      onCancel: onCancel,
      confirmText: confirmText,
      cancelText: cancelText,
      showResultDialog: showResultDialog,
      successMessage: successMessage,
    );
  }

  static List<Widget> _buildActions({
    VoidCallback? onConfirm,
    Future<void> Function()? onConfirmAsync,
    Future<ApiCallResult> Function()? onConfirmAsyncApi,
    VoidCallback? onCancel,
    required String confirmText,
    required String cancelText,
    required bool showResultDialog,
    Widget? successMessage,
  }) {
    assert(
      onConfirm != null || onConfirmAsync != null || onConfirmAsyncApi != null,
      'Either onConfirm, onConfirmAsync, or onConfirmAsyncGrpc must be provided',
    );
    assert(
      (onConfirm != null ? 1 : 0) +
              (onConfirmAsync != null ? 1 : 0) +
              (onConfirmAsyncApi != null ? 1 : 0) ==
          1,
      'Only one of onConfirm, onConfirmAsync, or onConfirmAsyncGrpc can be provided',
    );

    return [
      Builder(
        builder: (context) => TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onCancel?.call();
          },
          child: Text(cancelText),
        ),
      ),
      const SizedBox(width: 8),
      if (onConfirm != null)
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: Text(confirmText),
          ),
        )
      else if (onConfirmAsync != null)
        _AsyncConfirmButton(
          confirmText: confirmText,
          onConfirmAsync: onConfirmAsync,
          showResultDialog: showResultDialog,
          successMessage: successMessage,
        )
      else if (onConfirmAsyncApi != null)
        _AsyncApiConfirmButton(
          confirmText: confirmText,
          onConfirmAsyncApi: onConfirmAsyncApi,
          showResultDialog: showResultDialog,
          successMessage: successMessage,
        ),
    ];
  }
}

class _AsyncConfirmButton extends HookWidget {
  final String confirmText;
  final Future<void> Function() onConfirmAsync;
  final bool showResultDialog;
  final Widget? successMessage;

  const _AsyncConfirmButton({
    required this.confirmText,
    required this.onConfirmAsync,
    required this.showResultDialog,
    this.successMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(false);

    Future<void> handleConfirm() async {
      if (isLoading.value) return;

      isLoading.value = true;

      try {
        await onConfirmAsync();
        if (context.mounted) {
          Navigator.of(context).pop();

          if (showResultDialog) {
            SnackBarDialog.success(
              message: successMessage is Text
                  ? (successMessage as Text).data ?? 'Success'
                  : 'Success',
            ).show(context);
          }
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop();

          if (showResultDialog) {
            PopupDialog.error(
              title: 'Error',
              message: Text('Operation failed: $e'),
            ).show(context);
          }
        }
      } finally {
        isLoading.value = false;
      }
    }

    return ElevatedButton(
      onPressed: isLoading.value ? null : handleConfirm,
      child: isLoading.value
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(confirmText),
    );
  }
}

class _AsyncApiConfirmButton extends HookWidget {
  final String confirmText;
  final Future<ApiCallResult> Function() onConfirmAsyncApi;
  final bool showResultDialog;
  final Widget? successMessage;

  const _AsyncApiConfirmButton({
    required this.confirmText,
    required this.onConfirmAsyncApi,
    required this.showResultDialog,
    this.successMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(false);

    Future<void> handleConfirm() async {
      if (isLoading.value) return;

      isLoading.value = true;

      try {
        final result = await onConfirmAsyncApi();

        if (context.mounted) {
          Navigator.of(context).pop();

          if (showResultDialog) {
            if (result.success) {
              SnackBarDialog.success(
                message: successMessage is Text
                    ? (successMessage as Text).data ?? 'Success'
                    : 'Success',
              ).show(context);
            } else {
              PopupDialog.fromApiResult(result: result).show(context);
            }
          }
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop();

          if (showResultDialog) {
            PopupDialog.error(
              title: 'Error',
              message: Text('Unexpected error: $e'),
            ).show(context);
          }
        }
      } finally {
        isLoading.value = false;
      }
    }

    return ElevatedButton(
      onPressed: isLoading.value ? null : handleConfirm,
      child: isLoading.value
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(confirmText),
    );
  }
}
