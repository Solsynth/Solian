import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/chat_summary.dart';
import 'package:island/shared/widgets/confuse_spinner.dart';
import 'package:styled_widget/styled_widget.dart';

/// A reusable widget that shows an animated sync indicator
/// when data is being retrieved.
class ChatSyncIndicator extends HookConsumerWidget {
  final double height;

  /// List of providers to watch for loading/syncing state
  const ChatSyncIndicator({super.key, this.height = 48});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if any of the providers are loading
    final summaryState = ref.watch(chatSummaryProvider).isLoading;
    final syncingState = ref.watch(chatSyncingProvider);
    final syncHint = ref.watch(chatSyncHintProvider);
    final isLoading = summaryState || syncingState;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isLoading
          ? Padding(
              key: const ValueKey('sync-indicator'),
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + 24,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConfuseSpinner(
                        size: 20,
                        speed: 7,
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      if (syncHint != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          syncHint,
                          style: Theme.of(context).textTheme.bodySmall,
                        ).bold(),
                      ],
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox(key: ValueKey('no-sync')),
    );
  }
}
