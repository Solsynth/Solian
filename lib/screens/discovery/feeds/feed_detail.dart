import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/webfeed.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/web_article_card.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';
import 'package:styled_widget/styled_widget.dart';

part 'feed_detail.g.dart';

@riverpod
Future<SnWebFeed> marketplaceWebFeed(Ref ref, String feedId) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/sphere/feeds/$feedId');
  return SnWebFeed.fromJson(resp.data);
}

/// Provider for web feed articles content
@riverpod
class MarketplaceWebFeedContentNotifier
    extends _$MarketplaceWebFeedContentNotifier
    with CursorPagingNotifierMixin<SnWebArticle> {
  static const int _pageSize = 20;

  @override
  Future<CursorPagingData<SnWebArticle>> build(String feedId) async {
    _feedId = feedId;
    return fetch(cursor: null);
  }

  late final String _feedId;
  ValueNotifier<int> totalCount = ValueNotifier(0);

  @override
  Future<CursorPagingData<SnWebArticle>> fetch({
    required String? cursor,
  }) async {
    final client = ref.read(apiClientProvider);
    final offset = cursor == null ? 0 : int.parse(cursor);

    final queryParams = {'offset': offset, 'take': _pageSize};

    final response = await client.get(
      '/sphere/feeds/$_feedId/articles',
      queryParameters: queryParams,
    );
    final total = int.parse(response.headers.value('X-Total') ?? '0');
    totalCount.value = total;
    final List<dynamic> data = response.data;
    final articles = data.map((json) => SnWebArticle.fromJson(json)).toList();

    final hasMore = offset + articles.length < total;
    final nextCursor = hasMore ? (offset + articles.length).toString() : null;

    return CursorPagingData(
      items: articles,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }

  void dispose() {
    totalCount.dispose();
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
    await api.get('/sphere/feeds/$feedId/subscription');
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
      await apiClient.post('/sphere/feeds/$id/subscribe');
      HapticFeedback.selectionClick();
      ref.invalidate(marketplaceWebFeedSubscriptionProvider(feedId: id));
      if (!context.mounted) return;
      showSnackBar('webFeedSubscribed'.tr());
    }

    // Unsubscribe from web feed
    Future<void> unsubscribeFromFeed() async {
      final apiClient = ref.watch(apiClientProvider);
      await apiClient.delete('/sphere/feeds/$id/subscribe');
      HapticFeedback.selectionClick();
      ref.invalidate(marketplaceWebFeedSubscriptionProvider(feedId: id));
      if (!context.mounted) return;
      showSnackBar('webFeedUnsubscribed'.tr());
    }

    final feedNotifier = ref.watch(
      marketplaceWebFeedContentNotifierProvider(id).notifier,
    );

    useEffect(() {
      return feedNotifier.dispose;
    }, []);

    return AppScaffold(
      appBar: AppBar(title: Text(feed.value?.title ?? 'loading'.tr())),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Feed meta
          feed
              .when(
                data:
                    (data) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(data.description ?? 'descriptionNone'.tr()),
                        Row(
                          spacing: 4,
                          children: [
                            const Icon(Symbols.rss_feed, size: 16),
                            ListenableBuilder(
                              listenable: feedNotifier.totalCount,
                              builder:
                                  (context, _) => Text(
                                    'webFeedArticleCount'.plural(
                                      feedNotifier.totalCount.value,
                                    ),
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
            child: PagingHelperView(
              provider: marketplaceWebFeedContentNotifierProvider(id),
              futureRefreshable:
                  marketplaceWebFeedContentNotifierProvider(id).future,
              notifierRefreshable:
                  marketplaceWebFeedContentNotifierProvider(id).notifier,
              contentBuilder:
                  (data, widgetCount, endItemView) => ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    itemCount: widgetCount,
                    itemBuilder: (context, index) {
                      if (index == widgetCount - 1) {
                        return endItemView;
                      }

                      final article = data.items[index];
                      return WebArticleCard(article: article);
                    },
                    separatorBuilder: (context, index) => const Gap(12),
                  ),
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
              data:
                  (isSubscribed) => FilledButton.icon(
                    onPressed:
                        isSubscribed ? unsubscribeFromFeed : subscribeToFeed,
                    icon: Icon(
                      isSubscribed ? Symbols.remove_circle : Symbols.add_circle,
                    ),
                    label: Text(
                      isSubscribed ? 'unsubscribe'.tr() : 'subscribe'.tr(),
                    ),
                  ),
              loading:
                  () => const SizedBox(
                    height: 32,
                    width: 32,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              error:
                  (_, _) => OutlinedButton.icon(
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
