import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:island/posts/screens/compose_post.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/pods/post_list.dart';
import 'package:island/posts/widgets/compose/post_featured.dart';
import 'package:island/posts/screens/compose_blog.dart';
import 'package:island/posts/compose.dart';
import 'package:island/posts/widgets/compose/filters/post_subscription_filter.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/screens/post_detail.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:island/posts/widgets/publishers/publisher_card.dart';
import 'package:island/posts/posts_pod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/realms/widgets/realm_card.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/page_app_bar.dart';
import 'package:island/shared/widgets/confuse_spinner.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/discovery/widgets/discovery_feedback_widget.dart';
import 'package:island/discovery/widgets/explore_card.dart';
import 'package:island/discovery/widgets/explore_config_sheet.dart';
import 'package:island/discovery/widgets/pill_app_bar.dart';
import 'package:island/discovery/widgets/friend_presence_strip.dart';
import 'package:island/discovery/widgets/friend_presence_widgets.dart';
import 'package:island/discovery/widgets/subscribed_publishers_strip.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:island/posts/widgets/compose/post_list.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:island/core/config.dart';
import 'package:island/core/theme.dart';

@RoutePage()
class ExploreScreen extends HookConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The timeline algorithm (section, ranking, aggressive mode) is configured
    // in the app settings screen and mirrored onto the timeline by the activity
    // list notifier; this screen only renders what it selects.
    final exploreSettings = ref.watch(appSettingsProvider).exploreSettings;
    // Publisher picks are session-scoped; only category/tag filters persist.
    final selectedPublisherNames = useState<List<String>>(<String>[]);
    // The explore section is a single persisted choice (null / subscriptions /
    // friends). The settings screen can change it out from under the page, so
    // it is read straight from the persisted state on every build.

    void handleFilterChange(String? filter) {
      ref
          .read(appSettingsProvider.notifier)
          .setExploreSettings(exploreSettings.copyWith(filter: filter));
    }

    // Selecting publishers is session-scoped and supersedes category/tag
    // filters, mirroring the subscription filter sheet behavior. Deselecting
    // every publisher leaves the persisted category/tag filters untouched.
    void handlePublishersChanged(List<String> names) {
      selectedPublisherNames.value = names;
      if (names.isEmpty) return;
      ref
          .read(appSettingsProvider.notifier)
          .setExploreSettings(
            exploreSettings.copyWith(
              selectedCategoryIds: const <String>[],
              selectedTagIds: const <String>[],
            ),
          );
    }

    // Drives the header's glass on a 0..1 scale: 0 the transparent bar at the
    // top of the feed, 1 the fully surfaced pill after scrolling. A notifier
    // rather than setState so a scroll tick repaints the header only, never the
    // whole timeline.
    final fade = useValueNotifier(0.0);

    final isWide = isWideScreen(context);

    // The wide layout's second column: the id of the post open beside the
    // feed, or null while the feed owns the whole window.
    final detailPostId = useState<String?>(null);
    // Authoring beside the feed: while set, the composer replaces the right
    // pane instead of pushing a full-page route, so a reply keeps the timeline
    // in view. A record, not a widget, so a scroll tick on the feed never
    // rebuilds the composer and drops its focus or half-typed text.
    final composeRequest =
        useState<
          ({
            SnPost? originalPost,
            PostComposeInitialState? initialState,
            SnPost? replyingTo,
            SnPost? forwardingTo,
            SnPost? chainingTo,
          })?
        >(null);

    // The pending `PostComposeScreen.show` future, so closing the pane
    // resolves the awaiting caller exactly as a popped route would.
    final composeResult = useRef<Completer<bool?>?>(null);

    useEffect(() {
      return () {
        final completer = composeResult.value;
        if (completer != null && !completer.isCompleted) {
          completer.complete(null);
        }
      };
    }, const []);

    void closeComposePane(bool submitted) {
      composeRequest.value = null;
      final completer = composeResult.value;
      composeResult.value = null;
      if (completer != null && !completer.isCompleted) {
        completer.complete(submitted ? true : null);
      }
    }

    // The wide layout routes `PostComposeScreen.show` here, so every reply,
    // forward, chain and edit affordance on the page opens in the pane rather
    // than covering the feed. Narrow has no host, so it pushes the route.
    Future<bool?> showComposeInPane({
      SnPost? originalPost,
      PostComposeInitialState? initialState,
      SnPost? replyingTo,
      SnPost? forwardingTo,
      SnPost? chainingTo,
    }) {
      final completer = Completer<bool?>();
      final previous = composeResult.value;
      if (previous != null && !previous.isCompleted) previous.complete(null);
      composeResult.value = completer;
      composeRequest.value = (
        originalPost: originalPost,
        initialState: initialState,
        replyingTo: replyingTo,
        forwardingTo: forwardingTo,
        chainingTo: chainingTo,
      );
      // The composer owns the pane while it is open.
      detailPostId.value = null;
      return completer.future;
    }

    // Opens a post the way the wide layout wants it. Articles keep their
    // two-pane reading layout and blogs their webview page — both need the
    // whole window, so they stay full-page navigations. Every other post
    // reads in the side pane next to the feed.
    void openPost(SnPost post) {
      if (post.type == 1 || post.type == 2) {
        context.router.push(PostDetailRoute(id: post.id));
        return;
      }
      detailPostId.value = post.id;
    }

    final hasSubscriptionFiltersApplied =
        selectedPublisherNames.value.isNotEmpty ||
        exploreSettings.selectedCategoryIds.isNotEmpty ||
        exploreSettings.selectedTagIds.isNotEmpty;

    final userInfo = ref.watch(userInfoProvider);

    // The tune action lives at the trailing edge of both headers: it opens
    // the quick configuration sheet without leaving the feed.
    final configButton = _buildConfigButton(
      context,
      selectedPublisherNames: selectedPublisherNames,
    );

    final feed = _buildFeed(
      context,
      ref,
      fade: fade,
      selectedPublisherNames: selectedPublisherNames,
      onPublishersChanged: handlePublishersChanged,
      hasSubscriptionFiltersApplied: hasSubscriptionFiltersApplied,
      handleFilterChange: handleFilterChange,
      currentFilter: exploreSettings.filter,
      isWide: isWide,
      onOpenPost: isWide ? openPost : null,
      headerTrailing: configButton,
    );

    final composeFab = userInfo.value != null
        ? _buildComposeFab(context)
        : null;

    if (isWide) {
      // Two even columns around a floating detail card: the feed keeps its
      // reading measure on the left and yields half the window to the pane
      // while it is open. The pill spans only the feed's column so it never
      // floats over the pane; the feed still drives `fade`, so its rows slide
      // underneath and the surface glassies in exactly as it does on narrow.
      return AppScaffold(
        isNoBackground: false,
        appBar: null,
        floatingActionButton: composeFab,
        body: ComposePaneHost(
          show: showComposeInPane,
          child: _WideExploreLayout(
            fade: fade,
            detailPostId: detailPostId.value,
            composeRequest: composeRequest.value,
            barControls: _buildExploreBarControls(
              currentFilter: exploreSettings.filter,
              hasSubscriptionFiltersApplied: hasSubscriptionFiltersApplied,
              handleFilterChange: handleFilterChange,
            ),
            barTrailing: configButton,
            feed: feed,
            onOpenFullPage: (id) =>
                context.router.push(PostDetailRoute(id: id)),
            // Reference posts and replies tapped inside the pane swap the
            // pane's own content; only the feed's first open picks between
            // the pane and a full-page article/blog route.
            onOpenInPane: (id) => detailPostId.value = id,
            onCloseDetail: () => detailPostId.value = null,
            onCloseCompose: closeComposePane,
          ),
        ),
      );
    }

    return AppScaffold(floatingActionButton: composeFab, body: feed);
  }

  /// The compose action, shared by both layouts.
  Widget _buildComposeFab(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'explore-fab',
      child: const Icon(Symbols.create),
      onPressed: () {
        final parentContext = context;
        showModalBottomSheet(
          context: parentContext,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (sheetContext) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Gap(40),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: const Icon(Symbols.post_add_rounded),
                title: Text('postCompose'.tr()),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await PostComposeScreen.show(parentContext);
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: const Icon(Symbols.article),
                title: Text('articleCompose'.tr()),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await context.router.push(ArticleComposeRoute());
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: const Icon(Symbols.docs),
                title: Text('linkBlog'.tr()),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await BlogComposeDialog.show(parentContext);
                },
              ),
              const Gap(16),
            ],
          ),
        );
      },
    ).padding(bottom: MediaQuery.of(context).padding.bottom);
  }

  /// The header's trailing action: the quick configuration sheet.
  Widget _buildConfigButton(
    BuildContext context, {
    required ValueNotifier<List<String>> selectedPublisherNames,
  }) {
    return IconButton(
      icon: const Icon(Symbols.tune),
      tooltip: 'settings'.tr(),
      onPressed: () => showExploreConfigSheet(
        context,
        selectedPublisherNames: selectedPublisherNames,
      ),
    );
  }

  /// The content capsule's controls: the section picker, which replaced the
  /// tab strip that used to be the bar's `bottom` row.
  ///
  /// The navigation toggle is not part of this row: the header paints it as
  /// its own glass circle ([PillSplitBar]), so the capsule only holds what the
  /// page can act on. Shared by both layouts so the controls never move
  /// between them: narrow pins this row inside the feed, wide floats it over
  /// the reading column.
  Widget _buildExploreBarControls({
    required String? currentFilter,
    required bool hasSubscriptionFiltersApplied,
    required void Function(String?) handleFilterChange,
  }) {
    return _ExploreSectionButton(
      filter: currentFilter,
      hasFiltersApplied: hasSubscriptionFiltersApplied,
      onSelected: handleFilterChange,
    );
  }

  /// Header of the narrow feed: a pinned sliver inside the feed's own scroll
  /// view.
  ///
  /// The bar never moves within the viewport: both surfaces sit 12px in from
  /// the edges and 12px below the status bar at every scroll offset, so the
  /// drawer toggle and the section picker stay under the same spot of the
  /// user's thumb. Scrolling only fades the glass in and raises its shadow
  /// ([PillSplitSliverAppBar]).
  ///
  /// The wide layout does not pin the bar inside the feed: its surfaces float
  /// over the window instead (see [ExploreScreen.build]).
  Widget _buildExploreSliverAppBar({
    required BuildContext context,
    required ValueNotifier<double> fade,
    required String? currentFilter,
    required bool hasSubscriptionFiltersApplied,
    required void Function(String?) handleFilterChange,
    required Widget trailing,
  }) {
    return PillSplitSliverAppBar(
      fade: fade,
      statusTop: MediaQuery.paddingOf(context).top,
      trailing: trailing,
      child: _buildExploreBarControls(
        currentFilter: currentFilter,
        hasSubscriptionFiltersApplied: hasSubscriptionFiltersApplied,
        handleFilterChange: handleFilterChange,
      ),
    );
  }

  Widget _buildActivityList(
    BuildContext context,
    WidgetRef ref, {
    void Function(SnPost)? onOpenPost,
  }) {
    return PaginationWidget(
      provider: activityListProvider,
      notifier: activityListProvider.notifier,
      isRefreshable: false,
      isSliver: true,
      footerSkeletonChild: const SizedBox(
        height: 64,
        child: Center(child: ConfuseSpinner(size: 40, speed: 6)),
      ),
      contentBuilder: (data, footer) =>
          _ActivityListView(data: data, footer: footer, onOpenPost: onOpenPost),
    );
  }

  Widget _buildPostList(
    BuildContext context,
    WidgetRef ref,
    List<String> selectedPublishers,
    List<String> selectedCategories,
    List<String> selectedTags, {
    void Function(SnPost)? onOpenPost,
  }) {
    return SliverPostList(
      queryKey: 'explore_filtered',
      query: PostListQuery(
        publishers: selectedPublishers,
        categories: selectedCategories,
        tags: selectedTags,
      ),
      padding: EdgeInsets.zero,
      itemPadding: const EdgeInsets.fromLTRB(
        SolSpace.lg,
        SolSpace.md + 2,
        SolSpace.lg,
        SolSpace.md,
      ),
      onOpenPost: onOpenPost,
      itemWrapper: (context, index, post, child) =>
          PostRowSurface(child: child),
      separatorBuilder: (context, index, post) => const Gap(kExploreCardGap),
    );
  }

  /// The feed itself.
  ///
  /// There is no page-wide surface card: the section quick pick, the featured
  /// strip and every row in the timeline are floating cards on the page
  /// background, separated by one uniform gap and no horizontal rules. The wide
  /// layout only constrains the feed to a readable column; it no longer wraps
  /// it in a card.
  Widget _buildFeed(
    BuildContext context,
    WidgetRef ref, {
    required ValueNotifier<double> fade,
    required ValueNotifier<List<String>> selectedPublisherNames,
    required ValueChanged<List<String>> onPublishersChanged,
    required bool hasSubscriptionFiltersApplied,
    required void Function(String?) handleFilterChange,
    required String? currentFilter,
    required bool isWide,
    required void Function(SnPost)? onOpenPost,
    required Widget headerTrailing,
  }) {
    final appSettings = ref.watch(appSettingsProvider);
    final exploreSettings = appSettings.exploreSettings;
    final gutter = explorePageGutter(context);
    // The header is a pinned row of two glass surfaces: the refresh indicator
    // has to clear the band itself plus the pill's top margin, exactly as the
    // bar measures itself.
    final sliverRefreshInset =
        MediaQuery.paddingOf(context).top + kPillSplitBarBand;
    final usePostList =
        selectedPublisherNames.value.isNotEmpty ||
        exploreSettings.selectedCategoryIds.isNotEmpty ||
        exploreSettings.selectedTagIds.isNotEmpty;
    final isSubscriptionsTab = currentFilter == 'subscriptions';
    final isExploreTab = currentFilter == null;
    // The featured carousel is a wide-screen section; only watch it there.
    final hasFeaturedPosts =
        isWide &&
        isExploreTab &&
        (ref.watch(featuredPostsProvider).value?.isNotEmpty == true);
    final activityState = ref.watch(activityListProvider);
    final isListInitialLoading =
        (activityState.isLoading || activityState.value?.isLoading == true) &&
        (activityState.value?.items.isEmpty ?? true);

    Future<void> refreshTimeline() async {
      // The publisher live list only exists while its quick pick is on screen
      // (the Subscriptions tab). Reading its notifier on any other tab would
      // refresh a throwaway instance that is already disposed by the time the
      // request resolves.
      if (isSubscriptionsTab) {
        await ref.read(publishersSubscriptionsLiveProvider.notifier).refresh();
      }
      if (!usePostList) {
        await ref.read(activityListProvider.notifier).refresh();
      }
    }

    // The glass fade is driven off the scroll offset itself (see
    // [updatePillFade]), so it interpolates with the drag instead of snapping
    // at the first pixel. A feed at its origin leaves the bar invisible;
    // once it has moved ~96px the pill is fully glassed.
    // The bar is pinned, so scrolling back plays the inverse as the feed
    // returns to the top.
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) => updatePillFade(notification, fade),
      child: ExtendedRefreshIndicator(
        leadingEdgeInset: sliverRefreshInset,
        hoverRefreshLabel: 'refresh'.tr(),
        onRefresh: refreshTimeline,
        child: CustomScrollView(
          slivers: [
            // Wide lifts the bar out of the feed and spans it across the
            // window, so the pinned sliver only exists in the narrow layout.
            if (!isWide) ...[
              _buildExploreSliverAppBar(
                context: context,
                fade: fade,
                currentFilter: currentFilter,
                hasSubscriptionFiltersApplied: hasSubscriptionFiltersApplied,
                handleFilterChange: handleFilterChange,
                trailing: headerTrailing,
              ),
              const SliverGap(kExploreCardGap),
            ],
            // The wide header floats over the feed instead of being a sliver
            // of it, so the column has to reserve the band's own height (plus
            // the status inset the pill's margin already carries) before its
            // first card. The gap is the scroll distance the rows travel under
            // the glass.
            if (isWide)
              SliverGap(
                MediaQuery.paddingOf(context).top +
                    kPillSplitBarBand +
                    kExploreCardGap,
              ),
            // The Subscriptions tab keeps the publisher quick pick; Explore and
            // Friends show the friend presence strip in the same floating slot.
            if (isSubscriptionsTab)
              SliverSubscribedPublishersStrip(
                selectedPublisherNames: selectedPublisherNames.value,
                onSelectedPublishersChanged: onPublishersChanged,
              )
            else
              const SliverFriendPresenceStrip(),
            const SliverGap(kExploreCardGap),
            // Explore only, and only once the carousel has something to show.
            if (hasFeaturedPosts) ...[
              SliverPadding(
                padding: gutter,
                sliver: SliverToBoxAdapter(
                  child: ExploreCard(
                    child: const PostFeaturedList(flush: true),
                  ),
                ),
              ),
              const SliverGap(kExploreCardGap),
            ],
            if (usePostList)
              SliverPadding(
                padding: gutter,
                sliver: _buildPostList(
                  context,
                  ref,
                  selectedPublisherNames.value,
                  exploreSettings.selectedCategoryIds,
                  exploreSettings.selectedTagIds,
                  onOpenPost: onOpenPost,
                ),
              )
            else if (isListInitialLoading)
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
              SliverPadding(
                padding: gutter,
                sliver: _buildActivityList(
                  context,
                  ref,
                  onOpenPost: onOpenPost,
                ),
              ),
            // The tab shell floats the NavigationBar over the page, so reserve
            // its height or the last card stays underneath the bar.
            SliverGap(MediaQuery.paddingOf(context).bottom + kExploreCardGap),
          ],
        ),
      ),
    );
  }
}

/// The explore page's wide layout: the feed and, beside it, the post currently
/// open.
///
/// The pane is a floating card of its own — same tone, radius and gap family
/// as the feed's rows — inset from the window edges so the page ground shows
/// around it. It animates width in and out rather than snapping the window in
/// two; while it moves the feed keeps its reading measure (centred in whatever
/// width is left to it) and the pill stays over the feed column, so the pane
/// never slides under the bar's controls.
class _WideExploreLayout extends StatelessWidget {
  /// The feed's glass ramp: 0 transparent at the top of the timeline, 1 fully
  /// surfaced once scrolled.
  final ValueNotifier<double> fade;

  /// The post open beside the feed, or null.
  final String? detailPostId;

  /// The composer open in the pane, or null while the pane shows a post (or
  /// is empty). A record of the request [PostComposeScreen.show] received, so
  /// the pane rebuilds the composer only when the target actually changes.
  final ({
    SnPost? originalPost,
    PostComposeInitialState? initialState,
    SnPost? replyingTo,
    SnPost? forwardingTo,
    SnPost? chainingTo,
  })?
  composeRequest;

  final Widget barControls;

  /// The header's trailing action, in its own glass capsule.
  final Widget barTrailing;
  final Widget feed;
  final ValueChanged<String> onOpenFullPage;

  /// Opens another post in the pane itself, replacing what it shows — the
  /// path reference posts and replies take when tapped inside the pane.
  final ValueChanged<String> onOpenInPane;
  final VoidCallback onCloseDetail;

  /// Closes the composer, resolving the awaiting `show` caller with `true`
  /// once a post was submitted, `false` on a plain close.
  final ValueChanged<bool> onCloseCompose;

  const _WideExploreLayout({
    required this.fade,
    required this.detailPostId,
    required this.composeRequest,
    required this.barControls,
    required this.barTrailing,
    required this.feed,
    required this.onOpenFullPage,
    required this.onOpenInPane,
    required this.onCloseDetail,
    required this.onCloseCompose,
  });

  /// How long the pane takes to slide in or out.
  static const _duration = Duration(milliseconds: 260);

  /// The curve the pane eases along.
  static const _curve = Curves.easeOutCubic;

  /// Whether either a post or the composer currently occupies the pane.
  bool get _isPaneOpen => detailPostId != null || composeRequest != null;

  @override
  Widget build(BuildContext context) {
    final statusTop = MediaQuery.paddingOf(context).top;
    final openId = detailPostId;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The feed column keeps the reading measure the wide layout has always
        // used: centred, capped at the column width. It yields half the window
        // while the pane is open and takes it back on close — the pane's
        // [AnimatedSize] is what makes that handover a slide rather than a cut.
        Expanded(
          child: Stack(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: kDiscoveryWideColumnWidth,
                  ),
                  child: SizedBox.expand(child: feed),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                // The same measurement the sliver's toolbar height gives it,
                // so both surfaces are exactly one control row tall either way.
                height: statusTop + kPillSplitBarBand,
                child: PillSplitBar(
                  fade: fade,
                  statusTop: statusTop,
                  trailing: barTrailing,
                  child: barControls,
                ),
              ),
            ],
          ),
        ),
        // The pane column: zero width while closed so the feed owns the whole
        // window, half the window while open — whether it holds a post or the
        // composer. The card inside fades and slides with the width, and stays
        // mounted through the close animation so the transition never flashes
        // the empty ground. The composer takes the pane while it is open; the
        // detail card is what remains.
        AnimatedSize(
          duration: _duration,
          curve: _curve,
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: _isPaneOpen ? _paneWidth(context) : 0,
            child: !_isPaneOpen
                ? null
                : composeRequest != null
                ? _ComposePaneCard(
                    request: composeRequest!,
                    statusTop: statusTop,
                    onClose: onCloseCompose,
                  )
                : _DetailPaneCard(
                    key: ValueKey(openId),
                    postId: openId!,
                    statusTop: statusTop,
                    onOpenFullPage: onOpenFullPage,
                    onOpenInPane: onOpenInPane,
                    onClose: onCloseDetail,
                  ),
          ),
        ),
      ],
    );
  }

  /// The pane's width: an even split of the window with the feed column, so a
  /// post reads in as much room as the timeline beside it.
  double _paneWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width / 2;
}

/// The composer as the wide layout's floating card: the detail pane's surface
/// tone, radius and inset, so authoring is the same sheet the feed opens to
/// read a post.
///
/// The composer draws its own chrome ([PostComposePane] with a pane pill), so
/// this card only gives it the ground. The pill's close action reports
/// [onClose] with `true` after a submit and `false` on a plain close, which
/// resolves the awaiting caller and tears the composer down.
class _ComposePaneCard extends StatelessWidget {
  /// The request the pane is authoring; its targets seed the composer state.
  final ({
    SnPost? originalPost,
    PostComposeInitialState? initialState,
    SnPost? replyingTo,
    SnPost? forwardingTo,
    SnPost? chainingTo,
  })
  request;

  final double statusTop;

  /// `true` once a post was submitted, `false` on a plain close.
  final ValueChanged<bool> onClose;

  const _ComposePaneCard({
    required this.request,
    required this.statusTop,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: statusTop + SolSpace.md,
        bottom: SolSpace.md,
        right: SolSpace.md,
      ),
      child: ClipRRect(
        borderRadius: SolRadius.cardRadius,
        child: ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: PostComposePane(
            originalPost: request.originalPost,
            initialState: request.initialState,
            replyingTo: request.replyingTo,
            forwardingTo: request.forwardingTo,
            chainingTo: request.chainingTo,
            chrome: PostComposeChrome.pane,
            onFinished: onClose,
          ),
        ),
      ),
    );
  }
}

/// The detail pane as a floating card: the feed's own surface tone and radius,
/// inset from the window edges so it hovers over the page ground instead of
/// bleeding into it.
///
/// The chrome is a real [PillAppBar], not a flat header row — the same glass
/// capsule the feed and chat pages use. It floats over the body and its fill
/// fades in on the body's own scroll offset ([updatePillFade]), so the post
/// slides under the bar exactly as timeline rows slide under the feed's pill.
/// [statusTop] keeps the card clear of the status bar; the pill then insets a
/// further [SolSpace.md] inside the card, reading as a control hovering on the
/// card's surface.
///
/// The embed carries no app bar of its own ([PostDetailBody] with
/// `isEmbedded`), so the pill supplies the chrome — the post-detail title with
/// open-in-full-page and close actions. Taps on posts inside the body
/// (reference posts, replies) go to [onOpenInPane], which swaps the pane's own
/// content instead of navigating away.
class _DetailPaneCard extends HookConsumerWidget {
  final String postId;
  final double statusTop;
  final ValueChanged<String> onOpenFullPage;
  final ValueChanged<String> onOpenInPane;
  final VoidCallback onClose;

  const _DetailPaneCard({
    super.key,
    required this.postId,
    required this.statusTop,
    required this.onOpenFullPage,
    required this.onOpenInPane,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    // The pill's glass ramp, driven by the body's scroll. A notifier rather
    // than a rebuild so a scroll tick repaints the capsule only, never the
    // post content underneath it.
    final fade = useValueNotifier(0.0);
    return Padding(
      padding: EdgeInsets.only(
        top: statusTop + SolSpace.md,
        bottom: SolSpace.md,
        right: SolSpace.md,
      ),
      child: ClipRRect(
        borderRadius: SolRadius.cardRadius,
        child: ColoredBox(
          color: colorScheme.surfaceContainerLow,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // The body scrolls the full height of the card, so its rows pass
              // under the pill and the glass has something to refract. The
              // band the capsule occupies is reserved inside that scroll view
              // (plus the feed's own card gap), so the first screen of the
              // post still clears it.
              NotificationListener<ScrollNotification>(
                onNotification: (notification) =>
                    updatePillFade(notification, fade),
                child: PostDetailBody(
                  id: postId,
                  isEmbedded: true,
                  topInset: kPillAppBarHeight + kExploreCardGap,
                  // Reference posts and replies open in the pane, replacing
                  // its content, rather than navigating to the full page.
                  onPostTap: onOpenInPane,
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: PillAppBar(
                  fade: fade,
                  // The card already clears the status bar; the pill only needs
                  // its own side/top gutter inside the card.
                  statusTop: 0,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'postDetail'.tr(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Symbols.open_in_new),
                        tooltip: 'open'.tr(),
                        onPressed: () => onOpenFullPage(postId),
                      ),
                      IconButton(
                        icon: const Icon(Symbols.close),
                        tooltip: 'close'.tr(),
                        onPressed: onClose,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
        separatorBuilder: (context, index) => const Gap(SolSpace.md),
        padding: const EdgeInsets.symmetric(vertical: SolSpace.xxs),
        itemBuilder: (context, index) {
          final item = Map<String, dynamic>.from(items[index]);
          final itemData = _extractDiscoveryItemData(item);
          final post = SnPost.fromJson(itemData);
          final rank = item['rank'] as String?;

          return Container(
            width: 320,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: const BorderRadius.all(
                Radius.circular(SolRadius.card),
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    child: PostActionableItem(
                      item: post,
                      isCompact: true,
                      padding: const EdgeInsets.fromLTRB(
                        SolSpace.lg,
                        SolSpace.md + 2,
                        SolSpace.lg,
                        SolSpace.md,
                      ),
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
                            borderRadius: BorderRadius.circular(SolRadius.xs),
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
                            borderRadius: BorderRadius.circular(SolRadius.xs),
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
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(SolRadius.sm),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: SolSpace.xs,
                      vertical: SolSpace.xxs,
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
              Wrap(
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
            if (shouldShowRank)
              Row(
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
          ],
        );
      }(),
      _ => CarouselView.weighted(
        flexWeights: flexWeights,
        consumeMaxWeight: false,
        enableSplash: false,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(SolRadius.md)),
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

    return ExploreCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                switch (type) {
                  'realm' => Symbols.public,
                  'publisher' => Symbols.account_circle,
                  'account' => Symbols.person,
                  'article' => Symbols.auto_stories,
                  'post' => Symbols.shuffle,
                  _ => Symbols.explore,
                },
                size: 19,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const Gap(8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ).padding(top: 1),
            ],
          ).padding(
            horizontal: SolSpace.lg,
            top: SolSpace.md + 2,
            bottom: SolSpace.sm,
          ),
          SizedBox(
            height: height,
            child: contentWidget,
          ).padding(left: SolSpace.md, right: SolSpace.md, bottom: SolSpace.md),
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
        ? CloudImageWidget(file: background, fit: BoxFit.cover, imageOnly: true)
        : ColoredBox(color: Theme.of(context).colorScheme.secondaryContainer);

    final card = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SolRadius.card),
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
                          fallbackName: account.nick,
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

class _ActivityListView extends HookConsumerWidget {
  final List<SnTimelineEvent> data;
  final Widget footer;
  final void Function(SnPost)? onOpenPost;

  const _ActivityListView({
    required this.data,
    required this.footer,
    this.onOpenPost,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(activityListProvider.notifier);

    return SuperSliverList.separated(
      itemCount: data.length + 1,
      // Cards own their boundary; the feed separates them with one gap instead
      // of a horizontal rule.
      separatorBuilder: (_, _) => const Gap(kExploreCardGap),
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

            itemWidget = PostRowSurface(
              child: PostActionableItem(
                padding: const EdgeInsets.fromLTRB(
                  SolSpace.lg,
                  SolSpace.md + 2,
                  SolSpace.lg,
                  SolSpace.md,
                ),
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
                onTap: onOpenPost != null ? () => onOpenPost!(post) : null,
              ),
            );
            break;
          case 'discovery':
          case 'discovery.v2':
            // Discovery sections carry their own card (they own a header plus
            // a row of suggestion cards inside it).
            itemWidget = _DiscoveryActivityItem(
              data: item.data!,
              eventType: item.type,
              resourceIdentifier: item.resourceIdentifier,
            );
            break;
          case 'presence.friend':
            final rawData = asStringKeyedMap(item.data);
            final activityJson = normalizePresenceActivityJson(
              asStringKeyedMap(rawData['activity']),
            );
            final activity = SnPresenceActivity.fromJson(activityJson);
            itemWidget = PostRowSurface(
              child: FriendPresenceItem(activity: activity, rawData: rawData),
            );
            break;
          case 'status.friend':
            final statusJson = normalizeStatusJson(
              asStringKeyedMap(asStringKeyedMap(item.data)['status']),
            );
            final status = SnAccountStatus.fromJson(statusJson);
            itemWidget = PostRowSurface(
              child: FriendStatusItem(
                status: status,
                createdAt: item.createdAt,
              ),
            );
            break;
          default:
            itemWidget = const SizedBox.shrink();
        }

        return itemWidget;
      },
    );
  }
}

/// Section picker for the explore header.
///
/// Shows the active section's icon and label in the bar's title slot, where
/// the brand mark used to sit. The trigger paints no surface of its own — it
/// floats directly on the bar's pill — so the only chrome is the icon, the
/// label and a dropdown caret. Selecting a section persists it through
/// [onSelected] using the same `null` / `'subscriptions'` / `'friends'`
/// vocabulary the old tab bar used.
class _ExploreSectionButton extends StatelessWidget {
  final String? filter;
  final bool hasFiltersApplied;
  final ValueChanged<String?> onSelected;

  const _ExploreSectionButton({
    required this.filter,
    required this.hasFiltersApplied,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selected = _sections.firstWhere(
      (section) => section.filter == filter,
      orElse: () => _sections.first,
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
              spacing: 8,
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
        for (final section in _sections)
          MenuItemButton(
            leadingIcon: Icon(section.icon, size: 20),
            trailingIcon: filter == section.filter
                ? const Icon(Symbols.check, size: 18)
                : null,
            onPressed: hasFiltersApplied
                ? null
                : () => onSelected(section.filter),
            child: Text(section.label.tr()),
          ),
      ],
    );
  }
}

class _ExploreSection {
  final String? filter;
  final String label;
  final IconData icon;

  const _ExploreSection({
    required this.filter,
    required this.label,
    required this.icon,
  });
}

const _sections = <_ExploreSection>[
  _ExploreSection(filter: null, label: 'explore', icon: Symbols.explore),
  _ExploreSection(
    filter: 'subscriptions',
    label: 'exploreFilterSubscriptions',
    icon: Symbols.subscriptions,
  ),
  _ExploreSection(
    filter: 'friends',
    label: 'exploreFilterFriends',
    icon: Symbols.people,
  ),
];
