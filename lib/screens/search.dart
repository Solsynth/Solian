import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:island/models/activitypub.dart';
import 'package:island/pods/post/post_list.dart';
import 'package:island/services/activitypub_service.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/activitypub/actor_list_item.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/extended_refresh_indicator.dart';
import 'package:island/widgets/paging/pagination_list.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:island/widgets/post/post_item_skeleton.dart';
import 'package:island/widgets/post/filters/post_filter.dart';
import 'package:island/widgets/realm/realm_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

const kSearchPostListId = 'search';

enum SearchTab { posts, fediverse, realms }

class UniversalSearchScreen extends HookConsumerWidget {
  final SearchTab initialTab;

  const UniversalSearchScreen({super.key, this.initialTab = SearchTab.posts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(
      initialLength: 3,
      initialIndex: initialTab.index,
    );

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(title: Text('universalSearch'.tr()), elevation: 0),
      body: Column(
        children: [
          TabBar(
            controller: tabController,
            tabs: [
              Tab(text: 'posts'.tr()),
              Tab(text: 'fediverseUsers'.tr()),
              Tab(text: 'realms'.tr()),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [_PostsSearchTab(), _FediverseSearchTab(), _RealmsSearchTab()],
            ),
          ),
        ],
      ),
    );
  }
}

class _RealmsSearchTab extends HookConsumerWidget {
  const _RealmsSearchTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Timer? debounceTimer;
    final searchController = useTextEditingController();
    final currentQuery = useState<String?>(null);

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            const SliverGap(88),
            SliverRealmList(
              query: currentQuery.value,
              key: ValueKey(currentQuery.value),
            ),
            SliverGap(MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SearchBar(
                  elevation: WidgetStateProperty.all(4),
                  controller: searchController,
                  hintText: 'search'.tr(),
                  leading: const Icon(Icons.search),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  onChanged: (value) {
                    if (debounceTimer?.isActive ?? false) {
                      debounceTimer?.cancel();
                    }
                    debounceTimer = Timer(const Duration(milliseconds: 300), () {
                      if (currentQuery.value != value) {
                        currentQuery.value = value;
                      }
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PostsSearchTab extends HookConsumerWidget {
  const _PostsSearchTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final debounce = useMemoized(() => Duration(milliseconds: 500));
    final debounceTimer = useRef<Timer?>(null);
    final showFilters = useState(false);
    final pubNameController = useTextEditingController();
    final realmController = useTextEditingController();

    final categoryTabController = useTabController(initialLength: 3);
    final queryState = useState(const PostListQuery());

    final noti = ref.read(
      postListProvider(PostListQueryConfig(id: kSearchPostListId)).notifier,
    );

    useEffect(() {
      return () {
        searchController.dispose();
        pubNameController.dispose();
        realmController.dispose();
        debounceTimer.value?.cancel();
      };
    }, []);

    void onSearchChanged(String query, {bool skipDebounce = false}) {
      queryState.value = queryState.value.copyWith(queryTerm: query);

      if (skipDebounce) {
        noti.applyFilter(queryState.value);
        return;
      }

      if (debounceTimer.value?.isActive ?? false) debounceTimer.value!.cancel();
      debounceTimer.value = Timer(debounce, () {
        noti.applyFilter(queryState.value);
      });
    }

    void toggleFilterDisplay() {
      showFilters.value = !showFilters.value;
    }

    Widget buildFilterPanel() {
      return PostFilterWidget(
        categoryTabController: categoryTabController,
        initialQuery: queryState.value,
        onQueryChanged: (newQuery) {
          queryState.value = newQuery;
          noti.applyFilter(newQuery);
        },
        hideSearch: true,
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        final searchState = ref.watch(
          postListProvider(PostListQueryConfig(id: kSearchPostListId)),
        );

        return isWideScreen(context)
            ? Row(
                children: [
                  Flexible(
                    flex: 4,
                    child: ExtendedRefreshIndicator(
                      onRefresh: noti.refresh,
                      child: CustomScrollView(
                        slivers: [
                          SliverGap(16),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: SearchBar(
                                elevation: WidgetStateProperty.all(4),
                                controller: searchController,
                                hintText: 'search'.tr(),
                                leading: const Icon(Icons.search),
                                padding: WidgetStateProperty.all(
                                  const EdgeInsets.symmetric(horizontal: 24),
                                ),
                                onChanged: onSearchChanged,
                                onSubmitted: (value) {
                                  onSearchChanged(value, skipDebounce: true);
                                },
                              ),
                            ),
                          ),
                          const SliverGap(12),
                          PaginationList(
                            provider: postListProvider(
                              PostListQueryConfig(id: kSearchPostListId),
                            ),
                            notifier: postListProvider(
                              PostListQueryConfig(id: kSearchPostListId),
                            ).notifier,
                            isSliver: true,
                            isRefreshable: false,
                            footerSkeletonChild: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: const PostItemSkeleton(
                                maxWidth: double.infinity,
                              ),
                            ),
                            itemBuilder: (context, index, post) {
                              return Card(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: PostActionableItem(
                                  item: post,
                                  borderRadius: 8,
                                ),
                              );
                            },
                          ),
                          if (searchState.value?.items.isEmpty == true &&
                              searchController.text.isNotEmpty &&
                              !searchState.isLoading)
                            SliverFillRemaining(
                              child: Center(child: Text('noResultsFound'.tr())),
                            ),
                          SliverGap(MediaQuery.of(context).padding.bottom + 16),
                        ],
                      ).padding(left: 8),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Gap(16),
                            Card(
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Symbols.tune,
                                    ).padding(horizontal: 8),
                                    Expanded(
                                      child: Text(
                                        'filters'.tr(),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Symbols.filter_alt,
                                        fill: showFilters.value ? 1 : null,
                                      ),
                                      onPressed: toggleFilterDisplay,
                                      tooltip: 'toggleFilters'.tr(),
                                    ),
                                    const Gap(4),
                                  ],
                                ),
                              ),
                            ),
                            const Gap(8),
                            if (showFilters.value) buildFilterPanel(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : CustomScrollView(
                slivers: [
                  const SliverGap(4),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: SearchBar(
                        elevation: WidgetStateProperty.all(4),
                        controller: searchController,
                        hintText: 'search'.tr(),
                        leading: const Icon(Icons.search),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        onChanged: onSearchChanged,
                        onSubmitted: (value) {
                          onSearchChanged(value, skipDebounce: true);
                        },
                      ),
                    ),
                  ),
                  const SliverGap(8),
                  SliverToBoxAdapter(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Card(
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                const Icon(Symbols.tune).padding(horizontal: 8),
                                Expanded(
                                  child: Text(
                                    'filters'.tr(),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Symbols.filter_alt,
                                    fill: showFilters.value ? 1 : null,
                                  ),
                                  onPressed: toggleFilterDisplay,
                                  tooltip: 'toggleFilters'.tr(),
                                ),
                                const Gap(4),
                              ],
                            ),
                          ),
                        ),
                        const Gap(4),
                        if (showFilters.value) buildFilterPanel(),
                      ],
                    ),
                  ),
                  PaginationList(
                    provider: postListProvider(
                      PostListQueryConfig(id: kSearchPostListId),
                    ),
                    notifier: postListProvider(
                      PostListQueryConfig(id: kSearchPostListId),
                    ).notifier,
                    isSliver: true,
                    isRefreshable: false,
                    footerSkeletonChild: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: const PostItemSkeleton(maxWidth: double.infinity),
                    ),
                    itemBuilder: (context, index, post) {
                      return Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 600),
                          child: Card(
                            margin: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: PostActionableItem(
                              item: post,
                              borderRadius: 8,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (searchState.value?.items.isEmpty == true &&
                      searchController.text.isNotEmpty &&
                      !searchState.isLoading)
                    SliverFillRemaining(
                      child: Center(child: Text('noResultsFound'.tr())),
                    ),
                ],
              );
      },
    );
  }
}

class _FediverseSearchTab extends HookConsumerWidget {
  const _FediverseSearchTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final debounce = useMemoized(() => const Duration(milliseconds: 500));
    final debounceTimer = useRef<Timer?>(null);
    final searchResults = useState<List<SnActivityPubActor>>([]);
    final isSearching = useState(false);

    useEffect(() {
      return () {
        searchController.dispose();
        debounceTimer.value?.cancel();
      };
    }, []);

    Future<void> performSearch(String query) async {
      if (query.trim().isEmpty) {
        searchResults.value = [];
        return;
      }

      isSearching.value = true;
      try {
        final service = ref.read(activityPubServiceProvider);
        final results = await service.searchUsers(query);
        searchResults.value = results;
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isSearching.value = false;
      }
    }

    void onSearchChanged(String query) {
      if (debounceTimer.value?.isActive ?? false) {
        debounceTimer.value!.cancel();
      }
      debounceTimer.value = Timer(debounce, () {
        performSearch(query);
      });
    }

    void updateActorIsFollowing(String actorId, bool isFollowing) {
      searchResults.value = searchResults.value
          .map(
            (a) => a.id == actorId ? a.copyWith(isFollowing: isFollowing) : a,
          )
          .toList();
    }

    Future<void> handleFollow(SnActivityPubActor actor) async {
      try {
        updateActorIsFollowing(actor.id, true);
        final service = ref.read(activityPubServiceProvider);
        await service.followRemoteUser(actor.uri);
        showSnackBar(
          'followedUser'.tr(
            args: [
              '${actor.username?.isNotEmpty ?? false ? actor.username : actor.displayName}',
            ],
          ),
        );
      } catch (err) {
        showErrorAlert(err);
        updateActorIsFollowing(actor.id, false);
      }
    }

    Future<void> handleUnfollow(SnActivityPubActor actor) async {
      try {
        updateActorIsFollowing(actor.id, false);
        final service = ref.read(activityPubServiceProvider);
        await service.unfollowRemoteUser(actor.uri);
        showSnackBar(
          'unfollowedUser'.tr(
            args: [
              '${actor.username?.isNotEmpty ?? false ? actor.username : actor.displayName}',
            ],
          ),
        );
      } catch (err) {
        showErrorAlert(err);
        updateActorIsFollowing(actor.id, true);
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SearchBar(
            controller: searchController,
            hintText: 'searchFediverseHint'.tr(
              args: ['@username@instance.com'],
            ),
            leading: const Icon(Symbols.search).padding(horizontal: 24),
            onChanged: onSearchChanged,
            onSubmitted: (value) {
              onSearchChanged(value);
              performSearch(value);
            },
          ),
        ),
        Expanded(
          child: isSearching.value
              ? const Center(child: CircularProgressIndicator())
              : searchResults.value.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Symbols.search,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      if (searchController.text.isEmpty)
                        Text(
                          'searchFediverseEmpty'.tr(),
                          style: Theme.of(context).textTheme.titleMedium,
                        )
                      else
                        Text(
                          'searchFediverseNoResults'.tr(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                    ],
                  ),
                )
              : ExtendedRefreshIndicator(
                  onRefresh: () => performSearch(searchController.text),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: searchResults.value.length,
                    separatorBuilder: (context, index) => const Gap(8),
                    itemBuilder: (context, index) {
                      final actor = searchResults.value[index];
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: ApActorListItem(
                            actor: actor,
                            isFollowing: actor.isFollowing ?? false,
                            isLoading: false,
                            onFollow: () => handleFollow(actor),
                            onUnfollow: () => handleUnfollow(actor),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
