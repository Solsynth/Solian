import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/chat_summary.dart';

/// A linear progress bar that slides in under the AppBar when syncing.
class ChatSyncIndicator extends HookConsumerWidget {
  const ChatSyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryState = ref.watch(chatSummaryProvider).isLoading;
    final syncingState = ref.watch(chatSyncingProvider);
    final syncHint = ref.watch(chatSyncHintProvider);
    final isLoading = summaryState || syncingState;

    final controller = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    useEffect(() {
      if (isLoading) {
        controller.forward();
      } else {
        controller.reverse();
      }
      return null;
    }, [isLoading]);

    if (!isLoading && controller.isDismissed) {
      return const SizedBox.shrink();
    }

    const barHeight = 4.0;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(controller.value);
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: t,
            child: Transform.translate(
              offset: Offset(0, (t - 1) * barHeight),
              child: child,
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            minHeight: barHeight,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          ),
          if (syncingState && syncHint != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
              child: Text(
                syncHint,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
