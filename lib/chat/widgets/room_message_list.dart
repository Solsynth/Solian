import 'dart:developer' as developer;

import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/widgets/chat_room_member_card.dart';
import 'package:island/chat/pods/chat_room_state.dart';
import 'package:island/chat/widgets/message_item_wrapper.dart';
import 'package:island/chat/widgets/online_avatar_badge.dart';
import 'package:island/chat/widgets/message_item.dart';
import 'package:island/chat/widgets/sticky_avatar_box.dart';
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

  /// Height of the chrome painted above the list. The list pads its oldest
  /// end by this much, so the first rows clear the floating header instead of
  /// hiding under it.
  final double topInset;

  /// Height of the chrome painted below the list. In a `reverse: true` list
  /// the newest rows sit at the viewport's bottom edge, so this keeps them
  /// clear of the composer.
  final double bottomInset;

  const RoomMessageList({
    super.key,
    required this.roomId,
    required this.messages,
    required this.roomAsync,
    required this.chatIdentity,
    required this.onJump,
    required this.onLoadMessageGap,
    this.topInset = 0,
    this.bottomInset = 0,
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
    // Messages that carry a timeline marker directly above them. Each one also
    // ends the sender run it sits in.
    final markerBoundaryIds = useMemoized(
      () => <String>{?messageLoadGap?.newerMessageId, ?lastReadAnchorMessageId},
      [messageLoadGap, lastReadAnchorMessageId],
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

    final messageIndexes = useMemoized(() {
      final byKey = <String, int>{};
      final byId = <String, int>{};
      for (var i = 0; i < displayMessages.length; i++) {
        byKey[displayMessages[i].clientMessageId ?? displayMessages[i].id] = i;
        byId[displayMessages[i].id] = i;
      }
      return (byKey: byKey, byId: byId);
    }, [displayMessages]);
    final messageIndexById = messageIndexes.byKey;
    final messageIndexByServerId = messageIndexes.byId;

    final pendingJumpMessageId = ref.watch(
      chatRoomStateProvider(
        roomId,
      ).select((state) => state.pendingJumpMessageId),
    );
    useEffect(() {
      if (pendingJumpMessageId == null) return null;
      final index = messageIndexByServerId[pendingJumpMessageId];
      if (index == null) {
        // The id is not in the rendered list yet; a later list change re-runs
        // this effect with a fresh index.
        return null;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        chatStateNotifier.revealPendingJump(index);
      });
      return null;
    }, [pendingJumpMessageId, messageIndexByServerId]);

    useEffect(() {
      final anchor = chatStateNotifier.pendingScrollAnchor;
      if (anchor == null) return null;
      final index = messageIndexByServerId[anchor.messageId];
      if (index == null) return null;
      chatStateNotifier.restoreScrollAnchor(index, anchor.alignment);
      return null;
    }, [displayMessages, messageIndexByServerId]);

    final listWidget = SuperListView.builder(
      listController: chatStateNotifier.listController,
      controller: chatStateNotifier.scrollController,
      reverse: true,
      // Padding is visual, not scroll-relative: even with `reverse: true` the
      // `top` inset sits above the newest rows and the `bottom` inset below
      // the oldest. The floating header covers the top band and the composer
      // the bottom one, so each side pads by the height the page measured for
      // that chrome. Without it the newest message would rest under the
      // composer, and scrolled-to-the-top rows under the header.
      padding: EdgeInsets.only(top: topInset, bottom: bottomInset + 8),
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
        // A timeline marker sits directly above the message it precedes, so it
        // also ends the run of bubbles it lands in: the reader gets a fresh
        // sender header and free corners on the far side of the seam instead of
        // one connected block with a rule punched through it.
        bool hasMarkerAbove(LocalChatMessage item) =>
            markerBoundaryIds.contains(item.id);
        bool isSameSenderGroup(LocalChatMessage? other) {
          return other != null &&
              other.senderId == message.senderId &&
              other.createdAt.difference(message.createdAt).inMinutes.abs() <=
                  3;
        }

        final isLastInGroup =
            !isSameSenderGroup(nextMessage) || hasMarkerAbove(message);
        final isFirstInGroup =
            !isSameSenderGroup(previousMessage) ||
            (previousMessage != null && hasMarkerAbove(previousMessage));
        final key = Key(
          '$messageKeyPrefix${message.clientMessageId ?? message.id}',
        );
        if (useStickyGroupedDisplay && !isFirstInGroup) {
          return SizedBox.shrink(key: key);
        }

        final groupedMessages = <LocalChatMessage>[message];
        if (useStickyGroupedDisplay) {
          for (var i = index + 1; i < displayMessages.length; i++) {
            final groupedMessage = displayMessages[i];
            if (groupedMessage.senderId != message.senderId ||
                hasMarkerAbove(groupedMessages.last) ||
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

        /// The "messages skipped" seam and the "new messages" rule belong to
        /// the message they precede. A group renders every bubble of its
        /// sender from one item, so the markers have to be offered to each of
        /// those bubbles — attaching them to the item alone would drop them
        /// whenever the boundary falls inside a group.
        Widget? markersBefore(LocalChatMessage item) {
          final gap = messageLoadGap;
          final showGap = gap != null && gap.newerMessageId == item.id;
          final showRead =
              lastReadAnchorMessageId != null &&
              item.id == lastReadAnchorMessageId;
          if (!showGap && !showRead) return null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showGap)
                _MessageLoadGapMarker(
                  key: ValueKey(
                    'message-gap-${gap.newerMessageId}-${gap.olderMessageId}',
                  ),
                  autoLoad: pendingJumpMessageId == null,
                  onLoad: () => onLoadMessageGap(gap),
                ),
              if (showRead) const _LastReadMarker(),
            ],
          );
        }

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

        final grouped = useStickyGroupedDisplay && groupedMessages.length > 1;
        final groupChildren = <Widget>[];
        if (grouped) {
          // Oldest first: the group reads top to bottom in the order it was
          // written, and each marker lands directly above its own bubble.
          for (var i = groupedMessages.length - 1; i >= 0; i--) {
            final groupedMessage = groupedMessages[i];
            final markers = markersBefore(groupedMessage);
            if (markers != null) groupChildren.add(markers);
            groupChildren.add(
              buildMessage(
                groupedMessage,
                index + i,
                isFirstInGroup: i == 0,
                isLastInGroup: i == groupedMessages.length - 1,
                drawBubbleAvatar: false,
                drawColumnAvatar: false,
                avatarAnchorKey: i == groupedMessages.length - 1
                    ? groupAvatarAnchorKey
                    : null,
              ),
            );
          }
        }

        final rowMarkers = markersBefore(message);
        final messageContent = grouped
            ? _StickyBubbleMessageGroup(
                key: ValueKey(
                  'sticky-group-${message.clientMessageId ?? message.id}',
                ),
                roomId: roomId,
                sender: message.toRemoteMessage().sender,
                // The grouped overlay draws the same avatar the row would,
                // so it has to take the radius from the renderer rather than
                // its own copy: a mismatch shows up as the avatar jumping
                // size when a group gains its second message.
                avatarRadius: useColumnDisplay
                    ? 12
                    : MessageItemDisplayBubble.avatarRadius,
                avatarAnchorKey: groupAvatarAnchorKey,
                stickyEnabled: !disableAnimationSetting,
                // The header floats over the list, so a pinned avatar has to
                // stop below it instead of under it.
                stickyTopMargin: topInset + _StickyBubbleMessageGroup.kRestGap,
                children: groupChildren,
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
            if (!grouped && rowMarkers != null) rowMarkers,
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
  final bool autoLoad;

  const _MessageLoadGapMarker({
    super.key,
    required this.onLoad,
    this.autoLoad = true,
  });

  @override
  State<_MessageLoadGapMarker> createState() => _MessageLoadGapMarkerState();
}

class _MessageLoadGapMarkerState extends State<_MessageLoadGapMarker> {
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.autoLoad) _load();
      });
    }
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final muted = colorScheme.onSurfaceVariant;

    return Padding(
      // The seam reads as a break in the timeline: a hairline on each side and
      // the way to close the gap in the middle. The label stays on one line and
      // ellipsizes rather than overflowing on narrow screens or long
      // translations.
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Divider(height: 1, color: colorScheme.outlineVariant),
          ),
          const Gap(8),
          Flexible(
            child: TextButton.icon(
              onPressed: _isLoading ? null : _load,
              style: TextButton.styleFrom(
                foregroundColor: muted,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: theme.textTheme.labelMedium,
              ),
              icon: _isLoading
                  ? SizedBox.square(
                      dimension: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: muted,
                      ),
                    )
                  : const Icon(Icons.unfold_more_rounded, size: 16),
              label: Text(
                (_isLoading
                        ? 'chatLoadingEarlierMessages'
                        : 'chatLoadEarlierMessages')
                    .tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const Gap(8),
          Expanded(
            child: Divider(height: 1, color: colorScheme.outlineVariant),
          ),
        ],
      ),
    );
  }
}

class _LastReadMarker extends StatelessWidget {
  const _LastReadMarker();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      // A rule rather than a banner: the reader needs the boundary, not a
      // second announcement of it.
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Icon(
            Icons.bookmark_added_rounded,
            size: 16,
            color: colorScheme.primary,
          ),
          const Gap(6),
          Text(
            'newMessageBelow'.tr(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Divider(
              height: 1,
              color: colorScheme.primary.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyBubbleMessageGroup extends StatelessWidget {
  /// Distance from the viewport top a pinned avatar rests at, before the
  /// floating header's own height is added.
  static const double kRestGap = 12;

  final String roomId;
  final SnChatMember sender;
  final double avatarRadius;
  final GlobalKey? avatarAnchorKey;
  final bool stickyEnabled;
  final double stickyTopMargin;
  final List<Widget> children;

  const _StickyBubbleMessageGroup({
    super.key,
    required this.roomId,
    required this.sender,
    required this.avatarRadius,
    required this.avatarAnchorKey,
    required this.stickyEnabled,
    required this.stickyTopMargin,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
        // The whole group draws a single avatar, anchored on the row that owns
        // the avatar slot — its oldest message. StickyAvatarBox keeps it
        // pinned to the viewport while the group scrolls beneath it.
        Positioned(
          left: 0,
          top: 0,
          child: StickyAvatarBox(
            anchorKey: avatarAnchorKey,
            topMargin: stickyTopMargin,
            enabled: stickyEnabled,
            child: RepaintBoundary(
              child: ChatRoomMemberRegion(
                roomId: roomId,
                member: sender,
                child: OnlineAvatarBadge(
                  roomId: roomId,
                  accountId: sender.accountId,
                  child: ProfilePictureWidget(
                    file: sender.account.profile.picture,
                    fallbackName: sender.account.nick,
                    radius: avatarRadius,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
