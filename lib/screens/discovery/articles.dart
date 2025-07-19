import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/webfeed.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/web_article_card.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';

part 'articles.g.dart';

@riverpod
class ArticlesListNotifier extends _$ArticlesListNotifier
    with CursorPagingNotifierMixin<SnWebArticle> {
  static const int _pageSize = 20;

  Map<String, dynamic> _params = {};

  @override
  Future<CursorPagingData<SnWebArticle>> build({
    String? feedId,
    String? publisherId,
  }) async {
    _params = {
      if (feedId != null) 'feedId': feedId,
      if (publisherId != null) 'publisherId': publisherId,
    };
    return fetch(cursor: null);
  }

  @override
  Future<CursorPagingData<SnWebArticle>> fetch({
    required String? cursor,
  }) async {
    final client = ref.read(apiClientProvider);
    final offset = cursor == null ? 0 : int.parse(cursor);

    final queryParams = {'limit': _pageSize, 'offset': offset, ..._params};

    try {
      final response = await client.get(
        '/sphere/feeds/articles',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data;
      final articles =
          data
              .map(
                (json) => SnWebArticle.fromJson(json as Map<String, dynamic>),
              )
              .toList();

      final total = int.tryParse(response.headers.value('X-Total') ?? '0') ?? 0;
      final hasMore = offset + articles.length < total;
      final nextCursor = hasMore ? (offset + articles.length).toString() : null;

      return CursorPagingData(
        items: articles,
        hasMore: hasMore,
        nextCursor: nextCursor,
      );
    } catch (e) {
      debugPrint('Error fetching articles: $e');
      rethrow;
    }
  }
}

class SliverArticlesList extends ConsumerWidget {
  final String? feedId;
  final String? publisherId;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final Function? onRefresh;

  const SliverArticlesList({
    super.key,
    this.feedId,
    this.publisherId,
    this.backgroundColor,
    this.padding,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PagingHelperSliverView(
      provider: articlesListNotifierProvider(
        feedId: feedId,
        publisherId: publisherId,
      ),
      futureRefreshable:
          articlesListNotifierProvider(
            feedId: feedId,
            publisherId: publisherId,
          ).future,
      notifierRefreshable:
          articlesListNotifierProvider(
            feedId: feedId,
            publisherId: publisherId,
          ).notifier,
      contentBuilder:
          (data, widgetCount, endItemView) => SliverList.builder(
            itemCount: widgetCount,
            itemBuilder: (context, index) {
              if (index == widgetCount - 1) {
                return endItemView;
              }

              final article = data.items[index];
              return WebArticleCard(article: article, showDetails: true);
            },
          ),
    );
  }
}

class ArticlesScreen extends ConsumerWidget {
  final String? feedId;
  final String? publisherId;
  final String? title;

  const ArticlesScreen({super.key, this.feedId, this.publisherId, this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      appBar: AppBar(title: Text(title ?? 'Articles')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                sliver: SliverArticlesList(
                  feedId: feedId,
                  publisherId: publisherId,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
