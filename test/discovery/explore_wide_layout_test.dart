import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/friends_overview.dart';
import 'package:island/core/theme.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/discovery/explore.dart';
import 'package:island/discovery/widgets/explore_card.dart';
import 'package:island/discovery/widgets/pill_app_bar.dart';
import 'package:island/discovery/widgets/friend_presence_strip.dart';
import 'package:island/discovery/widgets/subscribed_publishers_strip.dart';
import 'package:island/posts/posts_pod.dart';
import 'package:island/posts/widgets/compose/filters/post_subscription_filter.dart';
import 'package:island/posts/widgets/compose/post_featured.dart';
import 'package:island/posts/screens/post_detail.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:island/shared/widgets/layouts/sidebar_panel_host.dart';
import 'package:island/shared/widgets/page_app_bar.dart';
import 'package:island/shared/widgets/pill_surface.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class _GuestUserInfo extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => null;
}

/// Holds the timeline in its initial-loading state: the wide body then renders
/// the spinner instead of paging the feed, so the test exercises layout only.
class _LoadingActivityList extends ActivityListNotifier {
  @override
  Future<PaginationState<SnTimelineEvent>> build() async =>
      const PaginationState(
        items: <SnTimelineEvent>[],
        isLoading: true,
        isReloading: false,
        totalCount: 0,
        hasMore: false,
        cursor: null,
      );

  @override
  Future<List<SnTimelineEvent>> fetch({int retryCount = 0}) async =>
      const <SnTimelineEvent>[];
}

/// One subscribed publisher so the quick pick has real content to paint.
class _OnePublisherSubscription extends PublishersSubscriptionsLiveNotifier {
  @override
  Future<List<PublisherSubscriptionLiveItem>> build() async => [
    _publisherSubscription(),
  ];
}

PublisherSubscriptionLiveItem _publisherSubscription() {
  return PublisherSubscriptionLiveItem(
    subscription: SnPublisherSubscriptionCompact(
      accountId: 'account-1',
      publisherId: 'publisher-1',
      publisher: SnPublisher.fromJson({
        'id': 'publisher-1',
        'name': 'alice',
        'nick': 'Alice',
      }),
    ),
    isLive: false,
    hasNewContent: true,
  );
}

SnPost _featuredPost([String id = 'featured-1']) {
  return SnPost.fromJson({
    'id': id,
    'type': 0,
    'content': 'featured body',
    'publisher': {'id': 'publisher-1', 'name': 'alice', 'nick': 'Alice'},
    'reactions_count': <String, dynamic>{},
    'reactions_made': <String, dynamic>{},
    'chained_posts': <dynamic>[],
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  });
}

SnFriendOverviewItem _friendOverviewItem() {
  final now = DateTime.utc(2026, 1, 1);
  return SnFriendOverviewItem(
    account: SnAccount(
      id: 'account-2',
      name: 'bob',
      nick: 'Bob',
      language: 'en-US',
      isSuperuser: false,
      automatedId: null,
      profile: SnAccountProfile(
        id: 'profile-2',
        experience: 0,
        level: 1,
        levelingProgress: 0,
        picture: null,
        background: null,
        verification: null,
        createdAt: now,
        updatedAt: now,
        deletedAt: null,
      ),
      perkSubscription: null,
      activatedAt: null,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    ),
    status: SnAccountStatus(
      id: 'status-2',
      attitude: 0,
      isOnline: true,
      isCustomized: false,
      meta: null,
      clearedAt: null,
      accountId: 'account-2',
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    ),
    activities: const <SnPresenceActivity>[],
  );
}

SnPost _smallPost({
  Map<String, dynamic> overrides = const {},
  String id = 'small-post',
}) {
  return SnPost.fromJson({
    'id': id,
    'type': 0,
    'content': 'A short post body.',
    'publisher': {'id': 'publisher-1', 'name': 'alice', 'nick': 'Alice'},
    'reactions_count': <String, dynamic>{},
    'reactions_made': <String, dynamic>{},
    'chained_posts': <dynamic>[],
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
    ...overrides,
  });
}

SnTimelineEvent _postEvent(SnPost post) => SnTimelineEvent.fromJson({
  'id': 'event-1',
  'type': 'posts.new',
  'resource_identifier': 'post:${post.id}',
  'data': post.toJson(),
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
  'deleted_at': null,
});

/// Timeline holding a single post row, so the wide feed renders something to
/// tap.
class _OnePostFeed extends ActivityListNotifier {
  _OnePostFeed(this.post);

  final SnPost post;

  @override
  Future<PaginationState<SnTimelineEvent>> build() async => PaginationState(
    items: [_postEvent(post)],
    isLoading: false,
    isReloading: false,
    totalCount: 1,
    hasMore: false,
    cursor: null,
  );

  @override
  Future<List<SnTimelineEvent>> fetch({int retryCount = 0}) async => [
    _postEvent(post),
  ];
}

/// Timeline with two rows, so the uniform gap between floating cards can be
/// measured.
class _TwoPostFeed extends ActivityListNotifier {
  _TwoPostFeed(this.posts);

  final List<SnPost> posts;

  List<SnTimelineEvent> get _events => [
    for (final (index, post) in posts.indexed)
      SnTimelineEvent.fromJson({
        'id': 'event-$index',
        'type': 'posts.new',
        'resource_identifier': 'post:${post.id}',
        'data': post.toJson(),
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-01-01T00:00:00Z',
        'deleted_at': null,
      }),
  ];

  @override
  Future<PaginationState<SnTimelineEvent>> build() async => PaginationState(
    items: _events,
    isLoading: false,
    isReloading: false,
    totalCount: _events.length,
    hasMore: false,
    cursor: null,
  );

  @override
  Future<List<SnTimelineEvent>> fetch({int retryCount = 0}) async => _events;
}

/// Answers every request with an empty JSON list so the sidebar cards settle
/// into their empty states without touching the network.
class _EmptyAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(const <dynamic>[]),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Future<void> pumpExplore(
    WidgetTester tester,
    Size size, {
    List<SnPost>? featuredPosts,
    ActivityListNotifier Function()? feed,
    GlobalKey<NavigatorState>? navigatorKey,
    // Posts the detail pane resolves by id, so a test can drive the pane's own
    // content (reference posts, replies) without a live backend.
    Map<String, SnPost> detailPosts = const {},
  }) async {
    final prefs = await SharedPreferences.getInstance();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);

    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = _EmptyAdapter();

    await tester.runAsync(() async {
      // The scope sits above the app, exactly as `main.dart` mounts it, so a
      // sheet pushed onto the root navigator still resolves providers.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            apiClientProvider.overrideWithValue(dio),
            userInfoProvider.overrideWith(() => _GuestUserInfo()),
            activityListProvider.overrideWith(
              feed ?? () => _LoadingActivityList(),
            ),
            publishersSubscriptionsLiveProvider.overrideWith(
              () => _OnePublisherSubscription(),
            ),
            featuredPostsProvider.overrideWith(
              (ref) async => featuredPosts ?? [_featuredPost()],
            ),
            friendsOverviewExpandedProvider.overrideWith(
              (ref) async => [_friendOverviewItem()],
            ),
            // Lets a test hand the pane a post to render, so reference
            // cards and reply rows can be exercised without a backend.
            postProvider.overrideWith((ref, id) async => detailPosts[id]),
          ],
          child: EasyLocalization(
            supportedLocales: const [Locale('en', 'US')],
            path: 'assets/i18n',
            saveLocale: false,
            child: Builder(
              builder: (context) => MaterialApp(
                navigatorKey: navigatorKey,
                locale: const Locale('en', 'US'),
                supportedLocales: const [Locale('en', 'US')],
                localizationsDelegates: context.localizationDelegates,
                home: const ExploreScreen(),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });

    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Unmounts inside the test body: visibility detectors reschedule their
  /// timers as the tree goes away, which otherwise trips the binding's
  /// pending-timer invariant at teardown.
  Future<void> disposeTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    while (tester.takeException() != null) {}
  }

  /// The quick pick is painted as a sliver of the main section's own scroll
  /// view, directly under the section app bar, in a pane that owns the window
  /// (there is no right sidebar sharing it).
  void expectUnderSectionAppBar(
    WidgetTester tester,
    Finder sliver,
    Finder strip, {
    required double windowWidth,
  }) {
    expect(sliver, findsOneWidget);
    expect(strip, findsOneWidget);
    expect(find.byType(SidebarPanelHost), findsNothing);
    expect(
      find.ancestor(of: strip, matching: find.byType(ExploreCard)),
      findsOneWidget,
      reason: 'the quick pick floats as its own section card',
    );

    final pane = find.ancestor(
      of: sliver,
      matching: find.byType(CustomScrollView),
    );
    final scrollView = tester.widget<CustomScrollView>(pane);
    // The pane keeps the wide reading measure and stays centred instead of
    // spanning the window. It is no longer wrapped in a page-wide card.
    final paneRect = tester.getRect(pane.first);
    expect(paneRect.width, closeTo(720, 1));
    expect(paneRect.left, closeTo((windowWidth - paneRect.width) / 2, 1));
    // The wide header is no longer a sliver: it floats over the pane as two
    // glass surfaces, so the feed starts with the gap that reserves its height
    // and the quick pick is the first content sliver.
    expect(
      find.ancestor(of: strip, matching: find.byType(PillSplitSliverAppBar)),
      findsNothing,
      reason: 'the wide pill is not pinned inside the feed',
    );
    expect(find.byType(PillSplitBar), findsOneWidget);
    expect(find.byType(PillAppBar), findsNothing);

    final sliverWidget = tester.widget(sliver);
    expect(
      scrollView.slivers.indexWhere(
        (s) => s.runtimeType == sliverWidget.runtimeType,
      ),
      1,
      reason: 'the strip is the first content sliver under the floating pill',
    );

    // Painted, not merely present: the strip occupies its full height at the
    // top of the pane.
    expect(tester.getSize(strip).height, greaterThan(60));
    expect(tester.getTopLeft(strip).dy, lessThan(200));
  }

  testWidgets('wide explore: the featured carousel follows the quick pick', (
    tester,
  ) async {
    await pumpExplore(tester, const Size(1400, 900));

    expectUnderSectionAppBar(
      tester,
      find.byType(SliverFriendPresenceStrip),
      find.byType(FriendPresenceStrip),
      windowWidth: 1400,
    );
    expect(find.byType(SliverSubscribedPublishersStrip), findsNothing);

    final featured = find.byType(PostFeaturedList);
    expect(featured, findsOneWidget);
    // The host owns the section's surface; each featured post still floats on
    // its own row card inside the strip.
    expect(
      find.descendant(of: featured, matching: find.byType(PostRowSurface)),
      findsWidgets,
      reason: 'featured posts keep their own card',
    );
    expect(
      find.ancestor(of: featured, matching: find.byType(ExploreCard)),
      findsOneWidget,
      reason: 'the featured section is its own floating card',
    );
    // The online strip uses the same list, so scope to the featured one.
    final featuredStrip = find.descendant(
      of: featured,
      matching: find.byType(CarouselView),
    );
    expect(featuredStrip, findsOneWidget);
    expect(
      find.descendant(of: featured, matching: find.byType(PageView)),
      findsNothing,
      reason: 'a snapped strip replaces the full-width pager',
    );
    final featuredItem = find
        .descendant(
          of: featuredStrip,
          matching: find.byType(PostActionableItem),
        )
        .first;
    expect(
      tester.getSize(featuredItem).width,
      320,
      reason: 'one post keeps its own width instead of filling the pane',
    );
    final scrollView = tester.widget<CustomScrollView>(
      find.ancestor(of: featured, matching: find.byType(CustomScrollView)),
    );
    expect(
      scrollView.slivers.indexWhere((s) => s is SliverFriendPresenceStrip),
      1,
      reason: 'only the gap reserving the pill height precedes it',
    );
    expect(
      tester.getTopLeft(featured).dy,
      greaterThan(tester.getTopLeft(find.byType(FriendPresenceStrip)).dy),
      reason: 'the carousel sits below the online accounts strip',
    );

    await disposeTree(tester);
  });

  testWidgets('wide explore: no carousel without featured posts', (
    tester,
  ) async {
    await pumpExplore(
      tester,
      const Size(1400, 900),
      featuredPosts: const <SnPost>[],
    );

    expectUnderSectionAppBar(
      tester,
      find.byType(SliverFriendPresenceStrip),
      find.byType(FriendPresenceStrip),
      windowWidth: 1400,
    );
    expect(find.byType(PostFeaturedList), findsNothing);

    await disposeTree(tester);
  });

  testWidgets('wide explore: the featured strip snaps to post boundaries', (
    tester,
  ) async {
    await pumpExplore(
      tester,
      const Size(1400, 900),
      featuredPosts: [for (var i = 0; i < 5; i++) _featuredPost('featured-$i')],
    );

    final carousel = find.descendant(
      of: find.byType(PostFeaturedList),
      matching: find.byType(CarouselView),
    );
    final items = find.descendant(
      of: carousel,
      matching: find.byType(PostActionableItem),
    );
    // Cards are spaced by the carousel's item extent, not by their width.
    final stride =
        tester.getTopLeft(items.at(1)).dx - tester.getTopLeft(items.at(0)).dx;
    final position = tester
        .state<ScrollableState>(
          find
              .descendant(of: carousel, matching: find.byType(Scrollable))
              .first,
        )
        .position;

    final gesture = await tester.startGesture(tester.getCenter(carousel));
    await gesture.moveBy(const Offset(-120, 0));
    await tester.pump();
    await gesture.moveBy(Offset(-stride, 0));
    await tester.pump();
    expect(position.pixels, greaterThan(0), reason: 'the strip scrolls');
    await gesture.up();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(position.pixels, greaterThan(0));
    expect(
      position.pixels % stride,
      moreOrLessEquals(0, epsilon: 1),
      reason: 'settling lands on a post boundary',
    );

    await disposeTree(tester);
  });

  testWidgets('wide explore: a short post opens in the side pane', (
    tester,
  ) async {
    await pumpExplore(
      tester,
      const Size(1400, 900),
      feed: () => _OnePostFeed(_smallPost()),
      // No featured strip, so the feed row is the only tappable post.
      featuredPosts: const <SnPost>[],
    );

    expect(find.byType(PostActionableItem), findsOneWidget);
    expect(find.byType(PostDetailBody), findsNothing);

    await tester.tap(find.textContaining('A short post body.'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // The post opens beside the feed instead of over it, and the two columns
    // split the window evenly (the card is inset by its own floating margin).
    final detail = find.byType(PostDetailBody);
    expect(detail, findsOneWidget);
    final feedCard = find.byType(PostActionableItem);
    expect(tester.getRect(detail).left, moreOrLessEquals(1400 / 2, epsilon: 1));
    expect(
      tester.getRect(feedCard).left + tester.getRect(feedCard).width,
      lessThanOrEqualTo(tester.getRect(detail).left + 1),
    );

    // The pane's own header closes it and hands the window back to the feed.
    await tester.tap(find.byTooltip('Close'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PostDetailBody), findsNothing);
    expect(find.byType(PostActionableItem), findsOneWidget);

    // Closing must not wedge the pane shut: the same post opens it again.
    await tester.tap(find.textContaining('A short post body.'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      find.byType(PostDetailBody),
      findsOneWidget,
      reason: 'a closed pane still opens on the next tap',
    );

    await disposeTree(tester);
  });

  testWidgets('wide explore: the pane slides in as a floating card', (
    tester,
  ) async {
    await pumpExplore(
      tester,
      const Size(1400, 900),
      feed: () => _OnePostFeed(_smallPost()),
      featuredPosts: const <SnPost>[],
    );

    // Opening animates width rather than snapping: one frame in, the pane is
    // present but only part-way to its half-window measure.
    await tester.tap(find.textContaining('A short post body.'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    final midTransition = tester.getRect(find.byType(PostDetailBody)).width;
    expect(midTransition, greaterThan(0));
    expect(
      midTransition,
      lessThan(1400 / 2),
      reason: 'the pane is still growing, so it has not reached full width',
    );

    await tester.pump(const Duration(milliseconds: 300));
    final settled = tester.getRect(find.byType(PostDetailBody)).width;
    expect(settled, closeTo(1400 / 2 - SolSpace.md, 1));

    // The pane is a floating card, not a bleeding panel: rounded corners in
    // the feed's card radius, the feed's own surface tone, and clear of the
    // window edge so the page ground shows around it.
    final card = find.ancestor(
      of: find.byType(PostDetailBody),
      matching: find.byType(ClipRRect),
    );
    expect(card, findsOneWidget);
    final clip = tester.widget<ClipRRect>(card);
    expect(clip.borderRadius, SolRadius.cardRadius);

    final coloredBox = find.descendant(
      of: card,
      matching: find.byType(ColoredBox),
    );
    expect(coloredBox, findsOneWidget);
    expect(
      tester.widget<ColoredBox>(coloredBox).color,
      equals(Theme.of(tester.element(card)).colorScheme.surfaceContainerLow),
    );

    final rect = tester.getRect(card);
    expect(rect.right, closeTo(1400 - SolSpace.md, 1), reason: 'inset margin');
    expect(
      rect.top,
      greaterThanOrEqualTo(MediaQuery.paddingOf(tester.element(card)).top),
    );

    await disposeTree(tester);
  });

  testWidgets('wide explore: the pane header is a pill bar', (tester) async {
    await pumpExplore(
      tester,
      const Size(1400, 900),
      feed: () => _OnePostFeed(_smallPost()),
      featuredPosts: const <SnPost>[],
    );

    // The feed's header is a split pair of surfaces; the pane has none yet.
    expect(find.byType(PillSplitBar), findsOneWidget);
    expect(find.byType(PillAppBar), findsNothing);

    await tester.tap(find.textContaining('A short post body.'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // The pane carries its own pill — the same glass capsule the detail page
    // uses — so the window now floats the split header plus one, and the
    // pane's holds the detail chrome.
    expect(find.byType(PillSplitBar), findsOneWidget);
    expect(find.byType(PillAppBar), findsOneWidget);
    expect(find.text('Post Detail'), findsOneWidget);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byTooltip('Open'), findsOneWidget);

    await disposeTree(tester);
  });

  testWidgets('wide explore: a reference post opens in the pane', (
    tester,
  ) async {
    final reference = _smallPost(
      id: 'ref-post',
      overrides: {'content': 'The referenced body.'},
    );
    final main = _smallPost(
      id: 'main-post',
      overrides: {
        'content': 'Main post body.',
        'forwarded_post': reference.toJson(),
      },
    );

    await pumpExplore(
      tester,
      const Size(1400, 900),
      feed: () => _OnePostFeed(main),
      featuredPosts: const <SnPost>[],
      detailPosts: {'main-post': main, 'ref-post': reference},
    );

    // Open the main post in the pane.
    await tester.tap(find.textContaining('Main post body.'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      tester.widget<PostDetailBody>(find.byType(PostDetailBody)).id,
      'main-post',
    );

    // The feed row renders the same reference, so scope to the pane's own copy.
    final paneReference = find.descendant(
      of: find.byType(PostDetailBody),
      matching: find.textContaining('The referenced body.'),
    );
    expect(paneReference, findsOneWidget);

    // Tapping it swaps the pane's own content instead of navigating away: the
    // window stays one pane, now showing the referenced post.
    await tester.tap(paneReference);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PostDetailBody), findsOneWidget);
    expect(
      tester.widget<PostDetailBody>(find.byType(PostDetailBody)).id,
      'ref-post',
      reason: 'the reference opens in the pane, replacing its content',
    );

    await disposeTree(tester);
  });

  testWidgets('wide explore: posts float on their own cards', (tester) async {
    await pumpExplore(
      tester,
      const Size(1400, 900),
      feed: () =>
          _TwoPostFeed([_smallPost(id: 'post-a'), _smallPost(id: 'post-b')]),
      featuredPosts: const <SnPost>[],
    );

    final posts = find.byType(PostActionableItem);
    expect(posts, findsNWidgets(2));
    final cards = find.ancestor(
      of: posts,
      matching: find.byType(PostRowSurface),
    );
    expect(cards, findsNWidgets(2));
    final rowSurface = tester.widget<PostRowSurface>(cards.first);
    expect(rowSurface.radius, SolRadius.card);
    expect(rowSurface.color, isNull, reason: 'the row uses its default tone');
    expect(
      tester
          .widget<Card>(
            find.descendant(of: cards.first, matching: find.byType(Card)),
          )
          .elevation,
      0,
    );

    final first = tester.getRect(cards.at(0));
    final second = tester.getRect(cards.at(1));
    // The feed is an inset card stack in the centred 720px column.
    expect(first.left, closeTo((1400 - 720) / 2 + 12, 1));
    expect(first.width, closeTo(720 - 24, 1));
    expect(second.top - first.bottom, closeTo(kExploreCardGap, 1));

    final scrollView = find.ancestor(
      of: posts.first,
      matching: find.byType(CustomScrollView),
    );
    expect(
      find.descendant(of: scrollView, matching: find.byType(Divider)),
      findsNothing,
      reason: 'cards are separated by gaps, not horizontal rules',
    );

    await disposeTree(tester);
  });

  testWidgets('narrow explore: cards use the page gutter and one gap', (
    tester,
  ) async {
    await pumpExplore(
      tester,
      const Size(420, 900),
      feed: () =>
          _TwoPostFeed([_smallPost(id: 'post-a'), _smallPost(id: 'post-b')]),
      featuredPosts: const <SnPost>[],
    );

    final posts = find.byType(PostActionableItem);
    expect(posts, findsNWidgets(2));
    final cards = find.ancestor(
      of: posts,
      matching: find.byType(PostRowSurface),
    );
    expect(cards, findsNWidgets(2));

    final first = tester.getRect(cards.at(0));
    final second = tester.getRect(cards.at(1));
    expect(first.left, closeTo(12, 1));
    expect(first.width, closeTo(420 - 24, 1));
    expect(second.top - first.bottom, closeTo(kExploreCardGap, 1));

    await disposeTree(tester);
  });
  testWidgets('the split header stays put and only fades its surfaces in', (
    tester,
  ) async {
    // A feed tall enough to hold the drag below: with only a couple of short
    // posts the scroll bounces straight back to the origin, and the fill
    // would never get a chance to fade in.
    await pumpExplore(
      tester,
      const Size(1400, 900),
      feed: () =>
          _TwoPostFeed([for (var i = 0; i < 8; i++) _smallPost(id: 'post-$i')]),
      featuredPosts: const <SnPost>[],
    );

    final surfaces = find.descendant(
      of: find.byType(PillSplitBar),
      matching: find.byType(PillSurface),
    );
    // Navigation circle, the picker's capsule, then the tune action.
    expect(surfaces, findsNWidgets(3));
    final nav = surfaces.at(0);
    final capsule = surfaces.at(1);
    final tune = surfaces.at(2);

    // The surface's own [DecoratedBox], the first one it paints — the controls
    // inside it come after.
    BoxDecoration chrome(Finder surface) =>
        (tester
                .widgetList<DecoratedBox>(
                  find.descendant(
                    of: surface,
                    matching: find.byType(DecoratedBox),
                  ),
                )
                .first
                .decoration
            as BoxDecoration);

    // Nothing moves with the scroll, the capsule hugs the picker instead of
    // stretching across the window, and the tune action keeps the far edge.
    void expectGeometry() {
      final navRect = tester.getRect(nav);
      final capsuleRect = tester.getRect(capsule);
      final tuneRect = tester.getRect(tune);
      expect(navRect.size, const Size.square(kGlassNavigationButtonSize));
      expect(navRect.left, closeTo(kPillSideGutter, 1));
      expect(capsuleRect.height, closeTo(kGlassNavigationButtonSize, 1));
      expect(capsuleRect.top, closeTo(navRect.top, 1));
      expect(capsuleRect.left, closeTo(navRect.right + SolSpace.xs, 1));
      expect(
        capsuleRect.right,
        lessThan(500),
        reason: 'the capsule ends with its controls, not at the window edge',
      );
      expect(tuneRect.size, const Size.square(kGlassNavigationButtonSize));
      expect(tuneRect.right, closeTo(1400 - kPillSideGutter, 1));
      expect(tuneRect.top, closeTo(navRect.top, 1));
      expect(chrome(nav).borderRadius, SolRadius.pillRadius);
      expect(chrome(capsule).borderRadius, SolRadius.pillRadius);
      expect(chrome(tune).borderRadius, SolRadius.pillRadius);
    }

    // The picker keeps a full spacing step of inset from the capsule's edge,
    // so its icon clears the curved end cap.
    final pickerRect = tester.getRect(find.byType(MenuAnchor));
    expect(
      pickerRect.left,
      closeTo(tester.getRect(capsule).left + SolSpace.md, 1),
    );

    expectGeometry();
    for (final surface in [nav, capsule, tune]) {
      expect(
        chrome(surface).boxShadow,
        isNull,
        reason: 'transparent surfaces over the empty page top cast no shadow',
      );
    }

    // The feed reserves exactly the band the surfaces occupy, so the quick
    // pick clears them at rest.
    expect(
      tester.getTopLeft(find.byType(FriendPresenceStrip)).dy,
      closeTo(kPillSplitBarBand + kExploreCardGap, 1),
    );

    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -200),
    );
    // Let the fling settle: the surfaces interpolate their fill while the
    // scroll is still animating.
    await tester.pumpAndSettle();

    // Scrolled: same geometry, and every surfaced shape casts its soft shadow.
    expectGeometry();
    for (final surface in [nav, capsule, tune]) {
      expect(chrome(surface).boxShadow!.single.color.a, greaterThan(0));
    }

    await disposeTree(tester);
  });

  testWidgets('narrow explore: the header is split into two pills', (
    tester,
  ) async {
    await pumpExplore(
      tester,
      const Size(420, 900),
      featuredPosts: const <SnPost>[],
    );

    expect(find.byType(PillSplitSliverAppBar), findsOneWidget);
    expect(find.byType(PillSliverAppBar), findsNothing);
    final nav = find.byType(GlassNavigationButton);
    final picker = find.byType(MenuAnchor);
    expect(nav, findsOneWidget);
    expect(picker, findsOneWidget);

    final navRect = tester.getRect(nav);
    final pickerRect = tester.getRect(picker);
    expect(navRect.left, closeTo(kPillSideGutter, 1));
    expect(pickerRect.left, greaterThan(navRect.right));
    expect(pickerRect.center.dy, closeTo(navRect.center.dy, 1));
    expect(
      pickerRect.right,
      lessThan(420 - kPillSideGutter),
      reason: 'the capsule hugs the picker instead of filling the row',
    );
    // The tune action keeps the trailing edge, one circle of its own.
    final tuneRect = tester.getRect(
      find.descendant(
        of: find.byType(PillSplitSliverAppBar),
        matching: find.byTooltip('Settings'),
      ),
    );
    expect(tuneRect.right, closeTo(420 - kPillSideGutter, 1));
    expect(tuneRect.center.dy, closeTo(navRect.center.dy, 1));
    expect(
      tuneRect.left,
      greaterThan(pickerRect.right),
      reason: 'the tune action sits outside the picker capsule',
    );

    // The action opens the quick configuration sheet in place.
    await tester.tap(find.byTooltip('Settings'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Preferred'), findsWidgets);
    expect(find.byType(SegmentedButton<String>), findsOneWidget);

    // The sheet writes the same persisted settings the settings screen owns.
    await tester.tap(find.text('Latest'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(kAppExploreSettings);
    expect(stored, isNotNull);
    expect(stored, contains('latest'));

    await disposeTree(tester);
  });

  group('postFitsAttentionModal', () {
    test('a short regular post fits', () {
      expect(postFitsAttentionModal(_smallPost()), isTrue);
    });

    test('long bodies keep the full page', () {
      expect(
        postFitsAttentionModal(_smallPost(overrides: {'content': 'x' * 500})),
        isFalse,
      );
      expect(
        postFitsAttentionModal(
          _smallPost(
            overrides: {'content': List.filled(12, 'line').join('\n')},
          ),
        ),
        isFalse,
      );
    });

    test('media, chains, embeds and articles keep the full page', () {
      expect(
        postFitsAttentionModal(
          _smallPost(
            overrides: {
              'attachments': [
                {'id': 'file-1', 'name': 'a.png', 'mime_type': 'image/png'},
              ],
            },
          ),
        ),
        isFalse,
      );
      expect(
        postFitsAttentionModal(
          _smallPost(
            overrides: {
              'chained_posts': [
                {
                  'id': 'chain-1',
                  'type': 0,
                  'content': 'chained',
                  'created_at': '2026-01-01T00:00:00Z',
                  'updated_at': '2026-01-01T00:00:00Z',
                },
              ],
            },
          ),
        ),
        isFalse,
      );
      expect(
        postFitsAttentionModal(
          _smallPost(
            overrides: {
              'embed_view': {'uri': 'https://example.com', 'renderer': 0},
            },
          ),
        ),
        isFalse,
      );
      expect(
        postFitsAttentionModal(_smallPost(overrides: {'type': 1})),
        isFalse,
      );
      expect(
        postFitsAttentionModal(_smallPost(overrides: {'is_truncated': true})),
        isFalse,
      );
    });
  });

  testWidgets('wide explore: the subscriptions tab swaps the quick pick', (
    tester,
  ) async {
    await pumpExplore(tester, const Size(1400, 900));

    // The section picker is now a dropdown in the leading slot, not a tab bar.
    await tester.tap(find.byType(MenuAnchor).first);
    await tester.pumpAndSettle();
    // Second menu item = Subscriptions (Explore, Subscriptions, Friends).
    await tester.tap(find.byType(MenuItemButton).at(1));
    await tester.pump();
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expectUnderSectionAppBar(
      tester,
      find.byType(SliverSubscribedPublishersStrip),
      find.byType(SubscribedPublishersStrip),
      windowWidth: 1400,
    );
    expect(find.byType(SliverFriendPresenceStrip), findsNothing);
    expect(
      find.byType(PostFeaturedList),
      findsNothing,
      reason: 'the carousel is Explore-only',
    );

    await disposeTree(tester);
  });
}
