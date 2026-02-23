import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/chat_summary.dart';
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
          ? Container(
              key: const ValueKey('sync-indicator'),
              height: height,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Row(
                spacing: 8,
                children: [
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  Text(syncHint ?? 'retrievingData'.tr())
                      .fontSize(16)
                      .textColor(
                        Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ],
              ).padding(horizontal: 22),
            )
          : const SizedBox(key: ValueKey('no-sync')),
    ).padding(top: MediaQuery.paddingOf(context).top);
  }
}
