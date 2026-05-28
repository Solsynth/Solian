import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/pods/post_list.dart';
import 'package:island/posts/compose_state_global.dart';
import 'package:island/posts/widgets/compose/compose_dialog.dart';
import 'package:island/posts/widgets/compose/compose_sidebar.dart';
import 'package:island/posts/widgets/compose/filters/post_subscription_filter.dart';
import 'package:island/core/translate.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/screens/post_detail.dart';
import 'package:island/posts/widgets/compose/post_interactions.dart';
import 'package:island/posts/widgets/compose/post_quick_reply.dart';
import 'package:island/posts/widgets/compose/post_replies.dart';
import 'package:island/posts/widgets/publishers/publisher_card.dart';
import 'package:island/discovery/models/webfeed.dart';
import 'package:island/posts/posts_pod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/realms/widgets/realm_card.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/confuse_spinner.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/discovery/web_article_card.dart';
import 'package:island/discovery/widgets/discovery_feedback_widget.dart';
import 'package:island/discovery/widgets/discovery_profile_sheet.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:island/posts/widgets/compose/post_list.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/account_pfc.dart';
import 'package:island/accounts/widgets/account/activity_presence.dart';
import 'package:island/accounts/widgets/account/friends_overview.dart';
import 'package:island/core/config.dart';
import 'package:island/core/services/time.dart';
import 'package:url_launcher/url_launcher_string.dart';

final friendAccountMapProvider = Provider<Map<String, SnAccount>>((ref) {
  final friendsAsync = ref.watch(friendsOverviewProvider);
  final friends = friendsAsync.asData?.value;
  if (friends == null) return {};
  return {for (final f in friends) f.account.id: f.account};
});

String _resolvePresenceArtworkUrl(WidgetRef ref, String imageUri) {
  if (imageUri.startsWith('sha256:')) {
    final serverURL = ref.read(serverUrlProvider);
    return '$serverURL/passport/presence/artworks/$imageUri';
  }
  return imageUri;
}

@RoutePage()
class ExploreScreen extends HookConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exploreSettings = ref.watch(appSettingsProvider).exploreSettings;
    final currentFilter = useState<String?>(null);
    final currentMode = useState(exploreSettings.mode);
    final currentAggressive = useState(exploreSettings.aggressiveMode);
    final selectedPublisherNames = useState<List<String>>(
      List<String>.from(exploreSettings.selectedPublisherNames),
    );
    final selectedCategoryIds = useState<List<String>>(
      List<String>.from(exploreSettings.selectedCategoryIds),
    );
    final selectedTagIds = useState<List<String>>(
      List<String>.from(exploreSettings.selectedTagIds),
    );
    final notifier = ref.watch(activityListProvider.notifier);
    final filterTabController = useTabController(initialLength: 3);
    final selectedPostId = useState<String?>(null);
    final isDetailExpanded = useState(false);
    final composeRequest = ref.watch(composeRequestProvider);

    void handleFilterChange(String? filter) {
      currentFilter.value = filter;
      notifier.applyFilter(filter);
      filterTabController.index = switch (filter) {
        'subscriptions' => 1,
        'friends' => 2,
        _ => 0,
      };
    }

    void handleModeChange(String? mode) {
      if (mode == null) return;
      currentMode.value = mode;
      notifier.applyMode(mode);
      ref
          .read(appSettingsProvider.notifier)
          .setExploreSettings(exploreSettings.copyWith(mode: mode));
    }

    void handleAggressiveChange(bool isAggressive) {
      currentAggressive.value = isAggressive;
      notifier.applyAggressiveMode(isAggressive);
      ref
          .read(appSettingsProvider.notifier)
          .setExploreSettings(
            exploreSettings.copyWith(aggressiveMode: isAggressive),
          );
    }

    final isWide = isWideScreen(context);

    final hasSubscriptionFiltersApplied =
        selectedPublisherNames.value.isNotEmpty ||
        selectedCategoryIds.value.isNotEmpty ||
        selectedTagIds.value.isNotEmpty;

    final userInfo = ref.watch(userInfoProvider);
    final isSidePanelOpen =
        isWide && (composeRequest != null || selectedPostId.value != null);

    if (isWide) {
      return AppScaffold(
        isNoBackground: false,
        appBar: null,
        floatingActionButton: userInfo.value != null && !isSidePanelOpen
            ? FloatingActionButton(
                heroTag: 'explore-fab',
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
                            await showCompose(parentContext, ref);
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
        body: _buildWideBody(
          context,
          ref,
          filterTabController,
          currentFilter,
          currentMode,
          selectedPublisherNames,
          selectedCategoryIds,
          selectedTagIds,
          currentAggressive,
          handleFilterChange,
          handleModeChange,
          handleAggressiveChange,
          hasSubscriptionFiltersApplied,
          exploreSettings,
          ref.read(appSettingsProvider.notifier),
          selectedPostId,
          isDetailExpanded,
          composeRequest,
        ),
      );
    }

    return AppScaffold(
      floatingActionButton: userInfo.value != null
          ? FloatingActionButton(
              heroTag: 'explore-fab',
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
      body: _buildNarrowBodySliver(
        context,
        ref,
        filterTabController,
        selectedPublisherNames,
        selectedCategoryIds,
        selectedTagIds,
        currentMode,
        handleModeChange,
        hasSubscriptionFiltersApplied,
        handleFilterChange,
        currentAggressive,
        currentFilter,
        handleAggressiveChange,
        exploreSettings,
        ref.read(appSettingsProvider.notifier),
      ),
    );
  }

  Future<void> _showAlgorithmConfigSheet(
    BuildContext context,
    ValueNotifier<List<String>> selectedPublishers,
    ValueNotifier<List<String>> selectedCategories,
    ValueNotifier<List<String>> selectedTags,
    ValueNotifier<bool> currentAggressive,
    ValueNotifier<String?> currentFilter,
    void Function(String?) handleFilterChange,
    void Function(bool) handleAggressiveChange,
    ValueNotifier<String> mode,
    void Function(String?) onModeChange,
    ExploreSettings exploreSettings,
    AppSettingsNotifier appSettingsNotifier, {
    required bool isWide,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (sheetContext) {
        return SheetScaffold(
          titleText: currentFilter.value == 'subscriptions'
              ? 'exploreFilterSubscriptions'.tr()
              : currentFilter.value == 'friends'
              ? 'exploreFilterFriends'.tr()
              : 'explore'.tr(),
          heightFactor: 0.6,
          child: ValueListenableBuilder<String?>(
            valueListenable: currentFilter,
            builder: (context, filterValue, child) {
              return ValueListenableBuilder<String>(
                valueListenable: mode,
                builder: (context, modeValue, child) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    children: [
                      if (isWide) ...[
                        _ExploreFilterToolbar(
                          currentFilter: filterValue,
                          currentMode: modeValue,
                          onFilterChange: handleFilterChange,
                          onModeChange: onModeChange,
                          onOpenSubscriptionFilters: () {},
                          disableFilterSwitching: false,
                          hideSubscriptionsTab: false,
                        ),
                        const Gap(16),
                      ] else if (filterValue == null) ...[
                        _RankingToolbar(
                          currentMode: modeValue,
                          onModeChange: onModeChange,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withOpacity(0.55),
                        ),
                        const Gap(16),
                      ],
                      Container(
                        decoration: BoxDecoration(
                          border: BoxBorder.all(
                            color: Theme.of(context).colorScheme.outline,
                            width: 1 / MediaQuery.devicePixelRatioOf(context),
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(12),
                          ),
                        ),
                        child: ValueListenableBuilder(
                          valueListenable: currentAggressive,
                          builder: (context, value, child) {
                            return CheckboxListTile(
                              title: Text('exploreAggressiveMode'.tr()),
                              subtitle: Text(
                                'exploreAggressiveModeDescription'.tr(),
                              ),
                              value: value,
                              onChanged: (value) {
                                handleAggressiveChange.call(value ?? true);
                              },
                            );
                          },
                        ),
                      ),
                      if (modeValue == 'personalized') ...[
                        const Gap(16),
                        Container(
                          decoration: BoxDecoration(
                            border: BoxBorder.all(
                              color: Theme.of(context).colorScheme.outline,
                              width: 1 / MediaQuery.devicePixelRatioOf(context),
                            ),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(12),
                            ),
                          ),
                          child: ListTile(
                            title: Text('exploreDiscoveryProfile'.tr()),
                            subtitle: Text(
                              'exploreDiscoveryProfileDescription'.tr(),
                            ),
                            trailing: const Icon(Symbols.chevron_right),
                            onTap: () => showDiscoveryProfileSheet(context),
                            contentPadding: const EdgeInsets.only(
                              left: 16,
                              right: 28,
                            ),
                          ),
                        ),
                      ],
                      const Gap(16),
                      Container(
                        decoration: BoxDecoration(
                          border: BoxBorder.all(
                            color: Theme.of(context).colorScheme.outline,
                            width: 1 / MediaQuery.devicePixelRatioOf(context),
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(12),
                          ),
                        ),
                        child: PostSubscriptionFilterWidget(
                          initialSelectedPublishers: selectedPublishers.value,
                          initialSelectedCategories: selectedCategories.value,
                          initialSelectedTags: selectedTags.value,
                          onSelectedPublishersChanged: (names) {
                            selectedPublishers.value = names;
                            appSettingsNotifier.setExploreSettings(
                              exploreSettings.copyWith(
                                selectedPublisherNames: names,
                              ),
                            );
                          },
                          onSelectedCategoriesChanged: (ids) {
                            selectedCategories.value = ids;
                            appSettingsNotifier.setExploreSettings(
                              exploreSettings.copyWith(
                                selectedCategoryIds: ids,
                              ),
                            );
                          },
                          onSelectedTagsChanged: (ids) {
                            selectedTags.value = ids;
                            appSettingsNotifier.setExploreSettings(
                              exploreSettings.copyWith(selectedTagIds: ids),
                            );
                          },
                        ),
                      ),
                      const Gap(32),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  SliverAppBar _buildExploreSliverAppBar({
    required BuildContext context,
    required WidgetRef ref,
    required TabController filterTabController,
    required bool hasSubscriptionFiltersApplied,
    required void Function(String?) handleFilterChange,
    required ValueNotifier<List<String>> selectedPublishers,
    required ValueNotifier<List<String>> selectedCategories,
    required ValueNotifier<List<String>> selectedTags,
    required ValueNotifier<bool> currentAggressive,
    required ValueNotifier<String?> currentFilter,
    required void Function(bool) handleAggressiveChange,
    required ValueNotifier<String> currentMode,
    required void Function(String?) handleModeChange,
    required ExploreSettings exploreSettings,
    required AppSettingsNotifier appSettingsNotifier,
    required bool isWide,
  }) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      automaticallyImplyActions: false,
      flexibleSpace:
          Row(
            children: [
              PopupMenuButton<_ExploreAction>(
                icon: Icon(
                  Symbols.widgets,
                  color: Theme.of(context).appBarTheme.foregroundColor,
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _ExploreAction.articles,
                    child: Row(
                      children: [
                        Icon(
                          Symbols.auto_stories,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const Gap(12),
                        Text('webArticlesStand').tr(),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: _ExploreAction.categories,
                    child: Row(
                      children: [
                        Icon(
                          Symbols.category,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const Gap(12),
                        Text('categoriesAndTags').tr(),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: _ExploreAction.shuffle,
                    child: Row(
                      children: [
                        Icon(
                          Symbols.shuffle,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const Gap(12),
                        Text('postShuffle').tr(),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: _ExploreAction.footprints,
                    child: Row(
                      children: [
                        Icon(
                          Symbols.footprint,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const Gap(12),
                        Text('browseFootprints').tr(),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case _ExploreAction.articles:
                      context.router.push(const ArticleStandRoute());
                      break;
                    case _ExploreAction.categories:
                      context.router.push(PostCategoriesListRoute());
                      break;
                    case _ExploreAction.shuffle:
                      context.router.push(const PostShuffleRoute());
                      break;
                    case _ExploreAction.footprints:
                      context.router.push(const BookmarksRoute());
                      break;
                    default:
                      break;
                  }
                },
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  context.router.push(UniversalSearchRoute());
                },
                icon: Icon(
                  Symbols.search,
                  color: Theme.of(context).appBarTheme.foregroundColor,
                ),
                tooltip: 'search'.tr(),
              ),
            ],
          ).padding(
            horizontal: 12,
            bottom: 8,
            top: MediaQuery.paddingOf(context).top + 8,
          ),
      title: SvgPicture.asset(
        'assets/icons/icon-outline.svg',
        color: Theme.of(context).appBarTheme.foregroundColor,
        width: 32,
        height: 32,
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Row(
          children: [
            Expanded(
              child: IgnorePointer(
                ignoring: hasSubscriptionFiltersApplied,
                child: TabBar(
                  indicatorColor: Theme.of(context).appBarTheme.foregroundColor,
                  controller: filterTabController,
                  dividerHeight: 0,
                  onTap: hasSubscriptionFiltersApplied
                      ? null
                      : (index) {
                          final filter = switch (index) {
                            1 => 'subscriptions',
                            2 => 'friends',
                            _ => null,
                          };
                          handleFilterChange(filter);
                        },
                  tabs: [
                    Tab(
                      child: Row(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Symbols.explore,
                            size: 18,
                            fill: filterTabController.index == 0 ? 1 : 0,
                            color: Theme.of(
                              context,
                            ).appBarTheme.foregroundColor,
                          ),
                          Flexible(
                            child: Text(
                              'explore'.tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).appBarTheme.foregroundColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Symbols.subscriptions,
                            size: 18,
                            fill: filterTabController.index == 1 ? 1 : 0,
                            color: Theme.of(
                              context,
                            ).appBarTheme.foregroundColor,
                          ),
                          Flexible(
                            child: Text(
                              'exploreFilterSubscriptions'.tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).appBarTheme.foregroundColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Symbols.people,
                            size: 18,
                            fill: filterTabController.index == 2 ? 1 : 0,
                            color: Theme.of(
                              context,
                            ).appBarTheme.foregroundColor,
                          ),
                          Flexible(
                            child: Text(
                              'exploreFilterFriends'.tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).appBarTheme.foregroundColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                onPressed: () => _showAlgorithmConfigSheet(
                  context,
                  selectedPublishers,
                  selectedCategories,
                  selectedTags,
                  currentAggressive,
                  currentFilter,
                  handleFilterChange,
                  handleAggressiveChange,
                  currentMode,
                  handleModeChange,
                  exploreSettings,
                  appSettingsNotifier,
                  isWide: isWide,
                ),
                icon: Icon(
                  Symbols.tune,
                  color: Theme.of(context).appBarTheme.foregroundColor,
                ),
                tooltip: 'settings'.tr(),
              ),
            ),
          ],
        ),
      ),
      floating: true,
      snap: true,
    );
  }

  Widget _buildActivityList(
    BuildContext context,
    WidgetRef ref, {
    void Function(String)? onPostTap,
  }) {
    final isWide = isWideScreen(context);

    return PaginationWidget(
      provider: activityListProvider,
      notifier: activityListProvider.notifier,
      isRefreshable: false,
      isSliver: true,
      footerSkeletonChild: const SizedBox(
        height: 64,
        child: Center(child: ConfuseSpinner(size: 40, speed: 6)),
      ),
      contentBuilder: (data, footer) => _ActivityListView(
        data: data,
        isWide: isWide,
        footer: footer,
        onPostTap: onPostTap,
      ),
    );
  }

  Widget _buildPostList(
    BuildContext context,
    WidgetRef ref,
    List<String> selectedPublishers,
    List<String> selectedCategories,
    List<String> selectedTags, {
    void Function(String)? onPostTap,
  }) {
    return SliverPostList(
      queryKey: 'explore_filtered',
      query: PostListQuery(
        publishers: selectedPublishers,
        categories: selectedCategories,
        tags: selectedTags,
      ),
      padding: EdgeInsets.zero,
      itemPadding: const EdgeInsets.only(bottom: 8),
      onPostTap: onPostTap,
    );
  }

  Widget _buildNarrowBodySliver(
    BuildContext context,
    WidgetRef ref,
    TabController filterTabController,
    ValueNotifier<List<String>> selectedPublishers,
    ValueNotifier<List<String>> selectedCategoryIds,
    ValueNotifier<List<String>> selectedTagIds,
    ValueNotifier<String> currentMode,
    void Function(String?) handleModeChange,
    bool hasSubscriptionFiltersApplied,
    void Function(String?) handleFilterChange,
    ValueNotifier<bool> currentAggressive,
    ValueNotifier<String?> currentFilter,
    void Function(bool) handleAggressiveChange,
    ExploreSettings exploreSettings,
    AppSettingsNotifier appSettingsNotifier,
  ) {
    final usePostList =
        selectedPublishers.value.isNotEmpty ||
        selectedCategoryIds.value.isNotEmpty ||
        selectedTagIds.value.isNotEmpty;
    final activityState = ref.watch(activityListProvider);
    final isListInitialLoading =
        (activityState.isLoading || activityState.value?.isLoading == true) &&
        (activityState.value?.items.isEmpty ?? true);

    final notifier = ref.watch(activityListProvider.notifier);

    return ExtendedRefreshIndicator(
      onRefresh: usePostList ? () async {} : notifier.refresh,
      child: CustomScrollView(
        slivers: [
          _buildExploreSliverAppBar(
            context: context,
            ref: ref,
            filterTabController: filterTabController,
            hasSubscriptionFiltersApplied: hasSubscriptionFiltersApplied,
            handleFilterChange: handleFilterChange,
            selectedPublishers: selectedPublishers,
            selectedCategories: selectedCategoryIds,
            selectedTags: selectedTagIds,
            currentAggressive: currentAggressive,
            currentFilter: currentFilter,
            handleAggressiveChange: handleAggressiveChange,
            currentMode: currentMode,
            handleModeChange: handleModeChange,
            exploreSettings: exploreSettings,
            appSettingsNotifier: appSettingsNotifier,
            isWide: false,
          ),
          if (usePostList) ...[
            _buildPostList(
              context,
              ref,
              selectedPublishers.value,
              selectedCategoryIds.value,
              selectedTagIds.value,
            ),
          ] else if (isListInitialLoading)
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
            _buildActivityList(context, ref),
        ],
      ),
    );
  }

  Widget _buildWideBody(
    BuildContext context,
    WidgetRef ref,
    TabController filterTabController,
    ValueNotifier<String?> currentFilter,
    ValueNotifier<String> currentMode,
    ValueNotifier<List<String>> selectedPublishers,
    ValueNotifier<List<String>> selectedCategories,
    ValueNotifier<List<String>> selectedTags,
    ValueNotifier<bool> currentAggressive,
    void Function(String?) handleFilterChange,
    void Function(String?) handleModeChange,
    void Function(bool) handleAggressiveChange,
    bool hasSubscriptionFiltersApplied,
    ExploreSettings exploreSettings,
    AppSettingsNotifier appSettingsNotifier,
    ValueNotifier<String?> selectedPostId,
    ValueNotifier<bool> isDetailExpanded,
    ComposeRequest? composeRequest,
  ) {
    final usePostList =
        selectedPublishers.value.isNotEmpty ||
        selectedCategories.value.isNotEmpty ||
        selectedTags.value.isNotEmpty;

    final notifier = usePostList
        ? null
        : ref.watch(activityListProvider.notifier);

    final activityState = ref.watch(activityListProvider);
    final isListInitialLoading =
        (activityState.isLoading || activityState.value?.isLoading == true) &&
        (activityState.value?.items.isEmpty ?? true);

    const timelineContentMaxWidth = 720.0;

    void handlePostTap(String postId) {
      if (composeRequest != null) {
        ref.read(composeRequestProvider.notifier).setRequest(null);
      }

      if (selectedPostId.value == postId) {
        context.router.push(PostDetailRoute(id: postId));
      } else {
        selectedPostId.value = postId;
        isDetailExpanded.value = false;
      }
    }

    final postListWidget = Card(
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.fromLTRB(12, 12, 0, 0),
      child: ExtendedRefreshIndicator(
        onRefresh: () async {
          if (notifier != null) {
            await notifier.refresh();
          }
        },
        child: CustomScrollView(
          slivers: [
            _buildExploreSliverAppBar(
              context: context,
              ref: ref,
              filterTabController: filterTabController,
              hasSubscriptionFiltersApplied: hasSubscriptionFiltersApplied,
              handleFilterChange: handleFilterChange,
              selectedPublishers: selectedPublishers,
              selectedCategories: selectedCategories,
              selectedTags: selectedTags,
              currentAggressive: currentAggressive,
              currentFilter: currentFilter,
              handleAggressiveChange: handleAggressiveChange,
              currentMode: currentMode,
              handleModeChange: handleModeChange,
              exploreSettings: exploreSettings,
              appSettingsNotifier: appSettingsNotifier,
              isWide: true,
            ),
            if (usePostList) ...[
              _buildPostList(
                context,
                ref,
                selectedPublishers.value,
                selectedCategories.value,
                selectedTags.value,
                onPostTap: handlePostTap,
              ),
            ] else if (isListInitialLoading)
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
              _buildActivityList(context, ref, onPostTap: handlePostTap),
          ],
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasCompose = composeRequest != null;
        final hasSelection = selectedPostId.value != null && !hasCompose;
        final totalWidth = constraints.maxWidth;
        final listWidth = (hasCompose || hasSelection)
            ? (totalWidth - 28) / 2
            : (timelineContentMaxWidth < totalWidth
                  ? timelineContentMaxWidth
                  : totalWidth);
        final detailWidth = (hasCompose || hasSelection)
            ? (totalWidth - 28) / 2
            : 0.0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              width: listWidth,
              child: postListWidget,
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              width: (hasCompose || hasSelection) ? 16 : 0,
              child: const SizedBox.shrink(),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              width: detailWidth,
              child: hasCompose
                  ? Container(
                      margin: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                      child: ComposeSidebar(
                        request: composeRequest,
                        onClose: () {
                          ref
                              .read(composeRequestProvider.notifier)
                              .setRequest(null);
                        },
                      ),
                    )
                  : hasSelection
                  ? Container(
                      margin: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _TimelineDetailPane(
                        postId: selectedPostId.value!,
                        isExpanded: false,
                        onExpandToggle: () {
                          context.router.push(
                            PostDetailRoute(id: selectedPostId.value!),
                          );
                        },
                        onClose: () {
                          selectedPostId.value = null;
                        },
                        onPostTap: handlePostTap,
                      ),
                    )
                  : null,
            ),
          ],
        );
      },
    );
  }
}

class _ExploreFilterToolbar extends StatelessWidget {
  final String? currentFilter;
  final String currentMode;
  final void Function(String?) onFilterChange;
  final void Function(String?) onModeChange;
  final VoidCallback? onOpenSubscriptionFilters;
  final bool disableFilterSwitching;
  final bool hideSubscriptionsTab;

  const _ExploreFilterToolbar({
    required this.currentFilter,
    required this.currentMode,
    required this.onFilterChange,
    required this.onModeChange,
    required this.onOpenSubscriptionFilters,
    required this.disableFilterSwitching,
    this.hideSubscriptionsTab = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondarySurfaceColor = theme.colorScheme.surfaceContainerHighest
        .withOpacity(0.55);
    final rowTwo = currentFilter == null
        ? _RankingToolbar(
            currentMode: currentMode,
            onModeChange: onModeChange,
            backgroundColor: secondarySurfaceColor,
          )
        : null;
    final selectedIndex = switch (currentFilter) {
      'subscriptions' => 1,
      'friends' => 2,
      _ => 0,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.55),
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Stack(
                      children: [
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          alignment: switch (selectedIndex) {
                            1 => Alignment.center,
                            2 => Alignment.centerRight,
                            _ => Alignment.centerLeft,
                          },
                          child: FractionallySizedBox(
                            widthFactor: 1 / 3,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 1,
                              ),
                              child: Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _FilterToggleButton(
                                label: 'explore'.tr(),
                                icon: Symbols.explore,
                                isSelected: currentFilter == null,
                                onTap: disableFilterSwitching
                                    ? null
                                    : () => onFilterChange(null),
                              ),
                            ),
                            Expanded(
                              child: _FilterToggleButton(
                                label: 'exploreFilterSubscriptions'.tr(),
                                icon: Symbols.subscriptions,
                                isSelected: currentFilter == 'subscriptions',
                                onTap: disableFilterSwitching
                                    ? null
                                    : () => onFilterChange('subscriptions'),
                              ),
                            ),
                            Expanded(
                              child: _FilterToggleButton(
                                label: 'exploreFilterFriends'.tr(),
                                icon: Symbols.people,
                                isSelected: currentFilter == 'friends',
                                onTap: disableFilterSwitching
                                    ? null
                                    : () => onFilterChange('friends'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(8),
                PopupMenuButton<_ExploreAction>(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _ExploreAction.search,
                      child: Row(
                        children: [
                          const Icon(Symbols.search),
                          const Gap(12),
                          Text('search').tr(),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: _ExploreAction.articles,
                      child: Row(
                        children: [
                          const Icon(Symbols.auto_stories),
                          const Gap(12),
                          Text('webArticlesStand').tr(),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: _ExploreAction.categories,
                      child: Row(
                        children: [
                          const Icon(Symbols.category),
                          const Gap(12),
                          Text('categoriesAndTags').tr(),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: _ExploreAction.shuffle,
                      child: Row(
                        children: [
                          const Icon(Symbols.shuffle),
                          const Gap(12),
                          Text('postShuffle').tr(),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: _ExploreAction.footprints,
                      child: Row(
                        children: [
                          const Icon(Symbols.footprint),
                          const Gap(12),
                          Text('browseFootprints').tr(),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case _ExploreAction.articles:
                        context.router.push(const ArticleStandRoute());
                        break;
                      case _ExploreAction.search:
                        context.router.push(UniversalSearchRoute());
                        break;
                      case _ExploreAction.categories:
                        context.router.push(PostCategoriesListRoute());
                        break;
                      case _ExploreAction.shuffle:
                        context.router.push(const PostShuffleRoute());
                        break;
                      case _ExploreAction.footprints:
                        context.router.push(const BookmarksRoute());
                        break;
                    }
                  },
                  icon: const Icon(Symbols.action_key),
                  tooltip: 'search'.tr(),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: rowTwo == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeOutCubic,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SizeTransition(
                              sizeFactor: animation,
                              axisAlignment: -1,
                              child: child,
                            ),
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey(currentFilter ?? 'explore'),
                          child: rowTwo,
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const _FilterToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final disabled = onTap == null;
    final foreground = disabled
        ? colorScheme.onSurface.withOpacity(0.38)
        : isSelected
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 10 : 8,
              vertical: isSelected ? 11 : 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    icon,
                    key: ValueKey('${label}_$isSelected'),
                    size: 18,
                    color: foreground,
                    fill: isSelected ? 1 : 0,
                  ),
                ),
                const Gap(6),
                Flexible(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    style: theme.textTheme.labelMedium!.copyWith(
                      color: foreground,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _ExploreAction { articles, search, categories, shuffle, footprints }

class _RankingToolbar extends StatelessWidget {
  final String currentMode;
  final void Function(String?) onModeChange;
  final Color backgroundColor;

  const _RankingToolbar({
    required this.currentMode,
    required this.onModeChange,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      key: const ValueKey('ranking_toolbar'),
      color: backgroundColor,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Row(
          children: [
            Icon(
              Symbols.tune,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const Gap(10),
            Expanded(
              child: Text(
                'explorePreferred'.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            _TimelineModeDropdown(value: currentMode, onChanged: onModeChange),
          ],
        ),
      ),
    );
  }
}

class _TimelineModeDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _TimelineModeDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final effectiveForegroundColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          iconEnabledColor: effectiveForegroundColor,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: effectiveForegroundColor),
          borderRadius: BorderRadius.circular(12),

          onChanged: onChanged,
          items: [
            DropdownMenuItem(
              value: 'personalized',
              child: Text('exploreModePersonalized'.tr()),
            ),
            DropdownMenuItem(value: 'top', child: Text('exploreModeTop'.tr())),
            DropdownMenuItem(
              value: 'latest',
              child: Text('exploreModeLatest'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoveryActivityItem extends ConsumerWidget {
  final Map<String, dynamic> data;
  final String eventType;
  final String resourceIdentifier;

  const _DiscoveryActivityItem({
    required this.data,
    required this.eventType,
    required this.resourceIdentifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);
    final currentUserId = userInfo.value?.id;
    final isAdmin = userInfo.value?.isSuperuser == true;

    final items =
        (data['items'] as List?)?.whereType<Map>().toList() ?? const [];
    if (items.isEmpty) return const SizedBox.shrink();

    final type = _resolveDiscoveryType(
      eventType: eventType,
      resourceIdentifier: resourceIdentifier,
      data: data,
      items: items,
    );
    final title = _resolveDiscoveryTitle(type, data);
    final isSingleSuggestion = type != 'post' && items.length == 1;

    var flexWeights = isWideScreen(context) ? <int>[3, 2, 1] : <int>[4, 1];
    if (type == 'post') flexWeights = <int>[3, 2];

    final height = switch (type) {
      'post' => 280.0,
      _ when isSingleSuggestion => null,
      _ => 180.0,
    };

    final contentWidget = switch (type) {
      'post' => SuperListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const Gap(12),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        itemBuilder: (context, index) {
          final item = Map<String, dynamic>.from(items[index]);
          final itemData = _extractDiscoveryItemData(item);
          final post = SnPost.fromJson(itemData);
          final rank = item['rank'] as String?;

          return Container(
            width: 320,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1 / MediaQuery.of(context).devicePixelRatio,
                color: Theme.of(context).dividerColor.withOpacity(0.5),
              ),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    child: SingleChildScrollView(
                      child: PostActionableItem(item: post, isCompact: true),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Row(
                    children: [
                      if (rank == 'highest')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'discoveryTopPick'.tr(),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                          ),
                        ),
                      if (rank == 'lowest')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'discoveryNotRecommended'.tr(),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                                ),
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: DiscoveryFeedbackWidget(
                      kind: 'post',
                      referenceId: post.id,
                      showNotInterested: false,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      _ when isSingleSuggestion => () {
        final item = Map<String, dynamic>.from(items.single);
        final itemData = _extractDiscoveryItemData(item);
        final reasons =
            (item['reasons'] as List?)?.whereType<String>().toList() ??
            const <String>[];
        if (reasons.isEmpty) reasons.add('discoverySuggestionReason'.tr());
        final rank = item['score'] is num
            ? (item['score'] as num).toDouble()
            : null;

        final itemOwnerId = switch (type) {
          'post' => (itemData['author'] as Map?)?['id'] as String?,
          'account' => itemData['id'] as String?,
          'publisher' => itemData['id'] as String?,
          'realm' => itemData['id'] as String?,
          _ => null,
        };
        final isCurrentUserItem =
            currentUserId != null && itemOwnerId == currentUserId;
        final shouldShowRank = rank != null && isAdmin && !isCurrentUserItem;

        return Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDiscoveryCard(type, itemData, maxWidth: double.infinity),
            if (reasons.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    const Icon(Symbols.mindfulness, size: 16),
                    for (final reason in reasons.take(3))
                      Text(
                        reason,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ),
            if (shouldShowRank)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  spacing: 8,
                  children: [
                    const Icon(Symbols.rule, size: 16),
                    Text(
                      'discoveryRank'.tr(args: ['$rank']),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      }(),
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
            () {
              final itemMap = Map<String, dynamic>.from(item);
              final itemData = _extractDiscoveryItemData(itemMap);
              return _buildDiscoveryCard(type, itemData);
            }(),
        ],
      ),
    };

    return Container(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(switch (type) {
                'realm' => Symbols.public,
                'publisher' => Symbols.account_circle,
                'account' => Symbols.person,
                'article' => Symbols.auto_stories,
                'post' => Symbols.shuffle,
                _ => Symbols.explore,
              }, size: 19),
              const Gap(8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ).padding(top: 1),
            ],
          ).padding(horizontal: 20, top: 8, bottom: 4),
          SizedBox(height: height, child: contentWidget).padding(bottom: 8),
        ],
      ),
    );
  }

  Widget _buildDiscoveryCard(
    String type,
    Map<String, dynamic> itemData, {
    double? maxWidth,
  }) {
    return switch (type) {
      'realm' => RealmDiscoveryCard(
        realm: SnRealm.fromJson(itemData),
        maxWidth: maxWidth ?? 280,
      ),
      'publisher' => PublisherDiscoveryCard(
        publisher: SnPublisher.fromJson(itemData),
        maxWidth: maxWidth ?? 280,
      ),
      'account' => AccountDiscoveryCard(
        account: SnAccount.fromJson(itemData),
        maxWidth: maxWidth ?? 280,
      ),
      'article' => WebArticleDiscoveryCard(
        article: SnWebArticle.fromJson(itemData),
        maxWidth: maxWidth ?? 280,
      ),
      _ => const SizedBox.shrink(),
    };
  }
}

String _resolveDiscoveryType({
  required String eventType,
  required String resourceIdentifier,
  required Map<String, dynamic> data,
  required List<Map> items,
}) {
  if (eventType == 'discovery.v2') {
    final kind = data['kind'];
    if (kind is String && kind.isNotEmpty) return kind;

    final parts = resourceIdentifier.split(':');
    if (parts.length > 1 && parts.last.isNotEmpty) return parts.last;
  }

  final itemType = items.firstOrNull?['type'];
  if (itemType is String && itemType.isNotEmpty) return itemType;

  final fallbackKind = data['kind'];
  if (fallbackKind is String && fallbackKind.isNotEmpty) return fallbackKind;

  return 'unknown';
}

String _resolveDiscoveryTitle(String type, Map<String, dynamic> data) {
  return (switch (type) {
    'realm' => 'suggestedRealm',
    'publisher' => 'suggestedPublisher',
    'account' => 'suggestedPeople',
    'article' => 'discoverWebArticles',
    'post' => 'discoverShuffledPost',
    _ => 'unknown',
  }).tr();
}

Map<String, dynamic> _extractDiscoveryItemData(Map<String, dynamic> item) {
  final raw = item['data'];
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return item;
}

class AccountDiscoveryCard extends ConsumerWidget {
  final SnAccount account;
  final double? maxWidth;
  final bool showFeedback;

  const AccountDiscoveryCard({
    super.key,
    required this.account,
    this.maxWidth,
    this.showFeedback = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final background = account.profile.background;
    final imageWidget = background != null
        ? CloudImageWidget(file: background, fit: BoxFit.cover)
        : ColoredBox(color: Theme.of(context).colorScheme.secondaryContainer);

    final card = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.zero,
      ),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          context.router.push(AccountProfileRoute(name: account.name));
        },
        child: AspectRatio(
          aspectRatio: 16 / 7,
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageWidget,
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ProfilePictureWidget(
                          file: account.profile.picture,
                          radius: 12,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        account.nick,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '@${account.name}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              if (showFeedback)
                Positioned(
                  top: 8,
                  right: 8,
                  child: DiscoveryFeedbackWidget(
                    kind: 'account',
                    referenceId: account.id,
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: card,
    );
  }
}

class _TimelineDetailPane extends HookConsumerWidget {
  final String postId;
  final bool isExpanded;
  final VoidCallback onExpandToggle;
  final VoidCallback onClose;
  final void Function(String)? onPostTap;

  const _TimelineDetailPane({
    required this.postId,
    required this.isExpanded,
    required this.onExpandToggle,
    required this.onClose,
    this.onPostTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postState = ref.watch(postStateProvider(postId));
    final user = ref.watch(userInfoProvider);
    final translating = useState(false);
    final translatedText = useState<String?>(null);
    final currentLanguage = context.locale.toString();

    Future<void> translatePost(String text) async {
      if (translatedText.value != null) {
        translatedText.value = null;
        return;
      }
      if (translating.value) return;
      translating.value = true;
      try {
        final result = await ref.read(
          translateStringProvider(
            TranslateQuery(text: text, lang: currentLanguage.substring(0, 2)),
          ).future,
        );
        translatedText.value = result;
      } catch (err) {
        showErrorAlert(err);
      } finally {
        translating.value = false;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.18),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withOpacity(0.12),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Tooltip(
                  message: isExpanded
                      ? 'restoreSplitView'.tr()
                      : 'expandPostDetails'.tr(),
                  child: IconButton(
                    onPressed: onExpandToggle,
                    icon: Icon(
                      isExpanded ? Symbols.fullscreen_exit : Symbols.fullscreen,
                      size: 20,
                    ),
                    style: IconButton.styleFrom(
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const Spacer(),
                Tooltip(
                  message: 'closePostDetails'.tr(),
                  child: IconButton(
                    onPressed: onClose,
                    icon: Icon(Symbols.close, size: 20),
                    style: IconButton.styleFrom(
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: postState.when(
                data: (post) {
                  if (post == null) {
                    return Center(
                      key: const ValueKey('error'),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Symbols.error_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const Gap(12),
                          Text(
                            'postNotFound'.tr(),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  return Stack(
                    key: ValueKey(postId),
                    children: [
                      ExtendedRefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(postProvider(postId));
                          ref
                              .read(postRepliesProvider(postId).notifier)
                              .refresh();
                        },
                        child: CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: PostItem(
                                item: post,
                                isFullPost: true,
                                isEmbedReply: false,
                                isTranslatable: false,
                                textScale: post.type == 1 ? 1.1 : 1.0,
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  12,
                                  12,
                                  0,
                                ),
                                onUpdate: (newPost) {
                                  ref
                                      .read(postStateProvider(postId).notifier)
                                      .updatePost(newPost);
                                },
                                onPostTap: onPostTap,
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: PostActionButtons(
                                post: post,
                                renderingPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                onRefresh: () {
                                  ref.invalidate(postProvider(postId));
                                  ref
                                      .read(
                                        postRepliesProvider(postId).notifier,
                                      )
                                      .refresh();
                                },
                                onUpdate: (newPost) {
                                  ref
                                      .read(postStateProvider(postId).notifier)
                                      .updatePost(newPost);
                                },
                                onTranslate: translatePost,
                              ).padding(horizontal: 12, vertical: 8),
                            ),
                            if (translatedText.value != null ||
                                translating.value)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12 + 16,
                                  ),
                                  child: buildPostTranslationSection(
                                    context: context,
                                    item: post,
                                    isTextSelectable: true,
                                    textScale: post.type == 1 ? 1.1 : 1.0,
                                    translatedText: translatedText.value,
                                    isTranslating: translating.value,
                                    onTranslate: () =>
                                        translatePost(post.content ?? ''),
                                    showTranslateButton: false,
                                  ),
                                ),
                              ),
                            if (post.realm != null)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    0,
                                    24,
                                    8,
                                  ),
                                  child: PostRealmBadge(realm: post.realm!),
                                ),
                              ),
                            if (post.publisherCollections.isNotEmpty)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    24,
                                    post.realm != null ? 0 : 8,
                                    24,
                                    8,
                                  ),
                                  child: PostCollectionNavigation(post: post),
                                ),
                              ),
                            DefaultTabController(
                              length: 4,
                              child: PostInteractionsSlivers(
                                postId: postId,
                                maxWidth: 720,
                              ),
                            ),
                            SliverGap(
                              MediaQuery.of(context).padding.bottom + 80,
                            ),
                          ],
                        ),
                      ),
                      if (user.value != null)
                        Positioned(
                          bottom: 16 + MediaQuery.of(context).padding.bottom,
                          left: 16,
                          right: 16,
                          child: PostQuickReply(
                            parent: post,
                            onPosted: () {
                              ref
                                  .read(postRepliesProvider(postId).notifier)
                                  .refresh();
                            },
                          ),
                        ),
                    ],
                  );
                },
                loading: () => Center(
                  key: const ValueKey('loading'),
                  child: ConfuseSpinner(
                    speed: 7,
                    size: 48,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withOpacity(0.65),
                  ),
                ),
                error: (error, _) => Center(
                  key: const ValueKey('error_load'),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Symbols.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const Gap(12),
                      Text(
                        'failedToLoadPost'.tr(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Gap(8),
                      TextButton(
                        onPressed: () => ref.invalidate(postProvider(postId)),
                        child: Text('retry'.tr()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityListView extends HookConsumerWidget {
  final List<SnTimelineEvent> data;
  final bool isWide;
  final Widget footer;
  final void Function(String)? onPostTap;

  const _ActivityListView({
    required this.data,
    required this.isWide,
    required this.footer,
    this.onPostTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(activityListProvider.notifier);

    return SliverList.separated(
      itemCount: data.length + 1,
      separatorBuilder: (_, _) => const Divider(height: 1),
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
            final postData = item.data!;
            final postJson = postData is Map<String, dynamic>
                ? postData
                : (postData as Map).cast<String, dynamic>();
            final post = SnPost.fromJson(postJson);

            itemWidget = PostActionableItem(
              borderRadius: 8,
              item: post,
              onRefresh: () {
                notifier.refresh();
              },
              onUpdate: (updatedPost) {
                notifier.updateOne(
                  index,
                  item.copyWith(data: updatedPost.toJson()),
                );
              },
              onTap: onPostTap != null ? () => onPostTap!(post.id) : null,
              onPostTap: onPostTap,
            );
            break;
          case 'discovery':
          case 'discovery.v2':
            itemWidget = _DiscoveryActivityItem(
              data: item.data!,
              eventType: item.type,
              resourceIdentifier: item.resourceIdentifier,
            );
            break;
          case 'presence.friend':
            final activityJson =
                (item.data as Map<String, dynamic>)['activity']
                    as Map<String, dynamic>;
            final activity = SnPresenceActivity.fromJson(activityJson);
            itemWidget = _FriendPresenceItem(activity: activity);
            break;
          default:
            itemWidget = const Placeholder();
        }

        return itemWidget;
      },
    );
  }
}

class _FriendPresenceItem extends ConsumerWidget {
  final SnPresenceActivity activity;

  const _FriendPresenceItem({required this.activity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userInfo = ref.watch(userInfoProvider);
    final currentUser = userInfo.value;
    final friendMap = ref.watch(friendAccountMapProvider);
    final account = currentUser?.id == activity.accountId
        ? currentUser
        : friendMap[activity.accountId];
    final isActive =
        activity.deletedAt == null &&
        activity.leaseExpiresAt.isAfter(DateTime.now());
    final isSpotify = activity.manualId == 'spotify';
    final isSteam = activity.manualId == 'steam';

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatarStack(theme, account, isSpotify, isSteam),
          if (_hasArtwork(activity) && !isSteam)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: _resolvePresenceArtworkUrl(
                  ref,
                  activity.largeImage ?? activity.smallImage!,
                ),
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (account != null) ...[
                  Row(
                    children: [
                      Flexible(
                        child: AccountName(
                          account: account,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                          hideOverlay: true,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        '·',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(
                            0.5,
                          ),
                        ),
                      ),
                      const Gap(4),
                      Text(
                        activity.createdAt.toLocal().formatRelative(context),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(
                            0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                Row(
                  spacing: 6,
                  children: [
                    Flexible(
                      child: Text(
                        activity.title ?? 'unknown'.tr(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (activity.titleUrl != null &&
                        activity.titleUrl!.isNotEmpty)
                      GestureDetector(
                        onTap: () => launchUrlString(activity.titleUrl!),
                        child: Icon(
                          Symbols.launch_rounded,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                if (activity.subtitle != null &&
                    activity.subtitle!.isNotEmpty) ...[
                  const Gap(2),
                  Row(
                    spacing: 4,
                    children: [
                      Flexible(
                        child: Text(
                          activity.subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (activity.subtitleUrl != null &&
                          activity.subtitleUrl!.isNotEmpty)
                        GestureDetector(
                          onTap: () => launchUrlString(activity.subtitleUrl!),
                          child: Icon(
                            Symbols.launch_rounded,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ],
                if (activity.caption != null &&
                    activity.caption!.isNotEmpty) ...[
                  const Gap(2),
                  Text(
                    activity.caption!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const Gap(6),
                Row(
                  spacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        kPresenceActivityTypes[activity.type],
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                      ).tr(),
                    ),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'presenceOngoing',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ).tr(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (account != null) {
      return AccountPfcRegion(uname: account.name, child: content);
    }
    return content;
  }

  Widget _buildAvatarStack(
    ThemeData theme,
    SnAccount? account,
    bool isSpotify,
    bool isSteam,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (account != null)
          ProfilePictureWidget(file: account.profile.picture, radius: 18)
        else
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _getActivityColor(activity.type).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              kPresenceActivityIcons[activity.type],
              size: 18,
              color: _getActivityColor(activity.type),
            ),
          ),
        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: _getActivityColor(activity.type),
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.surface, width: 2),
            ),
            child: Icon(
              kPresenceActivityIcons[activity.type],
              size: 10,
              color: Colors.white,
            ),
          ),
        ),
        if (isSpotify)
          Positioned(
            right: -6,
            top: -2,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Symbols.music_note,
                size: 8,
                color: Colors.white,
              ),
            ),
          ),
        if (isSteam)
          Positioned(
            right: -6,
            top: -2,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: Color(0xFF1B2838),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Symbols.sports_esports,
                size: 8,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  static Color _getActivityColor(int type) {
    switch (type) {
      case 1:
        return Colors.purple;
      case 2:
        return Colors.green;
      case 3:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  static bool _hasArtwork(SnPresenceActivity activity) {
    return activity.largeImage != null || activity.smallImage != null;
  }
}
