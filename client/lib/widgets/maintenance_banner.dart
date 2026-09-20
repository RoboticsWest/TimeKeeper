import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:time_keeper/models/settings.dart';
import 'package:time_keeper/providers/settings_provider.dart';

/// Bottom-of-screen notice shown while the server is in maintenance mode.
///
/// Advisory only — it does not block the UI. Maintenance mode exists for the window where a
/// deploy is half-finished, so the client still has to work; the point is that users understand
/// why something might be missing rather than filing it as a bug.
///
/// Dismissal is per-message: dismissing hides this notice, but if the operator changes the
/// reason (or turns maintenance off and on again) it comes back, since that is new information.
class MaintenanceBanner extends HookConsumerWidget {
  const MaintenanceBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watched, not read once: the settings subscription pushes the flag, so toggling maintenance
    // on the server shows the banner on every connected client without a refresh.
    final settings = ref.watch(settingsQueryProvider).value;
    final enabled = settings?.maintenanceMode ?? false;
    final message = settings?.maintenanceBannerText ?? Settings.defaultMaintenanceMessage;

    final dismissedMessage = useState<String?>(null);

    if (!enabled || dismissedMessage.value == message) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Amber rather than the error red: maintenance is expected and temporary, and reserving red
    // for genuine failures keeps it meaningful.
    final accent = isDark ? Colors.amber.shade300 : Colors.amber.shade800;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.16 : 0.12),
                  border: Border.all(color: accent.withValues(alpha: 0.7)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.construction, size: 20, color: accent),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        message,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Dismiss',
                      icon: const Icon(Icons.close, size: 18),
                      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                      padding: EdgeInsets.zero,
                      color: accent,
                      onPressed: () => dismissedMessage.value = message,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
