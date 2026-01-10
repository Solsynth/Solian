import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/database/message.dart';
import 'package:island/models/chat.dart';
import 'package:island/screens/chat/widgets/message_item_wrapper.dart';

class RoomMessageList extends HookConsumerWidget {
  final List<LocalChatMessage> messages;
  final AsyncValue<SnChatRoom?> roomAsync;
  final AsyncValue<SnChatMember?> chatIdentity;
  final ScrollController scrollController;
  final bool isSelectionMode;
  final Set<String> selectedMessages;
  final VoidCallback toggleSelectionMode;
  final void Function(String) toggleMessageSelection;
  final void Function(String action, LocalChatMessage message) onMessageAction;
  final void Function(String messageId) onJump;
  final Map<String, Map<int, double?>> attachmentProgress;
  final double inputHeight;
  final double? previousInputHeight;
  final DateTime roomOpenTime;
  final bool disableAnimation;

  const RoomMessageList({
    super.key,
    required this.messages,
    required this.roomAsync,
    required this.chatIdentity,
    required this.scrollController,
    required this.isSelectionMode,
    required this.selectedMessages,
    required this.toggleSelectionMode,
    required this.toggleMessageSelection,
    required this.onMessageAction,
    required this.onJump,
    required this.attachmentProgress,
    required this.inputHeight,
    required this.roomOpenTime,
    required this.disableAnimation,
    this.previousInputHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animatedListKey = useMemoized(
      () => GlobalKey<SliverAnimatedListState>(),
      [],
    );
    const messageKeyPrefix = 'message-';

    final bottomPadding =
        inputHeight + MediaQuery.of(context).padding.bottom + 8;

    final listKeys = useRef<List<String>>([]);
    final messageMap = useRef<Map<String, LocalChatMessage>>({});

    useEffect(() {
      final currentKeys = messages
          .map((m) => '$messageKeyPrefix${m.nonce ?? m.id}')
          .toList();
      final previousKeys = listKeys.value;

      final addedKeys = currentKeys
          .where((k) => !previousKeys.contains(k))
          .toList();
      final removedKeys = previousKeys
          .where((k) => !currentKeys.contains(k))
          .toList();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final state = animatedListKey.currentState;
        if (state != null) {
          for (final key in removedKeys) {
            final index = messageMap.value.keys.toList().indexOf(key);
            if (index != -1) {
              state.removeItem(
                index,
                (context, animation) => _buildRemovedItem(context, animation),
              );
            }
          }

          for (final key in addedKeys) {
            final index = currentKeys.indexOf(key);
            state.insertItem(
              index,
              duration: Duration(milliseconds: 300 + (index % 3) * 50),
            );
          }
        }
      });

      listKeys.value = currentKeys;
      messageMap.value = {
        for (var m in messages) '$messageKeyPrefix${m.nonce ?? m.id}': m,
      };
      return null;
    }, [messages]);

    final listWidget = CustomScrollView(
      controller: scrollController,
      reverse: true,
      slivers: [
        if (previousInputHeight != null && previousInputHeight != inputHeight)
          SliverPadding(
            padding: EdgeInsets.only(top: 8, bottom: bottomPadding),
            sliver: SliverAnimatedList(
              key: animatedListKey,
              initialItemCount: messages.length,
              itemBuilder: (context, index, animation) {
                if (index >= messages.length) {
                  return const SizedBox.shrink();
                }

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

                return _buildAnimatedItem(
                  context,
                  animation,
                  MessageItemWrapper(
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
                    roomOpenTime: roomOpenTime,
                    disableAnimation: true,
                  ),
                );
              },
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.only(top: 8, bottom: bottomPadding),
            sliver: SliverAnimatedList(
              key: animatedListKey,
              initialItemCount: messages.length,
              itemBuilder: (context, index, animation) {
                if (index >= messages.length) {
                  return const SizedBox.shrink();
                }

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

                return _buildAnimatedItem(
                  context,
                  animation,
                  MessageItemWrapper(
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
                    roomOpenTime: roomOpenTime,
                    disableAnimation: true,
                  ),
                );
              },
            ),
          ),
      ],
    );

    return listWidget;
  }

  Widget _buildAnimatedItem(
    BuildContext context,
    Animation<double> animation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutQuart,
    );

    final scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(curvedAnimation);
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(curvedAnimation);
    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.1, 1.0, curve: Curves.easeOut),
      ),
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: SlideTransition(position: slideAnimation, child: child),
      ),
    );
  }

  Widget _buildRemovedItem(BuildContext context, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(opacity: animation, child: SizedBox.shrink()),
    );
  }
}
