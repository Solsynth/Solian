import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/widgets/message_item_wrapper.dart';
import 'package:island/data/message.dart';
import 'package:island/core/config.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class RoomMessageList extends HookConsumerWidget {
  final List<LocalChatMessage> messages;
  final AsyncValue<SnChatRoom?> roomAsync;
  final AsyncValue<SnChatMember?> chatIdentity;
  final ScrollController scrollController;
  final ListController listController;
  final bool isSelectionMode;
  final Set<String> selectedMessages;
  final VoidCallback toggleSelectionMode;
  final void Function(String) toggleMessageSelection;
  final void Function(String action, LocalChatMessage message) onMessageAction;
  final void Function(String messageId) onJump;
  final Map<String, Map<int, double?>> attachmentProgress;
  final bool disableAnimation;
  final DateTime roomOpenTime;
  final double? previousInputHeight;
  final String? lastReadAnchorMessageId;
  final VoidCallback? onFollowBack;

  const RoomMessageList({
    super.key,
    required this.messages,
    required this.roomAsync,
    required this.chatIdentity,
    required this.scrollController,
    required this.listController,
    required this.isSelectionMode,
    required this.selectedMessages,
    required this.toggleSelectionMode,
    required this.toggleMessageSelection,
    required this.onMessageAction,
    required this.onJump,
    required this.attachmentProgress,
    required this.disableAnimation,
    required this.roomOpenTime,
    this.lastReadAnchorMessageId,
    this.onFollowBack,
    this.previousInputHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    const messageKeyPrefix = 'message-';

    final bottomPadding = MediaQuery.of(context).padding.bottom + 8;

    // Track the last index returned by findChildIndexCallback to ensure
    // indices are returned in strictly increasing order (required by Flutter)
    int lastReturnedIndex = -1;

    final listWidget = SuperListView.builder(
      listController: listController,
      controller: scrollController,
      reverse: true,
      padding: EdgeInsets.only(top: 8, bottom: bottomPadding),
      itemCount: messages.length,
      findChildIndexCallback: (key) {
        // If messages is empty, return null early to avoid issues
        if (messages.isEmpty) return null;
        
        if (key is! ValueKey<String>) return null;
        
        final keyString = key.value;
        if (!keyString.startsWith(messageKeyPrefix)) return null;
        
        final messageId = keyString.substring(messageKeyPrefix.length);
        
        // Find the index, but validate it before returning
        final index = messages.indexWhere(
          (m) => (m.nonce ?? m.id) == messageId,
        );
        
        // Only return valid indices that are greater than the last returned index
        // This ensures we comply with Flutter's requirement that indices must
        // be returned in strictly increasing order during a build
        if (index > lastReturnedIndex) {
          lastReturnedIndex = index;
          return index;
        }
        
        // If the index is invalid or not in increasing order, return null
        // This will cause Flutter to create a new widget instead of reusing
        return null;
      },
      extentEstimation: (_, _) => 40,
      itemBuilder: (context, index) {
        final message = messages[index];
        final nextMessage = index < messages.length - 1
            ? messages[index + 1]
            : null;
        final isLastInGroup =
            nextMessage == null ||
            nextMessage.senderId != message.senderId ||
            nextMessage.createdAt
                    .difference(message.createdAt)
                    .inMinutes
                    .abs() >
                3;

        final key = Key('$messageKeyPrefix${message.nonce ?? message.id}');
        final showLastReadMarker =
            lastReadAnchorMessageId != null &&
            message.id == lastReadAnchorMessageId;

        return Column(
          key: key,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showLastReadMarker)
              Container(
                margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.bookmark_added,
                      size: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Last read position',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    if (onFollowBack != null)
                      TextButton(
                        onPressed: onFollowBack,
                        child: const Text('Follow back'),
                      ),
                  ],
                ),
              ),
            MessageItemWrapper(
              message: message,
              index: index,
              isLastInGroup: isLastInGroup,
              isSelectionMode: isSelectionMode,
              selectedMessages: selectedMessages,
              chatIdentity: chatIdentity,
              toggleSelectionMode: toggleSelectionMode,
              toggleMessageSelection: toggleMessageSelection,
              onMessageAction: onMessageAction,
              onJump: onJump,
              attachmentProgress: attachmentProgress,
              disableAnimation: settings.disableAnimation,
              roomOpenTime: roomOpenTime,
            ),
          ],
        );
      },
    );

    return listWidget;
  }
}
