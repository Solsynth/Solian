import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/config.dart';
import 'package:island/posts/widgets/post_detail_content.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class _UserInfoGuest extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => null;
}

SnPost _article({String? content}) {
  return SnPost.fromJson({
    'id': 'post-1',
    'type': 1,
    'title': 'The Headline',
    'content':
        content ??
        'intro paragraph\n\n'
            '# First Section\n\n'
            '${'first body text. ' * 80}\n\n'
            '## Second Section\n\n'
            '${'second body text. ' * 80}\n',
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  });
}

Widget _wrap(Widget child) {
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
          overrides: [
            sharedPreferencesProvider.overrideWithValue(_prefs),
            userInfoProvider.overrideWith(_UserInfoGuest.new),
          ],
          child: mui.Material(child: child),
        ),
      ),
    ),
  );
}

Widget _content({required SnPost post, bool showToc = true}) {
  return PostDetailContent(
    postId: post.id,
    post: post,
    showTableOfContents: showToc,
    onRefresh: () async {},
    onUpdate: (_) {},
    onReplyPosted: () {},
    interactionsSection: const SliverToBoxAdapter(child: SizedBox.shrink()),
    actionBuilder: (context, onTranslate) => const SizedBox.shrink(),
  );
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(_wrap(child));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pumpAndSettle();
}

late SharedPreferences _prefs;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    _prefs = await SharedPreferences.getInstance();
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('floating TOC button appears only when enabled and content has '
      'sections', (tester) async {
    await _pump(
      tester,
      _content(post: _article(), showToc: true),
    );
    expect(find.byTooltip('Contents'), findsOneWidget);

    // The entry point is opt-in: preview surfaces keep it hidden.
    await _pump(
      tester,
      _content(post: _article(), showToc: false),
    );
    expect(find.byTooltip('Contents'), findsNothing);

    // No headings, no contents: the button would be a dead tap.
    await _pump(
      tester,
      _content(
        post: _article(content: 'just a plain paragraph without headings.'),
        showToc: true,
      ),
    );
    expect(find.byTooltip('Contents'), findsNothing);
  });

  testWidgets('TOC button opens a sheet listing the article sections', (
    tester,
  ) async {
    await _pump(tester, _content(post: _article()));
    await tester.tap(find.byTooltip('Contents'));
    await tester.pumpAndSettle();

    final sheet = find.byType(SheetScaffold);
    expect(sheet, findsOneWidget);
    expect(
      find.descendant(of: sheet, matching: find.text('Contents')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sheet, matching: find.text('First Section')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sheet, matching: find.text('Second Section')),
      findsOneWidget,
    );
  });

  testWidgets('tapping a section entry jumps the article to that heading', (
    tester,
  ) async {
    await _pump(tester, _content(post: _article()));

    // The second heading starts well below the viewport.
    final secondHeading = find.text('Second Section');
    expect(tester.getTopLeft(secondHeading).dy, greaterThan(600));

    await tester.tap(find.byTooltip('Contents'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(SheetScaffold),
        matching: find.text('Second Section'),
      ),
    );
    await tester.pumpAndSettle();

    // The sheet is gone and the heading now sits near the top of the article.
    expect(find.byType(SheetScaffold), findsNothing);
    expect(tester.getTopLeft(secondHeading).dy, lessThan(200));
  });
}
