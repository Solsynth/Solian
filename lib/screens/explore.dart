import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/activity.dart';
import 'package:island/models/realm.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/models/post.dart';
import 'package:island/widgets/check_in.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:island/screens/tabs.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/realm/realm_card.dart';
import 'package:island/widgets/publisher/publisher_card.dart';
import 'package:styled_widget/styled_widget.dart';

part 'explore.g.dart';

class ExploreShellScreen extends HookConsumerWidget {
  final Widget child;
  const ExploreShellScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width > 640;

    if (isWide) {
      return AppBackground(
        isRoot: true,
        child: Row(
          children: [
            Flexible(flex: 2, child: ExploreScreen(isAside: true)),
            VerticalDivider(width: 1),
            Flexible(flex: 3, child: child),
          ],
        ),
      );
    }

    return AppBackground(isRoot: true, child: child);
  }
}

class ExploreScreen extends HookConsumerWidget {
  final bool isAside;
  const ExploreScreen({super.key, this.isAside = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);
    if (isWide && !isAside) {
      return const EmptyPageHolder();
    }

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

    return AppScaffold(
      extendBody: false, // Prevent conflicts with tabs navigation
      appBar: AppBar(
        toolbarHeight: 0,
        bottom: TabBar(
          controller: tabController,
          tabs: [
            Tab(
              child: Text(
                'explore'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor!,
                ),
              ),
            ),
            Tab(
              child: Text(
                'exploreFilterSubscriptions'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor!,
                ),
              ),
            ),
            Tab(
              child: Text(
                'exploreFilterFriends'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor!,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: Key("explore-page-fab"),
        onPressed: () {
          context.push('/posts/compose').then((value) {
            if (value != null) {
              activitiesNotifier.forceRefresh();
            }
          });
        },
        child: const Icon(Symbols.edit),
      ),
      floatingActionButtonLocation: TabbedFabLocation(context),
      body: TabBarView(
        controller: tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildActivityList(ref, null),
          _buildActivityList(ref, 'subscriptions'),
          _buildActivityList(ref, 'friends'),
        ],
      ),
    );
  }

  Widget _buildActivityList(WidgetRef ref, String? filter) {
    final activitiesNotifier = ref.watch(
      activityListNotifierProvider(filter).notifier,
    );

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
                contentOnly: filter != null,
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

    return Column(
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
                _ => 'unknown',
              }).tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ).padding(top: 1),
          ],
        ).padding(horizontal: 20, top: 8, bottom: 4),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              switch (type) {
                case 'realm':
                  return RealmCard(
                    realm: SnRealm.fromJson(item['data']),
                    maxWidth: 280,
                  );
                case 'publisher':
                  return PublisherCard(
                    publisher: SnPublisher.fromJson(item['data']),
                    maxWidth: 280,
                  );
                default:
                  return Placeholder();
              }
            },
          ),
        ).padding(bottom: 4),
      ],
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

    return CustomScrollView(
      slivers: [
        if (user.hasValue && !contentOnly)
          SliverToBoxAdapter(child: CheckInWidget()),
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
                final isReply = item.type == 'posts.new.replies';
                itemWidget = PostItem(
                  backgroundColor:
                      isWideScreen(context) ? Colors.transparent : null,
                  item: SnPost.fromJson(item.data!),
                  padding:
                      isReply
                          ? const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          )
                          : null,
                  onRefresh: (_) {
                    activitiesNotifier.forceRefresh();
                  },
                  onUpdate: (post) {
                    activitiesNotifier.updateOne(
                      index,
                      item.copyWith(data: post.toJson()),
                    );
                  },
                );
                if (isReply) {
                  itemWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Symbols.reply),
                          const Gap(8),
                          Text('Replying your post'),
                        ],
                      ).padding(horizontal: 20, vertical: 8),
                      itemWidget,
                    ],
                  );
                }
                break;
              case 'discovery':
                itemWidget = _DiscoveryActivityItem(data: item.data!);
                break;
              default:
                itemWidget = const Placeholder();
            }

            return Column(children: [itemWidget, const Divider(height: 1)]);
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
      if (kDebugMode) 'debugInclude': 'realms,publishers',
    };

    final response = await client.get(
      '/activities',
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
