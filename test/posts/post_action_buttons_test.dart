import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/posts/pods/bookmarks.dart';
import 'package:island/posts/screens/post_detail.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final _account = SnAccount.fromJson({
  'id': 'account-1',
  'name': 'alice',
  'nick': 'Alice',
  'language': 'en-US',
  'is_superuser': false,
  'automated_id': null,
  'profile': {
    'id': 'profile-1',
    'experience': 0,
    'level': 0,
    'leveling_progress': 0.0,
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  },
  'perk_subscription': null,
  'activated_at': '2026-01-01T00:00:00Z',
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
  'deleted_at': null,
});

class _UserInfoAuthor extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => _account;
}

class _UserInfoGuest extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => null;
}

SnPost _post({
  int repliesCount = 0,
  int awardedScore = 0,
  int viewsTotal = 0,
  String? publisherAccountId,
  String? content = 'hello',
}) {
  return SnPost.fromJson({
    'id': 'post-1',
    'type': 0,
    'content': content,
    'replies_count': repliesCount,
    'awarded_score': awardedScore,
    'views_total': viewsTotal,
    if (publisherAccountId != null)
      'publisher': {
        'id': 'publisher-1',
        'name': 'alice',
        'nick': 'Alice',
        'account_id': publisherAccountId,
      },
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  });
}

Widget _wrap(Widget child, {List<Object?> overrides = const []}) {
  return EasyLocalization(
    supportedLocales: const [Locale('en', 'US')],
    path: 'assets/i18n',
    saveLocale: false,
    child: Builder(
      builder: (context) => mui.MaterialApp(
        locale: const Locale('en', 'US'),
        supportedLocales: const [Locale('en', 'US')],
        localizationsDelegates: context.localizationDelegates,
        theme: mui.ThemeData(
          colorScheme: mui.ColorScheme.fromSeed(seedColor: Colors.indigo),
        ),
        home: ProviderScope(
          overrides: overrides.cast(),
          child: mui.Material(child: child),
        ),
      ),
    ),
  );
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  List<Object?> overrides = const [],
}) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(_wrap(child, overrides: overrides));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pumpAndSettle();
}

List<Object?> _overrides({
  required UserInfoNotifier user,
  bool bookmarked = false,
}) {
  return [
    userInfoProvider.overrideWith(() => user),
    bookmarkStatusProvider.overrideWith(
      (ref, postId) async => bookmarked
          ? SnPostBookmark.fromJson({
              'id': 'bm-1',
              'post_id': postId,
              'account_id': 'account-1',
              'created_at': '2026-01-01T00:00:00Z',
              'updated_at': '2026-01-01T00:00:00Z',
            })
          : null,
    ),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('rail shows live reply count and award pts', (tester) async {
    await _pump(
      tester,
      PostActionButtons(
        post: _post(repliesCount: 12, awardedScore: 240, viewsTotal: 1200),
      ),
      overrides: _overrides(user: _UserInfoGuest()),
    );

    expect(find.text('Reply'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Forward'), findsOneWidget);
    expect(find.text('Bookmark'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('240 pts'), findsOneWidget);
    expect(find.text('Thread'), findsOneWidget);
  });

  testWidgets('counts stay hidden while the post has no standing', (
    tester,
  ) async {
    await _pump(
      tester,
      PostActionButtons(post: _post()),
      overrides: _overrides(user: _UserInfoGuest()),
    );

    expect(find.text('Reply'), findsOneWidget);
    expect(find.text('12'), findsNothing);
    expect(find.text('240 pts'), findsNothing);
    // The award action remains available even at zero points.
    expect(find.text('Award'), findsOneWidget);
  });

  testWidgets('bookmarked post renders the selected state', (tester) async {
    await _pump(
      tester,
      PostActionButtons(post: _post()),
      overrides: _overrides(user: _UserInfoGuest(), bookmarked: true),
    );

    expect(find.byIcon(Symbols.bookmark_added), findsOneWidget);
    expect(find.text('Unbookmark'), findsOneWidget);
  });

  testWidgets('author console renders for the author', (tester) async {
    final authorPost = _post(publisherAccountId: 'account-1');

    await _pump(
      tester,
      PostActionButtons(post: authorPost),
      overrides: _overrides(user: _UserInfoAuthor()),
    );

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Pin Post'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('author console stays hidden for guests', (tester) async {
    final authorPost = _post(publisherAccountId: 'account-1');

    await _pump(
      tester,
      PostActionButtons(post: authorPost),
      overrides: _overrides(user: _UserInfoGuest()),
    );

    expect(find.text('Edit'), findsNothing);
    expect(find.text('Pin Post'), findsNothing);
    expect(find.text('Delete'), findsNothing);
  });

  testWidgets(
    'translate shows disabled with hint for short or missing content',
    (tester) async {
      for (final content in [null, '', '   ', 'hi', 'thanks a lot!']) {
        await _pump(
          tester,
          PostActionButtons(
            post: _post(content: content),
            onTranslate: (_) async {},
          ),
          overrides: _overrides(user: _UserInfoGuest()),
        );
        expect(
          find.text('Translate'),
          findsOneWidget,
          reason: 'content: $content',
        );
        expect(
          find.byTooltip('Too short to translate'),
          findsOneWidget,
          reason: 'content: $content',
        );
      }
    },
  );

  testWidgets('translate enabled for substantial content', (tester) async {
    await _pump(
      tester,
      PostActionButtons(
        post: _post(
          content: 'This post is long enough to be worth translating.',
        ),
        onTranslate: (_) async {},
      ),
      overrides: _overrides(user: _UserInfoGuest()),
    );

    expect(find.text('Translate'), findsOneWidget);
    expect(find.byTooltip('Too short to translate'), findsNothing);
  });

  testWidgets('translate hidden when no handler is provided', (tester) async {
    await _pump(
      tester,
      PostActionButtons(
        post: _post(
          content: 'This post is long enough to be worth translating.',
        ),
      ),
      overrides: _overrides(user: _UserInfoGuest()),
    );

    expect(find.text('Translate'), findsNothing);
  });

  testWidgets('share opens chooser with link and photo options', (
    tester,
  ) async {
    await _pump(
      tester,
      PostActionButtons(post: _post()),
      overrides: _overrides(user: _UserInfoGuest()),
    );

    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();

    expect(find.text('Share Post'), findsOneWidget);
    expect(find.text('Share Post as Photo'), findsOneWidget);
  });

  testWidgets('rail lays out without overflow on narrow and wide widths', (
    tester,
  ) async {
    for (final logicalWidth in [320.0, 360.0, 640.0]) {
      tester.view.physicalSize = Size(logicalWidth * 2, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await _pump(
        tester,
        PostActionButtons(
          post: _post(repliesCount: 1234, awardedScore: 240, viewsTotal: 1200),
        ),
        overrides: _overrides(user: _UserInfoGuest()),
      );

      expect(
        tester.takeException(),
        isNull,
        reason: 'overflow at $logicalWidth logical px',
      );
      expect(find.text('Reply'), findsOneWidget);
    }
  });
}
