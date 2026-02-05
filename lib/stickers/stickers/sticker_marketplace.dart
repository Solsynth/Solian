import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pagination/pagination.dart';
import 'package:island/stickers/stickers_models/sticker.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/drive/drive_widgets/cloud_files.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'dart:async';

import 'package:styled_widget/styled_widget.dart';

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
    final client = ref.read(apiClientProvider);

    final response = await client.get(
      '/sphere/stickers',
      queryParameters: {
        'offset': fetchedCount.toString(),
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

/// User-facing marketplace screen for browsing sticker packs.
/// This version does NOT rely on publisher name (no pubName).
class MarketplaceStickersScreen extends HookConsumerWidget {
  const MarketplaceStickersScreen({super.key});

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
          const Gap(8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: SearchBar(
              elevation: WidgetStateProperty.all(4),
              controller: searchController,
              focusNode: focusNode,
              hintText: 'search'.tr(),
              leading: const Icon(Symbols.search),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 24),
              ),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              trailing: [
                if (query.value.query != null && query.value.query!.isNotEmpty)
                  IconButton(
                    icon: const Icon(Symbols.close),
                    onPressed: () {
                      query.value = query.value.copyWith(query: null);
                      notifier.applyFilter(query.value);
                      searchController.clear();
                      focusNode.unfocus();
                    },
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
              padding: EdgeInsets.only(top: 8),
              provider: marketplaceStickerPacksNotifierProvider,
              notifier: marketplaceStickerPacksNotifierProvider.notifier,
              itemBuilder: (context, idx, pack) => Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Column(
                  children: [
                    if (pack.stickers.isNotEmpty)
                      Container(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
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
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        maxWidth: 80,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.tertiaryContainer,
                                      ),
                                      child: CloudImageWidget(
                                        file: pack.stickers[index].image,
                                      ),
                                    ).clipRRect(all: 8),
                                  ),
                                ),
                              ),
                              if (pack.stickers.length > 4)
                                const SizedBox(height: 8),
                              if (pack.stickers.length > 4)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    math.min(pack.stickers.length - 4, 4),
                                    (index) => Padding(
                                      padding: EdgeInsets.only(
                                        right: index < 3 ? 8 : 0,
                                      ),
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          maxWidth: 80,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.tertiaryContainer,
                                        ),
                                        child: CloudImageWidget(
                                          file: pack.stickers[index + 4].image,
                                        ),
                                      ).clipRRect(all: 8),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ).clipRRect(topLeft: 8, topRight: 8),
                    ListTile(
                      leading: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.tertiaryContainer,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        child: CloudImageWidget(
                          file: pack.icon ?? pack.stickers.firstOrNull?.image,
                        ),
                      ).width(40).height(40).clipRRect(all: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      title: Text(pack.name),
                      subtitle: Text(pack.description),
                      trailing: const Icon(Symbols.chevron_right),
                      onTap: () {
                        // Navigate to user-facing sticker pack detail page.
                        // Adjust the route name/parameters if your app uses different ones.
                        context.pushNamed(
                          'stickerPackDetail',
                          pathParameters: {'packId': pack.id},
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
