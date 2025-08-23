import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/webfeed.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';

part 'feed_marketplace.g.dart';

@riverpod
class MarketplaceWebFeedsNotifier extends _$MarketplaceWebFeedsNotifier
    with CursorPagingNotifierMixin<SnWebFeed> {
  String? _query;

  @override
  Future<CursorPagingData<SnWebFeed>> build({required String? query}) {
    _query = query;
    return fetch(cursor: null);
  }

  @override
  Future<CursorPagingData<SnWebFeed>> fetch({required String? cursor}) async {
    final client = ref.read(apiClientProvider);
    final offset = cursor == null ? 0 : int.parse(cursor);

    final response = await client.get(
      '/sphere/feeds/explore',
      queryParameters: {
        'offset': offset,
        'take': 20,
        if (_query != null && _query!.isNotEmpty) 'query': _query,
      },
    );

    final total = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    final feeds = data.map((e) => SnWebFeed.fromJson(e)).toList();

    final hasMore = offset + feeds.length < total;
    final nextCursor = hasMore ? (offset + feeds.length).toString() : null;

    return CursorPagingData(
      items: feeds,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }
}

/// Marketplace screen for browsing web feeds.
class MarketplaceWebFeedsScreen extends HookConsumerWidget {
  const MarketplaceWebFeedsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    }, [query.value]);

    // Clean up timer on dispose
    useEffect(() {
      return () {
        debounceTimer.value?.cancel();
      };
    }, []);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('webFeeds').tr(),
        actions: const [Gap(8)],
      ),
      body: PagingHelperView(
        provider: marketplaceWebFeedsNotifierProvider(query: query.value),
        futureRefreshable:
            marketplaceWebFeedsNotifierProvider(query: query.value).future,
        notifierRefreshable:
            marketplaceWebFeedsNotifierProvider(query: query.value).notifier,
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

                      final feed = data.items[index];
                      return ListTile(
                        title: Text(feed.title),
                        subtitle: Text(feed.description ?? ''),
                        trailing: const Icon(Symbols.chevron_right),
                        onTap: () {
                          // Navigate to web feed detail page
                          context.pushNamed(
                            'webFeedDetail',
                            pathParameters: {'feedId': feed.id},
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
