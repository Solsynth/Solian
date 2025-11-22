import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:island/database/message.dart';
import 'package:island/models/chat.dart';
import 'package:island/widgets/chat/message_item.dart';

// Provider to track animated messages to prevent replay
final animatedMessagesProvider = StateProvider<Set<String>>((ref) => {});

class MessageItemWrapper extends HookConsumerWidget {
  final LocalChatMessage message;
  final int index;
  final bool isLastInGroup;
  final bool isSelectionMode;
  final Set<String> selectedMessages;
  final AsyncValue<SnChatMember?> chatIdentity;
  final VoidCallback toggleSelectionMode;
  final Function(String) toggleMessageSelection;
  final Function(String, LocalChatMessage) onMessageAction;
  final Function(String) onJump;
  final Map<String, Map<int, double?>> attachmentProgress;
  final bool disableAnimation;
  final DateTime roomOpenTime;

  const MessageItemWrapper({
    super.key,
    required this.message,
    required this.index,
    required this.isLastInGroup,
    required this.isSelectionMode,
    required this.selectedMessages,
    required this.chatIdentity,
    required this.toggleSelectionMode,
    required this.toggleMessageSelection,
    required this.onMessageAction,
    required this.onJump,
    required this.attachmentProgress,
    required this.disableAnimation,
    required this.roomOpenTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Animation logic
    final animatedMessages = ref.watch(animatedMessagesProvider);
    final isNewMessage = message.createdAt.isAfter(roomOpenTime);
    final hasAnimated = animatedMessages.contains(message.id);

    // Only animate if:
    // 1. Animation is enabled
    // 2. Message is new (created after room open)
    // 3. Has not animated yet
    final shouldAnimate = !disableAnimation && isNewMessage && !hasAnimated;

    final child = chatIdentity.when(
      skipError: true,
      data: (identity) => _buildContent(context, identity),
      loading: () => _buildLoading(),
      error: (_, _) => const SizedBox.shrink(),
    );

    if (!shouldAnimate) {
      return child;
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey('anim-${message.id}'), // Ensure unique key for animation
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index % 5) * 50),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      onEnd: () {
        // Mark as animated
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(animatedMessagesProvider.notifier)
              .update((state) => {...state, message.id});
        });
      },
      child: child,
    );
  }

  Widget _buildContent(BuildContext context, SnChatMember? identity) {
    final isSelected = selectedMessages.contains(message.id);
    final isCurrentUser = identity?.id == message.senderId;

    return GestureDetector(
      onLongPress: () {
        if (!isSelectionMode) {
          toggleSelectionMode();
          toggleMessageSelection(message.id);
        }
      },
      onTap: () {
        if (isSelectionMode) {
          toggleMessageSelection(message.id);
        }
      },
      child: Container(
        color:
            isSelected
                ? Theme.of(
                  context,
                ).colorScheme.primaryContainer.withOpacity(0.3)
                : null,
        child: Stack(
          children: [
            MessageItem(
              // If animation is disabled, we might want to pass a key to maintain state?
              // But here we are inside the wrapper.
              key: ValueKey('item-${message.id}'),
              message: message,
              isCurrentUser: isCurrentUser,
              onAction:
                  isSelectionMode
                      ? null
                      : (action) => onMessageAction(action, message),
              onJump: onJump,
              progress: attachmentProgress[message.id],
              showAvatar: isLastInGroup,
              isSelectionMode: isSelectionMode,
              isSelected: isSelected,
              onToggleSelection: toggleMessageSelection,
              onEnterSelectionMode: () {
                if (!isSelectionMode) toggleSelectionMode();
              },
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 12,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return MessageItem(
      message: message,
      isCurrentUser: false,
      onAction: null,
      progress: null,
      showAvatar: false,
      onJump: (_) {},
    );
  }
}
