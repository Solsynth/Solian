import 'dart:developer' as developer;

import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/widgets/chat_room_member_card.dart';
import 'package:island/chat/pods/chat_room_state.dart';
import 'package:island/chat/widgets/message_item_wrapper.dart';
import 'package:island/chat/widgets/online_avatar_badge.dart';
import 'package:island/core/config.dart';
import 'package:island/data/message.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island_plugin_foundation/island_plugin_foundation.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class _DisplayMessageCacheEntry {
  final LocalChatMessage source;
  final LocalChatMessage? display;
  final MessageStatus status;
  final List<UniversalFile>? localAttachments;

  const _DisplayMessageCacheEntry({
    required this.source,
    required this.display,
    required this.status,
    required this.localAttachments,
  });
}

LocalChatMessage? _transformDisplayMessage(LocalChatMessage message) {
  final hookResult = PluginHooks().runBeforeMessageDisplay(
    message.toRemoteMessage().toJson(),
  );
  if (hookResult.cancelled) return null;

  try {
    final messageData = message.toRemoteMessage().toJson()
      ..addAll(hookResult.data!);
    final remote = SnChatMessage.fromJson(messageData);
    var transformed = LocalChatMessage.fromRemoteMessage(
      remote,
      message.status,
      clientMessageId: message.clientMessageId,
      nonce: message.nonce,
    );
    transformed.data.addAll(message.data);
    transformed.localAttachments = message.localAttachments;
    if (message.isDeleted != null || message.deletedAt != null) {
      transformed = LocalChatMessage(
        id: transformed.id,
        roomId: transformed.roomId,
        senderId: transformed.senderId,
        sender: transformed.sender,
        data: transformed.data,
        createdAt: transformed.createdAt,
        clientMessageId: transformed.clientMessageId,
        nonce: transformed.nonce,
        status: transformed.status,
        content: transformed.content,
        isDeleted: message.isDeleted,
        updatedAt: transformed.updatedAt,
        deletedAt: message.deletedAt,
        type: transformed.type,
        meta: transformed.meta,
        membersMentioned: transformed.membersMentioned,
        editedAt: transformed.editedAt,
        attachments: transformed.attachments,
        reactions: transformed.reactions,
        repliedMessageId: transformed.repliedMessageId,
        forwardedMessageId: transformed.forwardedMessageId,
        localAttachments: message.localAttachments,
      );
    }
    return transformed;
  } catch (_) {
    // Invalid plugin output must not prevent the original message rendering.
    return message;
  }
}

List<LocalChatMessage> _buildDisplayMessages(
  List<LocalChatMessage> messages,
  Map<String, _DisplayMessageCacheEntry> cache,
) {
  // Thread membership is explicit via `thread_id`: in-thread replies render
  // inside the thread panel. Regular (direct) replies carry only
  // `replied_message_id` and keep their normal place in the main timeline
  // with their quoted reference.
  final threadRootIds = <String>{};
  final replyCounts = <String, int>{};
  for (final message in messages) {
    final threadId = message.threadId ?? message.data['thread_id'] as String?;
    if (threadId != null) {
      threadRootIds.add(threadId);
      replyCounts[threadId] = (replyCounts[threadId] ?? 0) + 1;
    }
  }

  final displayMessages = <LocalChatMessage>[];
  final activeKeys = <String>{};

  for (final message in messages) {
    // In-thread replies live in the thread panel, not the main timeline.
    if (message.threadId != null) continue;

    final key = message.clientMessageId ?? message.id;
    activeKeys.add(key);
    final cached = cache[key];
    LocalChatMessage? transformed;
    if (cached != null &&
        identical(cached.source, message) &&
        cached.status == message.status &&
        identical(cached.localAttachments, message.localAttachments)) {
      transformed = cached.display;
    } else {
      transformed = _transformDisplayMessage(message);
      cache[key] = _DisplayMessageCacheEntry(
        source: message,
        display: transformed,
        status: message.status,
        localAttachments: message.localAttachments,
      );
    }
    if (transformed == null) continue;

    // A message with in-thread replies is a thread root and shows the reply
    // count hint, derived from the loaded replies so it appears without
    // first opening the thread.
    if (threadRootIds.contains(transformed.id)) {
      transformed.data['thread_replies_count'] =
          replyCounts[transformed.id] ?? 0;
    }
    displayMessages.add(transformed);
  }

  // Pagination compaction can replace the visible timeline. Drop entries no
  // longer displayed so a long-running room does not retain old history.
  cache.removeWhere((key, _) => !activeKeys.contains(key));

  return List.unmodifiable(displayMessages);
}

/// Simplified RoomMessageList that uses universal chat room state.
/// All state is managed by [ChatRoomStateNotifier] via [chatRoomStateProvider].
class RoomMessageList extends HookConsumerWidget {
  static const int _animationBatchThreshold = 10;

  final String roomId;
  final List<LocalChatMessage> messages;
  final AsyncValue<SnChatRoom?> roomAsync;
  final AsyncValue<SnChatMember?> chatIdentity;
  final void Function(String messageId) onJump;
  final Future<void> Function(MessageLoadGap gap) onLoadMessageGap;

  const RoomMessageList({
    super.key,
    required this.roomId,
    required this.messages,
    required this.roomAsync,
    required this.chatIdentity,
    required this.onJump,
    required this.onLoadMessageGap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Plugin transforms deserialize every message. Keeping the result stable for
    // the lifetime of an unchanged message list avoids doing that work when UI
    // state changes (selection, read marker, display settings) rebuild this
    // widget while the user is scrolling.
    final displayMessageCache = useRef(<String, _DisplayMessageCacheEntry>{});
    // A plugin can be enabled, disabled, or reloaded while this screen is
    // open. In that case transformed rows must be recomputed once using the
    // new hook chain instead of retaining the previous plugin output.
    final pluginRevision = useState(0);
    useEffect(() {
      void invalidatePluginTransforms() {
        displayMessageCache.value.clear();
        pluginRevision.value += 1;
      }

      final pluginManager = PluginManager();
      pluginManager.addListener(invalidatePluginTransforms);
      return () => pluginManager.removeListener(invalidatePluginTransforms);
    }, []);
    final displayMessages = useMemoized(
      () => developer.Timeline.timeSync(
        'chat.buildDisplayMessages',
        () => _buildDisplayMessages(messages, displayMessageCache.value),
        arguments: {'roomId': roomId, 'messageCount': messages.length},
      ),
      [messages, pluginRevision.value],
    );

    final displayStyle = ref.watch(
      appSettingsProvider.select((settings) => settings.messageDisplayStyle),
    );
    final disableAnimationSetting = ref.watch(
      appSettingsProvider.select((settings) => settings.disableAnimation),
    );
    final lastReadAnchorMessageId = ref.watch(
      chatRoomStateProvider(
        roomId,
      ).select((state) => state.lastReadAnchorMessageId),
    );
    final roomOpenTime = ref.watch(
      chatRoomStateProvider(roomId).select((state) => state.roomOpenTime),
    );
    final messageLoadGap = ref.watch(
      chatRoomStateProvider(roomId).select((state) => state.messageLoadGap),
    );
    final chatStateNotifier = ref.read(chatRoomStateProvider(roomId).notifier);
    final skipInitialLoadMessageAnimations = useState(true);
    final previousMessageCount = useRef<int?>(null);
    const messageKeyPrefix = 'message-';
    final addedMessageCount = previousMessageCount.value == null
        ? 0
        : displayMessages.length - previousMessageCount.value!;
    final skipBatchMessageAnimations =
        addedMessageCount >= _animationBatchThreshold;

    useEffect(() {
      if (!skipInitialLoadMessageAnimations.value || displayMessages.isEmpty) {
        return null;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          skipInitialLoadMessageAnimations.value = false;
        }
      });

      return null;
    }, [displayMessages.length, skipInitialLoadMessageAnimations.value]);

    useEffect(() {
      previousMessageCount.value = displayMessages.length;
      return null;
    }, [displayMessages.length]);

    final useColumnDisplay = displayStyle == 'column';
    final useBubbleDisplay = displayStyle != 'compact' && !useColumnDisplay;
    final useStickyGroupedDisplay = useBubbleDisplay || useColumnDisplay;
    // The group stack already lives after MessageItemWrapper's selection
    // gutter. Keep the overlay aligned with the message bubble itself; adding
    // the gutter here would shift the avatar twice in selection mode.
    const stickyAvatarLeft = 12.0;

    final messageIndexById = useMemoized(() {
      return {
        for (var i = 0; i < displayMessages.length; i++)
          displayMessages[i].clientMessageId ?? displayMessages[i].id: i,
      };
    }, [displayMessages]);

    final listWidget = SuperListView.builder(
      listController: chatStateNotifier.listController,
      controller: chatStateNotifier.scrollController,
      reverse: true,
      padding: const EdgeInsets.only(top: 8),
      itemCount: displayMessages.length,
      findChildIndexCallback: (key) {
        if (displayMessages.isEmpty) return null;

        if (key is! ValueKey<String>) return null;

        final keyString = key.value;
        if (!keyString.startsWith(messageKeyPrefix)) return null;

        final messageId = keyString.substring(messageKeyPrefix.length);

        return messageIndexById[messageId];
      },
      extentEstimation: (_, _) => 40,
      itemBuilder: (context, index) {
        final message = displayMessages[index];

        final nextMessage = index < displayMessages.length - 1
            ? displayMessages[index + 1]
            : null;
        final previousMessage = index > 0 ? displayMessages[index - 1] : null;
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
          for (var i = index + 1; i < displayMessages.length; i++) {
            final groupedMessage = displayMessages[i];
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
            lastReadAnchorMessageId != null &&
            message.id == lastReadAnchorMessageId;

        Widget buildMessage(
          LocalChatMessage item,
          int itemIndex, {
          required bool isFirstInGroup,
          required bool isLastInGroup,
          required bool drawBubbleAvatar,
          required bool drawColumnAvatar,
          GlobalKey<State<StatefulWidget>>? avatarAnchorKey,
        }) {
          return MessageItemWrapper(
            message: item,
            index: itemIndex,
            roomId: roomId,
            isLastInGroup: isLastInGroup,
            isFirstInGroup: isFirstInGroup,
            showBubbleAvatar: drawBubbleAvatar,
            showColumnAvatar: drawColumnAvatar,
            avatarAnchorKey: avatarAnchorKey,
            chatIdentity: chatIdentity,
            toggleSelectionMode: chatStateNotifier.toggleSelectionMode,
            toggleMessageSelection: chatStateNotifier.toggleMessageSelection,
            onMessageAction: chatStateNotifier.onMessageAction,
            onJump: onJump,
            disableAnimation:
                disableAnimationSetting ||
                skipInitialLoadMessageAnimations.value ||
                skipBatchMessageAnimations,
            roomOpenTime: roomOpenTime,
          );
        }

        final groupAvatarAnchorKey = GlobalObjectKey<State<StatefulWidget>>(
          'group-avatar-$roomId-${message.clientMessageId ?? message.id}',
        );

        final messageContent =
            useStickyGroupedDisplay && groupedMessages.length > 1
            ? _StickyBubbleMessageGroup(
                key: ValueKey(
                  'sticky-group-${message.clientMessageId ?? message.id}',
                ),
                roomId: roomId,
                sender: message.toRemoteMessage().sender,
                avatarSize: useColumnDisplay ? 24 : 32,
                avatarLeft: stickyAvatarLeft,
                avatarTop: useColumnDisplay ? 4 : 9,
                avatarAnchorKey: groupAvatarAnchorKey,
                stickyEnabled: !disableAnimationSetting,
                children: [
                  for (var i = groupedMessages.length - 1; i >= 0; i--)
                    buildMessage(
                      groupedMessages[i],
                      index + i,
                      isFirstInGroup: i == 0,
                      isLastInGroup: i == groupedMessages.length - 1,
                      drawBubbleAvatar: false,
                      drawColumnAvatar: false,
                      avatarAnchorKey: i == groupedMessages.length - 1
                          ? groupAvatarAnchorKey
                          : null,
                    ),
                ],
              )
            : buildMessage(
                message,
                index,
                isFirstInGroup: isFirstInGroup,
                isLastInGroup: isLastInGroup,
                drawBubbleAvatar: true,
                drawColumnAvatar: true,
              );

        return Column(
          key: key,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (messageLoadGap?.newerMessageId == message.id)
              _MessageLoadGapMarker(
                key: ValueKey(
                  'message-gap-${messageLoadGap!.newerMessageId}-${messageLoadGap.olderMessageId}',
                ),
                onLoad: () => onLoadMessageGap(messageLoadGap),
              ),
            // Only one row can own the marker. Avoid placing an AnimatedSize
            // (and its hidden child) in every visible message during a fling.
            if (showLastReadMarker) const _LastReadMarker(),
            messageContent,
          ],
        );
      },
    );

    return listWidget;
  }
}

class _MessageLoadGapMarker extends StatefulWidget {
  final Future<void> Function() onLoad;

  const _MessageLoadGapMarker({super.key, required this.onLoad});

  @override
  State<_MessageLoadGapMarker> createState() => _MessageLoadGapMarkerState();
}

class _MessageLoadGapMarkerState extends State<_MessageLoadGapMarker> {
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (_isLoading || !mounted) return;
    setState(() => _isLoading = true);
    try {
      await widget.onLoad();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: _isLoading ? null : _load,
        icon: _isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.unfold_more, size: 18),
        label: Text(
          _isLoading ? 'Loading messages…' : 'Messages skipped — tap to load',
        ),
      ),
    );
  }
}

class _LastReadMarker extends StatelessWidget {
  const _LastReadMarker();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
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
    );
  }
}

class _StickyBubbleMessageGroup extends StatefulWidget {
  static const double _viewportTopMargin = 12;

  final String roomId;
  final SnChatMember sender;
  final double avatarSize;
  final double avatarLeft;
  final double avatarTop;
  final GlobalKey<State<StatefulWidget>>? avatarAnchorKey;
  final bool stickyEnabled;
  final List<Widget> children;

  const _StickyBubbleMessageGroup({
    super.key,
    required this.roomId,
    required this.sender,
    required this.avatarSize,
    required this.avatarLeft,
    required this.avatarTop,
    required this.avatarAnchorKey,
    required this.stickyEnabled,
    required this.children,
  });

  @override
  State<_StickyBubbleMessageGroup> createState() =>
      _StickyBubbleMessageGroupState();
}

class _StickyBubbleMessageGroupState extends State<_StickyBubbleMessageGroup> {
  final _groupKey = GlobalKey();
  final _avatarKey = GlobalKey<_StickyGroupAvatarState>();

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        _avatarKey.currentState?._scheduleLayoutRefresh();
        return false;
      },
      child: SizeChangedLayoutNotifier(
        child: Stack(
          key: _groupKey,
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: widget.children,
            ),
            Positioned(
              left: widget.avatarLeft,
              top: 0,
              child: _StickyGroupAvatar(
                key: _avatarKey,
                childCount: widget.children.length,
                groupKey: _groupKey,
                roomId: widget.roomId,
                sender: widget.sender,
                avatarSize: widget.avatarSize,
                avatarTop: widget.avatarTop,
                avatarAnchorKey: widget.avatarAnchorKey,
                stickyEnabled: widget.stickyEnabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyGroupAvatar extends StatefulWidget {
  final GlobalKey groupKey;
  final String roomId;
  final SnChatMember sender;
  final double avatarSize;
  final double avatarTop;
  final int childCount;
  final GlobalKey<State<StatefulWidget>>? avatarAnchorKey;
  final bool stickyEnabled;

  const _StickyGroupAvatar({
    super.key,
    required this.groupKey,
    required this.roomId,
    required this.sender,
    required this.avatarSize,
    required this.avatarTop,
    required this.childCount,
    required this.avatarAnchorKey,
    required this.stickyEnabled,
  });

  @override
  State<_StickyGroupAvatar> createState() => _StickyGroupAvatarState();
}

class _StickyGroupAvatarState extends State<_StickyGroupAvatar> {
  ScrollPosition? _position;
  bool _framePending = false;
  double? _resolvedBaseTop;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateScrollPosition();
    _scheduleLayoutRefresh();
  }

  @override
  void didUpdateWidget(covariant _StickyGroupAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateScrollPosition();

    // Message heights and the anchor can change when a message is sent,
    // edited, or replaced by its server version. Recompute after that layout
    // without rebuilding the whole message group.
    if (oldWidget.avatarTop != widget.avatarTop ||
        oldWidget.childCount != widget.childCount ||
        oldWidget.stickyEnabled != widget.stickyEnabled ||
        oldWidget.avatarAnchorKey != widget.avatarAnchorKey) {
      _scheduleLayoutRefresh();
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_handleScroll);
    super.dispose();
  }

  void _updateScrollPosition() {
    final nextPosition = widget.stickyEnabled ? _readScrollPosition() : null;
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
    if (mounted) setState(() {});
  }

  void _scheduleLayoutRefresh() {
    if (_framePending || !mounted) return;
    _framePending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _framePending = false;
      if (mounted) setState(() {});
    });
  }

  double? _baseAvatarTop(RenderBox? groupBox) {
    if (groupBox == null || !groupBox.hasSize) return null;

    final anchorBox =
        widget.avatarAnchorKey?.currentContext?.findRenderObject()
            as RenderBox?;
    if (anchorBox == null || !anchorBox.hasSize) return null;

    try {
      return anchorBox.localToGlobal(Offset.zero, ancestor: groupBox).dy;
    } catch (_) {
      return null;
    }
  }

  double? _avatarOffset() {
    final groupBox =
        widget.groupKey.currentContext?.findRenderObject() as RenderBox?;
    final measuredBaseTop = _baseAvatarTop(groupBox);
    if (measuredBaseTop != null) {
      _resolvedBaseTop = measuredBaseTop;
    }
    final baseTop = _resolvedBaseTop;
    if (baseTop == null) return null;
    if (groupBox == null || !groupBox.hasSize || !widget.stickyEnabled) {
      return baseTop;
    }

    final scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) return baseTop;

    final viewportBox = scrollable.context.findRenderObject() as RenderBox?;
    if (viewportBox == null || !viewportBox.hasSize) return baseTop;

    final double groupTop;
    try {
      groupTop =
          groupBox.localToGlobal(Offset.zero).dy -
          viewportBox.localToGlobal(Offset.zero).dy;
    } catch (_) {
      return baseTop;
    }

    final maxOffset = (groupBox.size.height - widget.avatarSize).clamp(
      0.0,
      double.infinity,
    );
    if (maxOffset <= baseTop) return baseTop;

    final stickyDelta = _StickyBubbleMessageGroup._viewportTopMargin - groupTop;
    return (baseTop + stickyDelta).clamp(baseTop, maxOffset);
  }

  Widget _buildAvatar(double offset) {
    // Keep the hit-test box at the same position as the painted avatar. A
    // Transform can paint the avatar outside the positioned child's original
    // bounds, which makes the member-card gesture intermittently miss while
    // the avatar is sticky or a message is expanding.
    return Padding(
      padding: EdgeInsets.only(top: offset),
      child: RepaintBoundary(
        child: ChatRoomMemberRegion(
          roomId: widget.roomId,
          member: widget.sender,
          child: OnlineAvatarBadge(
            roomId: widget.roomId,
            accountId: widget.sender.accountId,
            child: ProfilePictureWidget(
              file: widget.sender.account.profile.picture,
              fallbackName: widget.sender.account.nick,
              radius: widget.avatarSize / 2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offset = _avatarOffset();
    if (offset == null) return const SizedBox.shrink();
    return _buildAvatar(offset);
  }
}
