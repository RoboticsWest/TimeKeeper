import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/generated/api/location.pbgrpc.dart';
import 'package:time_keeper/helpers/grpc_call_wrapper.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/utils/grpc_result.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';
import 'package:time_keeper/widgets/dialogs/popup_dialog.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';

void showLocationDialog(
  BuildContext context,
  WidgetRef ref, {
  String? id,
  String? existingName,
}) {
  final isEdit = id != null;

  PopupDialog.info(
    title: isEdit ? 'Edit Location' : 'Add Location',
    message: _LocationForm(
      isEdit: isEdit,
      locationId: id,
      initialName: existingName,
    ),
    actions: const [],
  ).show(context);
}

void showDeleteLocationDialog(
  BuildContext context,
  WidgetRef ref, {
  required String id,
  required String name,
}) {
  ConfirmDialog.warn(
    title: 'Delete Location',
    message: Text('Are you sure you want to delete "$name"?'),
    confirmText: 'Delete',
    onConfirmAsyncGrpc: () async {
      final client = ref.read(locationServiceProvider);
      return await callGrpcEndpoint(
        () => client.deleteLocation(DeleteLocationRequest(id: id)),
      );
    },
    showResultDialog: true,
    successMessage: Text('"$name" has been deleted'),
  ).show(context);
}

class _LocationForm extends HookConsumerWidget {
  final bool isEdit;
  final String? locationId;
  final String? initialName;

  const _LocationForm({
    required this.isEdit,
    this.locationId,
    this.initialName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController(text: initialName ?? '');
    final isLoading = useState(false);

    return SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Location Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: isLoading.value
                    ? null
                    : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: isLoading.value
                    ? null
                    : () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;

                        isLoading.value = true;
                        try {
                          final client = ref.read(locationServiceProvider);
                          final GrpcResult<dynamic> result;
                          if (isEdit) {
                            result = await callGrpcEndpoint(
                              () => client.updateLocation(
                                UpdateLocationRequest(
                                  id: locationId,
                                  location: name,
                                ),
                              ),
                            );
                          } else {
                            result = await callGrpcEndpoint(
                              () => client.createLocation(
                                CreateLocationRequest(location: name),
                              ),
                            );
                          }

                          if (context.mounted) {
                            Navigator.of(context).pop();
                            switch (result) {
                              case GrpcSuccess():
                                SnackBarDialog.success(
                                  message: isEdit
                                      ? '"$name" updated successfully'
                                      : '"$name" created successfully',
                                ).show(context);
                              case GrpcFailure():
                                SnackBarDialog.fromGrpcStatus(
                                  result: result,
                                ).show(context);
                            }
                          }
                        } finally {
                          isLoading.value = false;
                        }
                      },
                child: isLoading.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEdit ? 'Save' : 'Create'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
