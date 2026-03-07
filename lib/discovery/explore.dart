import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/notifications/notification.dart';
import 'package:island/posts/pods/post_list.dart';
import 'package:island/posts/widgets/compose/compose_dialog.dart';
import 'package:island/posts/widgets/compose/filters/post_subscription_filter.dart';
import 'package:island/core/network.dart';
import 'package:island/livestreams/livestream.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/publishers/publisher_card.dart';
import 'package:island/discovery/models/webfeed.dart';
import 'package:island/accounts/event_calendar.dart';
import 'package:island/discovery/screens/livestreams.dart';
import 'package:island/posts/posts_pod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/auth/login_modal.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/realms/realms_widgets/realm/realm_card.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/confuse_spinner.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/discovery/web_article_card.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:island/posts/widgets/compose/post_list.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class ExploreScreen extends HookConsumerWidget {
  const ExploreScreen({super.key});

  static final publisherActiveLivestreamProvider = FutureProvider.family
      .autoDispose<SnLiveStream?, String>((ref, publisherId) async {
        final client = ref.watch(apiClientProvider);
        final response = await client.get(
          '/sphere/livestreams/publisher/$publisherId',
          queryParameters: {'limit': 20, 'offset': 0},
        );
        final raw = response.data;
        final list = switch (raw) {
          List value => value,
          Map value when value['items'] is List => value['items'] as List,
          _ => const <dynamic>[],
        };
        for (final item in list.whereType<Map>()) {
          final stream = SnLiveStream.fromJson(Map<String, dynamic>.from(item));
          if (stream.status == SnLiveStreamStatus.active) return stream;
        }
        return null;
      });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = useState<String?>(null);
    final selectedPublisherNames = useState<List<String>>([]);
    final selectedCategoryIds = useState<List<String>>([]);
    final selectedTagIds = useState<List<String>>([]);
    final notifier = ref.watch(activityListProvider.notifier);

    void handleFilterChange(String? filter) {
      currentFilter.value = filter;
      notifier.applyFilter(filter);
    }

    final now = DateTime.now();

    final query = useState(
      EventCalendarQuery(uname: 'me', year: now.year, month: now.month),
    );

    final events = ref.watch(eventCalendarProvider(query.value));

    final selectedDay = useState(now);

    final user = ref.watch(userInfoProvider);

    final notificationCount = ref.watch(notificationUnreadCountProvider);

    final isWide = isWideScreen(context);

    final hasSubscriptionsSelected = selectedPublisherNames.value.isNotEmpty;

    final filterBar = Card(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Row(
        children: [
          Row(
            spacing: 8,
            children: [
              IconButton(
                onPressed: hasSubscriptionsSelected
                    ? null
                    : () => handleFilterChange(null),
                icon: Icon(
                  Symbols.explore,
                  fill: currentFilter.value == null ? 1 : null,
                ),
                tooltip: 'explore'.tr(),
                isSelected: currentFilter.value == null,
                color: currentFilter.value == null
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              IconButton(
                onPressed: hasSubscriptionsSelected
                    ? null
                    : () => handleFilterChange('subscriptions'),
                icon: Icon(
                  Symbols.subscriptions,
                  fill: currentFilter.value == 'subscriptions' ? 1 : null,
                ),
                tooltip: 'exploreFilterSubscriptions'.tr(),
                isSelected: currentFilter.value == 'subscriptions',
                color: currentFilter.value == 'subscriptions'
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              IconButton(
                onPressed: hasSubscriptionsSelected
                    ? null
                    : () => handleFilterChange('friends'),
                icon: Icon(
                  Symbols.people,
                  fill: currentFilter.value == 'friends' ? 1 : null,
                ),
                tooltip: 'exploreFilterFriends'.tr(),
                isSelected: currentFilter.value == 'friends',
                color: currentFilter.value == 'friends'
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              context.router.push(ArticleStandRoute());
            },
            icon: Icon(Symbols.auto_stories),
            tooltip: 'webArticlesStand'.tr(),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Symbols.search),
                    const Gap(12),
                    Text('search').tr(),
                  ],
                ),
                onTap: () {
                  context.router.push(UniversalSearchRoute());
                },
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Symbols.live_tv),
                    const Gap(12),
                    Text('livestreams').tr(),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ActiveLivestreamsScreen(),
                    ),
                  );
                },
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Symbols.category),
                    const Gap(12),
                    Text('categoriesAndTags').tr(),
                  ],
                ),
                onTap: () {
                  context.router.push(PostCategoriesListRoute());
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
                  context.router.push(PostShuffleRoute());
                },
              ),
            ],
            icon: Icon(Symbols.action_key),
            tooltip: 'search'.tr(),
          ),
        ],
      ).padding(horizontal: 8, vertical: 4),
    );

    final userInfo = ref.watch(userInfoProvider);

    final appBar = isWide
        ? null
        : _buildAppBar(
            currentFilter.value,
            handleFilterChange,
            context,
            hasSubscriptionsSelected,
          );

    return AppScaffold(
      isNoBackground: false,
      appBar: appBar,
      floatingActionButton: userInfo.value != null
          ? FloatingActionButton(
              child: const Icon(Symbols.create),
              onPressed: () {
                final parentContext = context;
                final router = context.router;
                showModalBottomSheet(
                  context: parentContext,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  builder: (sheetContext) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Gap(40),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        leading: const Icon(Symbols.post_add_rounded),
                        title: Text('postCompose').tr(),
                        onTap: () async {
                          Navigator.of(sheetContext).pop();
                          await PostComposeDialog.show(parentContext);
                        },
                      ),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        leading: const Icon(Symbols.article),
                        title: Text('articleCompose').tr(),
                        onTap: () async {
                          Navigator.of(sheetContext).pop();
                          await router.push(ArticleComposeRoute());
                        },
                      ),
                      const Gap(16),
                    ],
                  ),
                );
              },
            ).padding(bottom: MediaQuery.of(context).padding.bottom)
          : null,
      body: isWide
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
              selectedPublisherNames,
              selectedCategoryIds,
              selectedTagIds,
            )
          : _buildNarrowBody(context, ref, currentFilter.value),
    );
  }

  Widget _buildActivityList(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);

    return PaginationWidget(
      provider: activityListProvider,
      notifier: activityListProvider.notifier,
      // Sliver list cannot provide refresh handled by the pagination list
      isRefreshable: false,
      isSliver: true,
      footerSkeletonChild: const SizedBox(
        height: 64,
        child: Center(child: ConfuseSpinner(size: 40, speed: 6)),
      ),
      contentBuilder: (data, footer) =>
          _ActivityListView(data: data, isWide: isWide, footer: footer),
    );
  }

  Widget _buildPostList(
    BuildContext context,
    WidgetRef ref,
    List<String> selectedPublishers,
    List<String> selectedCategories,
    List<String> selectedTags,
  ) {
    return SliverPostList(
      queryKey: 'explore_filtered',
      query: PostListQuery(
        publishers: selectedPublishers,
        categories: selectedCategories,
        tags: selectedTags,
      ),
      padding: EdgeInsets.zero,
      itemPadding: const EdgeInsets.only(bottom: 8),
    );
  }

  Widget _buildLiveStreamsOnTop(
    BuildContext context,
    WidgetRef ref,
    List<String> selectedPublishers,
  ) {
    final subsAsync = ref.watch(publishersSubscriptionsLiveProvider);
    return subsAsync.when(
      data: (subs) {
        final selectedSubs = subs.where((item) {
          final pub = item.subscription.publisher;
          return selectedPublishers.contains(pub.name);
        }).toList();
        if (selectedSubs.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        return SliverToBoxAdapter(
          child: Column(
            children: [
              for (final item in selectedSubs)
                _SelectedPublisherLiveStreamEmbed(
                  publisher: item.subscription.publisher,
                  isLive: item.isLive,
                ),
            ],
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
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
    String? currentFilter,
    ValueNotifier<List<String>> selectedPublishers,
    ValueNotifier<List<String>> selectedCategories,
    ValueNotifier<List<String>> selectedTags,
  ) {
    // Use post list when subscription filter is active and publishers are selected
    final usePostList =
        selectedPublishers.value.isNotEmpty ||
        selectedCategories.value.isNotEmpty ||
        selectedTags.value.isNotEmpty;
    final bodyView = usePostList ? null : _buildActivityList(context, ref);

    final notifier = usePostList
        ? null // Post list handles its own refreshing
        : ref.watch(activityListProvider.notifier);

    final activityState = ref.watch(activityListProvider);
    final isListInitialLoading =
        (activityState.isLoading || activityState.value?.isLoading == true) &&
        (activityState.value?.items.isEmpty ?? true);

    return Row(
      spacing: 12,
      children: [
        Flexible(
          flex: 3,
          child: ExtendedRefreshIndicator(
            onRefresh: () async {
              await notifier?.refresh();
            },
            child: CustomScrollView(
              slivers: [
                const SliverGap(12),
                SliverToBoxAdapter(child: filterBar),
                const SliverGap(8),
                if (usePostList) ...[
                  _buildLiveStreamsOnTop(
                    context,
                    ref,
                    selectedPublishers.value,
                  ),
                  _buildPostList(
                    context,
                    ref,
                    selectedPublishers.value,
                    selectedCategories.value,
                    selectedTags.value,
                  ),
                ] else
                  if (isListInitialLoading)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: ConfuseSpinner(
                          speed: 7,
                          size: 72,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withOpacity(0.65),
                        ),
                      ),
                    )
                  else
                    bodyView!,
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
                    Gap(4 + MediaQuery.paddingOf(context).top),
                    PostSubscriptionFilterWidget(
                      initialSelectedPublishers: selectedPublishers.value,
                      initialSelectedCategories: selectedCategories.value,
                      initialSelectedTags: selectedTags.value,
                      onSelectedPublishersChanged: (names) {
                        selectedPublishers.value = names;
                      },
                      onSelectedCategoriesChanged: (ids) {
                        selectedCategories.value = ids;
                      },
                      onSelectedTagsChanged: (ids) {
                        selectedTags.value = ids;
                      },
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
    String? currentFilter,
    void Function(String?) handleFilterChange,
    BuildContext context,
    bool hasSubscriptionsSelected,
  ) {
    final foregroundColor = Theme.of(context).appBarTheme.foregroundColor;

    return AppBar(
      flexibleSpace: Container(
        height: 48,
        margin: EdgeInsets.only(
          left: 8,
          right: 8,
          top: 4 + MediaQuery.of(context).padding.top,
          bottom: 4,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            spacing: 8,
            children: [
              IconButton(
                onPressed: hasSubscriptionsSelected
                    ? null
                    : () => handleFilterChange(null),
                icon: Icon(
                  Symbols.explore,
                  color: foregroundColor,
                  fill: currentFilter == null ? 1 : null,
                ),
                tooltip: 'explore'.tr(),
                isSelected: currentFilter == null,
                color: currentFilter == null ? foregroundColor : null,
              ),
              IconButton(
                onPressed: hasSubscriptionsSelected
                    ? null
                    : () => handleFilterChange('subscriptions'),
                icon: Icon(
                  Symbols.subscriptions,
                  color: foregroundColor,
                  fill: currentFilter == 'subscription' ? 1 : null,
                ),
                tooltip: 'exploreFilterSubscriptions'.tr(),
                isSelected: currentFilter == 'subscriptions',
              ),
              IconButton(
                onPressed: hasSubscriptionsSelected
                    ? null
                    : () => handleFilterChange('friends'),
                icon: Icon(
                  Symbols.people,
                  color: foregroundColor,
                  fill: currentFilter == 'friends' ? 1 : null,
                ),
                tooltip: 'exploreFilterFriends'.tr(),
                isSelected: currentFilter == 'friends',
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  context.router.push(const ArticleStandRoute());
                },
                icon: Icon(Symbols.auto_stories, color: foregroundColor),
                tooltip: 'webArticlesStand'.tr(),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Row(
                      children: [
                        const Icon(Symbols.search),
                        const Gap(12),
                        Text('search').tr(),
                      ],
                    ),
                    onTap: () {
                      context.router.push(UniversalSearchRoute());
                    },
                  ),
                  PopupMenuItem(
                    child: Row(
                      children: [
                        const Icon(Symbols.live_tv),
                        const Gap(12),
                        Text('livestreams').tr(),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ActiveLivestreamsScreen(),
                        ),
                      );
                    },
                  ),
                  PopupMenuItem(
                    child: Row(
                      children: [
                        const Icon(Symbols.category),
                        const Gap(12),
                        Text('categoriesAndTags').tr(),
                      ],
                    ),
                    onTap: () {
                      context.router.push(PostCategoriesListRoute());
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
                      context.router.push(const PostShuffleRoute());
                    },
                  ),
                ],
                icon: Icon(Symbols.action_key, color: foregroundColor),
                tooltip: 'search'.tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNarrowBody(
    BuildContext context,
    WidgetRef ref,
    String? currentFilter,
  ) {
    final activityState = ref.watch(activityListProvider);
    final isListInitialLoading =
        (activityState.isLoading || activityState.value?.isLoading == true) &&
        (activityState.value?.items.isEmpty ?? true);

    final bodyView = isListInitialLoading
        ? SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: ConfuseSpinner(
                speed: 7,
                size: 72,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(0.65),
              ),
            ),
          )
        : _buildActivityList(context, ref);

    final notifier = ref.watch(activityListProvider.notifier);

    return Expanded(
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: ExtendedRefreshIndicator(
          onRefresh: notifier.refresh,
          child: CustomScrollView(slivers: [SliverGap(8), bodyView]),
        ),
      ).padding(horizontal: 8),
    );
  }
}

class _SelectedPublisherLiveStreamEmbed extends ConsumerWidget {
  final SnPublisher publisher;
  final bool isLive;

  const _SelectedPublisherLiveStreamEmbed({
    required this.publisher,
    required this.isLive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileCard = Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        leading: ProfilePictureWidget(file: publisher.picture, radius: 16),
        title: Text(publisher.nick),
        subtitle: Text('@${publisher.name}'),
        trailing: FilledButton.tonal(
          onPressed: () {
            context.router.push(PublisherProfileRoute(name: publisher.name));
          },
          child: Text('open').tr(),
        ),
      ),
    );

    if (!isLive) {
      return profileCard;
    }

    final streamAsync = ref.watch(
      ExploreScreen.publisherActiveLivestreamProvider(publisher.id),
    );
    return streamAsync.when(
      data: (stream) {
        if (stream == null) return profileCard;
        return Column(
          children: [
            profileCard,
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: LivestreamEmbedWidget(
                livestreamId: stream.id,
                margin: EdgeInsets.zero,
              ),
            ),
          ],
        );
      },
      loading: () => profileCard,
      error: (_, _) => profileCard,
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
              'realm' => RealmDiscoveryCard(
                realm: SnRealm.fromJson(item['data']),
                maxWidth: 280,
              ),
              'publisher' => PublisherDiscoveryCard(
                publisher: SnPublisher.fromJson(item['data']),
                maxWidth: 280,
              ),
              'article' => WebArticleDiscoveryCard(
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
  final Widget footer;

  const _ActivityListView({
    required this.data,
    required this.isWide,
    required this.footer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(activityListProvider.notifier);

    return SliverList.separated(
      itemCount: data.length + 1,
      separatorBuilder: (_, _) => const Gap(8),
      itemBuilder: (context, index) {
        if (index == data.length) {
          return footer;
        }

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
