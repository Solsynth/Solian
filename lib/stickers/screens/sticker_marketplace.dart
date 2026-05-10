import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/route.gr.dart';
import 'package:island/stickers/models/sticker.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'dart:async';
import 'package:island/stickers/widgets/stickers/sticker_picker.dart'
    show myStickerOwnershipsProvider;

part 'sticker_marketplace.freezed.dart';

@freezed
sealed class MarketplaceStickerQuery with _$MarketplaceStickerQuery {
  const factory MarketplaceStickerQuery({
    required bool byUsage,
    required String? query,
  }) = _MarketplaceStickerQuery;
}

final marketplaceStickerPacksNotifierProvider =
    AsyncNotifierProvider.autoDispose(MarketplaceStickerPacksNotifier.new);

class MarketplaceStickerPacksNotifier
    extends AsyncNotifier<PaginationState<SnStickerPack>>
    with
        AsyncPaginationController<SnStickerPack>,
        AsyncPaginationFilter<MarketplaceStickerQuery, SnStickerPack> {
  static const int pageSize = 20;

  @override
  MarketplaceStickerQuery currentFilter = MarketplaceStickerQuery(
    byUsage: true,
    query: null,
  );

  @override
  Future<List<SnStickerPack>> fetch() async {
    final client = ref.read(solarNetworkClientProvider);

    final response = await client.dio.get(
      '/sphere/stickers',
      queryParameters: {
        'offset': fetchedCount,
        'take': pageSize,
        'order': currentFilter.byUsage ? 'usage' : 'date',
        if (currentFilter.query != null && currentFilter.query!.isNotEmpty)
          'query': currentFilter.query,
      },
    );

    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final stickers = response.data
        .map((e) => SnStickerPack.fromJson(e))
        .cast<SnStickerPack>()
        .toList();

    return stickers;
  }
}

@RoutePage()
class StickerMarketplaceScreen extends HookConsumerWidget {
  const StickerMarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = useState<MarketplaceStickerQuery>(
      MarketplaceStickerQuery(byUsage: true, query: null),
    );
    final searchController = useTextEditingController();
    final focusNode = useFocusNode();
    final debounceTimer = useState<Timer?>(null);

    final notifier = ref.watch(
      marketplaceStickerPacksNotifierProvider.notifier,
    );

    // Clear search when query is cleared
    useEffect(() {
      if (query.value.query == null || query.value.query!.isEmpty) {
        searchController.clear();
      }
      return null;
    }, [query]);

    // Clean up timer on dispose
    useEffect(() {
      return () {
        debounceTimer.value?.cancel();
      };
    }, []);

    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        appBar: AppBar(
          title: const Text('stickers').tr(),
          leading: const AutoLeadingButton(),
          actions: [
            IconButton(
              onPressed: () {
                query.value = query.value.copyWith(
                  byUsage: !query.value.byUsage,
                );
                notifier.applyFilter(query.value);
              },
              icon: query.value.byUsage
                  ? const Icon(Symbols.local_fire_department)
                  : const Icon(Symbols.access_time),
              tooltip: query.value.byUsage
                  ? 'orderByPopularity'.tr()
                  : 'orderByReleaseDate'.tr(),
            ),
            const Gap(16),
          ],
          bottom: TabBar(
            labelColor: Theme.of(context).appBarTheme.foregroundColor,
            unselectedLabelColor: Theme.of(
              context,
            ).appBarTheme.foregroundColor?.withOpacity(0.6),
            tabs: [
              Tab(text: 'marketplace'.tr()),
              Tab(text: 'myStickers'.tr()),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SearchBar(
                    controller: searchController,
                    focusNode: focusNode,
                    hintText: 'search'.tr(),
                    leading: const Icon(Symbols.search),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    trailing: [
                      if (query.value.query != null &&
                          query.value.query!.isNotEmpty)
                        IconButton.filledTonal(
                          icon: const Icon(Symbols.close),
                          onPressed: () {
                            query.value = query.value.copyWith(query: null);
                            notifier.applyFilter(query.value);
                            searchController.clear();
                            focusNode.unfocus();
                          },
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                    onChanged: (value) {
                      debounceTimer.value?.cancel();
                      debounceTimer.value = Timer(
                        const Duration(milliseconds: 500),
                        () {
                          query.value = query.value.copyWith(query: value);
                          notifier.applyFilter(query.value);
                        },
                      );
                    },
                    onSubmitted: (value) {
                      query.value = query.value.copyWith(query: value);
                      notifier.applyFilter(query.value);
                      focusNode.unfocus();
                    },
                  ),
                ),
                Expanded(
                  child: PaginationList(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    provider: marketplaceStickerPacksNotifierProvider,
                    notifier: marketplaceStickerPacksNotifierProvider.notifier,
                    itemBuilder: (context, idx, pack) =>
                        _MarketplacePackCard(pack: pack),
                  ),
                ),
              ],
            ),
            const _OwnedStickerPacksPage(),
          ],
        ),
      ),
    );
  }
}

class _MarketplacePackCard extends StatelessWidget {
  final SnStickerPack pack;

  const _MarketplacePackCard({required this.pack});

  @override
  Widget build(BuildContext context) {
    final stickers = [...pack.stickers]
      ..sort((a, b) => a.order.compareTo(b.order));

    return Card.filled(
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          if (stickers.isNotEmpty)
            Card.filled(
              margin: EdgeInsets.zero,
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        math.min(stickers.length, 4),
                        (index) => Padding(
                          padding: EdgeInsets.only(right: index < 3 ? 8 : 0),
                          child: Card.outlined(
                            elevation: 0,
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 72,
                                height: 72,
                                child: CloudImageWidget(
                                  file: stickers[index].image,
                                  noBlurhash: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (stickers.length > 4) ...[
                      const Gap(8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          math.min(stickers.length - 4, 4),
                          (index) => Padding(
                            padding: EdgeInsets.only(right: index < 3 ? 8 : 0),
                            child: Card.outlined(
                              elevation: 0,
                              margin: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 72,
                                  height: 72,
                                  child: CloudImageWidget(
                                    file: stickers[index + 4].image,
                                    noBlurhash: true,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Card.outlined(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: CloudImageWidget(
                    file: pack.icon ?? pack.stickers.firstOrNull?.image,
                    noBlurhash: true,
                  ),
                ),
              ),
            ),
            title: Text(
              pack.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text(
              pack.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Icon(
              Symbols.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onTap: () {
              context.router.push(
                StickerMarketplacePackDetailRoute(id: pack.id),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OwnedStickerPacksPage extends HookConsumerWidget {
  const _OwnedStickerPacksPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownershipsAsync = ref.watch(myStickerOwnershipsProvider);

    return ownershipsAsync.when(
      data: (ownerships) {
        final orderedOwnerships = [...ownerships]
          ..sort((a, b) => a.order.compareTo(b.order));
        if (orderedOwnerships.isEmpty) {
          return Center(child: Text('noStickerPacks'.tr()));
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(myStickerOwnershipsProvider),
          child: ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            buildDefaultDragHandles: false,
            itemCount: orderedOwnerships.length,
            onReorder: (oldIndex, newIndex) async {
              if (newIndex > oldIndex) newIndex -= 1;
              final reordered = [...orderedOwnerships];
              final item = reordered.removeAt(oldIndex);
              reordered.insert(newIndex, item);
              final client = ref.read(solarNetworkClientProvider);
              await client.stickers.reorderOwnedStickerPacks(
                items: reordered.asMap().entries.map((e) => {'id': e.value.id, 'order': e.key}).toList(),
              );
              ref.invalidate(myStickerOwnershipsProvider);
            },
            itemBuilder: (context, index) {
              final ownership = orderedOwnerships[index];
              final pack = ownership.pack;
              return _OwnedPackCard(
                key: ValueKey(ownership.id),
                index: index,
                pack: pack,
                onRemove: () async {
                  final client = ref.read(solarNetworkClientProvider);
                  await client.stickers.releaseStickerPack(ownership.packId);
                  ref.invalidate(myStickerOwnershipsProvider);
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}

class _OwnedPackCard extends StatefulWidget {
  final int index;
  final SnStickerPack? pack;
  final VoidCallback onRemove;

  const _OwnedPackCard({
    super.key,
    required this.index,
    required this.pack,
    required this.onRemove,
  });

  @override
  State<_OwnedPackCard> createState() => _OwnedPackCardState();
}

class _OwnedPackCardState extends State<_OwnedPackCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final pack = widget.pack;
    final stickers = pack?.stickers ?? [];

    return Card.filled(
      color: Theme.of(context).colorScheme.surfaceContainer,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: ReorderableDragStartListener(
              index: widget.index,
              child: const Icon(Symbols.drag_indicator),
            ),
            title: Text(pack?.name ?? 'Unknown'),
            subtitle: Text(
              pack?.description ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _isExpanded ? Symbols.expand_less : Symbols.expand_more,
                  ),
                  onPressed: () {
                    setState(() => _isExpanded = !_isExpanded);
                  },
                ),
                IconButton(
                  icon: const Icon(Symbols.delete_outline),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('removePack'.tr()),
                        content: Text('removePackConfirm'.tr()),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('cancel'.tr()),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('remove'.tr()),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      widget.onRemove();
                    }
                  },
                ),
              ],
            ),
          ),
          if (_isExpanded && pack != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (pack.icon != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: CloudImageWidget(
                            file: pack.icon!,
                            noBlurhash: true,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: stickers.isEmpty
                        ? Text(
                            'noStickersInPack'.tr(),
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        : SizedBox(
                            height: 56,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: stickers.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, idx) {
                                final sticker = stickers[idx];
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: CloudImageWidget(
                                      file: sticker.image,
                                      noBlurhash: true,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
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
