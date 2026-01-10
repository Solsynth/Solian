import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/database/message.dart';
import 'package:island/models/chat.dart';
import 'package:island/pods/config.dart';
import 'package:island/screens/chat/widgets/message_item_wrapper.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

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
  final double inputHeight;
  final double? previousInputHeight;

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
    required this.inputHeight,
    this.previousInputHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    const messageKeyPrefix = 'message-';

    final bottomPadding =
        inputHeight + MediaQuery.of(context).padding.bottom + 8;

    final listWidget =
        previousInputHeight != null && previousInputHeight != inputHeight
        ? TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: previousInputHeight, end: inputHeight),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            builder: (context, height, child) => SuperListView.builder(
              listController: listController,
              controller: scrollController,
              reverse: true,
              padding: EdgeInsets.only(
                top: 8,
                bottom: height + MediaQuery.of(context).padding.bottom + 8,
              ),
              itemCount: messages.length,
              findChildIndexCallback: (key) {
                if (key is! ValueKey<String>) return null;
                final messageId = key.value.substring(messageKeyPrefix.length);
                final index = messages.indexWhere(
                  (m) => (m.nonce ?? m.id) == messageId,
                );
                return index >= 0 ? index : null;
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

                final key = Key(
                  '$messageKeyPrefix${message.nonce ?? message.id}',
                );

                return MessageItemWrapper(
                  key: key,
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
                );
              },
            ),
          )
        : SuperListView.builder(
            listController: listController,
            controller: scrollController,
            reverse: true,
            padding: EdgeInsets.only(top: 8, bottom: bottomPadding),
            itemCount: messages.length,
            findChildIndexCallback: (key) {
              if (key is! ValueKey<String>) return null;
              final messageId = key.value.substring(messageKeyPrefix.length);
              final index = messages.indexWhere(
                (m) => (m.nonce ?? m.id) == messageId,
              );
              return index >= 0 ? index : null;
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

              final key = Key(
                '$messageKeyPrefix${message.nonce ?? message.id}',
              );

              return MessageItemWrapper(
                key: key,
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
              );
            },
          );

    return listWidget;
  }
}
