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
import 'package:island/widgets/account/fortune_graph.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/models/post.dart';
import 'package:island/widgets/check_in.dart';
import 'package:island/widgets/post/post_featured.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:island/screens/tabs.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/realm/realm_card.dart';
import 'package:island/widgets/publisher/publisher_card.dart';
import 'package:island/widgets/web_article_card.dart';
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
    leading: const Icon(Symbols.notifications),
    title: Row(
      children: [
        Text('notifications').tr().fontSize(14),
        const Gap(8),
        Badge(label: Text(count.toString())),
      ],
    ),
    trailing: const Icon(Symbols.chevron_right),
    minTileHeight: 40,
    contentPadding: EdgeInsets.only(left: 16, right: 15),
    onTap: () {
      GoRouter.of(context).pushNamed('notifications');
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

    final activitiesNotifier = ref.watch(
      activityListNotifierProvider(currentFilter.value).notifier,
    );

    final now = DateTime.now();

    final query = useState(
      EventCalendarQuery(uname: 'me', year: now.year, month: now.month),
    );

    final events = ref.watch(eventCalendarProvider(query.value));

    final selectedDay = useState(now);
    // Function to handle day selection for synchronizing between widgets
    void onDaySelected(DateTime day) {
      selectedDay.value = day;
    }

    final user = ref.watch(userInfoProvider);

    final notificationCount = ref.watch(
      notificationUnreadCountNotifierProvider,
    );

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        toolbarHeight: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
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
                            child: Icon(
                              Symbols.explore,
                              color:
                                  Theme.of(
                                    context,
                                  ).appBarTheme.foregroundColor!,
                            ),
                          ),
                        ),
                        Tab(
                          icon: Tooltip(
                            message: 'exploreFilterSubscriptions'.tr(),
                            child: Icon(
                              Symbols.subscriptions,
                              color:
                                  Theme.of(
                                    context,
                                  ).appBarTheme.foregroundColor!,
                            ),
                          ),
                        ),
                        Tab(
                          icon: Tooltip(
                            message: 'exploreFilterFriends'.tr(),
                            child: Icon(
                              Symbols.people,
                              color:
                                  Theme.of(
                                    context,
                                  ).appBarTheme.foregroundColor!,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.pushNamed('articles');
                    },
                    icon: Icon(
                      Symbols.auto_stories,
                      color: Theme.of(context).appBarTheme.foregroundColor!,
                    ),
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
                    icon: Icon(
                      Symbols.action_key,
                      color: Theme.of(context).appBarTheme.foregroundColor!,
                    ),
                    tooltip: 'search'.tr(),
                  ),
                ],
              )
              .padding(horizontal: 8)
              .border(
                bottom: 1 / MediaQuery.of(context).devicePixelRatio,
                color: Theme.of(context).dividerColor,
              ),
        ),
      ),
      floatingActionButton: InkWell(
        onLongPress: () {
          context.pushNamed('postCompose', queryParameters: {'type': '1'}).then(
            (value) {
              if (value != null) {
                activitiesNotifier.forceRefresh();
              }
            },
          );
        },
        child: FloatingActionButton(
          heroTag: Key("explore-page-fab"),
          onPressed: () {
            context.pushNamed('postCompose').then((value) {
              if (value != null) {
                activitiesNotifier.forceRefresh();
              }
            });
          },
          child: const Icon(Symbols.edit),
        ),
      ),
      floatingActionButtonLocation: TabbedFabLocation(context),
      body: Builder(
        builder: (context) {
          final isWide = isWideScreen(context);

          final bodyView = _buildActivityList(
            context,
            ref,
            currentFilter.value,
          );

          if (isWide) {
            return Row(
              children: [
                Flexible(flex: 3, child: bodyView.padding(left: 8)),
                if (user.value != null)
                  Flexible(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            CheckInWidget(
                              margin: EdgeInsets.only(
                                left: 8,
                                right: 12,
                                top: 16,
                              ),
                              onChecked: () {
                                ref.invalidate(
                                  eventCalendarProvider(query.value),
                                );
                              },
                            ),
                            if (notificationCount.value != null &&
                                notificationCount.value! > 0)
                              notificationIndicatorWidget(
                                context,
                                count: notificationCount.value ?? 0,
                                margin: EdgeInsets.only(
                                  left: 8,
                                  right: 12,
                                  top: 8,
                                ),
                              ),
                            PostFeaturedList().padding(
                              left: 8,
                              right: 12,
                              top: 8,
                            ),
                            FortuneGraphWidget(
                              margin: EdgeInsets.only(
                                left: 8,
                                right: 12,
                                top: 8,
                              ),
                              events: events,
                              constrainWidth: true,
                              onPointSelected: onDaySelected,
                            ),
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
            );
          }

          return bodyView;
        },
      ),
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

    return RefreshIndicator(
      onRefresh: () => Future.sync(activitiesNotifier.forceRefresh),
      child: PagingHelperView(
        provider: activityListNotifierProvider(filter),
        futureRefreshable: activityListNotifierProvider(filter).future,
        notifierRefreshable: activityListNotifierProvider(filter).notifier,
        contentBuilder:
            (data, widgetCount, endItemView) => Center(
              child: _ActivityListView(
                data: data,
                widgetCount: widgetCount,
                endItemView: endItemView,
                activitiesNotifier: activitiesNotifier,
                contentOnly: isWide || filter != null,
              ),
            ),
      ),
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

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Symbols.explore, size: 19),
              const Gap(8),
              Text(
                (switch (type) {
                  'realm' => 'discoverRealms',
                  'publisher' => 'discoverPublishers',
                  'article' => 'discoverWebArticles',
                  _ => 'unknown',
                }).tr(),
                style: Theme.of(context).textTheme.titleMedium,
              ).padding(top: 1),
            ],
          ).padding(horizontal: 20, top: 8, bottom: 4),
          SizedBox(
            height: 180,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: CarouselView.weighted(
                flexWeights:
                    isWideScreen(context) ? <int>[3, 2, 1] : <int>[4, 1],
                consumeMaxWeight: false,
                enableSplash: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
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
                      _ => Placeholder(),
                    },
                ],
              ),
            ),
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
  final bool contentOnly;
  final ActivityListNotifier activitiesNotifier;

  const _ActivityListView({
    required this.data,
    required this.widgetCount,
    required this.endItemView,
    required this.activitiesNotifier,
    this.contentOnly = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);

    final notificationCount = ref.watch(
      notificationUnreadCountNotifierProvider,
    );

    return CustomScrollView(
      slivers: [
        SliverGap(12),
        if (user.value != null && !contentOnly)
          SliverToBoxAdapter(
            child: CheckInWidget(
              margin: EdgeInsets.only(left: 8, right: 8, bottom: 4),
            ),
          ),
        if (!contentOnly)
          SliverToBoxAdapter(
            child: PostFeaturedList().padding(horizontal: 8, bottom: 4, top: 4),
          ),
        if (!contentOnly && (notificationCount.value ?? 0) > 0)
          SliverToBoxAdapter(
            child: notificationIndicatorWidget(
              context,
              count: notificationCount.value ?? 0,
              margin: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
            ),
          ),
        SliverList.builder(
          itemCount: widgetCount,
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
                itemWidget = Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: itemWidget,
                );
                break;
              case 'discovery':
                itemWidget = _DiscoveryActivityItem(data: item.data!);
                break;
              default:
                itemWidget = const Placeholder();
            }

            return itemWidget;
          },
        ),
        SliverGap(getTabbedPadding(context).bottom),
      ],
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
      if (kDebugMode) 'debugInclude': 'realms,publishers,articles',
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
        items
            .map((x) => x.createdAt)
            .lastOrNull
            ?.toUtc()
            .toIso8601String()
            .toString();

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
