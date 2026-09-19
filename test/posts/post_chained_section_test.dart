import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/posts/pods/post_chain.dart';
import 'package:island/posts/widgets/compose/post_chained_section.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:dio/dio.dart';
import 'package:island/core/network.dart';
import 'package:island/creators/screens/publishers_form.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

SnPost _post(String id, String content) {
  return SnPost.fromJson({
    'id': id,
    'type': 0,
    'content': content,
    'chained_posts': const [],
    'publisher': {'id': 'publisher-$id', 'name': 'alice', 'nick': 'Alice'},
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Future<void> pumpSection(WidgetTester tester, Widget section) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.runAsync(() async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en', 'US')],
          path: 'assets/i18n',
          saveLocale: false,
          child: Builder(
            builder: (context) => mui.MaterialApp(
              locale: const Locale('en', 'US'),
              supportedLocales: const [Locale('en', 'US')],
              home: mui.Material(
                child: ProviderScope(
                  overrides: [
                    sharedPreferencesProvider.overrideWithValue(prefs),
                    publishersManagedProvider.overrideWith(
                      (ref) async => <SnPublisher>[],
                    ),
                    apiClientProvider.overrideWith((ref) => Dio()),
                  ],
                  child: section,
                ),
              ),
              localizationsDelegates: context.localizationDelegates,
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
  }

  testWidgets('renders nothing when the head has no chained posts', (
    tester,
  ) async {
    final head = _post('head', 'root');
    await pumpSection(tester, PostChainedSection(head: head));
    expect(find.text('first', findRichText: true), findsNothing);
  });

  testWidgets('renders each chained post threaded under the head', (
    tester,
  ) async {
    final head = SnPost.fromJson({
      ..._post('head', 'root').toJson(),
      'chained_posts': [
        _post('c1', 'first').toJson(),
        _post('c2', 'second').toJson(),
      ],
    });
    await pumpSection(tester, PostChainedSection(head: head));
    expect(find.text('root'), findsNothing); // head body is not re-rendered
    expect(find.text('first', findRichText: true), findsOneWidget);
    expect(find.text('second', findRichText: true), findsOneWidget);
    // Each child avatar is drawn on the rail.
    expect(find.byType(PostAvatar), findsNWidgets(2));
  });

  testWidgets('aligns chained head content with its header column', (
    tester,
  ) async {
    final head = SnPost.fromJson({
      ..._post('head', 'root').toJson(),
      'chained_posts': [_post('c1', 'first').toJson()],
    });
    await pumpSection(tester, PostItem(item: head));

    final headContent = find.text('root', findRichText: true);
    final childContent = find.text('first', findRichText: true);
    final headName = find.text('Alice').first;

    expect(
      tester.getTopLeft(headContent).dx,
      tester.getTopLeft(childContent).dx,
    );
    expect(tester.getTopLeft(headName).dx, tester.getTopLeft(headContent).dx);
    // Head and chained avatars share one column so the threading line runs
    // vertically through both.
    final avatars = find.byType(PostAvatar);
    expect(
      tester.getCenter(avatars.first).dx,
      tester.getCenter(avatars.last).dx,
    );
  });

  testWidgets('onPostTap is forwarded to chained posts', (tester) async {
    final head = SnPost.fromJson({
      ..._post('head', 'root').toJson(),
      'chained_posts': [_post('c1', 'first').toJson()],
    });
    String? tapped;
    await pumpSection(
      tester,
      PostChainedSection(head: head, onPostTap: (id) => tapped = id),
    );
    await tester.tap(find.text('first', findRichText: true));
    await tester.pumpAndSettle();
    expect(tapped, 'c1');
  });

  testWidgets('spaces chained rows apart', (tester) async {
    final head = SnPost.fromJson({
      ..._post('head', 'root').toJson(),
      'chained_posts': [
        _post('c1', 'first').toJson(),
        _post('c2', 'second').toJson(),
      ],
    });
    await pumpSection(tester, PostChainedSection(head: head));

    // One row gap per non-last child: in the rail column and the content
    // column of the first row; the last row carries none.
    final gaps = find
        .descendant(
          of: find.byType(PostChainedSection),
          matching: find.byType(Gap),
        )
        .evaluate()
        .where(
          (e) =>
              (e.renderObject as RenderBox?)?.size.height == kChainedRowGap,
        )
        .toList();
    expect(gaps.length, 2);

    // The rail-column gap sits directly under the child's avatar, inside
    // the rail span, so the thread column stays connected.
    final avatar = tester.getRect(find.byType(PostAvatar).first);
    final railGap = tester.getRect(
      find.byWidget(gaps.first.widget),
    );
    expect(railGap.top, moreOrLessEquals(avatar.bottom, epsilon: 0.5));
  });

  testWidgets('keeps the rail continuous across the row gap', (tester) async {
    final head = SnPost.fromJson({
      ..._post('head', 'root').toJson(),
      'chained_posts': [
        _post('c1', 'first').toJson(),
        _post('c2', 'second').toJson(),
      ],
    });
    await pumpSection(tester, PostChainedSection(head: head));

    final lines = find.descendant(
      of: find.byType(PostChainedSection),
      matching: find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == kPostThreadingLineWidth,
      ),
    );
    expect(lines, findsNWidgets(2));

    // The next row's rail starts exactly where the previous one ends.
    final first = tester.getRect(lines.at(0));
    final second = tester.getRect(lines.at(1));
    expect(second.top, moreOrLessEquals(first.bottom, epsilon: 0.5));
    expect(second.left, moreOrLessEquals(first.left, epsilon: 0.5));
  });

  testWidgets('collapses chains longer than three children', (tester) async {
    final head = SnPost.fromJson({
      ..._post('head', 'root').toJson(),
      'chained_posts': [
        _post('c1', 'first').toJson(),
        _post('c2', 'second').toJson(),
        _post('c3', 'third').toJson(),
        _post('c4', 'fourth').toJson(),
        _post('c5', 'fifth').toJson(),
      ],
    });
    await pumpSection(tester, PostChainedSection(head: head));

    // Only the first three children render; the rest hide behind the row.
    expect(find.byType(PostAvatar), findsNWidgets(3));
    expect(find.text('first', findRichText: true), findsOneWidget);
    expect(find.text('third', findRichText: true), findsOneWidget);
    expect(find.text('fifth', findRichText: true), findsNothing);
    expect(find.text('Show 2 more'), findsOneWidget);

    await tester.tap(find.text('Show 2 more'));
    await tester.pumpAndSettle();

    expect(find.byType(PostAvatar), findsNWidgets(5));
    expect(find.text('fifth', findRichText: true), findsOneWidget);
    expect(find.text('Show 2 more'), findsNothing);
  });

  testWidgets('keeps the rail continuous in the collapsed state', (
    tester,
  ) async {
    final head = SnPost.fromJson({
      ..._post('head', 'root').toJson(),
      'chained_posts': [
        _post('c1', 'first').toJson(),
        _post('c2', 'second').toJson(),
        _post('c3', 'third').toJson(),
        _post('c4', 'fourth').toJson(),
      ],
    });
    await pumpSection(tester, PostChainedSection(head: head));

    final lines = find.descendant(
      of: find.byType(PostChainedSection),
      matching: find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == kPostThreadingLineWidth,
      ),
    );
    // Three child rails plus the terminal stub on the expand row.
    expect(lines, findsNWidgets(4));
    final third = tester.getRect(lines.at(2));
    final stub = tester.getRect(lines.at(3));
    expect(stub.top, moreOrLessEquals(third.bottom, epsilon: 0.5));
    expect(stub.left, moreOrLessEquals(third.left, epsilon: 0.5));
  });

  group('splitChainMembers', () {
    test('splits the chain around the current member', () {
      final chain = [
        _post('head', 'root'),
        _post('c1', 'first'),
        _post('c2', 'second'),
      ];

      final split = splitChainMembers(chain, 'c1');

      expect(split.preceding.map((e) => e.id), ['head']);
      expect(split.following.map((e) => e.id), ['c2']);
    });

    test('a chain head has nothing before it', () {
      final chain = [_post('head', 'root'), _post('c1', 'first')];

      final split = splitChainMembers(chain, 'head');

      expect(split.preceding, isEmpty);
      expect(split.following.map((e) => e.id), ['c1']);
    });

    test('an anchor missing from the chain reads as context only', () {
      final chain = [_post('head', 'root'), _post('c1', 'first')];

      final split = splitChainMembers(chain, 'invisible');

      expect(split.preceding.map((e) => e.id), ['head', 'c1']);
      expect(split.following, isEmpty);
    });
  });

  testWidgets('renders the members passed in place of the post own', (
    tester,
  ) async {
    // A chained post carries no members of its own: the detail screen passes the
    // rest of the chain in, and those are what renders.
    final current = SnPost.fromJson({
      ..._post('c1', 'first').toJson(),
      'chained_post_id': 'head',
      'chained_posts': [_post('stale', 'stale').toJson()],
    });

    await pumpSection(
      tester,
      PostChainedSection(
        head: current,
        children: [_post('c2', 'second')],
      ),
    );

    expect(find.text('second', findRichText: true), findsOneWidget);
    expect(find.text('stale', findRichText: true), findsNothing);
  });

  testWidgets('renders the members that precede a post, head first', (
    tester,
  ) async {
    await pumpSection(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostChainPrecedingSection(
            posts: [_post('head', 'root'), _post('c1', 'first')],
          ),
        ],
      ),
    );

    final root = tester.getRect(find.text('root', findRichText: true));
    final first = tester.getRect(find.text('first', findRichText: true));
    expect(root.top, lessThan(first.top));

    // The last row's rail runs all the way to the section's bottom edge, so the
    // post below continues it instead of the thread breaking off.
    final lines = find.descendant(
      of: find.byType(PostChainPrecedingSection),
      matching: find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == kPostThreadingLineWidth,
      ),
    );
    expect(lines, findsNWidgets(2));
    expect(
      tester.getRect(lines.last).bottom,
      moreOrLessEquals(
        tester.getRect(find.byType(PostChainPrecedingSection)).bottom,
        epsilon: 0.5,
      ),
    );
  });

  testWidgets('collapses long preambles to the rows closest to the post', (
    tester,
  ) async {
    await pumpSection(
      tester,
      PostChainPrecedingSection(
        posts: [for (var i = 0; i < 5; i++) _post('c$i', 'member$i')],
      ),
    );

    expect(find.byType(PostAvatar), findsNWidgets(3));
    expect(find.text('member2', findRichText: true), findsOneWidget);
    expect(find.text('member4', findRichText: true), findsOneWidget);
    expect(find.text('member0', findRichText: true), findsNothing);
    expect(find.text('Show 2 more'), findsOneWidget);

    await tester.tap(find.text('Show 2 more'));
    await tester.pumpAndSettle();

    expect(find.byType(PostAvatar), findsNWidgets(5));
    expect(find.text('member0', findRichText: true), findsOneWidget);
    expect(find.text('Show 2 more'), findsNothing);
  });

  testWidgets('onPostTap is forwarded from the preceding members', (
    tester,
  ) async {
    String? tapped;
    await pumpSection(
      tester,
      PostChainPrecedingSection(
        posts: [_post('head', 'root')],
        onPostTap: (id) => tapped = id,
      ),
    );

    await tester.tap(find.text('root', findRichText: true));
    await tester.pumpAndSettle();

    expect(tapped, 'head');
  });

  /// The chain columns the detail screen builds around the post it shows: the
  /// members before it, the post itself, then the members that follow. Each
  /// column is inset like the detail screen insets it, so the avatars are
  /// expected to land on one rail.
  Future<void> pumpChainColumns(
    WidgetTester tester, {
    required SnPost post,
    required List<SnPost> preceding,
    required List<SnPost> following,
  }) {
    return pumpSection(
      tester,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (preceding.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: PostChainPrecedingSection(posts: preceding),
            ),
          PostItem(
            item: post,
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
            connectChainAbove: preceding.isNotEmpty,
            connectChainBelow: following.isNotEmpty,
          ),
          if (following.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PostChainedSection(head: post, children: following),
            ),
        ],
      ),
    );
  }

  testWidgets('threads the post into the members above it', (tester) async {
    final post = _post('c1', 'current');
    await pumpChainColumns(
      tester,
      post: post,
      preceding: [_post('head', 'root')],
      following: const [],
    );

    // The upper line of the header carries the rail from the row above down to
    // the avatar, so the column reads as one thread instead of a gap.
    final stub = find.descendant(
      of: find.byType(PostHeader),
      matching: find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.constraints ==
                const BoxConstraints.tightFor(
                  width: kPostThreadingLineWidth,
                  height: 12,
                ),
      ),
    );
    expect(stub, findsOneWidget);

    final precedingSection = find.byType(PostChainPrecedingSection);
    final avatars = find.byType(PostAvatar);
    final rowRail = find.descendant(
      of: precedingSection,
      matching: find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == kPostThreadingLineWidth,
      ),
    );

    expect(
      tester.getRect(stub).top,
      moreOrLessEquals(tester.getRect(precedingSection).bottom, epsilon: 0.5),
    );
    expect(
      tester.getRect(stub).bottom,
      moreOrLessEquals(tester.getRect(avatars.last).top, epsilon: 0.5),
    );
    // Both avatars share the rail the rows are drawn on.
    expect(
      tester.getCenter(avatars.last).dx,
      moreOrLessEquals(tester.getCenter(avatars.first).dx, epsilon: 0.5),
    );
    expect(
      tester.getRect(stub).left,
      moreOrLessEquals(tester.getRect(rowRail).left, epsilon: 0.5),
    );
  });

  testWidgets('keeps the rail open for the members below the post', (
    tester,
  ) async {
    final post = _post('c1', 'current');
    await pumpChainColumns(
      tester,
      post: post,
      preceding: const [],
      following: [_post('c2', 'next')],
    );

    final itemRail = find.descendant(
      of: find.byType(PostItem).first,
      matching: find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == kPostThreadingLineWidth,
      ),
    );
    final nextRail = find.descendant(
      of: find.byType(PostChainedSection),
      matching: find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == kPostThreadingLineWidth,
      ),
    );
    expect(itemRail, findsOneWidget);
    expect(nextRail, findsOneWidget);

    final avatars = find.byType(PostAvatar);
    expect(
      tester.getRect(itemRail).top,
      moreOrLessEquals(tester.getRect(avatars.first).bottom, epsilon: 0.5),
    );
    // The rail reaches the bottom of the post, where the following row picks it
    // up, so the thread never breaks between them.
    expect(
      tester.getRect(itemRail).bottom,
      moreOrLessEquals(tester.getRect(nextRail).top, epsilon: 0.5),
    );
    expect(
      tester.getRect(itemRail).bottom,
      moreOrLessEquals(
        tester.getRect(find.byType(PostItem).first).bottom,
        epsilon: 0.5,
      ),
    );
    expect(
      tester.getRect(itemRail).left,
      moreOrLessEquals(tester.getRect(nextRail).left, epsilon: 0.5),
    );
    expect(
      tester.getCenter(avatars.last).dx,
      moreOrLessEquals(tester.getCenter(avatars.first).dx, epsilon: 0.5),
    );
  });
}
