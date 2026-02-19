import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/widgets/embeds/livestream.dart';
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

class ActiveLivestreamsScreen extends ConsumerWidget {
  const ActiveLivestreamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamsAsync = ref.watch(activeLivestreamsProvider);

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(title: const Text('livestreams').tr()),
      body: streamsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (streams) {
          final activeStreams = streams
              .where((e) => e.status == SnLiveStreamStatus.active)
              .toList();
          if (activeStreams.isEmpty) {
            return EmptyState(
              icon: Symbols.live_tv,
              title: 'noActiveLivestreams'.tr(),
              description: 'thereAreNoLiveStreamsRightNow'.tr(),
            );
          }

          return ExtendedRefreshIndicator(
            onRefresh: () => ref.refresh(activeLivestreamsProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              itemCount: activeStreams.length,
              itemBuilder: (context, index) {
                final stream = activeStreams[index];
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: _ActiveLivestreamCard(stream: stream),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ActiveLivestreamCard extends StatelessWidget {
  final SnLiveStream stream;

  const _ActiveLivestreamCard({required this.stream});

  @override
  Widget build(BuildContext context) {
    final thumbnail = stream.thumbnail?.id != null
        ? CloudImageWidget(fileId: stream.thumbnail!.id, fit: BoxFit.cover)
        : ColoredBox(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: const Center(child: Icon(Symbols.live_tv, size: 28)),
          );
    final title = stream.title ?? 'untitledLivestream'.tr();
    final description = stream.description;
    final publisher = stream.publisher;
    final publisherDisplayName = publisher?.nick ?? publisher?.name;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _LivestreamWatchScreen(stream: stream),
            ),
          );
        },
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              thumbnail,
              Positioned(
                left: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Symbols.fiber_manual_record,
                        size: 12,
                        color: Colors.redAccent,
                      ),
                      const Gap(4),
                      Text(
                        'live'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.75),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (description != null && description.isNotEmpty)
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white.withOpacity(0.9)),
                        ),
                      if (publisherDisplayName != null) ...[
                        const Gap(4),
                        Row(
                          children: [
                            ProfilePictureWidget(
                              file: publisher?.picture,
                              fallbackIcon: Symbols.campaign,
                              radius: 9,
                            ),
                            const Gap(6),
                            Expanded(
                              child: Text(
                                publisher?.name != null
                                    ? '$publisherDisplayName · @${publisher!.name}'
                                    : publisherDisplayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.white70),
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
}

class _LivestreamWatchScreen extends StatelessWidget {
  final SnLiveStream stream;

  const _LivestreamWatchScreen({required this.stream});

  @override
  Widget build(BuildContext context) {
    final publisher = stream.publisher;
    final publisherDisplayName = publisher?.nick ?? publisher?.name;

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(title: Text(stream.title ?? 'untitledLivestream'.tr())),
      body: ListView(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: LivestreamEmbedWidget(
                livestreamId: stream.id,
                margin: const EdgeInsets.all(12),
              ),
            ),
          ),
          if (publisherDisplayName != null)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Row(
                      children: [
                        ProfilePictureWidget(
                          file: publisher?.picture,
                          fallbackIcon: Symbols.campaign,
                          radius: 14,
                        ),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            publisher?.name != null
                                ? '$publisherDisplayName · @${publisher!.name}'
                                : publisherDisplayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    context.router.push(
                      PublisherProfileRoute(name: publisher!.name),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
