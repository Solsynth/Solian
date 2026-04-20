import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/discovery/models/webfeed.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:island/discovery/web_article_card.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
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

@RoutePage()
class FeedMarketplaceDetailScreen extends HookConsumerWidget {
  final String id;
  const FeedMarketplaceDetailScreen({super.key, required this.id});

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
      appBar: AppBar(
        title: Text(feed.value?.title ?? 'loading'.tr()),
        actions: [
          if (feed.value?.publisher != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _PublisherChip(publisher: feed.value!.publisher!),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Feed meta section with Material 3 Card
          feed
              .when(
                data: (data) => Card.filled(
                  margin: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12,
                      children: [
                        // Feed title header
                        Row(
                          spacing: 16,
                          children: [
                            Card.outlined(
                              elevation: 0,
                              margin: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SizedBox(
                                width: 56,
                                height: 56,
                                child: Icon(
                                  Symbols.rss_feed,
                                  size: 28,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 4,
                                children: [
                                  Text(
                                    data.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  if (data.description != null &&
                                      data.description!.isNotEmpty)
                                    Text(
                                      data.description!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Metadata chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _FeedMetadataChip(
                              icon: Symbols.article,
                              label: 'webFeedArticleCount'.plural(
                                feedNotifier.totalCount ?? 0,
                              ),
                            ),
                            _FeedMetadataChip(
                              icon: Symbols.link,
                              label: data.url,
                              isSelectable: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                error: (err, _) => Text(err.toString()).center(),
                loading: () => const CircularProgressIndicator().center(),
              )
              .padding(horizontal: 0, vertical: 0),
          // Articles list
          Expanded(
            child: PaginationList(
              spacing: 8,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              provider: marketplaceWebFeedContentNotifierProvider(id),
              notifier: marketplaceWebFeedContentNotifierProvider(id).notifier,
              itemBuilder: (context, index, article) {
                return WebArticleCard(article: article);
              },
            ),
          ),
          // Action button container
          Container(
            padding: EdgeInsets.only(
              bottom: 16 + MediaQuery.of(context).padding.bottom,
              left: 16,
              right: 16,
              top: 8,
            ),
            color: Theme.of(context).colorScheme.surface,
            child: subscribed.when(
              data: (isSubscribed) => FilledButton.icon(
                onPressed: isSubscribed ? unsubscribeFromFeed : subscribeToFeed,
                icon: Icon(
                  isSubscribed ? Symbols.remove_circle : Symbols.add_circle,
                ),
                label: Text(
                  isSubscribed ? 'unsubscribe'.tr() : 'subscribe'.tr(),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              loading: () => const SizedBox(
                height: 48,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (_, _) => OutlinedButton.icon(
                onPressed: subscribeToFeed,
                icon: const Icon(Symbols.add_circle),
                label: Text('subscribe').tr(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PublisherChip extends StatelessWidget {
  final SnPublisher publisher;

  const _PublisherChip({required this.publisher});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: publisher.picture != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CloudImageWidget(
                  file: publisher.picture!,
                  fit: BoxFit.cover,
                  noBlurhash: true,
                ),
              ),
            )
          : Icon(
              Symbols.account_circle,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      label: Text(
        publisher.nick,
        style: Theme.of(context).textTheme.labelLarge,
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      side: BorderSide.none,
      onPressed: () {
        context.router.push(PublisherProfileRoute(name: publisher.name));
      },
    );
  }
}

class _FeedMetadataChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelectable;

  const _FeedMetadataChip({
    required this.icon,
    required this.label,
    this.isSelectable = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        isSelectable
            ? SelectableText(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
      ],
    );

    return Chip(
      label: content,
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      visualDensity: VisualDensity.compact,
    );
  }
}
