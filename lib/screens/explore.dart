import 'package:desktop_drop/desktop_drop.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/account.dart';
import 'package:island/models/activity.dart';
import 'package:island/models/publisher.dart';
import 'package:island/models/realm.dart';
import 'package:island/models/webfeed.dart';
import 'package:island/pods/event_calendar.dart';
import 'package:island/pods/timeline.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/screens/auth/login_modal.dart';
import 'package:island/screens/notification.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/account/account_name.dart';
import 'package:island/widgets/account/friends_overview.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/models/post.dart';
import 'package:island/widgets/check_in.dart';
import 'package:island/widgets/extended_refresh_indicator.dart';
import 'package:island/widgets/navigation/fab_menu.dart';
import 'package:island/widgets/paging/pagination_list.dart';
import 'package:island/widgets/post/post_featured.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/widgets/realm/realm_card.dart';
import 'package:island/widgets/publisher/publisher_card.dart';
import 'package:island/widgets/web_article_card.dart';
import 'package:island/services/event_bus.dart';
import 'package:island/widgets/share/share_sheet.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

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
      // Set FAB type to chat
      final fabMenuNotifier = ref.read(fabMenuTypeProvider.notifier);
      Future(() {
        fabMenuNotifier.state = FabMenuType.compose;
      });
      return () {
        // Clean up: reset FAB type to main
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (fabMenuNotifier.state == FabMenuType.compose) {
            fabMenuNotifier.state = FabMenuType.main;
          }
        });
      };
    }, []);

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

    final notifier = ref.watch(activityListNotifierProvider.notifier);

    useEffect(() {
      Future(() {
        notifier.applyFilter(currentFilter.value);
      });
      return null;
    }, [currentFilter.value]);

    // Listen for post creation events to refresh activities
    useEffect(() {
      final subscription = eventBus.on<PostCreatedEvent>().listen((event) {
        ref.invalidate(activityListNotifierProvider);
      });
      return subscription.cancel;
    }, []);

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
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
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

    final appBar = isWide ? null : _buildAppBar(tabController, context);

    final dragging = useState(false);

    return DropTarget(
      onDragDone: (detail) {
        dragging.value = false;
        if (detail.files.isNotEmpty) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useRootNavigator: true,
            builder: (context) => ShareSheet.files(files: detail.files),
          );
        }
      },
      onDragEntered: (_) => dragging.value = true,
      onDragExited: (_) => dragging.value = false,
      child: Stack(
        children: [
          AppScaffold(
            isNoBackground: false,
            appBar: appBar,
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
                    )
                    : _buildNarrowBody(context, ref, currentFilter.value),
          ),
          if (dragging.value)
            Positioned.fill(
              child: Container(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withOpacity(0.9),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Symbols.upload_file,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const Gap(16),
                      Text(
                        'dropToShare'.tr(),
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityList(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);

    return PaginationWidget(
      provider: activityListNotifierProvider,
      notifier: activityListNotifierProvider.notifier,
      // Sliver list cannot provide refresh handled by the pagination list
      isRefreshable: false,
      contentBuilder: (data) => _ActivityListView(data: data, isWide: isWide),
    );
  }

  Widget _buildWideBody(
    BuildContext context,
    WidgetRef ref,
    Widget filterBar,
    AsyncValue<SnAccount?> user,
    AsyncValue<int?> notificationCount,
    ValueNotifier<EventCalendarQuery> query,
    AsyncValue<List<dynamic>> events,
    ValueNotifier<DateTime> selectedDay,
  ) {
    final bodyView = _buildActivityList(context, ref);

    final notifier = ref.watch(activityListNotifierProvider.notifier);

    return Row(
      spacing: 12,
      children: [
        Flexible(
          flex: 3,
          child: ExtendedRefreshIndicator(
            onRefresh: notifier.refresh,
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
                    const Gap(4),
                    if (user.value?.activatedAt == null)
                      AccountUnactivatedCard(),
                    CheckInWidget(
                      margin: EdgeInsets.zero,
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
                    FriendsOverviewWidget(),
                  ],
                ),
              ),
            ),
          )
        else
          Flexible(
            flex: 2,
            child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Symbols.emoji_people_rounded, size: 40),
                    const Gap(8),
                    Text(
                      'Welcome to\nthe Solar Network',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ).bold(),
                    const Gap(2),
                    Text(
                      'Login to explore more!',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const Gap(4),
                    TextButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          useRootNavigator: true,
                          isScrollControlled: true,
                          builder: (context) => LoginModal(),
                        );
                      },
                      icon: const Icon(Symbols.login),
                      label: Text('login').tr(),
                    ),
                  ],
                ).padding(horizontal: 36, vertical: 16).center(),
          ),
      ],
    ).padding(horizontal: 12);
  }

  PreferredSizeWidget _buildAppBar(
    TabController tabController,
    BuildContext context,
  ) {
    final foregroundColor = Theme.of(context).appBarTheme.foregroundColor;

    return AppBar(
      toolbarHeight: 48 + 4,
      flexibleSpace: Container(
        height: 48,
        margin: EdgeInsets.only(
          left: 8,
          right: 8,
          top: 4 + MediaQuery.of(context).padding.top,
        ),
        child: Row(
          children: [
            Expanded(
              child: TabBar(
                controller: tabController,
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                dividerColor: Colors.transparent,
                labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                tabs: [
                  Tab(
                    icon: Tooltip(
                      message: 'explore'.tr(),
                      child: Icon(Symbols.explore, color: foregroundColor),
                    ),
                  ),
                  Tab(
                    icon: Tooltip(
                      message: 'exploreFilterSubscriptions'.tr(),
                      child: Icon(
                        Symbols.subscriptions,
                        color: foregroundColor,
                      ),
                    ),
                  ),
                  Tab(
                    icon: Tooltip(
                      message: 'exploreFilterFriends'.tr(),
                      child: Icon(Symbols.people, color: foregroundColor),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                context.pushNamed('articles');
              },
              icon: Icon(Symbols.auto_stories, color: foregroundColor),
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
              icon: Icon(Symbols.action_key, color: foregroundColor),
              tooltip: 'search'.tr(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNarrowBody(
    BuildContext context,
    WidgetRef ref,
    String? currentFilter,
  ) {
    final user = ref.watch(userInfoProvider);
    final notificationCount = ref.watch(
      notificationUnreadCountNotifierProvider,
    );

    final bodyView = _buildActivityList(context, ref);

    final notifier = ref.watch(activityListNotifierProvider.notifier);

    return Expanded(
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: ExtendedRefreshIndicator(
          onRefresh: notifier.refresh,
          child: CustomScrollView(
            slivers: [
              const SliverGap(8),
              if (user.value?.activatedAt == null)
                SliverToBoxAdapter(
                  child: AccountUnactivatedCard().padding(bottom: 8),
                ),
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
              SliverToBoxAdapter(
                child: FriendsOverviewWidget(
                  padding: const EdgeInsets.only(bottom: 8),
                  hideWhenEmpty: true,
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
        ),
      ).padding(horizontal: 8),
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
      'post' => SuperListView.separated(
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
  final List<SnTimelineEvent> data;
  final bool isWide;

  const _ActivityListView({required this.data, required this.isWide});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(activityListNotifierProvider.notifier);

    return SliverList.separated(
      itemCount: data.length,
      separatorBuilder: (_, _) => const Gap(8),
      itemBuilder: (context, index) {
        final item = data[index];
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
                notifier.refresh();
              },
              onUpdate: (post) {
                notifier.updateOne(index, item.copyWith(data: post.toJson()));
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
