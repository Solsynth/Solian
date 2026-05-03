import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/pods/chat_room_state.dart';
import 'package:island/chat/widgets/message_item_wrapper.dart';
import 'package:island/core/config.dart';
import 'package:island/data/message.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

bool _isBotMessage(LocalChatMessage message) {
  return message.sender?.account.automatedId != null;
}

class BotGroupInfo {
  final String groupId;
  final int startIndex;
  final int endIndex;
  final int messageCount;

  BotGroupInfo({
    required this.groupId,
    required this.startIndex,
    required this.endIndex,
    required this.messageCount,
  });
}

List<BotGroupInfo> _computeBotGroups(List<LocalChatMessage> messages) {
  final groups = <BotGroupInfo>[];
  final n = messages.length;

  int i = 0;
  while (i < n) {
    final msg = messages[i];
    if (!_isBotMessage(msg)) {
      i++;
      continue;
    }

    final senderId = msg.senderId;
    int j = i + 1;
    while (j < n) {
      final next = messages[j];
      if (!_isBotMessage(next) || next.senderId != senderId) break;
      j++;
    }

    final count = j - i;
    if (count > 1) {
      groups.add(
        BotGroupInfo(
          groupId: msg.id,
          startIndex: i,
          endIndex: j - 1,
          messageCount: count,
        ),
      );
    }

    i = j;
  }

  return groups;
}

/// Simplified RoomMessageList that uses universal chat room state.
/// All state is managed by [ChatRoomStateNotifier] via [chatRoomStateProvider].
class RoomMessageList extends HookConsumerWidget {
  final String roomId;
  final List<LocalChatMessage> messages;
  final AsyncValue<SnChatRoom?> roomAsync;
  final AsyncValue<SnChatMember?> chatIdentity;
  final void Function(String messageId) onJump;

  const RoomMessageList({
    super.key,
    required this.roomId,
    required this.messages,
    required this.roomAsync,
    required this.chatIdentity,
    required this.onJump,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final chatState = ref.watch(chatRoomStateProvider(roomId));
    final chatStateNotifier = ref.read(chatRoomStateProvider(roomId).notifier);
    const messageKeyPrefix = 'message-';

    final lastReadMarkerKey = useState<String?>(null);
    final isLastReadMarkerDismissed = useState(false);

    useEffect(() {
      if (chatState.lastReadAnchorMessageId != lastReadMarkerKey.value) {
        lastReadMarkerKey.value = chatState.lastReadAnchorMessageId;
        isLastReadMarkerDismissed.value = false;
      }
      return null;
    }, [chatState.lastReadAnchorMessageId]);

    final handleDismiss = useCallback(() {
      isLastReadMarkerDismissed.value = true;
      chatStateNotifier.dismissLastReadMarker();
    }, [chatStateNotifier]);

    final botGroups = useMemoized(() => _computeBotGroups(messages), [
      messages,
    ]);
    final botGroupMap = useMemoized(() {
      final map = <int, BotGroupInfo>{};
      for (final g in botGroups) {
        for (int i = g.startIndex; i <= g.endIndex; i++) {
          map[i] = g;
        }
      }
      return map;
    }, [botGroups]);
    final allGroupIds = useMemoized(
      () => botGroups.map((g) => g.groupId).toSet(),
      [botGroups],
    );
    final effectiveCollapsed = useMemoized(
      () => {...allGroupIds}..removeAll(chatState.collapsedBotGroupIds),
      [allGroupIds, chatState.collapsedBotGroupIds],
    );

    int lastReturnedIndex = -1;

    final listWidget = SuperListView.builder(
      listController: chatStateNotifier.listController,
      controller: chatStateNotifier.scrollController,
      reverse: true,
      padding: EdgeInsets.only(top: 8),
      itemCount: messages.length,
      findChildIndexCallback: (key) {
        if (messages.isEmpty) return null;

        if (key is! ValueKey<String>) return null;

        final keyString = key.value;
        if (!keyString.startsWith(messageKeyPrefix)) return null;

        final messageId = keyString.substring(messageKeyPrefix.length);

        final index = messages.indexWhere(
          (m) => (m.clientMessageId ?? m.id) == messageId,
        );

        if (index > lastReturnedIndex) {
          lastReturnedIndex = index;
          return index;
        }

        return null;
      },
      extentEstimation: (_, _) => 40,
      itemBuilder: (context, index) {
        final message = messages[index];
        final botGroup = botGroupMap[index];
        final isCollapsed =
            botGroup != null && effectiveCollapsed.contains(botGroup.groupId);

        if (isCollapsed && index != botGroup.startIndex) {
          return const SizedBox.shrink();
        }

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
                3 ||
            (botGroup != null && isCollapsed && index == botGroup.endIndex);

        final key = Key(
          '$messageKeyPrefix${message.clientMessageId ?? message.id}',
        );
        final showLastReadMarker =
            chatState.lastReadAnchorMessageId != null &&
            message.id == chatState.lastReadAnchorMessageId;

        return Column(
          key: key,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showLastReadMarker)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isLastReadMarkerDismissed.value ? 0.0 : 1.0,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bookmark_added,
                        size: 20,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'newMessageBelow'.tr(),
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ),
                      if (chatState.lastReadAnchorMessageId != null)
                        IconButton(
                          onPressed: handleDismiss,
                          icon: Icon(
                            Icons.close,
                            size: 18,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ),
              ),
            MessageItemWrapper(
              message: message,
              index: index,
              isLastInGroup: isLastInGroup,
              isSelectionMode: chatState.isSelectionMode,
              selectedMessages: chatState.selectedMessageIds,
              chatIdentity: chatIdentity,
              toggleSelectionMode: chatStateNotifier.toggleSelectionMode,
              toggleMessageSelection: chatStateNotifier.toggleMessageSelection,
              onMessageAction: chatStateNotifier.onMessageAction,
              onJump: onJump,
              attachmentProgress: chatState.attachmentProgress,
              disableAnimation: settings.disableAnimation,
              roomOpenTime: chatState.roomOpenTime,
            ),
            if (botGroup != null && isCollapsed && index == botGroup.startIndex)
              _BotGroupExpandBar(
                hiddenCount: botGroup.messageCount - 1,
                onToggle: () =>
                    chatStateNotifier.toggleBotGroup(botGroup.groupId),
                isExpanded: false,
              ),
            if (botGroup != null && !isCollapsed && index == botGroup.endIndex)
              _BotGroupExpandBar(
                hiddenCount: 0,
                onToggle: () =>
                    chatStateNotifier.toggleBotGroup(botGroup.groupId),
                isExpanded: true,
              ),
          ],
        );
      },
    );

    return listWidget;
  }
}

class _BotGroupExpandBar extends StatelessWidget {
  static const double _bubbleContentOffset = 64;

  final int hiddenCount;
  final VoidCallback onToggle;
  final bool isExpanded;

  const _BotGroupExpandBar({
    required this.hiddenCount,
    required this.onToggle,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    if (isExpanded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(_bubbleContentOffset, 4, 12, 4),
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.unfold_less,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  'Collapse',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ).alignment(Alignment.centerLeft),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(_bubbleContentOffset, 4, 12, 4),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.smart_toy,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                hiddenCount == 1
                    ? 'Show 1 more message'
                    : 'Show $hiddenCount more messages',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.expand_more,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ).alignment(Alignment.centerLeft),
    );
  }
}
