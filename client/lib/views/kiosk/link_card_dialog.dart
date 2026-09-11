import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/providers/rfid_tag_provider.dart';
import 'package:time_keeper/providers/team_member_provider.dart';
import 'package:time_keeper/widgets/dialogs/popup_dialog.dart';
import 'package:time_keeper/widgets/dialogs/toast_overlay.dart';
import 'package:time_keeper/widgets/member_search_list.dart';

void showLinkCardDialog(
  BuildContext context,
  WidgetRef ref,
  String scannedUid,
) {
  PopupDialog.warn(
    title: 'Card not found [$scannedUid]: Link Card to team member',
    message: _LinkCardContent(scannedUid: scannedUid),
    actions: [
      Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    ],
  ).show(context);
}

class _LinkCardContent extends ConsumerWidget {
  final String scannedUid;

  const _LinkCardContent({required this.scannedUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamMembers = ref.watch(teamMembersProvider);

    return SizedBox(
      width: 400,
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scanned UID: $scannedUid',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: MemberSearchList(
              teamMembers: teamMembers,
              trailingBuilder: (memberId, member) {
                return FilledButton.icon(
                  icon: const Icon(Icons.link, color: Colors.white),
                  label: const Text(
                    'Link',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    final result = await ref.read(rfidTagsProvider.notifier).create(memberId, scannedUid);

                    if (!context.mounted) return;

                    final name = member.displayName;

                    if (result.success) {
                      Navigator.of(context).pop();
                      ToastOverlay.success(
                        context,
                        title: 'Card Linked',
                        message: 'Linked card to $name',
                      );
                    } else {
                      ToastOverlay.error(
                        context,
                        title: 'Link Failed',
                        message: result.message ?? 'An error occurred',
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
