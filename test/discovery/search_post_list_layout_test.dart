import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/data/database.dart';
import 'package:island/core/theme.dart';
import 'package:island/discovery/search.dart';
import 'package:island/discovery/widgets/explore_card.dart';
import 'package:island/discovery/widgets/pill_app_bar.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/posts/widgets/compose/filters/post_filter.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_item_skeleton.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Serves a canned posts page so the search tab renders real rows.
///
/// [until] gates the posts page, which keeps the section on its loading
/// placeholders for as long as the caller wants.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter({this.until});

  final Future<void>? until;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    // The messages section syncs chat rooms (expects an object); everything
    // else serves the canned posts page.
    if (options.path.contains('/messager/chat/rooms/sync')) {
      return ResponseBody.fromString(
        jsonEncode(<String, dynamic>{}),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    }
    await until;
    return ResponseBody.fromString(
      jsonEncode([_postJson('p1'), _postJson('p2'), _postJson('p3')]),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
        'x-total': ['3'],
      },
    );
  }
}

Map<String, dynamic> _postJson(String id) => {
  'id': id,
  'type': 0,
  'content': 'body $id',
  'publisher': {'id': 'publisher-1', 'name': 'alice', 'nick': 'Alice'},
  'reactions_count': <String, dynamic>{},
  'reactions_made': <String, dynamic>{},
  'chained_posts': <dynamic>[],
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  /// Pumps the shimmering loading state in bounded steps until the rows land.
  Future<void> pumpUntilRows(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(PostActionableItem).evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> pumpSearch(
    WidgetTester tester,
    Size size, {
    AppDatabase? database,
    Future<void>? until,
    double statusTop = 0,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    if (statusTop > 0) {
      // The band a pill occupies is `statusTop + kPillAppBarHeight`; a device
      // with no status bar would hide a section that forgot the inset.
      final inset = FakeViewPadding(top: statusTop);
      tester.view.padding = inset;
      tester.view.viewPadding = inset;
    }
    addTearDown(tester.view.reset);

    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = _ScriptedAdapter(until: until);

    await tester.runAsync(() async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en', 'US')],
          path: 'assets/i18n',
          saveLocale: false,
          child: Builder(
            builder: (context) => MaterialApp(
              locale: const Locale('en', 'US'),
              supportedLocales: const [Locale('en', 'US')],
              localizationsDelegates: context.localizationDelegates,
              home: ProviderScope(
                overrides: [
                  sharedPreferencesProvider.overrideWithValue(prefs),
                  apiClientProvider.overrideWithValue(dio),
                  // Only the messages section reads the local database.
                  if (database != null)
                    databaseProvider.overrideWithValue(database),
                ],
                child: const UniversalSearchScreen(),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });

    // The skeleton shimmer animates indefinitely, so settle with bounded
    // pumps instead of pumpAndSettle and stop once the rows are up.
    await pumpUntilRows(tester);
  }

  /// Unmounts inside the test body: VisibilityDetector reschedules a 500ms
  /// update as the tree goes away, which otherwise trips the binding's
  /// pending-timer invariant at teardown.
  Future<void> disposeTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    // VisibilityDetector re-schedules a 500ms update from its paint/detach
    // callbacks; pump long enough for the chain to die out before teardown
    // trips the binding's pending-timer invariant.
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(seconds: 1));
      while (tester.takeException() != null) {}
    }
  }

  testWidgets('wide: every row is its own floating card', (tester) async {
    await pumpSearch(tester, const Size(1400, 900));

    final items = find.byType(PostActionableItem);
    expect(items, findsNWidgets(3));

    // One card per row, each the full reading measure of the pane.
    final cards = find.ancestor(of: items, matching: find.byType(Card));
    expect(cards, findsNWidgets(3));

    final firstCard = tester.widget<Card>(cards.at(0));
    expect(
      firstCard.shape,
      isA<RoundedRectangleBorder>().having(
        (s) => s.borderRadius,
        'borderRadius',
        const BorderRadius.all(Radius.circular(SolRadius.card)),
      ),
    );
    expect(firstCard.margin, EdgeInsets.zero);

    // Rows share one left edge and step down by a single card gap.
    final firstRect = tester.getRect(items.at(0));
    final secondRect = tester.getRect(items.at(1));
    expect(secondRect.left, firstRect.left);
    expect(
      tester.getTopLeft(cards.at(1)).dy - tester.getBottomLeft(cards.at(0)).dy,
      closeTo(kExploreCardGap, 1),
    );
    // No more dividers: the gap does the separating.
    expect(find.byType(Divider), findsNothing);

    await disposeTree(tester);
  });

  testWidgets('narrow: rows are floating cards on the page background', (
    tester,
  ) async {
    await pumpSearch(tester, const Size(400, 800));

    final items = find.byType(PostActionableItem);
    expect(items, findsNWidgets(3));
    final cards = find.ancestor(of: items, matching: find.byType(Card));
    expect(cards, findsNWidgets(3));

    // The cards carry the page's own gutter.
    expect(tester.getRect(cards.at(0)).left, closeTo(12, 1));
    expect(tester.getRect(cards.at(0)).width, closeTo(400 - 24, 1));
    expect(find.byType(Divider), findsNothing);
    // The field fills the pill's control row exactly — the same height the
    // explore bar's row uses, so the two headers line up.
    expect(
      tester.getSize(find.byType(SearchBar)).height,
      closeTo(SolSpace.control, 1),
    );
    await disposeTree(tester);
  });

  testWidgets('the app bar carries the drawer toggle the explore bar uses', (
    tester,
  ) async {
    await pumpSearch(tester, const Size(400, 800));

    // The leading slot is the same SolDrawerButton every root tab uses, so the
    // drawer opens from the same spot on either tab.
    expect(
      find.descendant(
        of: find.byType(PillAppBar),
        matching: find.byIcon(Symbols.menu_rounded),
      ),
      findsOneWidget,
    );

    // Its icon sits at the capsule's left inset, and the section picker starts
    // at the same x as the explore bar's picker: drawer box 40..64, picker
    // icon 92..112 — one control row apart, matching explore exactly.
    expect(
      tester.getRect(find.byIcon(Symbols.menu_rounded)).left,
      closeTo(40, 1),
    );
    final pickerIcon = find.descendant(
      of: find.byType(PillAppBar),
      matching: find.byIcon(Symbols.article),
    );
    expect(tester.getRect(pickerIcon).left, closeTo(92, 1));

    await disposeTree(tester);
  });

  testWidgets('wide: the results keep the explore column measure', (
    tester,
  ) async {
    await pumpSearch(tester, const Size(1400, 900));

    final items = find.byType(PostActionableItem);
    final cards = find.ancestor(of: items, matching: find.byType(Card));
    final rect = tester.getRect(cards.at(0));
    // The same centred reading measure the wide explore feed uses, so a card
    // sits on one column across the two tabs.
    expect(rect.width, closeTo(kDiscoveryWideColumnWidth - 24, 1));
    expect(rect.left, closeTo((1400 - kDiscoveryWideColumnWidth) / 2 + 12, 1));

    await disposeTree(tester);
  });

  /// While the first page loads the section shows [PostItemSkeleton]
  /// placeholders in place of the rows. They must carry the rows' own extent
  /// and content inset, or the list jumps the moment the page lands.
  Future<void> expectPlaceholderMatchesRows(
    WidgetTester tester,
    Size size,
  ) async {
    final page = Completer<void>();
    addTearDown(() {
      if (!page.isCompleted) page.complete();
    });

    await pumpSearch(tester, size, until: page.future);

    final placeholder = find.byType(PostItemSkeleton).first;
    expect(placeholder, findsOneWidget);
    expect(find.byType(PostActionableItem), findsNothing);
    // Placeholders render straight on the background: each row owns its card,
    // and the shimmer is not one of them.
    expect(
      find.ancestor(of: placeholder, matching: find.byType(Card)),
      findsNothing,
    );
    expect(
      find.descendant(of: placeholder, matching: find.byType(Card)),
      findsNothing,
    );

    final placeholderBox = tester.getRect(placeholder);
    final placeholderAvatar = tester.getRect(
      find.descendant(of: placeholder, matching: find.byType(Container)).first,
    );

    page.complete();
    await pumpUntilRows(tester);

    final row = find.byType(PostActionableItem).first;
    expect(row, findsOneWidget);
    // Every landed row sits in exactly its own card.
    expect(find.ancestor(of: row, matching: find.byType(Card)), findsOneWidget);
    final rowBox = tester.getRect(row);
    final rowAvatar = tester.getRect(
      find
          .descendant(of: row, matching: find.byType(ProfilePictureWidget))
          .first,
    );

    expect(placeholderBox.left, rowBox.left);
    expect(placeholderBox.right, rowBox.right);
    expect(placeholderAvatar.left, rowAvatar.left);
    expect(placeholderAvatar.size, rowAvatar.size);

    await disposeTree(tester);
  }

  testWidgets('narrow: the loading placeholder matches the row layout', (
    tester,
  ) async {
    await expectPlaceholderMatchesRows(tester, const Size(400, 800));
  });

  testWidgets('wide: the loading placeholder matches the row layout', (
    tester,
  ) async {
    await expectPlaceholderMatchesRows(tester, const Size(1400, 900));
  });

  /// Opens the section picker in the search bar's leading slot and switches
  /// to the section named [label].
  Future<void> selectSection(WidgetTester tester, String label) async {
    // The trigger shows the current section's label ('Posts' at launch). The
    // menu animates open, so let it settle before tapping an item: taps land
    // through the transparent overlay while it plays.
    await tester.tap(find.text('Posts'));
    await tester.pumpAndSettle();
    expect(find.byType(MenuItemButton), findsWidgets, reason: 'menu open');
    await tester.tap(find.widgetWithText(MenuItemButton, label));
    await tester.pumpAndSettle();
  }

  /// The single app bar filter action (icon-only [IconButton]).
  Finder filterAction() => find.descendant(
    of: find.byType(PillAppBar),
    matching: find.byWidgetPredicate(
      (w) =>
          w is IconButton &&
          w.icon is Icon &&
          ((w.icon as Icon).icon == Symbols.filter_list ||
              (w.icon as Icon).icon == Symbols.filter_list_off),
    ),
  );

  Finder postList() =>
      find.byWidgetPredicate((w) => w is PaginationList<SnPost>);

  testWidgets('narrow: the app bar action toggles the posts filter panel', (
    tester,
  ) async {
    await pumpSearch(tester, const Size(400, 800));

    // Only the app bar action exists — the section no longer carries its own.
    expect(find.byIcon(Symbols.filter_list), findsOneWidget);
    expect(find.byType(PostFilterWidget), findsNothing);

    await tester.tap(filterAction());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byIcon(Symbols.filter_list_off), findsOneWidget);
    expect(find.byType(PostFilterWidget), findsOneWidget);

    await tester.tap(filterAction());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byIcon(Symbols.filter_list), findsOneWidget);
    expect(find.byType(PostFilterWidget), findsNothing);

    await disposeTree(tester);
  });

  testWidgets('wide: the app bar action toggles the posts filter panel', (
    tester,
  ) async {
    await pumpSearch(tester, const Size(1400, 900));

    // The sidebar is closed at rest, so the filter panel is not mounted; the
    // action slides it in.
    expect(find.byType(PostFilterWidget), findsNothing);
    await tester.tap(filterAction());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(PostFilterWidget), findsOneWidget);

    await disposeTree(tester);
  });

  testWidgets('narrow: scrolling the posts results does not toggle filters', (
    tester,
  ) async {
    // A short viewport makes the three canned rows overflow and scroll.
    await pumpSearch(tester, const Size(400, 280));

    final scrollable = find
        .descendant(of: postList(), matching: find.byType(Scrollable))
        .first;
    final firstRow = find.byType(PostActionableItem).first;
    final start = tester.getTopLeft(firstRow).dy;

    // Scroll down first so the upward leg actually moves the list.
    await tester.drag(scrollable, const Offset(0, -160));
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      tester.getTopLeft(firstRow).dy,
      lessThan(start),
      reason: 'the list should have scrolled down',
    );

    // Scrolling back up previously revealed the filter panel.
    await tester.drag(scrollable, const Offset(0, 160));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(PostFilterWidget), findsNothing);

    await disposeTree(tester);
  });

  testWidgets('the filter action is disabled on sections without filters', (
    tester,
  ) async {
    await pumpSearch(tester, const Size(400, 800));

    expect(tester.widget<IconButton>(filterAction()).onPressed, isNotNull);

    await selectSection(tester, 'Accounts');
    expect(tester.widget<IconButton>(filterAction()).onPressed, isNull);

    await disposeTree(tester);
  });

  testWidgets('the messages section reuses the app bar filter action', (
    tester,
  ) async {
    await pumpSearch(tester, const Size(400, 800), database: AppDatabase.web());

    await selectSection(tester, 'Messages');
    await tester.pump(const Duration(milliseconds: 300));

    // No per-view trigger remains, and the filter bar starts collapsed.
    expect(find.byIcon(Symbols.filter_list), findsOneWidget);
    expect(find.byIcon(Symbols.cloud), findsNothing);

    await tester.tap(filterAction());
    // One frame for the switch to start, then its animation.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byIcon(Symbols.cloud), findsOneWidget);

    await disposeTree(tester);
  });

  /// The page's pill is the scaffold's app bar, drawn *over* the body
  /// (`extendBodyBehindAppBar`). Every section therefore has to reserve the
  /// pill's whole band — the status-bar inset plus the capsule — or its first
  /// row starts underneath the capsule.
  testWidgets('narrow: the first result clears the whole pill band', (
    tester,
  ) async {
    const statusTop = 44.0;
    await pumpSearch(tester, const Size(400, 880), statusTop: statusTop);

    final pill = tester.getRect(find.byType(PillAppBar));
    expect(pill.bottom, closeTo(statusTop + kPillAppBarHeight, 1));

    final firstRow = tester.getRect(find.byType(PostActionableItem).first);
    expect(
      firstRow.top,
      greaterThanOrEqualTo(pill.bottom),
      reason: 'results must start below the capsule, not behind it',
    );

    await disposeTree(tester);
  });

  testWidgets('wide: the filter pane clears the pill and paints no surface', (
    tester,
  ) async {
    const statusTop = 44.0;
    await pumpSearch(tester, const Size(1400, 900), statusTop: statusTop);

    await tester.tap(filterAction());
    await tester.pump(const Duration(milliseconds: 400));

    final panel = find.byType(PostFilterWidget);
    expect(panel, findsOneWidget);
    // The pane is a column of controls over the page ground, so its first
    // control starts below the pill rather than behind it.
    expect(
      tester.getRect(panel).top,
      greaterThanOrEqualTo(statusTop + kPillAppBarHeight),
      reason: 'the filter pane must not slide under the pill',
    );

    await disposeTree(tester);
  });

  testWidgets('wide: the first result clears the whole pill band', (
    tester,
  ) async {
    const statusTop = 44.0;
    await pumpSearch(tester, const Size(1400, 900), statusTop: statusTop);

    final pill = tester.getRect(find.byType(PillAppBar));
    final firstRow = tester.getRect(find.byType(PostActionableItem).first);
    expect(firstRow.top, greaterThanOrEqualTo(pill.bottom));

    await disposeTree(tester);
  });
}
