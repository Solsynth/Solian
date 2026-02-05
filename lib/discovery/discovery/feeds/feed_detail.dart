import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/discovery/discovery_models/webfeed.dart';
import 'package:island/core/network.dart';
import 'package:island/pagination/pagination.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:island/discovery/web_article_card.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'feed_detail.g.dart';

@riverpod
Future<SnWebFeed> marketplaceWebFeed(Ref ref, String feedId) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/insight/feeds/$feedId');
  return SnWebFeed.fromJson(resp.data);
}

final marketplaceWebFeedContentNotifierProvider = AsyncNotifierProvider.family
    .autoDispose(MarketplaceWebFeedContentNotifier.new);

class MarketplaceWebFeedContentNotifier
    extends AsyncNotifier<PaginationState<SnWebArticle>>
    with AsyncPaginationController<SnWebArticle> {
  static const int pageSize = 20;

  final String arg;
  MarketplaceWebFeedContentNotifier(this.arg);

  @override
  Future<List<SnWebArticle>> fetch() async {
    final client = ref.read(apiClientProvider);

    final queryParams = {'offset': fetchedCount.toString(), 'take': pageSize};

    final response = await client.get(
      '/insight/feeds/$arg/articles',
      queryParameters: queryParams,
    );
    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final articles = response.data
        .map((json) => SnWebArticle.fromJson(json))
        .cast<SnWebArticle>()
        .toList();

    return articles;
  }
}

/// Provider for web feed subscription status
@riverpod
Future<bool> marketplaceWebFeedSubscription(
  Ref ref, {
  required String feedId,
}) async {
  final api = ref.watch(apiClientProvider);
  try {
    await api.get('/insight/feeds/$feedId/subscription');
    // If not 404, consider subscribed
    return true;
  } on Object catch (e) {
    // Dio error handling agnostic: treat 404 as not-subscribed, rethrow others
    final msg = e.toString();
    if (msg.contains('404')) return false;
    rethrow;
  }
}

class MarketplaceWebFeedDetailScreen extends HookConsumerWidget {
  final String id;
  const MarketplaceWebFeedDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(marketplaceWebFeedProvider(id));
    final subscribed = ref.watch(
      marketplaceWebFeedSubscriptionProvider(feedId: id),
    );

    // Subscribe to web feed
    Future<void> subscribeToFeed() async {
      final apiClient = ref.watch(apiClientProvider);
      await apiClient.post('/insight/feeds/$id/subscribe');
      HapticFeedback.selectionClick();
      ref.invalidate(marketplaceWebFeedSubscriptionProvider(feedId: id));
      if (!context.mounted) return;
      showSnackBar('webFeedSubscribed'.tr());
    }

    // Unsubscribe from web feed
    Future<void> unsubscribeFromFeed() async {
      final apiClient = ref.watch(apiClientProvider);
      await apiClient.delete('/insight/feeds/$id/subscribe');
      HapticFeedback.selectionClick();
      ref.invalidate(marketplaceWebFeedSubscriptionProvider(feedId: id));
      if (!context.mounted) return;
      showSnackBar('webFeedUnsubscribed'.tr());
    }

    final feedNotifier = ref.watch(
      marketplaceWebFeedContentNotifierProvider(id).notifier,
    );

    return AppScaffold(
      appBar: AppBar(title: Text(feed.value?.title ?? 'loading'.tr())),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Feed meta
          feed
              .when(
                data: (data) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(data.description ?? 'descriptionNone'.tr()),
                    Row(
                      spacing: 4,
                      children: [
                        const Icon(Symbols.rss_feed, size: 16),
                        Text(
                          'webFeedArticleCount'.plural(
                            feedNotifier.totalCount ?? 0,
                          ),
                        ),
                      ],
                    ).opacity(0.85),
                    Row(
                      spacing: 4,
                      children: [
                        const Icon(Symbols.link, size: 16),
                        SelectableText(data.url),
                      ],
                    ).opacity(0.85),
                  ],
                ),
                error: (err, _) => Text(err.toString()),
                loading: () => CircularProgressIndicator().center(),
              )
              .padding(horizontal: 24, vertical: 24),
          const Divider(height: 1),
          // Articles list
          Expanded(
            child: PaginationList(
              spacing: 8,
              padding: EdgeInsets.symmetric(vertical: 8),
              provider: marketplaceWebFeedContentNotifierProvider(id),
              notifier: marketplaceWebFeedContentNotifierProvider(id).notifier,
              itemBuilder: (context, index, article) {
                return WebArticleCard(article: article).padding(horizontal: 12);
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              bottom: 16 + MediaQuery.of(context).padding.bottom,
              left: 24,
              right: 24,
              top: 16,
            ),
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: subscribed.when(
              data: (isSubscribed) => FilledButton.icon(
                onPressed: isSubscribed ? unsubscribeFromFeed : subscribeToFeed,
                icon: Icon(
                  isSubscribed ? Symbols.remove_circle : Symbols.add_circle,
                ),
                label: Text(
                  isSubscribed ? 'unsubscribe'.tr() : 'subscribe'.tr(),
                ),
              ),
              loading: () => const SizedBox(
                height: 32,
                width: 32,
                child: CircularProgressIndicator(strokeWidth: 2),
              ).center(),
              error: (_, _) => OutlinedButton.icon(
                onPressed: subscribeToFeed,
                icon: const Icon(Symbols.add_circle),
                label: Text('subscribe').tr(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
