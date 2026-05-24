import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:island/accounts/widgets/account/activity_presence.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:gap/gap.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:island/shared/widgets/confuse_spinner.dart';

class AccountTimelineList extends ConsumerWidget {
  final String uname;

  const AccountTimelineList({super.key, required this.uname});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(accountTimelineProvider(uname));

    return timelineAsync.when(
      data: (state) {
        final items = state.items;
        final groupedItems = _groupDuplicateItems(items);

        if (groupedItems.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('dataEmpty').tr(),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.only(bottom: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index == groupedItems.length) {
                if (state.hasMore) {
                  return _TimelineLoadMore(
                    state: state,
                    notifier: ref.read(accountTimelineProvider(uname).notifier),
                  );
                }
                return const SizedBox.shrink();
              }

              final groupedItem = groupedItems[index];
              if (groupedItem.items.length > 1) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AccountTimelineItem(
                    item: groupedItem.items.first,
                    duplicateCount: groupedItem.items.length,
                    duration: groupedItem.duration,
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AccountTimelineItem(
                  item: groupedItem.items.first,
                  duration: groupedItem.duration,
                ),
              );
            }, childCount: groupedItems.length + 1),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) =>
          SliverToBoxAdapter(child: Center(child: Text('Error: $error'))),
    );
  }

  List<_GroupedTimelineItem> _groupDuplicateItems(
    List<SnAccountTimelineItem> items,
  ) {
    if (items.isEmpty) return [];

    final List<_GroupedTimelineItem> grouped = [];
    _GroupedTimelineItem? currentGroup;

    for (final item in items) {
      if (currentGroup == null ||
          !_isSameType(currentGroup.items.first, item)) {
        currentGroup = _GroupedTimelineItem(items: [item]);
        grouped.add(currentGroup);
      } else {
        currentGroup.items.add(item);
      }
    }

    final now = DateTime.now();
    for (var i = 0; i < grouped.length; i++) {
      final current = grouped[i];
      final end = i == 0 ? now : grouped[i - 1].items.first.createdAt;
      current.duration = end.difference(current.items.first.createdAt);
    }

    return grouped;
  }

  bool _isSameType(SnAccountTimelineItem a, SnAccountTimelineItem b) {
    if (a.eventType != b.eventType) return false;
    if (a.eventType == 0) return false;
    if (a.eventType == 1 && a.activity != null && b.activity != null) {
      final activityA = a.activity!;
      final activityB = b.activity!;

      if (activityA.manualId == 'spotify' || activityB.manualId == 'spotify') {
        return false;
      }

      if (activityA.manualId != activityB.manualId ||
          activityA.type != activityB.type) {
        return false;
      }

      if (activityA.manualId == 'steam' &&
          activityA.meta != null &&
          activityB.meta != null) {
        final metaA = activityA.meta as Map<String, dynamic>;
        final metaB = activityB.meta as Map<String, dynamic>;
        return metaA['game_id'] == metaB['game_id'];
      }

      return activityA.title == activityB.title;
    }
    return false;
  }
}

class _TimelineLoadMore extends StatefulWidget {
  final PaginationState<SnAccountTimelineItem> state;
  final AccountTimelineNotifier notifier;

  const _TimelineLoadMore({required this.state, required this.notifier});

  @override
  State<_TimelineLoadMore> createState() => _TimelineLoadMoreState();
}

class _TimelineLoadMoreState extends State<_TimelineLoadMore> {
  bool _hasTriggered = false;
  bool _hasBeenVisible = false;

  @override
  Widget build(BuildContext context) {
    final child = _hasBeenVisible
        ? (widget.state.isLoading)
              ? Container(
                  height: 60,
                  alignment: Alignment.center,
                  child: ConfuseSpinner(
                    size: 32,
                    speed: 3,
                    text: 'o.O O.o',
                    fontSize: 16,
                  ),
                )
              : SizedBox(
                  height: 64,
                  child: Row(
                    spacing: 8,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Symbols.close, size: 16, color: Colors.grey),
                      Text(
                        'noFurtherData'.tr(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
        : Container(
            height: 60,
            alignment: Alignment.center,
            child: ConfuseSpinner(
              size: 32,
              speed: 3,
              text: 'o.O O.o',
              fontSize: 16,
            ),
          );

    return VisibilityDetector(
      key: Key("timeline-load-more-${widget.notifier.hashCode}"),
      onVisibilityChanged: (info) {
        if (!mounted) return;
        setState(() => _hasBeenVisible = true);
        if (info.visibleFraction > 0.1 && !_hasTriggered) {
          _hasTriggered = true;
          if (!widget.notifier.fetchedAll &&
              !widget.state.isLoading &&
              !widget.state.isReloading) {
            widget.notifier.fetchFurther();
          }
        }
      },
      child: child,
    );
  }
}

class _GroupedTimelineItem {
  final List<SnAccountTimelineItem> items;
  Duration? duration;

  _GroupedTimelineItem({required this.items});
}

class AccountTimelineItem extends ConsumerWidget {
  final SnAccountTimelineItem item;
  final int duplicateCount;
  final Duration? duration;

  const AccountTimelineItem({
    super.key,
    required this.item,
    this.duplicateCount = 1,
    this.duration,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final createdAt = item.createdAt;

    switch (item.eventType) {
      case 0:
        final status = item.status!;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            spacing: 12,
            children: [
              Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(status),
                      size: 20,
                      color: _getStatusColor(status),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: status.isOnline ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.surface,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (status.symbol != null && status.symbol!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              status.symbol!,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            status.label.isNotEmpty
                                ? status.label
                                : 'statusChange'.tr(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Gap(2),
                    Row(
                      spacing: 6,
                      children: [
                        Expanded(
                          child: Text(
                            '${createdAt.toLocal().formatRelative(context)} · ${createdAt.toLocal().formatSystem()}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (status.appIdentifier != null &&
                            status.appIdentifier!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              status.appIdentifier!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (duration != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 2,
                            children: [
                              Icon(
                                Symbols.schedule,
                                size: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              Text(
                                duration!.abs().formatDuration(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (status.isAutomated)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      Icon(
                        Symbols.smart_toy,
                        size: 14,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                      Text(
                        'bot',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ).tr(),
                    ],
                  ),
                ),
              if (duplicateCount > 1)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'x$duplicateCount',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
            ],
          ),
        );
      case 1:
        final activity = item.activity!;
        final isSpotify = activity.manualId == 'spotify';
        final isSteam = activity.manualId == 'steam';
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isSteam && activity.meta != null)
                _SteamBackgroundImage(
                  meta: activity.meta as Map<String, dynamic>,
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  spacing: 12,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getActivityColor(
                              activity.type,
                            ).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getActivityIcon(activity.type),
                            size: 20,
                            color: _getActivityColor(activity.type),
                          ),
                        ),
                        if (isSpotify)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Symbols.music_note,
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (isSteam)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1B2838),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Symbols.sports_esports,
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (activity.largeImage != null && !isSteam)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: _resolveArtworkUrl(ref, activity.largeImage!),
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title ?? 'unknown'.tr(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (activity.subtitle != null &&
                              activity.subtitle!.isNotEmpty) ...[
                            const Gap(2),
                            Text(
                              activity.subtitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (activity.caption != null &&
                              activity.caption!.isNotEmpty) ...[
                            const Gap(2),
                            Text(
                              activity.caption!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const Gap(2),
                          Text(
                            '${createdAt.toLocal().formatRelative(context)} · ${createdAt.toLocal().formatSystem()}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (duration != null) ...[
                            const Gap(4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 2,
                              children: [
                                Icon(
                                  Symbols.schedule,
                                  size: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                Text(
                                  duration!.abs().formatDuration(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            kPresenceActivityTypes[activity.type],
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                          ).tr(),
                        ),
                        if (duplicateCount > 1 && !isSpotify)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'x$duplicateCount',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      default:
        return Text('unknown').tr();
    }
  }

  Color _getStatusColor(SnAccountStatus status) {
    switch (status.type) {
      case SnAccountStatusType.busy:
        return Colors.red;
      case SnAccountStatusType.doNotDisturb:
        return Colors.orange;
      case SnAccountStatusType.invisible:
        return Colors.grey;
      default:
        return Colors.green;
    }
  }

  IconData _getStatusIcon(SnAccountStatus status) {
    switch (status.type) {
      case SnAccountStatusType.busy:
        return Symbols.do_not_disturb_on;
      case SnAccountStatusType.doNotDisturb:
        return Symbols.mic_off;
      case SnAccountStatusType.invisible:
        return Symbols.visibility_off;
      default:
        return Symbols.circle;
    }
  }

  Color _getActivityColor(int type) {
    switch (type) {
      case 1:
        return Colors.purple;
      case 2:
        return Colors.green;
      case 3:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getActivityIcon(int type) {
    switch (type) {
      case 1:
        return Symbols.play_arrow;
      case 2:
        return Symbols.music_note;
      case 3:
        return Symbols.fitness_center;
      default:
        return Symbols.category;
    }
  }

  String _resolveArtworkUrl(WidgetRef ref, String imageUri) {
    if (imageUri.startsWith('sha256:')) {
      final serverURL = ref.read(serverUrlProvider);
      return '$serverURL/passport/presence/artworks/$imageUri';
    }
    return imageUri;
  }
}

class _SteamBackgroundImage extends StatelessWidget {
  final Map<String, dynamic> meta;

  const _SteamBackgroundImage({required this.meta});

  @override
  Widget build(BuildContext context) {
    final gameId = meta['game_id']?.toString();
    if (gameId == null) return const SizedBox.shrink();

    final heroUrl =
        'https://cdn.cloudflare.steamstatic.com/steam/apps/$gameId/library_hero.jpg';

    return CachedNetworkImage(
      imageUrl: heroUrl,
      height: 120,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: 80,
        color: const Color(0xFF1B2838),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => Container(
        height: 80,
        color: const Color(0xFF1B2838),
        child: const Center(
          child: Icon(Symbols.sports_esports, color: Colors.white70, size: 32),
        ),
      ),
    );
  }
}

final accountTimelineProvider = AsyncNotifierProvider.autoDispose
    .family<
      AccountTimelineNotifier,
      PaginationState<SnAccountTimelineItem>,
      String
    >(AccountTimelineNotifier.new);

class AccountTimelineNotifier
    extends AsyncNotifier<PaginationState<SnAccountTimelineItem>>
    with AsyncPaginationController<SnAccountTimelineItem> {
  static const int pageSize = 20;

  final String arg;
  AccountTimelineNotifier(this.arg);

  @override
  FutureOr<PaginationState<SnAccountTimelineItem>> build() async {
    final items = await fetch();
    return PaginationState(
      items: items,
      isLoading: false,
      isReloading: false,
      totalCount: totalCount,
      hasMore: hasMore,
      cursor: cursor,
    );
  }

  @override
  Future<List<SnAccountTimelineItem>> fetch() async {
    final client = ref.read(apiClientProvider);

    final queryParams = {
      'offset': fetchedCount.toString(),
      'take': pageSize.toString(),
    };

    final response = await client.get(
      '/passport/accounts/$arg/timeline',
      queryParameters: queryParams,
    );

    totalCount = int.parse(response.headers.value('X-Total') ?? '0');

    return (response.data as List<dynamic>)
        .map((e) => SnAccountTimelineItem.fromJson(e))
        .cast<SnAccountTimelineItem>()
        .toList();
  }
}
