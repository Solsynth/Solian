import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/webfeed.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/paging.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/paging/pagination_list.dart';
import 'package:island/widgets/web_article_card.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'articles.g.dart';
part 'articles.freezed.dart';

@freezed
sealed class ArticleListQuery with _$ArticleListQuery {
  const factory ArticleListQuery({String? feedId, String? publisherId}) =
      _ArticleListQuery;
}

final articlesListNotifierProvider = AsyncNotifierProvider.family.autoDispose(
  ArticlesListNotifier.new,
);

class ArticlesListNotifier extends AsyncNotifier<PaginationState<SnWebArticle>>
    with AsyncPaginationController<SnWebArticle> {
  static const int pageSize = 20;

  final ArticleListQuery arg;
  ArticlesListNotifier(this.arg);

  @override
  Future<List<SnWebArticle>> fetch() async {
    final client = ref.read(apiClientProvider);

    final queryParams = {
      'limit': pageSize,
      'offset': fetchedCount.toString(),
      'feedId': arg.feedId,
      'publisherId': arg.publisherId,
    }..removeWhere((key, value) => value == null);

    try {
      final response = await client.get(
        '/sphere/feeds/articles',
        queryParameters: queryParams,
      );

      final articles = response.data
          .map((json) => SnWebArticle.fromJson(json as Map<String, dynamic>))
          .cast<SnWebArticle>()
          .toList();

      totalCount = int.tryParse(response.headers.value('X-Total') ?? '0') ?? 0;

      return articles;
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
    final provider = articlesListNotifierProvider(
      ArticleListQuery(feedId: feedId, publisherId: publisherId),
    );
    return PaginationList(
      spacing: 12,
      provider: provider,
      notifier: provider.notifier,
      isRefreshable: false,
      isSliver: true,
      itemBuilder: (context, index, article) {
        return WebArticleCard(article: article, showDetails: true);
      },
    );
  }
}

@riverpod
Future<List<SnWebFeed>> subscribedFeeds(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get('/sphere/feeds/subscribed');
  final data = response.data as List<dynamic>;
  return data.map((json) => SnWebFeed.fromJson(json)).toList();
}

class ArticlesScreen extends ConsumerWidget {
  const ArticlesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscribedFeedsAsync = ref.watch(subscribedFeedsProvider);

    return subscribedFeedsAsync.when(
      data: (feeds) {
        return DefaultTabController(
          length: feeds.length + 1,
          child: AppScaffold(
            isNoBackground: false,
            appBar: AppBar(
              title: const Text('Articles'),
              bottom: TabBar(
                isScrollable: true,
                tabs: [
                  Tab(
                    child: Text(
                      'All',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).appBarTheme.foregroundColor!,
                      ),
                    ),
                  ),
                  ...feeds.map(
                    (feed) => Tab(
                      child: Text(
                        feed.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).appBarTheme.foregroundColor!,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.only(
                            top: 12,
                            left: 8,
                            right: 8,
                          ),
                          sliver: SliverArticlesList(),
                        ),
                      ],
                    ),
                  ),
                ),
                ...feeds.map((feed) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.only(
                              top: 8,
                              left: 8,
                              right: 8,
                            ),
                            sliver: SliverArticlesList(feedId: feed.id),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
      loading: () => AppScaffold(
        isNoBackground: false,
        appBar: AppBar(title: const Text('Articles')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => AppScaffold(
        isNoBackground: false,
        appBar: AppBar(title: const Text('Articles')),
        body: Center(child: Text('Error: $err')),
      ),
    );
  }
}
