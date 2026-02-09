import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/generated/api/team_member.pbgrpc.dart';
import 'package:time_keeper/helpers/grpc_call_wrapper.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/utils/grpc_result.dart';
import 'package:time_keeper/views/setup/common/file_upload_setting.dart';
import 'package:time_keeper/views/setup/common/settings_page_layout.dart';
import 'package:time_keeper/widgets/dialogs/confirm_dialog.dart';

class MemberSetupTab extends HookConsumerWidget {
  const MemberSetupTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<GrpcResult<UploadStudentCsvResponse>> uploadStudentCsv(
      Uint8List bytes,
    ) async {
      final req = UploadStudentCsvRequest(csvData: bytes);
      return await callGrpcEndpoint(
        () => ref.read(teamMemberServiceProvider).uploadStudentCsv(req),
      );
    }

    Future<GrpcResult<UploadMentorCsvResponse>> uploadMentorCsv(
      Uint8List bytes,
    ) async {
      final req = UploadMentorCsvRequest(csvData: bytes);
      return await callGrpcEndpoint(
        () => ref.read(teamMemberServiceProvider).uploadMentorCsv(req),
      );
    }

    return SettingsPageLayout(
      title: 'Team Member Setup',
      subtitle: 'Configure your team settings',
      children: [
        FileUploadSetting(
          label: 'Upload Student CSV',
          description: 'Upload a CSV file containing the student data',
          allowedExtensions: ['csv'],
          uploadButtonLabel: 'Upload',
          onUpload: (file) async {
            if (file.bytes != null) {
              ConfirmDialog.warn(
                title: 'Confirm Upload',
                message: const Text(
                  'Uploading students can have impacts on existing data integrity',
                ),
                onConfirmAsyncGrpc: () async {
                  return await uploadStudentCsv(file.bytes!);
                },
                showResultDialog: true,
                successMessage: const Text('Students uploaded successfully!'),
              ).show(context);
            }
          },
        ),
        const SizedBox(height: 24),
        FileUploadSetting(
          label: 'Upload Mentor CSV',
          description: 'Upload a CSV file containing the mentor data',
          allowedExtensions: ['csv'],
          uploadButtonLabel: 'Upload',
          onUpload: (file) async {
            if (file.bytes != null) {
              ConfirmDialog.warn(
                title: 'Confirm Upload',
                message: const Text(
                  'Uploading mentors can have impacts on existing data integrity',
                ),
                onConfirmAsyncGrpc: () async {
                  return await uploadMentorCsv(file.bytes!);
                },
                showResultDialog: true,
                successMessage: const Text('Mentors uploaded successfully!'),
              ).show(context);
            }
          },
        ),
      ],
    );
  }
}
