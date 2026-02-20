import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/widgets/embeds/livestream_chat_message.dart';
import 'package:island/core/widgets/embeds/livestream_room.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';

final livestreamDetailProvider = FutureProvider.family
    .autoDispose<SnLiveStream, String>((ref, livestreamId) async {
      final client = ref.watch(apiClientProvider);
      final response = await client.get('/sphere/livestreams/$livestreamId');
      return SnLiveStream.fromJson(Map<String, dynamic>.from(response.data));
    });

class LivestreamEmbedWidget extends HookConsumerWidget {
  final String livestreamId;
  final bool isInteractive;
  final EdgeInsets margin;
  final bool showChat;

  const LivestreamEmbedWidget({
    super.key,
    required this.livestreamId,
    this.isInteractive = true,
    this.margin = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.showChat = true,
  });

  static String _roomDiagnostics(lk.Room? room) {
    if (room == null) return 'notConnected'.tr();
    final remoteParticipants = room.remoteParticipants.values.toList();
    return 'remoteParticipants: ${remoteParticipants.length}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(livestreamDetailProvider(livestreamId));
    final roomState = ref.watch(livestreamRoomProvider(livestreamId));
    final room = roomState.room;
    final videoTrack = roomState.videoTrack;
    final viewerCount = roomState.viewerCount;
    final volume = roomState.volume;
    final messages = roomState.messages;
    final isConnecting = roomState.isConnecting;
    final errorText = roomState.errorText;
    final isSendingChat = roomState.isSendingChat;
    final isChatCollapsed = roomState.isChatCollapsed;

    final notifier = ref.read(livestreamRoomProvider(livestreamId).notifier);

    final fullScreenOpen = useState(false);

    return VisibilityDetector(
      key: ValueKey('livestream-$livestreamId'),
      onVisibilityChanged: (info) {
        // Could add idle disconnect logic here
      },
      child: Card(
        margin: margin,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              detailAsync
                  .when(
                    data: (stream) => Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stream.title ?? 'untitledLivestream'.tr(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              if (stream.description?.isNotEmpty ?? false)
                                Text(
                                  stream.description!,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ).opacity(0.85),
                            ],
                          ),
                        ),
                        if (room != null) ...[
                          Text(
                            '$viewerCount in room',
                            style: Theme.of(context).textTheme.bodySmall,
                          ).opacity(0.8),
                        ],
                      ],
                    ),
                    loading: () => const LinearProgressIndicator(minHeight: 2),
                    error: (_, _) => const Text('livestreamUnavailable').tr(),
                  )
                  .padding(horizontal: 4),
              const SizedBox(height: 10),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: videoTrack != null
                              ? lk.VideoTrackRenderer(videoTrack)
                              : detailAsync.when(
                                  data: (stream) {
                                    final thumbnailId = stream.thumbnail?.id;
                                    return Stack(
                                      children: [
                                        Positioned.fill(
                                          child: thumbnailId != null
                                              ? CloudImageWidget(
                                                  fileId: thumbnailId,
                                                  fit: BoxFit.cover,
                                                )
                                              : const ColoredBox(
                                                  color: Colors.black,
                                                ),
                                        ),
                                        const Positioned.fill(
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: Color(0x66000000),
                                            ),
                                          ),
                                        ),
                                        if (room != null)
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Text(
                                                'Connected. Waiting for video...\n${_roomDiagnostics(room)}',
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                  loading: () => Center(
                                    child: Text(
                                      'loadingStream'.tr(),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                  error: (_, _) => Center(
                                    child: Text(
                                      'livestreamUnavailable'.tr(),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        if (isInteractive && room == null)
                          Positioned.fill(
                            child: Center(
                              child: detailAsync.when(
                                data: (stream) {
                                  final canWatch =
                                      stream.status ==
                                      SnLiveStreamStatus.active;
                                  return FilledButton.icon(
                                    onPressed: isConnecting
                                        ? null
                                        : canWatch
                                        ? () => notifier.connect()
                                        : null,
                                    icon: isConnecting
                                        ? const SizedBox.square(
                                            dimension: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Icon(Symbols.play_arrow),
                                    label: Text('watch'.tr()),
                                  );
                                },
                                loading: () => const SizedBox.shrink(),
                                error: (_, _) => const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        if (isInteractive && room != null)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton.filledTonal(
                                  tooltip: 'fullscreen'.tr(),
                                  onPressed: () async {
                                    fullScreenOpen.value = true;
                                    await showDialog(
                                      context: context,
                                      useSafeArea: false,
                                      builder: (context) =>
                                          _LivestreamFullscreenViewer(
                                            livestreamId: livestreamId,
                                          ),
                                    );
                                    fullScreenOpen.value = false;
                                  },
                                  icon: const Icon(Symbols.fullscreen),
                                  iconSize: 18,
                                  visualDensity: VisualDensity.compact,
                                ),
                                const SizedBox(width: 8),
                                FilledButton.tonalIcon(
                                  onPressed: () => notifier.disconnect(),
                                  icon: const Icon(Symbols.stop, size: 20),
                                  label: Text('leave'.tr()).padding(right: 4),
                                  style: FilledButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (errorText != null) ...[
                const SizedBox(height: 10),
                Text(
                  errorText,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              if (room != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Symbols.volume_up, size: 18),
                    Expanded(
                      child: Slider(
                        max: 2,
                        value: volume,
                        onChanged: (value) => notifier.setVolume(value),
                        year2023: true,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text('${(volume * 100).toStringAsFixed(0)}%'),
                    ),
                  ],
                ).padding(vertical: 4, horizontal: 6),
                if (showChat)
                  _LivestreamChatWidget(
                    livestreamId: livestreamId,
                    isCollapsed: isChatCollapsed,
                    messages: messages,
                    isSendingChat: isSendingChat,
                    onToggleCollapse: () => notifier.toggleChatCollapsed(),
                    onSendMessage: (msg) => notifier.sendMessage(msg),
                  ).padding(top: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LivestreamChatWidget extends HookConsumerWidget {
  final String livestreamId;
  final bool isCollapsed;
  final List<ChatMessage> messages;
  final bool isSendingChat;
  final VoidCallback onToggleCollapse;
  final Function(String) onSendMessage;

  const _LivestreamChatWidget({
    required this.livestreamId,
    required this.isCollapsed,
    required this.messages,
    required this.isSendingChat,
    required this.onToggleCollapse,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final scrollController = useScrollController();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onToggleCollapse,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
              child: Row(
                children: [
                  const Icon(Symbols.chat_bubble, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'liveChatCount'.tr(args: ['${messages.length}']),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Spacer(),
                  IconButton(
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                    tooltip: isCollapsed ? 'expand'.tr() : 'collapse'.tr(),
                    onPressed: onToggleCollapse,
                    icon: Icon(
                      isCollapsed ? Symbols.expand_more : Symbols.expand_less,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isCollapsed) ...[
            SizedBox(
              height: 220,
              child: messages.isEmpty
                  ? Center(
                      child: Text(
                        'noChatMessagesYet'.tr(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return LivestreamChatMessage(msg: messages[index]);
                      },
                    ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onSubmitted: (value) {
                        onSendMessage(value);
                        controller.clear();
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'liveChatMessageHint'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'send'.tr(),
                    onPressed: isSendingChat
                        ? null
                        : () {
                            onSendMessage(controller.text);
                            controller.clear();
                          },
                    icon: isSendingChat
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Symbols.send),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LivestreamFullscreenViewer extends HookConsumerWidget {
  final String livestreamId;

  const _LivestreamFullscreenViewer({required this.livestreamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(livestreamDetailProvider(livestreamId));
    final roomState = ref.watch(livestreamRoomProvider(livestreamId));
    final notifier = ref.read(livestreamRoomProvider(livestreamId).notifier);

    String title = 'untitledLivestream'.tr();
    String? thumbnailId;
    if (detailAsync case AsyncData(value: final stream)) {
      title = stream.title ?? title;
      thumbnailId = stream.thumbnail?.id;
    }

    final controlsVisible = useState(true);
    final chatCollapsed = useState(true);
    final chatInputController = useTextEditingController();
    final chatScrollController = useScrollController();

    useEffect(() {
      final timer = Timer(const Duration(seconds: 3), () {
        controlsVisible.value = false;
      });
      return () => timer.cancel();
    }, []);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            controlsVisible.value = !controlsVisible.value;
            if (controlsVisible.value) {
              Future.delayed(const Duration(seconds: 3), () {
                controlsVisible.value = false;
              });
            }
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: roomState.videoTrack != null
                    ? lk.VideoTrackRenderer(roomState.videoTrack!)
                    : Stack(
                        children: [
                          Positioned.fill(
                            child: thumbnailId != null
                                ? CloudImageWidget(
                                    fileId: thumbnailId,
                                    fit: BoxFit.contain,
                                  )
                                : const ColoredBox(color: Colors.black),
                          ),
                          const Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Color(0x66000000),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              roomState.room == null
                                  ? 'disconnected'.tr()
                                  : 'connectedWaitingForVideo'.tr(),
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                right: 20,
                bottom: controlsVisible.value ? 72 : 20,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeOutCubic,
                  child: chatCollapsed.value
                      ? IconButton.filledTonal(
                          key: const ValueKey('chat-collapsed'),
                          tooltip: 'openChat'.tr(),
                          onPressed: () => chatCollapsed.value = false,
                          icon: const Icon(Symbols.chat_bubble),
                        )
                      : Container(
                          key: const ValueKey('chat-expanded'),
                          width: 340,
                          height: 320,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  10,
                                  10,
                                  10,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Symbols.chat_bubble,
                                      size: 18,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'chatCount'.tr(
                                          args: [
                                            '${roomState.messages.length}',
                                          ],
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Collapse',
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () =>
                                          chatCollapsed.value = true,
                                      icon: const Icon(
                                        Symbols.chevron_right,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1, color: Colors.white24),
                              Expanded(
                                child: roomState.messages.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'noChatMessagesYet',
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        controller: chatScrollController,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ),
                                        itemCount: roomState.messages.length,
                                        itemBuilder: (context, index) {
                                          return LivestreamChatMessage(
                                            msg: roomState.messages[index],
                                            dark: true,
                                          );
                                        },
                                      ),
                              ),
                              const Divider(height: 1, color: Colors.white24),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: chatInputController,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        onSubmitted: (value) async {
                                          final text = value.trim();
                                          if (text.isEmpty) return;
                                          await notifier.sendMessage(text);
                                          chatInputController.clear();
                                        },
                                        decoration: InputDecoration(
                                          isDense: true,
                                          hintText: 'liveChatMessageHint'.tr(),
                                          hintStyle: const TextStyle(
                                            color: Colors.white54,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton.filled(
                                      tooltip: 'send'.tr(),
                                      onPressed: roomState.isSendingChat
                                          ? null
                                          : () async {
                                              final text = chatInputController
                                                  .text
                                                  .trim();
                                              if (text.isEmpty) return;
                                              await notifier.sendMessage(text);
                                              chatInputController.clear();
                                            },
                                      icon: roomState.isSendingChat
                                          ? const SizedBox.square(
                                              dimension: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Symbols.send),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                top: controlsVisible.value ? 12 : -100,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Symbols.close),
                      iconSize: 18,
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Symbols.group,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${roomState.viewerCount}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ],
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                left: 16,
                right: 16,
                bottom: controlsVisible.value ? 16 : -120,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Symbols.volume_up,
                        color: Colors.white70,
                        size: 18,
                      ),
                      Expanded(
                        child: Slider(
                          max: 2,
                          value: roomState.volume,
                          onChanged: roomState.room == null
                              ? null
                              : (value) => notifier.setVolume(value),
                          year2023: true,
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                      ),
                      Text(
                        '${(roomState.volume * 100).round()}%',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
