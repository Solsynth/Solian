import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/chat_summary.dart';

/// A linear progress bar that slides in under the AppBar when syncing.
class ChatSyncIndicator extends HookConsumerWidget {
  const ChatSyncIndicator({super.key});

  static const double _barHeight = 3.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryLoading = ref.watch(chatSummaryProvider).isLoading;
    final isSyncing = ref.watch(chatSyncingProvider);
    final syncHint = ref.watch(chatSyncHintProvider);
    final isLoading = summaryLoading || isSyncing;
    final showHint = isSyncing && syncHint != null && syncHint.isNotEmpty;

    final controller = useAnimationController(
      duration: const Duration(milliseconds: 280),
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

    final colorScheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.2,
    );

    // Animate the full chrome (bar + optional hint) so the label isn't
    // clipped by a height factor sized only for the progress track.
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(controller.value);
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: t,
            child: Opacity(
              opacity: t.clamp(0.0, 1.0),
              child: child,
            ),
          ),
        );
      },
      child: ColoredBox(
        color: colorScheme.surfaceContainerLowest.withOpacity(0.92),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              minHeight: _barHeight,
              backgroundColor: colorScheme.surfaceContainer,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: showHint
                    ? Padding(
                        key: ValueKey(syncHint),
                        padding: const EdgeInsets.fromLTRB(16, 5, 16, 6),
                        child: Text(
                          syncHint,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: labelStyle,
                        ),
                      )
                    : const SizedBox(
                        key: ValueKey('sync-hint-hidden'),
                        width: double.infinity,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
