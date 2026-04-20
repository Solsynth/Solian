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

    return AppScaffold(
      appBar: AppBar(
        title: const Text('stickers').tr(),
        leading: const AutoLeadingButton(),
        actions: [
          IconButton(
            onPressed: () {
              query.value = query.value.copyWith(byUsage: !query.value.byUsage);
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
      ),
      body: Column(
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
                if (query.value.query != null && query.value.query!.isNotEmpty)
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
                // Debounce search to avoid excessive API calls
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              provider: marketplaceStickerPacksNotifierProvider,
              notifier: marketplaceStickerPacksNotifierProvider.notifier,
              itemBuilder: (context, idx, pack) => Card.filled(
                margin: const EdgeInsets.only(bottom: 12),
                color: Theme.of(context).colorScheme.surfaceContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    if (pack.stickers.isNotEmpty)
                      Card.filled(
                        margin: EdgeInsets.zero,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHigh,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  math.min(pack.stickers.length, 4),
                                  (index) => Padding(
                                    padding: EdgeInsets.only(
                                      right: index < 3 ? 8 : 0,
                                    ),
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
                                            file: pack.stickers[index].image,
                                            noBlurhash: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (pack.stickers.length > 4) ...[
                                const Gap(8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    math.min(pack.stickers.length - 4, 4),
                                    (index) => Padding(
                                      padding: EdgeInsets.only(
                                        right: index < 3 ? 8 : 0,
                                      ),
                                      child: Card.outlined(
                                        elevation: 0,
                                        margin: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: SizedBox(
                                            width: 72,
                                            height: 72,
                                            child: CloudImageWidget(
                                              file: pack
                                                  .stickers[index + 4]
                                                  .image,
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
                              file:
                                  pack.icon ?? pack.stickers.firstOrNull?.image,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
