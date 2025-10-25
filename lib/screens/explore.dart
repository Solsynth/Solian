import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/activity.dart';
import 'package:island/models/publisher.dart';
import 'package:island/models/realm.dart';
import 'package:island/models/webfeed.dart';
import 'package:island/pods/event_calendar.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/screens/notification.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/models/post.dart';
import 'package:island/widgets/check_in.dart';
import 'package:island/widgets/post/post_featured.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:island/widgets/post/compose_card.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/realm/realm_card.dart';
import 'package:island/widgets/publisher/publisher_card.dart';
import 'package:island/widgets/web_article_card.dart';
import 'package:island/widgets/extended_refresh_indicator.dart';
import 'package:styled_widget/styled_widget.dart';

part 'explore.g.dart';

Widget notificationIndicatorWidget(
  BuildContext context, {
  required int count,
  EdgeInsets? margin,
}) => Card(
  margin: margin,
  child: ListTile(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    minTileHeight: 48,
    leading: const Icon(Symbols.notifications),
    title: Row(
      children: [
        Text('notifications').tr().fontSize(14),
        const Gap(8),
        Badge(label: Text(count.toString())),
      ],
    ),
    trailing: const Icon(Symbols.chevron_right),
    contentPadding: EdgeInsets.only(left: 16, right: 15),
    onTap: () {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (context) => const NotificationSheet(),
      );
    },
  ),
);

class ExploreScreen extends HookConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 3);
    final currentFilter = useState<String?>(null);

    useEffect(() {
      void listener() {
        switch (tabController.index) {
          case 0:
            currentFilter.value = null;
            break;
          case 1:
            currentFilter.value = 'subscriptions';
            break;
          case 2:
            currentFilter.value = 'friends';
            break;
        }
      }

      tabController.addListener(listener);
      return () => tabController.removeListener(listener);
    }, [tabController]);

    final now = DateTime.now();

    final query = useState(
      EventCalendarQuery(uname: 'me', year: now.year, month: now.month),
    );

    final events = ref.watch(eventCalendarProvider(query.value));

    final selectedDay = useState(now);

    final user = ref.watch(userInfoProvider);

    final notificationCount = ref.watch(
      notificationUnreadCountNotifierProvider,
    );

    final isWide = isWideScreen(context);

    final filterBar = Card(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              controller: tabController,
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  icon: Tooltip(
                    message: 'explore'.tr(),
                    child: Icon(Symbols.explore),
                  ),
                ),
                Tab(
                  icon: Tooltip(
                    message: 'exploreFilterSubscriptions'.tr(),
                    child: Icon(Symbols.subscriptions),
                  ),
                ),
                Tab(
                  icon: Tooltip(
                    message: 'exploreFilterFriends'.tr(),
                    child: Icon(Symbols.people),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              context.pushNamed('articles');
            },
            icon: Icon(Symbols.auto_stories),
            tooltip: 'webArticlesStand'.tr(),
          ),
          PopupMenuButton(
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    child: Row(
                      children: [
                        const Icon(Symbols.category),
                        const Gap(12),
                        Text('categories').tr(),
                      ],
                    ),
                    onTap: () {
                      context.pushNamed('postCategories');
                    },
                  ),
                  PopupMenuItem(
                    child: Row(
                      children: [
                        const Icon(Symbols.label),
                        const Gap(12),
                        Text('tags').tr(),
                      ],
                    ),
                    onTap: () {
                      context.pushNamed('postTags');
                    },
                  ),
                  PopupMenuItem(
                    child: Row(
                      children: [
                        const Icon(Symbols.shuffle),
                        const Gap(12),
                        Text('postShuffle').tr(),
                      ],
                    ),
                    onTap: () {
                      context.pushNamed('postShuffle');
                    },
                  ),
                  PopupMenuItem(
                    child: Row(
                      children: [
                        const Icon(Symbols.search),
                        const Gap(12),
                        Text('search').tr(),
                      ],
                    ),
                    onTap: () {
                      context.pushNamed('postSearch');
                    },
                  ),
                ],
            icon: Icon(Symbols.action_key),
            tooltip: 'search'.tr(),
          ),
        ],
      ).padding(horizontal: 8),
    );

    return AppScaffold(
      isNoBackground: false,
      body:
          isWide
              ? _buildWideBody(
                context,
                ref,
                filterBar,
                user,
                notificationCount,
                query,
                events,
                selectedDay,
                currentFilter.value,
              )
              : _buildNarrowBody(context, ref, filterBar, currentFilter.value),
    );
  }

  Widget _buildActivityList(
    BuildContext context,
    WidgetRef ref,
    String? filter,
  ) {
    final activitiesNotifier = ref.watch(
      activityListNotifierProvider(filter).notifier,
    );

    final isWide = isWideScreen(context);

    return PagingHelperSliverView(
      provider: activityListNotifierProvider(filter),
      futureRefreshable: activityListNotifierProvider(filter).future,
      notifierRefreshable: activityListNotifierProvider(filter).notifier,
      contentBuilder:
          (data, widgetCount, endItemView) => _ActivityListView(
            data: data,
            widgetCount: widgetCount,
            endItemView: endItemView,
            activitiesNotifier: activitiesNotifier,
            isWide: isWide,
          ),
    );
  }

  Widget _buildWideBody(
    BuildContext context,
    WidgetRef ref,
    Widget filterBar,
    AsyncValue<dynamic> user,
    AsyncValue<int?> notificationCount,
    ValueNotifier<EventCalendarQuery> query,
    AsyncValue<List<dynamic>> events,
    ValueNotifier<DateTime> selectedDay,
    String? currentFilter,
  ) {
    final bodyView = _buildActivityList(context, ref, currentFilter);

    final activitiesNotifier = ref.watch(
      activityListNotifierProvider(currentFilter).notifier,
    );

    return Row(
      spacing: 12,
      children: [
        Flexible(
          flex: 3,
          child: ExtendedRefreshIndicator(
            onRefresh: () => Future.sync(activitiesNotifier.forceRefresh),
            child: CustomScrollView(
              slivers: [
                const SliverGap(12),
                SliverToBoxAdapter(child: filterBar),
                const SliverGap(8),
                bodyView,
              ],
            ),
          ),
        ),
        if (user.value != null)
          Flexible(
            flex: 2,
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                child: Column(
                  spacing: 8,
                  children: [
                    CheckInWidget(
                      margin: EdgeInsets.only(top: 12),
                      onChecked: () {
                        ref.invalidate(eventCalendarProvider(query.value));
                      },
                    ),
                    if (notificationCount.value != null &&
                        notificationCount.value! > 0)
                      notificationIndicatorWidget(
                        context,
                        count: notificationCount.value ?? 0,
                        margin: EdgeInsets.zero,
                      ),
                    PostFeaturedList(),
                    const PostComposeCard(),
                  ],
                ),
              ),
            ),
          )
        else
          Flexible(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to\nthe Solar Network',
                  style: Theme.of(context).textTheme.titleLarge,
                ).bold(),
                const Gap(2),
                Text(
                  'Login to explore more!',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ).padding(horizontal: 36, vertical: 16),
          ),
      ],
    ).padding(horizontal: 12);
  }

  Widget _buildNarrowBody(
    BuildContext context,
    WidgetRef ref,
    Widget filterBar,
    String? currentFilter,
  ) {
    final user = ref.watch(userInfoProvider);
    final notificationCount = ref.watch(
      notificationUnreadCountNotifierProvider,
    );

    final activitiesNotifier = ref.watch(
      activityListNotifierProvider(currentFilter).notifier,
    );

    final bodyView = _buildActivityList(context, ref, currentFilter);

    return Column(
      spacing: 8,
      children: [
        filterBar.padding(horizontal: 8, top: 8),
        Expanded(
          child: ExtendedRefreshIndicator(
            onRefresh: () => Future.sync(activitiesNotifier.forceRefresh),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: CustomScrollView(
                slivers: [
                  if (user.value != null)
                    SliverToBoxAdapter(
                      child: CheckInWidget(
                        margin: const EdgeInsets.only(bottom: 8),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: PostFeaturedList(),
                    ),
                  ),
                  if (notificationCount.value != null &&
                      notificationCount.value! > 0)
                    SliverToBoxAdapter(
                      child: notificationIndicatorWidget(
                        context,
                        count: notificationCount.value ?? 0,
                        margin: const EdgeInsets.only(bottom: 8),
                      ),
                    ),
                  bodyView,
                ],
              ),
            ).padding(horizontal: 8),
          ),
        ),
      ],
    );
  }
}

class _DiscoveryActivityItem extends StatelessWidget {
  final Map<String, dynamic> data;

  const _DiscoveryActivityItem({required this.data});

  @override
  Widget build(BuildContext context) {
    final items = data['items'] as List;
    final type = items.firstOrNull?['type'] ?? 'unknown';

    var flexWeights = isWideScreen(context) ? <int>[3, 2, 1] : <int>[4, 1];
    if (type == 'post') flexWeights = <int>[3, 2];

    final height = type == 'post' ? 280.0 : 180.0;

    final contentWidget = switch (type) {
      'post' => ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const Gap(12),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: 320,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1 / MediaQuery.of(context).devicePixelRatio,
                color: Theme.of(context).dividerColor.withOpacity(0.5),
              ),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: SingleChildScrollView(
                child: PostActionableItem(
                  item: SnPost.fromJson(item['data']),
                  isCompact: true,
                ),
              ),
            ),
          );
        },
      ),
      _ => CarouselView.weighted(
        flexWeights: flexWeights,
        consumeMaxWeight: false,
        enableSplash: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        itemSnapping: false,
        children: [
          for (final item in items)
            switch (type) {
              'realm' => RealmCard(
                realm: SnRealm.fromJson(item['data']),
                maxWidth: 280,
              ),
              'publisher' => PublisherCard(
                publisher: SnPublisher.fromJson(item['data']),
                maxWidth: 280,
              ),
              'article' => WebArticleCard(
                article: SnWebArticle.fromJson(item['data']),
                maxWidth: 280,
              ),
              _ => const Placeholder(),
            },
        ],
      ),
    };

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(switch (type) {
                'realm' => Symbols.public,
                'publisher' => Symbols.account_circle,
                'article' => Symbols.auto_stories,
                'post' => Symbols.shuffle,
                _ => Symbols.explore,
              }, size: 19),
              const Gap(8),
              Text(
                (switch (type) {
                  'realm' => 'discoverRealms',
                  'publisher' => 'discoverPublishers',
                  'article' => 'discoverWebArticles',
                  'post' => 'discoverShuffledPost',
                  _ => 'unknown',
                }).tr(),
                style: Theme.of(context).textTheme.titleMedium,
              ).padding(top: 1),
            ],
          ).padding(horizontal: 20, top: 8, bottom: 4),
          SizedBox(
            height: height,
            child: contentWidget,
          ).padding(bottom: 8, horizontal: 8),
        ],
      ),
    );
  }
}

class _ActivityListView extends HookConsumerWidget {
  final CursorPagingData<SnActivity> data;
  final int widgetCount;
  final Widget endItemView;
  final ActivityListNotifier activitiesNotifier;
  final bool isWide;

  const _ActivityListView({
    required this.data,
    required this.widgetCount,
    required this.endItemView,
    required this.activitiesNotifier,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverList.separated(
      itemCount: widgetCount,
      separatorBuilder: (_, _) => const Gap(8),
      itemBuilder: (context, index) {
        if (index == widgetCount - 1) {
          return endItemView;
        }

        final item = data.items[index];
        if (item.data == null) {
          return const SizedBox.shrink();
        }
        Widget itemWidget;

        switch (item.type) {
          case 'posts.new':
          case 'posts.new.replies':
            itemWidget = PostActionableItem(
              borderRadius: 8,
              item: SnPost.fromJson(item.data!),
              onRefresh: () {
                activitiesNotifier.forceRefresh();
              },
              onUpdate: (post) {
                activitiesNotifier.updateOne(
                  index,
                  item.copyWith(data: post.toJson()),
                );
              },
            );
            itemWidget = Card(margin: EdgeInsets.zero, child: itemWidget);
            break;
          case 'discovery':
            itemWidget = _DiscoveryActivityItem(data: item.data!);
            break;
          default:
            itemWidget = const Placeholder();
        }

        return itemWidget;
      },
    );
  }
}

@riverpod
class ActivityListNotifier extends _$ActivityListNotifier
    with CursorPagingNotifierMixin<SnActivity> {
  @override
  Future<CursorPagingData<SnActivity>> build(String? filter) =>
      fetch(cursor: null);

  @override
  Future<CursorPagingData<SnActivity>> fetch({required String? cursor}) async {
    final client = ref.read(apiClientProvider);
    final take = 20;

    final queryParameters = {
      if (cursor != null) 'cursor': cursor,
      'take': take,
      if (filter != null) 'filter': filter,
      if (kDebugMode)
        'debugInclude': 'realms,publishers,articles,shuffledPosts',
    };

    final response = await client.get(
      '/sphere/activities',
      queryParameters: queryParameters,
    );

    final List<SnActivity> items =
        (response.data as List)
            .map((e) => SnActivity.fromJson(e as Map<String, dynamic>))
            .toList();

    final hasMore = (items.firstOrNull?.type ?? 'empty') != 'empty';
    final nextCursor =
        items.isNotEmpty
            ? items
                .map((x) => x.createdAt)
                .reduce((a, b) => a.isBefore(b) ? a : b)
                .toUtc()
                .toIso8601String()
            : null;

    return CursorPagingData(
      items: items,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }

  void updateOne(int index, SnActivity activity) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updatedItems = [...currentState.items];
    updatedItems[index] = activity;

    state = AsyncData(
      CursorPagingData(
        items: updatedItems,
        hasMore: currentState.hasMore,
        nextCursor: currentState.nextCursor,
      ),
    );
  }
}
