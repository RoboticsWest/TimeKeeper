import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/generated/api/session.pbgrpc.dart';
import 'package:time_keeper/generated/db/db.pb.dart';
import 'package:time_keeper/helpers/grpc_call_wrapper.dart';
import 'package:time_keeper/providers/location_provider.dart';
import 'package:time_keeper/providers/session_provider.dart';
import 'package:time_keeper/utils/time.dart';
import 'package:time_keeper/utils/formatting.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';
import 'package:time_keeper/widgets/dialogs/popup_dialog.dart';

void showSessionDialog(
  BuildContext context,
  WidgetRef ref, {
  String? id,
  Session? existingSession,
}) {
  final isEdit = id != null;

  PopupDialog.info(
    title: isEdit ? 'Edit Session' : 'Create Session',
    message: _SessionForm(
      ref: ref,
      isEdit: isEdit,
      sessionId: id,
      existingSession: existingSession,
    ),
    actions: const [],
  ).show(context);
}

void showDeleteSessionDialog(
  BuildContext context,
  WidgetRef ref, {
  required String id,
  required Session session,
}) {
  final start = session.startTime.toDateTime();
  final label = '${formatDate(start)} ${formatTime(start)}';

  ConfirmDialog.warn(
    title: 'Delete Session',
    message: Text('Are you sure you want to delete the session on $label?'),
    confirmText: 'Delete',
    onConfirmAsyncGrpc: () async {
      final client = ref.read(sessionServiceProvider);
      return await callGrpcEndpoint(
        () => client.deleteSession(DeleteSessionRequest(id: id)),
      );
    },
    showResultDialog: true,
    successMessage: const Text('Session has been deleted'),
  ).show(context);
}

class _SessionForm extends HookWidget {
  final WidgetRef ref;
  final bool isEdit;
  final String? sessionId;
  final Session? existingSession;

  const _SessionForm({
    required this.ref,
    required this.isEdit,
    this.sessionId,
    this.existingSession,
  });

  @override
  Widget build(BuildContext context) {
    final locations = ref.watch(locationsProvider);

    final now = DateTime.now();
    final existingStart = existingSession?.startTime.toDateTime();
    final existingEnd = existingSession?.endTime.toDateTime();

    final startDate = useState(existingStart ?? now);
    final startTime = useState(TimeOfDay.fromDateTime(existingStart ?? now));
    final endDate = useState(existingEnd ?? now.add(const Duration(hours: 2)));
    final endTime = useState(
      TimeOfDay.fromDateTime(existingEnd ?? now.add(const Duration(hours: 2))),
    );
    final selectedLocationId = useState<String?>(existingSession?.locationId);
    final finished = useState(existingSession?.finished ?? false);

    final locationEntries = locations.entries.toList()
      ..sort((a, b) => a.value.location.compareTo(b.value.location));

    // Default to first location if none selected
    if (selectedLocationId.value == null && locationEntries.isNotEmpty) {
      selectedLocationId.value = locationEntries.first.key;
    }

    return SizedBox(
      width: 450,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Start date/time
          Text('Start', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DatePickerField(
                  label: 'Date',
                  value: startDate.value,
                  onChanged: (d) => startDate.value = d,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimePickerField(
                  label: 'Time',
                  value: startTime.value,
                  onChanged: (t) => startTime.value = t,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // End date/time
          Text('End', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DatePickerField(
                  label: 'Date',
                  value: endDate.value,
                  onChanged: (d) => endDate.value = d,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimePickerField(
                  label: 'Time',
                  value: endTime.value,
                  onChanged: (t) => endTime.value = t,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Location
          Text('Location', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: selectedLocationId.value,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: locationEntries
                .map(
                  (entry) => DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value.location),
                  ),
                )
                .toList(),
            onChanged: (value) => selectedLocationId.value = value,
          ),

          // Finished toggle (only for edit)
          if (isEdit) ...[
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Finished'),
              value: finished.value,
              onChanged: (value) => finished.value = value,
              contentPadding: EdgeInsets.zero,
            ),
          ],

          const SizedBox(height: 24),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  final locationId = selectedLocationId.value;
                  if (locationId == null) return;

                  final startDt = DateTime(
                    startDate.value.year,
                    startDate.value.month,
                    startDate.value.day,
                    startTime.value.hour,
                    startTime.value.minute,
                  );
                  final endDt = DateTime(
                    endDate.value.year,
                    endDate.value.month,
                    endDate.value.day,
                    endTime.value.hour,
                    endTime.value.minute,
                  );

                  if (endDt.isBefore(startDt) ||
                      endDt.isAtSameMomentAs(startDt)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('End time must be after start time'),
                      ),
                    );
                    return;
                  }

                  final label = '${formatDate(startDt)} ${formatTime(startDt)}';
                  Navigator.of(context).pop();

                  ConfirmDialog.info(
                    title: isEdit ? 'Update Session' : 'Create Session',
                    message: Text(
                      isEdit
                          ? 'Save changes to session on $label?'
                          : 'Create session on $label?',
                    ),
                    confirmText: isEdit ? 'Save' : 'Create',
                    onConfirmAsyncGrpc: () async {
                      final client = ref.read(sessionServiceProvider);
                      if (isEdit) {
                        return await callGrpcEndpoint(
                          () => client.updateSession(
                            UpdateSessionRequest(
                              id: sessionId,
                              startTime: startDt.toTimestamp(),
                              endTime: endDt.toTimestamp(),
                              locationId: locationId,
                              finished: finished.value,
                            ),
                          ),
                        );
                      } else {
                        return await callGrpcEndpoint(
                          () => client.createSession(
                            CreateSessionRequest(
                              startTime: startDt.toTimestamp(),
                              endTime: endDt.toTimestamp(),
                              locationId: locationId,
                            ),
                          ),
                        );
                      }
                    },
                    showResultDialog: true,
                    successMessage: Text(
                      isEdit
                          ? 'Session updated successfully'
                          : 'Session created successfully',
                    ),
                  ).show(context);
                },
                child: Text(isEdit ? 'Save' : 'Create'),
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
