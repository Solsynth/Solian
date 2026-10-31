import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/page_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:island/shared/hooks/material_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/account_picker.dart';
import 'package:island/chat/widgets/chat_search_screen.dart';
import 'package:island/core/network.dart';
import 'package:island/core/theme.dart';
import 'package:island/discovery/search_navigation.dart';
import 'package:island/discovery/widgets/explore_card.dart';
import 'package:island/discovery/widgets/pill_app_bar.dart';
import 'package:island/posts/pods/post_list.dart';
import 'package:island/posts/widgets/compose/filters/post_filter.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_item_skeleton.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/core/utils/text.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/realms/widgets/realm_list.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/empty_state.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:island_ui_foundation/island_ui_foundation.dart'
    hide isWideScreen;
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

const kSearchPostListId = 'search';

/// Step between two floating result cards, matching the explore feed.
const _kResultGap = kExploreCardGap;

/// Extra gutter the wide result panes add on top of [explorePageGutter].
const _kWidePaneInset = 12.0;

/// The band this page's pill actually occupies, measured from the top of the
/// viewport.
///
/// [kPillAppBarHeight] is only the capsule and its top gutter; the bar also
/// carries the status-bar inset, and the scaffold here draws it over the body
/// (`extendBodyBehindAppBar`). A section that reserved only the constant would
/// start its first result that many pixels *under* the capsule.
double _pillBand(BuildContext context) =>
    MediaQuery.paddingOf(context).top;

enum SearchScope { local, remote }

@RoutePage()
class UniversalSearchScreen extends HookConsumerWidget {
  const UniversalSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(searchTabProvider);
    final searchQuery = useState<String>('');
    final debouncedSearchQuery = useState<String>('');
    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();
    final debounceTimer = useRef<Timer?>(null);
    // Filter panel visibility, driven solely by the app bar action so it can
    // stay in sync across the sections that expose filters.
    final filtersVisible = useState(false);
    // Which section the results below the bar are drawn from. The sections
    // show the same kinds of rows, so they swap in place instead of sliding
    // in a new page.
    final activeTab = useState(selectedTab);
    const debounce = Duration(milliseconds: 450);
    final fade = useValueNotifier(0.0);
    final statusTop = MediaQuery.paddingOf(context).top;

    // A query handed over by an outside entry point (the command palette) lands
    // in the field and runs straight away.
    final querySeed = ref.watch(searchQuerySeedProvider);
    useEffect(() {
      if (querySeed == null || querySeed.trim().isEmpty) return null;
      searchController.text = querySeed;
      searchQuery.value = querySeed;
      debouncedSearchQuery.value = querySeed;
      // Consuming the seed writes to a provider, which is not allowed while the
      // tree is building — the hook effect runs mid-build, so defer it.
      final seeds = ref.read(searchQuerySeedProvider.notifier);
      WidgetsBinding.instance.addPostFrameCallback((_) => seeds.clear());
      return null;
    }, [querySeed]);

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

    // Follow section requests from outside the page (chat list, realms...).
    useEffect(() {
      if (activeTab.value != selectedTab) activeTab.value = selectedTab;
      return null;
    }, [selectedTab]);

    // The sections below the bar; each is handed the page's live notifiers, so
    // switching swaps which one the viewport shows without rebuilding the
    // bar or re-running the query.
    Widget buildResults(SearchTab tab) => switch (tab) {
      SearchTab.posts => _PostsSearchTab(
        searchQuery: debouncedSearchQuery,
        filtersVisible: filtersVisible,
      ),
      SearchTab.accounts => _AccountSearchTab(
        searchQuery: debouncedSearchQuery,
      ),
      SearchTab.realms => _RealmsSearchTab(searchQuery: debouncedSearchQuery),
      SearchTab.messages => ChatMessageSearchView(
        searchQuery: debouncedSearchQuery,
        filtersVisible: filtersVisible,
      ),
    };

    // `extendBodyBehindAppBar` puts the results under the pill, which is what
    // lets them slide beneath it and fade its surface in; the background comes
    // from [AppBackground], the same one the old scaffold wrapper painted.
    //
    // The pill's band is *not* reserved here: a fixed gap above the sections
    // would stop their rows at the capsule instead of letting them run under
    // it, and the glass would have nothing to refract. Each section reserves
    // the band as its own first sliver/padding instead, so the first result
    // starts below the pill and everything after it slides underneath.
    return AppBackground(
      isRoot: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        // The results fade the bar's surface in as they slide under it, the same
        // way the explore feed drives its own header.
        body: NotificationListener<ScrollNotification>(
          onNotification: (notification) => updatePillFade(notification, fade),
          child: buildResults(activeTab.value),
        ),
        appBar: PillAppBar(
          fade: fade,
          statusTop: statusTop,
          child: Row(
            children: [
              // The same leading the explore bar uses, so both root tabs open
              // the drawer from the same spot.
              const SolDrawerButton(),
              const Gap(SolSpace.sm),
              Expanded(
                child: SearchBar(
                  backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                  overlayColor: WidgetStatePropertyAll(Colors.transparent),
                  controller: searchController,
                  focusNode: searchFocusNode,
                  // The same control height the explore pill's row uses, so the
                  // two bars line up when switching pages.
                  constraints: const BoxConstraints(
                    minHeight: SolSpace.control,
                  ),
                  // Only the trailing edge is inset: the leading slot holds the
                  // section picker, which carries the explore picker's own
                  // inset so it lands on the same x as the bar it mirrors.
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.only(right: SolSpace.sm),
                  ),
                  hintText: 'search'.tr(),
                  hintStyle: const WidgetStatePropertyAll(
                    TextStyle(fontSize: 14),
                  ),
                  textStyle: const WidgetStatePropertyAll(
                    TextStyle(fontSize: 14),
                  ),
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
                  // The section picker takes the search icon's slot, so the
                  // result kind is chosen at the field itself rather than from
                  // a second row of tabs under the bar.
                  leading: _SearchSectionButton(
                    tab: activeTab.value,
                    onSelected: (tab) {
                      activeTab.value = tab;
                      ref.read(searchTabProvider.notifier).select(tab);
                    },
                  ),
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: filtersVisible,
                builder: (context, visible, _) {
                  final supported =
                      activeTab.value == SearchTab.posts ||
                      activeTab.value == SearchTab.messages;
                  return IconButton(
                    onPressed: supported
                        ? () => filtersVisible.value = !filtersVisible.value
                        : null,
                    icon: Icon(
                      visible ? Symbols.filter_list_off : Symbols.filter_list,
                    ),
                    tooltip: visible ? 'hideFilters'.tr() : 'showFilters'.tr(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section picker for the search bar's leading slot.
///
/// Shows the active section's icon and label where the search icon used to
/// sit, so the result kind is chosen at the field itself: the trigger paints
/// no surface of its own and floats directly on the bar's pill. It reads the
/// same `null`-free [SearchTab] vocabulary the rest of the page uses.
class _SearchSectionButton extends StatelessWidget {
  final SearchTab tab;
  final ValueChanged<SearchTab> onSelected;

  const _SearchSectionButton({required this.tab, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selected = _searchSections.firstWhere(
      (section) => section.tab == tab,
      orElse: () => _searchSections.first,
    );

    return MenuAnchor(
      animated: true,
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(
          colorScheme.surfaceContainerHigh,
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: SolRadius.menuRadius),
        ),
      ),
      builder: (context, controller, child) {
        return InkWell(
          borderRadius: SolRadius.pillRadius,
          onTap: () =>
              controller.isOpen ? controller.close() : controller.open(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SolSpace.sm,
              vertical: SolSpace.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: SolSpace.sm,
              children: [
                Icon(selected.icon, size: 20, color: colorScheme.onSurface),
                Text(
                  selected.label.tr(),
                  style: theme.appBarTheme.titleTextStyle,
                ),
              ],
            ),
          ),
        );
      },
      menuChildren: [
        for (final section in _searchSections)
          MenuItemButton(
            leadingIcon: Icon(section.icon, size: 20),
            trailingIcon: tab == section.tab
                ? const Icon(Symbols.check, size: 18)
                : null,
            onPressed: () => onSelected(section.tab),
            child: Text(section.label.tr()),
          ),
      ],
    );
  }
}

class _SearchSection {
  final SearchTab tab;
  final String label;
  final IconData icon;

  const _SearchSection({
    required this.tab,
    required this.label,
    required this.icon,
  });
}

const _searchSections = <_SearchSection>[
  _SearchSection(tab: SearchTab.posts, label: 'posts', icon: Symbols.article),
  _SearchSection(
    tab: SearchTab.accounts,
    label: 'accounts',
    icon: Symbols.person,
  ),
  _SearchSection(tab: SearchTab.realms, label: 'realms', icon: Symbols.public),
  _SearchSection(
    tab: SearchTab.messages,
    label: 'messages',
    icon: Symbols.chat,
  ),
];

class _RealmsSearchTab extends HookConsumerWidget {
  final ValueNotifier<String> searchQuery;

  const _RealmsSearchTab({required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        // The pill's band lives inside the scroll view, so rows pass under
        // the capsule instead of stopping at it.
        SliverGap(_pillBand(context) + _kResultGap),
        // The same gutter the posts rows and the explore feed use, so a card
        SliverPadding(
          padding: explorePageGutter(context),
          sliver: SliverRealmList(
            query: searchQuery.value,
            key: ValueKey(searchQuery.value),
          ),
        ),
        SliverGap(MediaQuery.of(context).padding.bottom + _kResultGap),
      ],
    );
  }
}

class _PostsSearchTab extends HookConsumerWidget {
  final ValueNotifier<String> searchQuery;
  final ValueNotifier<bool> filtersVisible;

  const _PostsSearchTab({
    required this.searchQuery,
    required this.filtersVisible,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryTabController = useMaterialTabController(initialLength: 3);
    final queryState = useState(const PostListQuery(includeReplies: false));

    final noti = ref.read(
      postListProvider(PostListQueryConfig(id: kSearchPostListId)).notifier,
    );

    void onSearchChanged(String query) {
      queryState.value = queryState.value.copyWith(queryTerm: query);
      noti.applyFilter(queryState.value);
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

    Widget buildPostRow(SnPost post) {
      return PostRowSurface(
        child: PostActionableItem(
          item: post,
          padding: const EdgeInsets.fromLTRB(
            SolSpace.lg,
            SolSpace.md + 2,
            SolSpace.lg,
            SolSpace.md,
          ),
        ),
      );
    }

    final filterSidebarContent = buildFilterPanel();

    Widget buildMainContent({
      double topGap = 0,
      Widget? header,
      EdgeInsetsGeometry? gutter,
    }) {
      return Consumer(
        builder: (context, ref, child) {
          final searchState = ref.watch(
            postListProvider(PostListQueryConfig(id: kSearchPostListId)),
          );
          return ExtendedRefreshIndicator(
            onRefresh: noti.refresh,
            child: CustomScrollView(
              slivers: [
                // The pill's band, inside the scroll view so the rows travel
                // under the capsule rather than stopping short of it.
                if (topGap > 0) SliverGap(topGap),
                if (header != null)
                  SliverPadding(
                    padding: gutter ?? EdgeInsets.zero,
                    sliver: SliverToBoxAdapter(child: header),
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
                  seperatorBuilder: (context, index, post) =>
                      const SizedBox(height: _kResultGap),
                  footerSkeletonChild: const PostItemSkeleton(
                    maxWidth: double.infinity,
                    showCard: false,
                  ),
                  itemBuilder: (context, index, post) => buildPostRow(post),
                ),
                if (searchState.value?.items.isEmpty == true &&
                    searchQuery.value.isNotEmpty &&
                    !searchState.isLoading)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      key: const Key('postSearchEmpty'),
                      icon: Symbols.search_off,
                      title: 'noResultsFound'.tr(),
                      description: 'tryDifferentKeywords'.tr(),
                    ),
                  ),
                SliverGap(MediaQuery.of(context).padding.bottom + _kResultGap),
              ],
            ),
          );
        },
      );
    }

    if (isWideScreen(context)) {
      // The rows keep the explore feed's own reading column and gutter, so a
      // card sits on the same measure in either tab; the filter content is
      // inset inside the sliding panel so it does not sit flush against its
      // edge.
      //
      // The pill is the scaffold's app bar, so it floats over both panes
      // rather than over the results alone: the sidebar spans the viewport
      // from the very top and would otherwise paint behind the capsule, with
      // its own first control cut by it. Both panes reserve the band the pill
      // occupies; only the results add the card gap below it.
      final band = _pillBand(context);
      return ResponsiveSidebar(
        showSidebar: filtersVisible,
        sidebarWidth: 320,
        // The pane paints no surface and no shadow of its own: it is a column
        // of controls floating over the page, so the page background runs
        // behind it and the panel never reads as a card laid over the results.
        sidebarBackgroundColor: Colors.transparent,
        sidebarElevation: 0,
        sidebarContent: Padding(
          padding: EdgeInsets.fromLTRB(
            _kWidePaneInset,
            band + _kWidePaneInset,
            _kWidePaneInset,
            _kWidePaneInset,
          ),
          child: filterSidebarContent,
        ),
        mainContent: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: kDiscoveryWideColumnWidth,
            ),
            child: Padding(
              padding: explorePageGutter(context),
              child: buildMainContent(topGap: band + _kResultGap),
            ),
          ),
        ),
      );
    }

    // Narrow: the filter panel is the list's first sliver instead of a fixed
    // band above it. Pinned above the list it would stop the rows at the
    // capsule; inside the scroll view they pass under the glass, and the panel
    // scrolls away with them.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SolSpace.md),
      child: buildMainContent(
        topGap: _pillBand(context) + _kResultGap,
        header: AnimatedSlide(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          offset: filtersVisible.value ? Offset.zero : const Offset(0, -0.08),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: filtersVisible.value
                  ? Padding(
                      key: const ValueKey('filters-visible'),
                      padding: const EdgeInsets.only(bottom: _kResultGap),
                      child: buildFilterPanel(),
                    )
                  : const SizedBox(key: ValueKey('filters-hidden')),
            ),
          ),
        ),
      ),
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
    final fediverseResults = useState<List<SnPublisher>>([]);
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
                .map((json) => SnPublisher.fromJson(json))
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

    // One scroll view for the whole section, so the scope switch and the
    // results both travel under the pill instead of the switch pinning the
    // list below the capsule.
    return ExtendedRefreshIndicator(
      onRefresh: () => performSearch(searchQuery.value),
      child: CustomScrollView(
        slivers: [
          SliverGap(_pillBand(context) + _kResultGap),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  // The feed's gutter, and only the row's own breathing room
                  // below: the band above already cleared the pill.
                  padding: const EdgeInsets.fromLTRB(
                    SolSpace.md,
                    0,
                    SolSpace.md,
                    SolSpace.sm,
                  ),
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
          ),
          if (isSearching.value)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (allResults.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                key: const Key('accountSearchEmpty'),
                icon: searchQuery.value.isEmpty
                    ? Symbols.search
                    : Symbols.search_off,
                title: searchQuery.value.isEmpty
                    ? 'searchUsersEmpty'.tr()
                    : 'searchUsersNoResults'.tr(),
                description: searchQuery.value.isEmpty
                    ? 'searchAccountsHint'.tr()
                    : 'tryDifferentKeywords'.tr(),
              ),
            )
          else
            SliverPadding(
              // The feed's gutter, with the last card clear of the tab shell's
              // bottom bar.
              padding: EdgeInsets.only(
                left: SolSpace.md,
                right: SolSpace.md,
                bottom: MediaQuery.paddingOf(context).bottom + _kResultGap,
              ),
              sliver: SliverList.separated(
                itemCount: allResults.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: _kResultGap),
                itemBuilder: (context, index) {
                  final result = allResults[index];
                  if (result['type'] == 'publisher') {
                    final publisher = result['data'] as SnPublisher;
                    return SearchResultCard(
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
                              fallbackName: publisher.nick,
                              borderRadius: publisher.type == 0 ? null : 6,
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
                                        file:
                                            publisher.account?.profile.picture,
                                        fallbackName: publisher.account?.nick,
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: const Icon(
                          Symbols.chevron_right,
                        ).padding(right: 12),
                      ),
                    );
                  } else if (result['type'] == 'fediverse') {
                    final actor = result['data'] as SnPublisher;
                    // Remote actors summarise themselves in HTML; the row
                    // shows the plain-text excerpt.
                    final actorBio = actor.bio.htmlToPlainText();
                    final actorAvatar = actor.picture?.storageUrl;
                    return SearchResultCard(
                      child: ListTile(
                        contentPadding: const EdgeInsets.only(
                          left: 16,
                          right: 12,
                        ),
                        onTap: () {
                          context.router.push(
                            FediverseActorProfileRoute(
                              id: actor.id,
                              fullHandle: actor.activitypub?.fullHandle,
                            ),
                          );
                        },
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              backgroundImage: actorAvatar != null
                                  ? CachedNetworkImageProvider(actorAvatar)
                                  : null,
                              radius: 24,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainer,
                              child: actorAvatar == null
                                  ? Icon(Symbols.person)
                                  : null,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.tertiary,
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
                              child: Text(
                                actor.effectiveName,
                                style: Theme.of(context).textTheme.titleMedium,
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
                                actor.domain ?? '',
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
                        subtitle: actorBio.isNotEmpty
                            ? Text(
                                actorBio,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              )
                            : null,
                        trailing: const Icon(
                          Symbols.chevron_right,
                        ).padding(right: 12),
                      ),
                    );
                  } else {
                    final account = result['data'] as SnAccount;
                    return SearchResultCard(
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
                              fallbackName: account.nick,
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
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// One account, publisher or fediverse hit: its own floating card.
///
/// All three results draw the same row, so they share the explore feed's
/// card surface instead of sitting in a divider-separated list.
class SearchResultCard extends StatelessWidget {
  final Widget child;

  const SearchResultCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: PostRowSurface(child: child),
      ),
    );
  }
}
