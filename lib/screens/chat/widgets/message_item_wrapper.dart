import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:island/database/message.dart';
import 'package:island/models/chat.dart';
import 'package:island/widgets/chat/message_item.dart';

class MessageItemWrapper extends ConsumerWidget {
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
  final DateTime roomOpenTime;
  final bool disableAnimation;

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
    required this.roomOpenTime,
    required this.disableAnimation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return chatIdentity.when(
      skipError: true,
      data: (identity) => _buildContent(context, identity),
      loading: () => _buildLoading(),
      error: (_, _) => const SizedBox.shrink(),
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
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
            : null,
        child: Stack(
          children: [
            MessageItem(
              // If animation is disabled, we might want to pass a key to maintain state?
              // But here we are inside the wrapper.
              key: ValueKey('item-${message.id}'),
              message: message,
              isCurrentUser: isCurrentUser,
              onAction: isSelectionMode
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
