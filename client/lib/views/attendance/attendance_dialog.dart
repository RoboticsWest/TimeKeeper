import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/generated/api/team_member_session.pbgrpc.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/helpers/grpc_call_wrapper.dart';
import 'package:time_keeper/providers/team_member_session_provider.dart';
import 'package:time_keeper/utils/grpc_result.dart';
import 'package:time_keeper/utils/time.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';
import 'package:time_keeper/widgets/dialogs/popup_dialog.dart';
import 'package:time_keeper/widgets/dialogs/snackbar_dialog.dart';

void showAttendanceDialog(
  BuildContext context,
  WidgetRef ref, {
  required String id,
  required TeamMemberSession existing,
  required String memberName,
  required String sessionLabel,
}) {
  PopupDialog.info(
    title: 'Edit Check-In',
    message: _AttendanceForm(
      id: id,
      existing: existing,
      memberName: memberName,
      sessionLabel: sessionLabel,
    ),
    actions: const [],
  ).show(context);
}

void showDeleteAttendanceDialog(
  BuildContext context,
  WidgetRef ref, {
  required String id,
  required String memberName,
}) {
  ConfirmDialog.warn(
    title: 'Delete Check-In',
    message: Text(
      'Are you sure you want to delete the check-in record for "$memberName"?',
    ),
    confirmText: 'Delete',
    onConfirmAsyncGrpc: () async {
      final client = ref.read(teamMemberSessionServiceProvider);
      return await callGrpcEndpoint(
        () => client.deleteTeamMemberSession(
          DeleteTeamMemberSessionRequest(id: id),
        ),
      );
    },
    showResultDialog: true,
    successMessage: Text('Check-in record for "$memberName" has been deleted'),
  ).show(context);
}

class _AttendanceForm extends HookConsumerWidget {
  final String id;
  final TeamMemberSession existing;
  final String memberName;
  final String sessionLabel;

  const _AttendanceForm({
    required this.id,
    required this.existing,
    required this.memberName,
    required this.sessionLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkInDt = existing.checkInTime.toDateTime();

    final checkInDate = useState(checkInDt);
    final checkInTime = useState(TimeOfDay.fromDateTime(checkInDt));

    final hasCheckOut = existing.hasCheckOutTime();
    final checkOutDt = hasCheckOut ? existing.checkOutTime.toDateTime() : null;

    final checkOutEnabled = useState(hasCheckOut);
    final checkOutDate = useState(
      checkOutDt ?? checkInDt.add(const Duration(hours: 2)),
    );
    final checkOutTime = useState(
      TimeOfDay.fromDateTime(
        checkOutDt ?? checkInDt.add(const Duration(hours: 2)),
      ),
    );
    final isLoading = useState(false);

    return SizedBox(
      width: 450,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Read-only info
          Text(
            'Member: $memberName',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Session: $sessionLabel',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Check-in date/time
          Text('Check In', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DatePickerField(
                  label: 'Date',
                  value: checkInDate.value,
                  onChanged: (d) => checkInDate.value = d,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimePickerField(
                  label: 'Time',
                  value: checkInTime.value,
                  onChanged: (t) => checkInTime.value = t,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Check-out date/time with toggle
          Row(
            children: [
              Text('Check Out', style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              Switch(
                value: checkOutEnabled.value,
                onChanged: (v) => checkOutEnabled.value = v,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (checkOutEnabled.value)
            Row(
              children: [
                Expanded(
                  child: _DatePickerField(
                    label: 'Date',
                    value: checkOutDate.value,
                    onChanged: (d) => checkOutDate.value = d,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimePickerField(
                    label: 'Time',
                    value: checkOutTime.value,
                    onChanged: (t) => checkOutTime.value = t,
                  ),
                ),
              ],
            )
          else
            Text(
              'No check-out time (still checked in)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

          const SizedBox(height: 24),

          // Actions
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
                        final inDt = DateTime(
                          checkInDate.value.year,
                          checkInDate.value.month,
                          checkInDate.value.day,
                          checkInTime.value.hour,
                          checkInTime.value.minute,
                        );

                        isLoading.value = true;
                        try {
                          final client = ref.read(
                            teamMemberSessionServiceProvider,
                          );

                          final request = UpdateTeamMemberSessionRequest(
                            id: id,
                            checkInTime: inDt.toTimestamp(),
                          );

                          if (checkOutEnabled.value) {
                            final outDt = DateTime(
                              checkOutDate.value.year,
                              checkOutDate.value.month,
                              checkOutDate.value.day,
                              checkOutTime.value.hour,
                              checkOutTime.value.minute,
                            );

                            if (outDt.isBefore(inDt) ||
                                outDt.isAtSameMomentAs(inDt)) {
                              if (context.mounted) {
                                SnackBarDialog.info(
                                  message:
                                      'Check-out must be after check-in time',
                                ).show(context);
                              }
                              return;
                            }

                            request.checkOutTime = outDt.toTimestamp();
                          }

                          final GrpcResult<dynamic> result =
                              await callGrpcEndpoint(
                                () => client.updateTeamMemberSession(request),
                              );

                          if (context.mounted) {
                            Navigator.of(context).pop();
                            switch (result) {
                              case GrpcSuccess():
                                SnackBarDialog.success(
                                  message: 'Check-in updated successfully',
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
                    : const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text('${value.day}/${value.month}/${value.year}'),
      ),
    );
  }
}

class _TimePickerField extends StatelessWidget {
  final String label;
  final TimeOfDay value;
  final ValueChanged<TimeOfDay> onChanged;

  const _TimePickerField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: value,
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.access_time, size: 18),
        ),
        child: Text(value.format(context)),
      ),
    );
  }
}
