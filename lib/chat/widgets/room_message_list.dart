import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/widgets/chat_room_member_card.dart';
import 'package:island/chat/pods/chat_room_state.dart';
import 'package:island/chat/widgets/message_item_wrapper.dart';
import 'package:island/chat/widgets/online_avatar_badge.dart';
import 'package:island/core/config.dart';
import 'package:island/data/message.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Simplified RoomMessageList that uses universal chat room state.
/// All state is managed by [ChatRoomStateNotifier] via [chatRoomStateProvider].
class RoomMessageList extends HookConsumerWidget {
  static const int _animationBatchThreshold = 10;

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
    final skipInitialLoadMessageAnimations = useState(true);
    final previousMessageCount = useRef<int?>(null);
    const messageKeyPrefix = 'message-';
    final addedMessageCount = previousMessageCount.value == null
        ? 0
        : messages.length - previousMessageCount.value!;
    final skipBatchMessageAnimations =
        addedMessageCount >= _animationBatchThreshold;

    useEffect(() {
      if (!skipInitialLoadMessageAnimations.value || messages.isEmpty) {
        return null;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          skipInitialLoadMessageAnimations.value = false;
        }
      });

      return null;
    }, [messages.length, skipInitialLoadMessageAnimations.value]);

    useEffect(() {
      previousMessageCount.value = messages.length;
      return null;
    }, [messages.length]);

    final useColumnDisplay = settings.messageDisplayStyle == 'column';
    final useBubbleDisplay =
        settings.messageDisplayStyle != 'compact' && !useColumnDisplay;
    final useStickyGroupedDisplay = useBubbleDisplay || useColumnDisplay;

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

        final nextMessage = index < messages.length - 1
            ? messages[index + 1]
            : null;
        final previousMessage = index > 0 ? messages[index - 1] : null;
        bool isSameSenderGroup(LocalChatMessage? other) {
          return other != null &&
              other.senderId == message.senderId &&
              other.createdAt.difference(message.createdAt).inMinutes.abs() <=
                  3;
        }

        final isLastInGroup = !isSameSenderGroup(nextMessage);
        final isFirstInGroup = !isSameSenderGroup(previousMessage);
        if (useStickyGroupedDisplay && !isFirstInGroup) {
          return const SizedBox.shrink();
        }

        final groupedMessages = <LocalChatMessage>[message];
        if (useStickyGroupedDisplay) {
          for (var i = index + 1; i < messages.length; i++) {
            final groupedMessage = messages[i];
            if (groupedMessage.senderId != message.senderId ||
                groupedMessage.createdAt
                        .difference(groupedMessages.last.createdAt)
                        .inMinutes
                        .abs() >
                    3) {
              break;
            }
            groupedMessages.add(groupedMessage);
          }
        }

        final key = Key(
          '$messageKeyPrefix${message.clientMessageId ?? message.id}',
        );
        final showLastReadMarker =
            chatState.lastReadAnchorMessageId != null &&
            message.id == chatState.lastReadAnchorMessageId;

        Widget buildMessage(
          LocalChatMessage item,
          int itemIndex, {
          required bool showItemAvatar,
          required bool drawBubbleAvatar,
          required bool drawColumnAvatar,
        }) {
          return MessageItemWrapper(
            message: item,
            index: itemIndex,
            roomId: roomId,
            isLastInGroup: showItemAvatar,
            showBubbleAvatar: drawBubbleAvatar,
            showColumnAvatar: drawColumnAvatar,
            chatIdentity: chatIdentity,
            toggleSelectionMode: chatStateNotifier.toggleSelectionMode,
            toggleMessageSelection: chatStateNotifier.toggleMessageSelection,
            onMessageAction: chatStateNotifier.onMessageAction,
            onJump: onJump,
            disableAnimation:
                settings.disableAnimation ||
                skipInitialLoadMessageAnimations.value ||
                skipBatchMessageAnimations,
            roomOpenTime: chatState.roomOpenTime,
          );
        }

        final messageContent =
            useStickyGroupedDisplay && groupedMessages.length > 1
            ? _StickyBubbleMessageGroup(
                key: ValueKey(
                  'sticky-group-${message.clientMessageId ?? message.id}',
                ),
                roomId: roomId,
                sender: message.toRemoteMessage().sender,
                avatarSize: useColumnDisplay ? 24 : 32,
                avatarLeft: 12,
                avatarTop: useColumnDisplay ? 8 : 9,
                children: [
                  for (var i = groupedMessages.length - 1; i >= 0; i--)
                    buildMessage(
                      groupedMessages[i],
                      index + i,
                      showItemAvatar: i == groupedMessages.length - 1,
                      drawBubbleAvatar: false,
                      drawColumnAvatar: false,
                    ),
                ],
              )
            : buildMessage(
                message,
                index,
                showItemAvatar: isLastInGroup,
                drawBubbleAvatar: true,
                drawColumnAvatar: true,
              );

        return Column(
          key: key,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LastReadMarker(visible: showLastReadMarker),
            messageContent,
          ],
        );
      },
    );

    return listWidget;
  }
}

class _LastReadMarker extends StatelessWidget {
  static const _duration = Duration(milliseconds: 240);

  final bool visible;

  const _LastReadMarker({required this.visible});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRect(
      child: AnimatedSize(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : _duration,
        curve: Curves.easeInOutCubic,
        alignment: Alignment.topCenter,
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: visible ? 1 : 0,
          child: AnimatedSlide(
            offset: visible ? Offset.zero : const Offset(0, -0.12),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : _duration,
            curve: Curves.easeOutCubic,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: colorScheme.primaryContainer),
              child: Row(
                children: [
                  Icon(
                    Icons.bookmark_added,
                    size: 20,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'newMessageBelow'.tr(),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StickyBubbleMessageGroup extends StatefulWidget {
  static const double _viewportTopMargin = 12;
  static const Duration _stickDuration = Duration(milliseconds: 70);

  final String roomId;
  final SnChatMember sender;
  final double avatarSize;
  final double avatarLeft;
  final double avatarTop;
  final List<Widget> children;

  const _StickyBubbleMessageGroup({
    super.key,
    required this.roomId,
    required this.sender,
    required this.avatarSize,
    required this.avatarLeft,
    required this.avatarTop,
    required this.children,
  });

  @override
  State<_StickyBubbleMessageGroup> createState() =>
      _StickyBubbleMessageGroupState();
}

class _StickyBubbleMessageGroupState extends State<_StickyBubbleMessageGroup> {
  final _key = GlobalKey();
  ScrollPosition? _position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateScrollPosition();
  }

  @override
  void dispose() {
    _position?.removeListener(_handleScroll);
    super.dispose();
  }

  void _updateScrollPosition() {
    final nextPosition = _readScrollPosition();
    if (identical(_position, nextPosition)) return;

    _position?.removeListener(_handleScroll);
    _position = nextPosition;
    _position?.addListener(_handleScroll);
  }

  ScrollPosition? _readScrollPosition() {
    final scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) return null;

    try {
      return scrollable.position;
    } catch (_) {
      return null;
    }
  }

  void _handleScroll() {
    if (!mounted) return;
    setState(() {});
  }

  double _avatarOffset() {
    final scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) return widget.avatarTop;

    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    final viewportBox = scrollable.context.findRenderObject() as RenderBox?;
    if (box == null || viewportBox == null || !box.hasSize) {
      return widget.avatarTop;
    }

    final double groupTop;
    try {
      groupTop = box.localToGlobal(Offset.zero, ancestor: viewportBox).dy;
    } catch (_) {
      return widget.avatarTop;
    }
    final stickyDelta = _StickyBubbleMessageGroup._viewportTopMargin - groupTop;
    final maxOffset = (box.size.height - widget.avatarSize).clamp(
      0.0,
      double.infinity,
    );
    if (maxOffset <= widget.avatarTop) return widget.avatarTop;

    return (widget.avatarTop + stickyDelta).clamp(widget.avatarTop, maxOffset);
  }

  @override
  Widget build(BuildContext context) {
    _updateScrollPosition();
    final offset = _avatarOffset();

    return Stack(
      key: _key,
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widget.children,
        ),
        Positioned(
          left: widget.avatarLeft,
          top: 0,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: offset),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : _StickyBubbleMessageGroup._stickDuration,
            curve: Curves.easeOutCubic,
            builder: (context, value, child) =>
                Transform.translate(offset: Offset(0, value), child: child),
            child: ChatRoomMemberRegion(
              roomId: widget.roomId,
              member: widget.sender,
              child: OnlineAvatarBadge(
                roomId: widget.roomId,
                accountId: widget.sender.accountId,
                child: ProfilePictureWidget(
                  file: widget.sender.account.profile.picture,
                  radius: widget.avatarSize / 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
