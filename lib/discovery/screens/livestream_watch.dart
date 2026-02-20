import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/core/widgets/embeds/livestream.dart';
import 'package:island/core/widgets/embeds/livestream_chat_message.dart';
import 'package:island/core/widgets/embeds/livestream_room.dart';
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

@RoutePage()
class LivestreamWatchScreen extends ConsumerWidget {
  final String livestreamId;

  const LivestreamWatchScreen({
    super.key,
    @PathParam('id') required this.livestreamId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamAsync = ref.watch(livestreamDetailProvider(livestreamId));

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: streamAsync.when(
          data: (stream) => Text(stream?.title ?? 'live'.tr()),
          loading: () => const Text('live').tr(),
          error: (e, s) => const Text('live').tr(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Symbols.share),
            tooltip: 'share'.tr(),
            onPressed: () {},
          ),
        ],
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
            );
          }

          return _LivestreamMobileLayout(
            livestreamId: livestreamId,
            stream: stream,
            publisher: publisher,
            publisherDisplayName: publisherDisplayName,
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

  const _LivestreamMobileLayout({
    required this.livestreamId,
    required this.stream,
    this.publisher,
    this.publisherDisplayName,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: LivestreamEmbedWidget(
              livestreamId: livestreamId,
              margin: const EdgeInsets.all(12),
            ),
          ),
        ),
        if (publisherDisplayName != null)
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
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

  const _LivestreamWideLayout({
    required this.livestreamId,
    required this.stream,
    this.publisher,
    this.publisherDisplayName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: LivestreamEmbedWidget(
                      livestreamId: livestreamId,
                      margin: const EdgeInsets.all(12),
                      showChat: false,
                    ),
                  ),
                ),
                if (publisherDisplayName != null)
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: publisher?.name != null
                                ? () => context.router.push(
                                    PublisherProfileRoute(
                                      name: publisher!.name,
                                    ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
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
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: _LivestreamChatPanel(livestreamId: livestreamId),
        ),
      ],
    );
  }

  Widget _buildPublisherAvatar(SnPublisher? publisher) {
    return ProfilePictureWidget(file: publisher?.picture, radius: 24);
  }
}

class _LivestreamChatPanel extends ConsumerWidget {
  final String livestreamId;

  const _LivestreamChatPanel({required this.livestreamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomState = ref.watch(livestreamRoomProvider(livestreamId));
    final room = roomState.room;
    final messages = roomState.messages;
    final isConnected = room != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'liveChat'.tr(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              if (!isConnected)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'watchToJoin'.tr(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
            ],
          ),
          const Gap(12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: isConnected
                  ? _ChatMessagesList(
                      messages: messages,
                      livestreamId: livestreamId,
                    )
                  : _ChatPlaceholder(livestreamId: livestreamId),
            ),
          ),
        ],
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

  const _ChatMessagesList({required this.messages, required this.livestreamId});

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
                      .read(livestreamRoomProvider(widget.livestreamId).notifier)
                      .sendMessage(),
                ),
              ),
              const Gap(8),
              IconButton.filled(
                onPressed: isSending
                    ? null
                    : () => ref
                          .read(livestreamRoomProvider(widget.livestreamId).notifier)
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
