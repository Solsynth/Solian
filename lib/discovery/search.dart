import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/account_picker.dart';
import 'package:island/core/network.dart';
import 'package:island/posts/pods/post_list.dart';
import 'package:island/posts/widgets/compose/filters/post_filter.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_item_skeleton.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/realms/widgets/realm_list.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

const kSearchPostListId = 'search';

enum SearchTab { posts, accounts, realms }

enum SearchScope { local, remote }

@RoutePage()
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
    final debouncedSearchQuery = useState<String>('');
    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();
    final debounceTimer = useRef<Timer?>(null);
    const debounce = Duration(milliseconds: 450);

    useEffect(() {
      if (searchQuery.value.isEmpty) {
        debounceTimer.value?.cancel();
        debouncedSearchQuery.value = '';
        return null;
      }

      debounceTimer.value?.cancel();
      debounceTimer.value = Timer(debounce, () {
        debouncedSearchQuery.value = searchQuery.value;
      });

      return () {
        debounceTimer.value?.cancel();
      };
    }, [searchQuery.value]);

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: SearchBar(
          controller: searchController,
          focusNode: searchFocusNode,
          constraints: const BoxConstraints(maxWidth: 400, minHeight: 32),
          hintText: 'search'.tr(),
          hintStyle: WidgetStatePropertyAll(TextStyle(fontSize: 14)),
          textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 14)),
          onTapOutside: (_) => searchFocusNode.unfocus(),
          trailing: [
            if (searchController.text.isNotEmpty)
              IconButton(
                onPressed: () {
                  debounceTimer.value?.cancel();
                  searchController.clear();
                  searchQuery.value = '';
                  debouncedSearchQuery.value = '';
                  searchFocusNode.unfocus();
                },
                icon: Icon(
                  Symbols.close,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
              ),
          ],
          onChanged: (value) {
            searchQuery.value = value;
          },
          onSubmitted: (value) {
            debounceTimer.value?.cancel();
            searchQuery.value = value;
            debouncedSearchQuery.value = value;
            searchFocusNode.unfocus();
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
                _PostsSearchTab(searchQuery: debouncedSearchQuery),
                _AccountSearchTab(searchQuery: debouncedSearchQuery),
                _RealmsSearchTab(searchQuery: debouncedSearchQuery),
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
      };
    }, []);

    void onSearchChanged(String query) {
      queryState.value = queryState.value.copyWith(queryTerm: query);
      noti.applyFilter(queryState.value);
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

    // Listen to debounced search query changes and update the list.
    useEffect(() {
      Future.microtask(() => onSearchChanged(searchQuery.value));
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
                            if (showFilters.value)
                              buildFilterPanel().padding(horizontal: 8),
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
                        if (showFilters.value)
                          buildFilterPanel().padding(horizontal: 8),
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
    final accountResults = useState<List<SnAccount>>([]);
    final publisherResults = useState<List<SnPublisher>>([]);
    final fediverseResults = useState<List<SnActivityPubActor>>([]);
    final isSearching = useState(false);
    final searchScope = useState(SearchScope.local);
    final requestToken = useRef(0);

    Future<void> performSearch(String query) async {
      final normalizedQuery = query.trim();
      final token = ++requestToken.value;

      if (normalizedQuery.isEmpty) {
        accountResults.value = [];
        publisherResults.value = [];
        fediverseResults.value = [];
        isSearching.value = false;
        return;
      }

      isSearching.value = true;
      try {
        final apiClient = ref.read(apiClientProvider);
        final accountFuture = ref.read(
          searchAccountsProvider(query: normalizedQuery).future,
        );
        final publisherFuture = apiClient.get(
          '/sphere/publishers/search',
          queryParameters: {'query': normalizedQuery},
        );

        final futures = <Future>[accountFuture, publisherFuture];

        if (searchScope.value == SearchScope.remote) {
          futures.add(
            apiClient.get(
              '/sphere/fediverse/actors/search',
              queryParameters: {'query': normalizedQuery, 'limit': 20},
            ),
          );
        }

        final results = await Future.wait(futures);

        if (token == requestToken.value) {
          accountResults.value = results[0] as List<SnAccount>;
          publisherResults.value = (results[1].data as List)
              .map((json) => SnPublisher.fromJson(json))
              .toList();

          if (searchScope.value == SearchScope.remote && results.length > 2) {
            fediverseResults.value = (results[2].data as List)
                .map((json) => SnActivityPubActor.fromJson(json))
                .toList();
          } else {
            fediverseResults.value = [];
          }
        }
      } catch (err) {
        if (token == requestToken.value) {
          showErrorAlert(err);
        }
      } finally {
        if (token == requestToken.value) {
          isSearching.value = false;
        }
      }
    }

    // Listen to debounced search query changes and update the list.
    useEffect(() {
      performSearch(searchQuery.value);
      return null;
    }, [searchQuery.value, searchScope.value]);

    // Combine and display results - accounts first, then publishers, then fediverse.
    final allResults = [
      ...accountResults.value.map(
        (account) => {'type': 'account', 'data': account},
      ),
      ...publisherResults.value.map(
        (publisher) => {'type': 'publisher', 'data': publisher},
      ),
      ...fediverseResults.value.map(
        (actor) => {'type': 'fediverse', 'data': actor},
      ),
    ];

    return Column(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: SegmentedButton<SearchScope>(
                segments: [
                  ButtonSegment(
                    value: SearchScope.local,
                    icon: const Icon(Symbols.home),
                    label: Text('localOnly'.tr()),
                  ),
                  ButtonSegment(
                    value: SearchScope.remote,
                    icon: const Icon(Symbols.public),
                    label: Text('includeFediverse'.tr()),
                  ),
                ],
                selected: {searchScope.value},
                onSelectionChanged: (selection) {
                  searchScope.value = selection.first;
                },
                showSelectedIcon: false,
              ),
            ).width(double.infinity),
          ),
        ),
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
                      if (result['type'] == 'publisher') {
                        final publisher = result['data'] as SnPublisher;
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 560),
                            child: ListTile(
                              contentPadding: const EdgeInsets.only(
                                left: 16,
                                right: 12,
                              ),
                              onTap: () {
                                context.router.push(
                                  PublisherProfileRoute(name: publisher.name),
                                );
                              },
                              leading: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ProfilePictureWidget(
                                    file: publisher.picture,
                                    borderRadius: publisher.type == 0
                                        ? null
                                        : 6,
                                  ),
                                  Positioned(
                                    right: -2,
                                    bottom: -2,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: publisher.account != null
                                          ? ProfilePictureWidget(
                                              file: publisher
                                                  .account
                                                  ?.profile
                                                  .picture,
                                            )
                                          : Icon(
                                              publisher.type == 0
                                                  ? Symbols.person
                                                  : Symbols.corporate_fare,
                                              size: 10,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onPrimaryContainer,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                              title: Text(
                                publisher.nick.isNotEmpty
                                    ? publisher.nick
                                    : publisher.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              subtitle: Text(
                                publisher.bio,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(
                                Symbols.chevron_right,
                              ).padding(right: 12),
                            ),
                          ),
                        );
                      } else if (result['type'] == 'fediverse') {
                        final actor = result['data'] as SnActivityPubActor;
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 560),
                            child: ListTile(
                              contentPadding: const EdgeInsets.only(
                                left: 16,
                                right: 12,
                              ),
                              onTap: () {
                                context.router.push(
                                  FediverseActorProfileRoute(
                                    id: actor.id,
                                    fullHandle: actor.fullHandle,
                                  ),
                                );
                              },
                              leading: Stack(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: actor.avatarUrl != null
                                        ? CachedNetworkImageProvider(
                                            actor.avatarUrl!,
                                          )
                                        : null,
                                    radius: 24,
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainer,
                                    child: actor.avatarUrl == null
                                        ? Icon(Symbols.person)
                                        : null,
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.tertiary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Symbols.public,
                                        size: 12,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onTertiary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              title: Row(
                                children: [
                                  Flexible(
                                    child: Column(
                                      children: [
                                        Text(
                                          actor.displayName ?? actor.username,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      actor.instance.domain,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSecondaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle:
                                  actor.bio != null && actor.bio!.isNotEmpty
                                  ? Text(
                                      actor.bio!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    )
                                  : null,
                              trailing: const Icon(
                                Symbols.chevron_right,
                              ).padding(right: 12),
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
                              onTap: () {
                                context.router.push(
                                  AccountProfileRoute(name: account.name),
                                );
                              },
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
                              subtitle: Text(
                                account.profile.bio,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              trailing: const Icon(
                                Symbols.chevron_right,
                              ).padding(right: 12),
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
