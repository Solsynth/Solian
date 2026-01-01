import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/webfeed.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/paging.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/paging/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';

final marketplaceWebFeedsNotifierProvider = AsyncNotifierProvider.autoDispose(
  MarketplaceWebFeedsNotifier.new,
);

class MarketplaceWebFeedsNotifier
    extends AsyncNotifier<PaginationState<SnWebFeed>>
    with
        AsyncPaginationController<SnWebFeed>,
        AsyncPaginationFilter<String?, SnWebFeed> {
  @override
  String? currentFilter;

  @override
  Future<List<SnWebFeed>> fetch() async {
    final client = ref.read(apiClientProvider);

    final response = await client.get(
      '/sphere/feeds/explore',
      queryParameters: {
        'offset': fetchedCount.toString(),
        'take': 20,
        if (currentFilter != null && currentFilter!.isNotEmpty)
          'query': currentFilter,
      },
    );

    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final feeds = response.data
        .map((e) => SnWebFeed.fromJson(e))
        .cast<SnWebFeed>()
        .toList();

    return feeds;
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
    }, [query]);

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
      body: Column(
        children: [
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
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
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
            child: PaginationList(
              provider: marketplaceWebFeedsNotifierProvider,
              notifier: marketplaceWebFeedsNotifierProvider.notifier,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index, feed) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
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
    );
  }
}
