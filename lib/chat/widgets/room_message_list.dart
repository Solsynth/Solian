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
  final displayMessages = <LocalChatMessage>[];
  final activeKeys = <String>{};

  for (final message in messages) {
    final key = message.clientMessageId ?? message.id;
    activeKeys.add(key);
    final cached = cache[key];
    if (cached != null &&
        identical(cached.source, message) &&
        cached.status == message.status &&
        identical(cached.localAttachments, message.localAttachments)) {
      if (cached.display != null) displayMessages.add(cached.display!);
      continue;
    }

    final transformed = _transformDisplayMessage(message);
    cache[key] = _DisplayMessageCacheEntry(
      source: message,
      display: transformed,
      status: message.status,
      localAttachments: message.localAttachments,
    );
    if (transformed != null) displayMessages.add(transformed);
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
    final isSelectionMode = ref.watch(
      chatRoomStateProvider(roomId).select((state) => state.isSelectionMode),
    );
    // Group sticky avatars are positioned absolutely against the group stack.
    // Selection mode inserts a checkbox gutter inside each row, so the avatar
    // must shift by the same amount or it will sit on top of the checkmark.
    final stickyAvatarLeft =
        12.0 +
        (isSelectionMode ? MessageItemWrapper.selectionGutterWidth : 0.0);

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
          required bool showItemAvatar,
          required bool drawBubbleAvatar,
          required bool drawColumnAvatar,
          GlobalKey<State<StatefulWidget>>? avatarAnchorKey,
        }) {
          return MessageItemWrapper(
            message: item,
            index: itemIndex,
            roomId: roomId,
            isLastInGroup: showItemAvatar,
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
                      showItemAvatar: i == groupedMessages.length - 1,
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
                showItemAvatar: isLastInGroup,
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
  final _key = GlobalKey();
  ScrollPosition? _position;
  bool _framePending = false;
  double? _stickyOffset;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateScrollPosition();
    _scheduleOffsetUpdate();
  }

  @override
  void didUpdateWidget(covariant _StickyBubbleMessageGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stickyEnabled != widget.stickyEnabled ||
        oldWidget.children.length != widget.children.length) {
      _stickyOffset = null;
    }
    _scheduleOffsetUpdate();
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

  void _handleScroll() => _scheduleOffsetUpdate();

  void _scheduleOffsetUpdate() {
    if (_framePending || !mounted) return;
    _framePending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _framePending = false;
      if (!mounted) return;

      final nextOffset = _avatarOffset();
      final currentOffset = _stickyOffset ?? widget.avatarTop;
      if ((currentOffset - nextOffset).abs() < 0.5) return;
      setState(() => _stickyOffset = nextOffset);
    });
  }

  double _baseAvatarTop(RenderBox? groupBox) {
    if (groupBox == null || !groupBox.hasSize) return widget.avatarTop;

    final anchorBox =
        widget.avatarAnchorKey?.currentContext?.findRenderObject()
            as RenderBox?;
    if (anchorBox == null || !anchorBox.hasSize) return widget.avatarTop;

    try {
      return anchorBox.localToGlobal(Offset.zero, ancestor: groupBox).dy;
    } catch (_) {
      return widget.avatarTop;
    }
  }

  double _avatarOffset() {
    final groupBox = _key.currentContext?.findRenderObject() as RenderBox?;
    final baseTop = _baseAvatarTop(groupBox);
    if (groupBox == null || !groupBox.hasSize) return baseTop;
    if (!widget.stickyEnabled) return baseTop;

    final scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) return baseTop;

    final viewportBox = scrollable.context.findRenderObject() as RenderBox?;
    if (viewportBox == null) return baseTop;

    final double groupTop;
    try {
      groupTop = groupBox.localToGlobal(Offset.zero, ancestor: viewportBox).dy;
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

  @override
  Widget build(BuildContext context) {
    _updateScrollPosition();
    final baseTop = _baseAvatarTop(
      _key.currentContext?.findRenderObject() as RenderBox?,
    );
    final offset = widget.stickyEnabled ? (_stickyOffset ?? baseTop) : baseTop;

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
          child: RepaintBoundary(
            child: Transform.translate(
              offset: Offset(0, offset),
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
        ),
      ],
    );
  }
}
