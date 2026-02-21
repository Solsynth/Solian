import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/livestreams/livestream.dart';
import 'package:island/core/widgets/embeds/livestream_award_sheet.dart';
import 'package:island/core/widgets/embeds/livestream_chat_message.dart';
import 'package:island/core/widgets/embeds/livestream_leaderboard_sheet.dart';
import 'package:island/core/widgets/embeds/livestream_playback.dart';
import 'package:island/livestreams/livestream_room.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/empty_state.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final livestreamDetailProvider = FutureProvider.autoDispose
    .family<SnLiveStream?, String>((ref, id) async {
      final client = ref.watch(apiClientProvider);
      try {
        final response = await client.get('/sphere/livestreams/$id');
        final data = response.data;
        if (data is Map) {
          return SnLiveStream.fromJson(Map<String, dynamic>.from(data));
        }
      } catch (_) {}
      return null;
    });

enum _LivestreamPlaybackMode { webrtc, hls }

@RoutePage()
class LivestreamWatchScreen extends HookConsumerWidget {
  final String livestreamId;

  const LivestreamWatchScreen({
    super.key,
    @PathParam('id') required this.livestreamId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamAsync = ref.watch(livestreamDetailProvider(livestreamId));
    final playbackMode = useState<_LivestreamPlaybackMode>(
      _LivestreamPlaybackMode.webrtc,
    );

    useEffect(
      () {
        final stream = streamAsync.value;
        if (stream == null) return null;
        final hasHls = (stream.hlsPlaylistPath ?? '').trim().isNotEmpty;
        if (stream.status == SnLiveStreamStatus.ended && hasHls) {
          playbackMode.value = _LivestreamPlaybackMode.hls;
        } else if (!hasHls &&
            playbackMode.value == _LivestreamPlaybackMode.hls) {
          playbackMode.value = _LivestreamPlaybackMode.webrtc;
        }
        return null;
      },
      [
        streamAsync.value?.id,
        streamAsync.value?.status,
        streamAsync.value?.hlsPlaylistPath,
      ],
    );

    useEffect(() {
      if (playbackMode.value == _LivestreamPlaybackMode.hls) {
        unawaited(
          ref.read(livestreamRoomProvider(livestreamId).notifier).disconnect(),
        );
      }
      return null;
    }, [playbackMode.value]);

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: streamAsync.when(
          data: (stream) => Text(stream?.title ?? 'live'.tr()),
          loading: () => const Text('live').tr(),
          error: (e, s) => const Text('live').tr(),
        ),
        actions: [],
      ),
      body: streamAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Symbols.error_outline, size: 48),
              const Gap(12),
              Text('errorLoadingStream'.tr()),
            ],
          ),
        ),
        data: (stream) {
          if (stream == null) {
            return EmptyState(
              icon: Symbols.error,
              title: 'streamNotFound'.tr(),
              description: 'thisStreamMayHaveEnded'.tr(),
            );
          }

          final isWide = isWideScreen(context);
          final publisher = stream.publisher;
          final publisherDisplayName = publisher?.nick ?? publisher?.name;

          if (isWide) {
            return _LivestreamWideLayout(
              livestreamId: livestreamId,
              stream: stream,
              publisher: publisher,
              publisherDisplayName: publisherDisplayName,
              playbackMode: playbackMode.value,
              onPlaybackModeChanged: (value) => playbackMode.value = value,
              hlsUrl: resolveLivestreamHlsUrl(stream),
            );
          }

          return _LivestreamMobileLayout(
            livestreamId: livestreamId,
            stream: stream,
            publisher: publisher,
            publisherDisplayName: publisherDisplayName,
            playbackMode: playbackMode.value,
            onPlaybackModeChanged: (value) => playbackMode.value = value,
            hlsUrl: resolveLivestreamHlsUrl(stream),
          );
        },
      ),
    );
  }
}

class _LivestreamMobileLayout extends StatelessWidget {
  final String livestreamId;
  final SnLiveStream stream;
  final SnPublisher? publisher;
  final String? publisherDisplayName;
  final _LivestreamPlaybackMode playbackMode;
  final ValueChanged<_LivestreamPlaybackMode> onPlaybackModeChanged;
  final String? hlsUrl;

  const _LivestreamMobileLayout({
    required this.livestreamId,
    required this.stream,
    this.publisher,
    this.publisherDisplayName,
    required this.playbackMode,
    required this.onPlaybackModeChanged,
    required this.hlsUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasHls = hlsUrl != null && hlsUrl!.isNotEmpty;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
          child: _PlaybackModeSelector(
            stream: stream,
            playbackMode: playbackMode,
            hasHls: hasHls,
            onChanged: onPlaybackModeChanged,
          ),
        ),
        if (hasHls) const Gap(12),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: playbackMode == _LivestreamPlaybackMode.webrtc
                ? LivestreamEmbedWidget(
                    livestreamId: livestreamId,
                    margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: _HlsPlaybackCard(hlsUrl: hlsUrl, stream: stream),
                  ),
          ),
        ),
        if (playbackMode == _LivestreamPlaybackMode.hls)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: ListTile(
              leading: Icon(Symbols.info),
              title: Text('HLS mode'),
              subtitle: Text(
                'Chat is unavailable when watching via HLS replay.',
              ),
            ),
          ),
        if (publisherDisplayName != null)
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: publisher?.name != null
                        ? () => context.router.push(
                            PublisherProfileRoute(name: publisher!.name),
                          )
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          _buildPublisherAvatar(publisher),
                          const Gap(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  publisherDisplayName!,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                if (publisher?.name != null)
                                  Text(
                                    '@${publisher!.name}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                              ],
                            ),
                          ),
                          const Icon(Symbols.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        const Gap(16),
      ],
    );
  }

  Widget _buildPublisherAvatar(SnPublisher? publisher) {
    return ProfilePictureWidget(radius: 24, file: publisher?.picture);
  }
}

class _LivestreamWideLayout extends StatelessWidget {
  final String livestreamId;
  final SnLiveStream stream;
  final SnPublisher? publisher;
  final String? publisherDisplayName;
  final _LivestreamPlaybackMode playbackMode;
  final ValueChanged<_LivestreamPlaybackMode> onPlaybackModeChanged;
  final String? hlsUrl;

  const _LivestreamWideLayout({
    required this.livestreamId,
    required this.stream,
    this.publisher,
    this.publisherDisplayName,
    required this.playbackMode,
    required this.onPlaybackModeChanged,
    required this.hlsUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasHls = hlsUrl != null && hlsUrl!.isNotEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
                  child: _PlaybackModeSelector(
                    stream: stream,
                    playbackMode: playbackMode,
                    hasHls: hasHls,
                    onChanged: onPlaybackModeChanged,
                  ),
                ),
                if (hasHls) const Gap(12),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: playbackMode == _LivestreamPlaybackMode.webrtc
                        ? LivestreamEmbedWidget(
                            livestreamId: livestreamId,
                            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            showChat: false,
                          )
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            child: _HlsPlaybackCard(
                              hlsUrl: hlsUrl,
                              stream: stream,
                            ),
                          ),
                  ),
                ),
                if (publisherDisplayName != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: publisher?.name != null
                            ? () => context.router.push(
                                PublisherProfileRoute(name: publisher!.name),
                              )
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              _buildPublisherAvatar(publisher),
                              const Gap(12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      publisherDisplayName!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    if (publisher?.name != null)
                                      Text(
                                        '@${publisher!.name}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                  ],
                                ),
                              ),
                              const Icon(Symbols.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                const Gap(16),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: playbackMode == _LivestreamPlaybackMode.webrtc
              ? _LivestreamChatPanel(livestreamId: livestreamId, stream: stream)
              : const _HlsChatPanel(),
        ),
      ],
    );
  }

  Widget _buildPublisherAvatar(SnPublisher? publisher) {
    return ProfilePictureWidget(file: publisher?.picture, radius: 24);
  }
}

class _PlaybackModeSelector extends StatelessWidget {
  final SnLiveStream stream;
  final _LivestreamPlaybackMode playbackMode;
  final bool hasHls;
  final ValueChanged<_LivestreamPlaybackMode> onChanged;

  const _PlaybackModeSelector({
    required this.stream,
    required this.playbackMode,
    required this.hasHls,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasHls) return const SizedBox.shrink();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Symbols.video_settings),
            const Gap(8),
            const Text('Watch by'),
            const Gap(12),
            Expanded(
              child: SegmentedButton<_LivestreamPlaybackMode>(
                selected: {playbackMode},
                segments: const [
                  ButtonSegment<_LivestreamPlaybackMode>(
                    value: _LivestreamPlaybackMode.webrtc,
                    label: Text('Live (WebRTC)'),
                    icon: Icon(Symbols.live_tv),
                  ),
                  ButtonSegment<_LivestreamPlaybackMode>(
                    value: _LivestreamPlaybackMode.hls,
                    label: Text('Replay (HLS)'),
                    icon: Icon(Symbols.play_circle),
                  ),
                ],
                onSelectionChanged: (selection) {
                  if (selection.isNotEmpty) {
                    onChanged(selection.first);
                  }
                },
              ),
            ),
            if (stream.status == SnLiveStreamStatus.ended) ...[
              const Gap(8),
              Text(
                'Ended',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HlsPlaybackCard extends StatelessWidget {
  final SnLiveStream stream;
  final String? hlsUrl;

  const _HlsPlaybackCard({required this.stream, required this.hlsUrl});

  @override
  Widget build(BuildContext context) {
    if (hlsUrl == null || hlsUrl!.isEmpty) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text(
              'HLS replay is not available for this stream.',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LivestreamHlsVideo(
          stream: stream,
          hlsUrl: hlsUrl,
          showVodBadge: true,
        ),
      ),
    );
  }
}

class _HlsChatPanel extends StatelessWidget {
  const _HlsChatPanel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Symbols.forum, size: 48),
                Gap(12),
                Text(
                  'Chat is unavailable in HLS replay mode. Switch to Live (WebRTC) to join chat.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LivestreamChatPanel extends ConsumerWidget {
  final String livestreamId;
  final SnLiveStream stream;

  const _LivestreamChatPanel({
    required this.livestreamId,
    required this.stream,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomState = ref.watch(livestreamRoomProvider(livestreamId));
    final room = roomState.room;
    final messages = roomState.messages;
    final isConnected = room != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: isConnected
            ? _ChatMessagesList(
                messages: messages,
                livestreamId: livestreamId,
                stream: stream,
              )
            : _ChatPlaceholder(livestreamId: livestreamId),
      ),
    );
  }
}

class _ChatPlaceholder extends ConsumerWidget {
  final String livestreamId;

  const _ChatPlaceholder({required this.livestreamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomState = ref.watch(livestreamRoomProvider(livestreamId));
    final isConnecting = roomState.isConnecting;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.forum,
              size: 56,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const Gap(16),
            Text(
              'liveChatSidePanelInfo'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            if (isConnecting)
              const CircularProgressIndicator()
            else
              FilledButton.tonalIcon(
                onPressed: () => ref
                    .read(livestreamRoomProvider(livestreamId).notifier)
                    .connect(),
                icon: const Icon(Symbols.play_arrow),
                label: Text('watchStream'.tr()),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessagesList extends ConsumerStatefulWidget {
  final List<ChatMessage> messages;
  final String livestreamId;
  final SnLiveStream stream;

  const _ChatMessagesList({
    required this.messages,
    required this.livestreamId,
    required this.stream,
  });

  @override
  ConsumerState<_ChatMessagesList> createState() => _ChatMessagesListState();
}

class _ChatMessagesListState extends ConsumerState<_ChatMessagesList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void didUpdateWidget(covariant _ChatMessagesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length > oldWidget.messages.length) {
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomState = ref.watch(livestreamRoomProvider(widget.livestreamId));
    final isSending = roomState.isSendingChat;
    final inputController = ref
        .read(livestreamRoomProvider(widget.livestreamId).notifier)
        .chatInputController;

    return Column(
      children: [
        Expanded(
          child: widget.messages.isEmpty
              ? Center(
                  child: Text(
                    'noChatMessagesYet'.tr(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: widget.messages.length,
                  itemBuilder: (context, index) {
                    final msg = widget.messages[index];
                    return LivestreamChatMessage(msg: msg);
                  },
                ),
        ),
        Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => LivestreamLeaderboardSheet(
                    livestreamId: widget.livestreamId,
                  ),
                ),
                icon: const Icon(Symbols.leaderboard),
                tooltip: 'livestreamLeaderboard'.tr(),
              ),
              IconButton(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) =>
                      LivestreamAwardSheet(livestream: widget.stream),
                ),
                icon: const Icon(Symbols.star),
                tooltip: 'awardLivestream'.tr(),
              ),
              Expanded(
                child: TextField(
                  controller: inputController,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'liveChatMessageHint'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onSubmitted: (value) => ref
                      .read(
                        livestreamRoomProvider(widget.livestreamId).notifier,
                      )
                      .sendMessage(),
                ),
              ),
              const Gap(8),
              IconButton.filled(
                onPressed: isSending
                    ? null
                    : () => ref
                          .read(
                            livestreamRoomProvider(
                              widget.livestreamId,
                            ).notifier,
                          )
                          .sendMessage(),
                icon: isSending
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
    );
  }
}
