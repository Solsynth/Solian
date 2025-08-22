import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/webfeed.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'feed_detail.g.dart';

/// Provider for web feed articles content
@riverpod
Future<List<SnWebArticle>> marketplaceWebFeedContent(
  Ref ref, {
  required String feedId,
}) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/sphere/feeds/$feedId/articles');
  return (resp.data as List).map((e) => SnWebArticle.fromJson(e)).toList();
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
    // TODO: Need to create a web feed provider similar to stickerPackProvider
    // For now, we'll fetch the feed directly
    final feedContent = ref.watch(
      marketplaceWebFeedContentProvider(feedId: id),
    );
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
      showSnackBar('feedSubscribed'.tr());
    }

    // Unsubscribe from web feed
    Future<void> unsubscribeFromFeed() async {
      final apiClient = ref.watch(apiClientProvider);
      await apiClient.delete('/sphere/feeds/$id/subscribe');
      HapticFeedback.selectionClick();
      ref.invalidate(marketplaceWebFeedSubscriptionProvider(feedId: id));
      if (!context.mounted) return;
      showSnackBar('feedUnsubscribed'.tr());
    }

    // TODO: Replace with actual feed data provider once created
    final dummyFeed = SnWebFeed(
      id: id,
      url: 'https://example.com',
      title: 'Loading...',
      publisherId: 'publisher-id',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return AppScaffold(
      appBar: AppBar(title: Text(dummyFeed.title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Feed meta
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(dummyFeed.description ?? ''),
              Row(
                spacing: 4,
                children: [
                  const Icon(Symbols.rss_feed, size: 16),
                  Text('${feedContent.value?.length ?? 0} articles'),
                ],
              ).opacity(0.85),
              Row(
                spacing: 4,
                children: [
                  const Icon(Symbols.link, size: 16),
                  SelectableText(dummyFeed.url),
                ],
              ).opacity(0.85),
            ],
          ).padding(horizontal: 24, vertical: 24),
          const Divider(height: 1),
          // Articles list
          Expanded(
            child: feedContent.when(
              data:
                  (articles) => RefreshIndicator(
                    onRefresh:
                        () => ref.refresh(
                          marketplaceWebFeedContentProvider(feedId: id).future,
                        ),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        final article = articles[index];
                        return Card(
                          child: ListTile(
                            title: Text(article.title),
                            subtitle: Text(article.author ?? ''),
                            trailing: const Icon(Symbols.open_in_new),
                            onTap: () {
                              // TODO: Navigate to article detail or open URL
                            },
                          ),
                        );
                      },
                    ),
                  ),
              error:
                  (err, _) =>
                      Text(
                        'Error: $err',
                      ).textAlignment(TextAlign.center).center(),
              loading: () => const CircularProgressIndicator().center(),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
          Gap(MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
