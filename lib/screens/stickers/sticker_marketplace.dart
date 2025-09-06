import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/sticker.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';

part 'sticker_marketplace.g.dart';

@riverpod
class MarketplaceStickerPacksNotifier extends _$MarketplaceStickerPacksNotifier
    with CursorPagingNotifierMixin<SnStickerPack> {
  @override
  Future<CursorPagingData<SnStickerPack>> build({
    required String? query,
    required bool byUsage,
  }) {
    return fetch(cursor: null);
  }

  @override
  Future<CursorPagingData<SnStickerPack>> fetch({
    required String? cursor,
  }) async {
    final client = ref.read(apiClientProvider);
    final offset = cursor == null ? 0 : int.parse(cursor);

    final response = await client.get(
      '/sphere/stickers',
      queryParameters: {
        'offset': offset,
        'take': 20,
        'order': byUsage ? 'usage' : 'date',
        if (query != null && query!.isNotEmpty) 'query': query,
      },
    );

    final total = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    final stickers = data.map((e) => SnStickerPack.fromJson(e)).toList();

    final hasMore = offset + stickers.length < total;
    final nextCursor = hasMore ? (offset + stickers.length).toString() : null;

    return CursorPagingData(
      items: stickers,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }
}

/// User-facing marketplace screen for browsing sticker packs.
/// This version does NOT rely on publisher name (no pubName).
class MarketplaceStickersScreen extends HookConsumerWidget {
  const MarketplaceStickersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byUsage = useState(true);
    final query = useState<String?>(null);
    final searchController = useTextEditingController();
    final focusNode = useFocusNode();
    final debounceTimer = useState<Timer?>(null);

    // Clear search when query is cleared
    useEffect(() {
      if (query.value == null || query.value!.isEmpty) {
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
              byUsage.value = !byUsage.value;
            },
            icon:
                byUsage.value
                    ? const Icon(Symbols.local_fire_department)
                    : const Icon(Symbols.access_time),
            tooltip:
                byUsage.value
                    ? 'orderByPopularity'.tr()
                    : 'orderByReleaseDate'.tr(),
          ),
          const Gap(8),
        ],
      ),
      body: PagingHelperView(
        provider: marketplaceStickerPacksNotifierProvider(
          byUsage: byUsage.value,
          query: query.value,
        ),
        futureRefreshable:
            marketplaceStickerPacksNotifierProvider(
              byUsage: byUsage.value,
              query: query.value,
            ).future,
        notifierRefreshable:
            marketplaceStickerPacksNotifierProvider(
              byUsage: byUsage.value,
              query: query.value,
            ).notifier,
        contentBuilder:
            (data, widgetCount, endItemView) => Column(
              children: [
                // Search bar above the list
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SearchBar(
                    elevation: WidgetStateProperty.all(4),
                    controller: searchController,
                    focusNode: focusNode,
                    hintText: 'search'.tr(),
                    leading: const Icon(Symbols.search),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    onTapOutside:
                        (_) => FocusManager.instance.primaryFocus?.unfocus(),
                    trailing: [
                      if (query.value != null && query.value!.isNotEmpty)
                        IconButton(
                          icon: const Icon(Symbols.close),
                          onPressed: () {
                            query.value = null;
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
                          query.value = value.isEmpty ? null : value;
                        },
                      );
                    },
                    onSubmitted: (value) {
                      query.value = value.isEmpty ? null : value;
                      focusNode.unfocus();
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: widgetCount,
                    itemBuilder: (context, index) {
                      if (index == widgetCount - 1) {
                        return endItemView;
                      }

                      final pack = data.items[index];
                      return ListTile(
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
                      );
                    },
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
