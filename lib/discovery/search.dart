import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:island/accounts/accounts_widgets/account/account_name.dart';
import 'package:island/accounts/accounts_widgets/account/account_picker.dart';
import 'package:island/accounts/accounts_widgets/activitypub/actor_list_item.dart';
import 'package:island/core/models/activitypub.dart';
import 'package:island/accounts/accounts_models/account.dart';
import 'package:island/posts/post/post_list.dart';
import 'package:island/posts/posts_widgets/post/filters/post_filter.dart';
import 'package:island/posts/posts_widgets/post/post_item.dart';
import 'package:island/posts/posts_widgets/post/post_item_skeleton.dart';
import 'package:island/core/services/activitypub_service.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/drive/drive_widgets/cloud_files.dart';
import 'package:island/realms/realms_widgets/realm/realm_list.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

const kSearchPostListId = 'search';

enum SearchTab { posts, accounts, realms }

class UniversalSearchScreen extends HookConsumerWidget {
  final SearchTab initialTab;

  const UniversalSearchScreen({super.key, this.initialTab = SearchTab.posts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(
      initialLength: 3,
      initialIndex: initialTab.index,
    );
    final searchQuery = useState<String>('');

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: SearchBar(
          constraints: const BoxConstraints(maxWidth: 400, minHeight: 32),
          hintText: 'search'.tr(),
          hintStyle: WidgetStatePropertyAll(TextStyle(fontSize: 14)),
          textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 14)),
          onChanged: (value) {
            searchQuery.value = value;
          },
          leading: Icon(
            Symbols.search,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          TabBar(
            controller: tabController,
            tabs: [
              Tab(text: 'posts'.tr()),
              Tab(text: 'accounts'.tr()),
              Tab(text: 'realms'.tr()),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                _PostsSearchTab(searchQuery: searchQuery),
                _AccountSearchTab(searchQuery: searchQuery),
                _RealmsSearchTab(searchQuery: searchQuery),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RealmsSearchTab extends HookConsumerWidget {
  final ValueNotifier<String> searchQuery;

  const _RealmsSearchTab({required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            const SliverGap(8),
            SliverRealmList(
              query: searchQuery.value,
              key: ValueKey(searchQuery.value),
            ),
            SliverGap(MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ],
    );
  }
}

class _PostsSearchTab extends HookConsumerWidget {
  final ValueNotifier<String> searchQuery;

  const _PostsSearchTab({required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    // Listen to search query changes and update the search
    useEffect(() {
      final query = searchQuery.value;
      if (query.isNotEmpty) {
        // Use Future.delayed to defer the provider modification
        Future.delayed(Duration.zero, () {
          onSearchChanged(query, skipDebounce: true);
        });
      }
      return null;
    }, [searchQuery.value]);

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
                          SliverGap(4),
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
                              searchQuery.value.isNotEmpty &&
                              !searchState.isLoading)
                            SliverFillRemaining(
                              child: Center(child: Text('noResultsFound'.tr())),
                            ),
                          SliverGap(MediaQuery.of(context).padding.bottom + 16),
                        ],
                      ).padding(left: 16),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(right: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Gap(8),
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
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: PostActionableItem(item: post, borderRadius: 8),
                      );
                    },
                  ),
                  if (searchState.value?.items.isEmpty == true &&
                      searchQuery.value.isNotEmpty &&
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

class _AccountSearchTab extends HookConsumerWidget {
  final ValueNotifier<String> searchQuery;

  const _AccountSearchTab({required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debounce = useMemoized(() => const Duration(milliseconds: 500));
    final debounceTimer = useRef<Timer?>(null);
    final fediverseResults = useState<List<SnActivityPubActor>>([]);
    final internalResults = useState<List<SnAccount>>([]);
    final isSearching = useState(false);

    useEffect(() {
      return () {
        debounceTimer.value?.cancel();
      };
    }, []);

    Future<void> performSearch(String query) async {
      if (query.trim().isEmpty) {
        fediverseResults.value = [];
        internalResults.value = [];
        return;
      }

      isSearching.value = true;
      try {
        // Search for fediverse users
        final activityPubService = ref.read(activityPubServiceProvider);
        final fediverseFuture = activityPubService.searchUsers(query);

        // Search for internal users
        final internalFuture = ref.read(
          searchAccountsProvider(query: query).future,
        );

        // Wait for both searches to complete
        final [fediverseData, internalData] = await Future.wait([
          fediverseFuture,
          internalFuture,
        ]);

        fediverseResults.value = fediverseData as List<SnActivityPubActor>;
        internalResults.value = internalData as List<SnAccount>;
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
      fediverseResults.value = fediverseResults.value
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

    // Listen to search query changes and update the search
    useEffect(() {
      final query = searchQuery.value;
      if (query.isNotEmpty) {
        // Use Future.delayed to defer the provider modification
        Future.delayed(Duration.zero, () {
          onSearchChanged(query);
        });
      }
      return null;
    }, [searchQuery.value]);

    // Combine and display results - local users first
    final allResults = [
      ...internalResults.value.map(
        (account) => {'type': 'internal', 'data': account},
      ),
      ...fediverseResults.value.map(
        (actor) => {'type': 'fediverse', 'data': actor},
      ),
    ];

    return Column(
      children: [
        Expanded(
          child: isSearching.value
              ? const Center(child: CircularProgressIndicator())
              : allResults.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Symbols.search,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const Gap(16),
                      if (searchQuery.value.isEmpty)
                        Text(
                          'searchUsersEmpty'.tr(),
                          style: Theme.of(context).textTheme.titleMedium,
                        )
                      else
                        Text(
                          'searchUsersNoResults'.tr(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                    ],
                  ),
                )
              : ExtendedRefreshIndicator(
                  onRefresh: () => performSearch(searchQuery.value),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: allResults.length,
                    separatorBuilder: (context, index) => const Gap(8),
                    itemBuilder: (context, index) {
                      final result = allResults[index];
                      if (result['type'] == 'fediverse') {
                        final actor = result['data'] as SnActivityPubActor;
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
                      } else {
                        final account = result['data'] as SnAccount;
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 560),
                            child: ListTile(
                              contentPadding: const EdgeInsets.only(
                                left: 16,
                                right: 12,
                              ),
                              leading: Stack(
                                children: [
                                  ProfilePictureWidget(
                                    file: account.profile.picture,
                                  ),
                                ],
                              ),
                              title: AccountName(
                                account: account,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              subtitle: Row(
                                children: [
                                  Text('@${account.name}'),
                                  if (account.profile.bio.isNotEmpty)
                                    Expanded(
                                      child: Text(
                                        account.profile.bio,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: const SizedBox(
                                width: 88,
                              ), // To align with ApActorListItem
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
