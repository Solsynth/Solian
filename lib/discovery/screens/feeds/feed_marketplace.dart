import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/discovery/models/webfeed.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

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
      '/insight/feeds/explore',
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
@RoutePage()
class FeedMarketplaceScreen extends HookConsumerWidget {
  const FeedMarketplaceScreen({super.key});

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
        leading: const AutoLeadingButton(),
        actions: const [Gap(16)],
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
                if (query.value != null && query.value!.isNotEmpty)
                  IconButton.filledTonal(
                    icon: const Icon(Symbols.close),
                    onPressed: () {
                      query.value = null;
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (context, index, feed) {
                return Card.filled(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Card.outlined(
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(
                          Symbols.rss_feed,
                          size: 24,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    title: Text(
                      feed.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (feed.description != null &&
                            feed.description!.isNotEmpty)
                          Text(
                            feed.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        if (feed.publisher != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 4,
                            children: [
                              Icon(
                                Symbols.account_circle,
                                size: 14,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              Text(
                                feed.publisher!.nick,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    trailing: Icon(
                      Symbols.chevron_right,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onTap: () {
                      // Navigate to web feed detail page
                      context.router.push(
                        FeedMarketplaceDetailRoute(id: feed.id),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
