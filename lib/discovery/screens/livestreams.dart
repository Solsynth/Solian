import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/empty_state.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final activeLivestreamsProvider =
    FutureProvider.autoDispose<List<SnLiveStream>>((ref) async {
      final client = ref.watch(apiClientProvider);
      final response = await client.get(
        '/sphere/livestreams',
        queryParameters: {'limit': 100, 'offset': 0},
      );

      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => SnLiveStream.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      if (data is Map && data['items'] is List) {
        return (data['items'] as List)
            .whereType<Map>()
            .map((e) => SnLiveStream.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return const [];
    });

@RoutePage()
class ActiveLivestreamsScreen extends ConsumerWidget {
  const ActiveLivestreamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamsAsync = ref.watch(activeLivestreamsProvider);
    final isWideScreen = MediaQuery.of(context).size.width >= 600;

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: const Text('livestreams').tr(),
        actions: [
          IconButton(
            icon: const Icon(Symbols.explore),
            tooltip: 'discover'.tr(),
            onPressed: () {
              context.router.push(const ExploreRoute());
            },
          ),
        ],
      ),
      body: streamsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Symbols.error_outline, size: 48),
              const Gap(12),
              Text('errorLoadingLivestreams'.tr()),
              const Gap(8),
              FilledButton.icon(
                onPressed: () => ref.refresh(activeLivestreamsProvider),
                icon: const Icon(Symbols.refresh),
                label: Text('retry'.tr()),
              ),
            ],
          ),
        ),
        data: (streams) {
          final activeStreams = streams
              .where((e) => e.status == SnLiveStreamStatus.active)
              .toList();

          if (activeStreams.isEmpty) {
            return EmptyState(
              icon: Symbols.live_tv,
              title: 'noActiveLivestreams'.tr(),
              description: 'thereAreNoLiveStreamsRightNow'.tr(),
              action: FilledButton.icon(
                onPressed: () => context.router.push(const ExploreRoute()),
                icon: const Icon(Symbols.explore),
                label: Text('exploreContent'.tr()),
              ),
            );
          }

          return ExtendedRefreshIndicator(
            onRefresh: () => ref.refresh(activeLivestreamsProvider.future),
            child: isWideScreen
                ? _buildGridLayout(context, activeStreams)
                : _buildListLayout(context, activeStreams),
          );
        },
      ),
    );
  }

  Widget _buildListLayout(BuildContext context, List<SnLiveStream> streams) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: streams.length,
      itemBuilder: (context, index) {
        final stream = streams[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: _ActiveLivestreamCard(
            stream: stream,
            layoutMode: _CardLayoutMode.list,
          ),
        );
      },
    );
  }

  Widget _buildGridLayout(BuildContext context, List<SnLiveStream> streams) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1000 ? 3 : 2;
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 16 / 10,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: streams.length,
          itemBuilder: (context, index) {
            final stream = streams[index];
            return _ActiveLivestreamCard(
              stream: stream,
              layoutMode: _CardLayoutMode.grid,
            );
          },
        );
      },
    );
  }
}

enum _CardLayoutMode { list, grid }

class _ActiveLivestreamCard extends StatelessWidget {
  final SnLiveStream stream;
  final _CardLayoutMode layoutMode;

  const _ActiveLivestreamCard({
    required this.stream,
    this.layoutMode = _CardLayoutMode.list,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGridMode = layoutMode == _CardLayoutMode.grid;

    final title = stream.title ?? 'untitledLivestream'.tr();
    final description = stream.description;
    final publisher = stream.publisher;
    final publisherDisplayName = publisher?.nick ?? publisher?.name;
    final viewerCount = stream.viewerCount;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.router.push(LivestreamWatchRoute(livestreamId: stream.id));
        },
        child: AspectRatio(
          aspectRatio: isGridMode ? 16 / 12 : 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail
              _buildThumbnail(context, isGridMode),

              // Live badge
              Positioned(
                left: isGridMode ? 8 : 10,
                top: isGridMode ? 8 : 10,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isGridMode ? 6 : 8,
                    vertical: isGridMode ? 3 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Symbols.fiber_manual_record,
                        size: isGridMode ? 8 : 10,
                        color: Colors.white,
                      ),
                      const Gap(3),
                      Text(
                        'live'.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: isGridMode ? 10 : 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Viewer count badge
              if (viewerCount > 0)
                Positioned(
                  right: isGridMode ? 8 : 10,
                  top: isGridMode ? 8 : 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isGridMode ? 6 : 8,
                      vertical: isGridMode ? 3 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Symbols.visibility,
                          size: isGridMode ? 10 : 12,
                          color: Colors.white,
                        ),
                        const Gap(3),
                        Text(
                          _formatViewerCount(viewerCount),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: isGridMode ? 10 : 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Bottom info overlay
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(isGridMode ? 8 : 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (!isGridMode &&
                          description != null &&
                          description.isNotEmpty) ...[
                        const Gap(2),
                        Text(
                          description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                      if (publisherDisplayName != null) ...[
                        const Gap(4),
                        Row(
                          children: [
                            _buildPublisherAvatar(publisher, isGridMode),
                            const Gap(6),
                            Expanded(
                              child: Text(
                                publisher?.name != null
                                    ? '$publisherDisplayName · @${publisher!.name}'
                                    : publisherDisplayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                  fontSize: isGridMode ? 10 : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildThumbnail(BuildContext context, bool isGridMode) {
    if (stream.thumbnail?.id != null) {
      return CloudImageWidget(file: stream.thumbnail, fit: BoxFit.cover);
    }
    return _buildPlaceholder(context, isGridMode);
  }

  Widget _buildPlaceholder(BuildContext context, bool isGridMode) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Center(
        child: Icon(
          Symbols.live_tv,
          size: isGridMode ? 36 : 28,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }

  Widget _buildPublisherAvatar(SnPublisher? publisher, bool isGridMode) {
    return ProfilePictureWidget(
      radius: isGridMode ? 8 : 9,
      file: publisher?.picture,
    );
  }

  String _formatViewerCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
