import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

SnPost _articleBody({String? content}) {
  return SnPost.fromJson({
    'id': 'post-1',
    'type': 1,
    'title': 'The Headline',
    'description': 'A short standfirst.',
    'content':
        content ??
        'intro paragraph\n\n'
            '# First Section\n\n'
            '${'body text. ' * 40}\n\n'
            '## Second Section\n\n'
            '${'more text. ' * 40}\n',
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
          child: mui.Material(child: SingleChildScrollView(child: child)),
        ),
      ),
    ),
  );
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(_wrap(child));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('captures article headings with their level and text', (
    tester,
  ) async {
    final registry = MarkdownHeadingRegistry();
    await _pump(
      tester,
      MarkdownTextContent(
        content: '# Intro\n\nbody\n\n## Details\n\nmore\n\n### Wrap up\n',
        headingAnchors: registry,
      ),
    );

    expect(registry.items.map((a) => a.text).toList(), [
      'Intro',
      'Details',
      'Wrap up',
    ]);
    expect(registry.items.map((a) => a.level).toList(), [1, 2, 3]);
    expect(find.text('Intro'), findsOneWidget);
    expect(find.text('Details'), findsOneWidget);
  });

  testWidgets('leaves no anchors when the body has no headings', (
    tester,
  ) async {
    final registry = MarkdownHeadingRegistry();
    await _pump(
      tester,
      MarkdownTextContent(
        content: 'just a paragraph\n\nand another',
        headingAnchors: registry,
      ),
    );

    expect(registry.items, isEmpty);
  });

  testWidgets('ignores hash lines inside fenced code blocks', (tester) async {
    final registry = MarkdownHeadingRegistry();
    await _pump(
      tester,
      MarkdownTextContent(
        content: '# Real\n\n```\n# not a heading\n```\n\n## Also real\n',
        headingAnchors: registry,
      ),
    );

    expect(registry.items.map((a) => a.text).toList(), ['Real', 'Also real']);
  });

  testWidgets('repeated identical headings scroll to distinct anchors', (
    tester,
  ) async {
    final registry = MarkdownHeadingRegistry();
    await _pump(
      tester,
      MarkdownTextContent(
        content: '## Summary\n\none\n\n## Summary\n\ntwo\n',
        headingAnchors: registry,
      ),
    );

    expect(registry.items.length, 2);
    expect(
      identical(registry.items[0].key, registry.items[1].key),
      isFalse,
      reason: 'two headings must not share one GlobalKey',
    );
  });

  testWidgets('reuses anchors across rebuilds of the same body', (
    tester,
  ) async {
    final registry = MarkdownHeadingRegistry();
    final content = '# Intro\n\nbody\n\n## Details\n\nmore\n';
    await _pump(
      tester,
      MarkdownTextContent(content: content, headingAnchors: registry),
    );
    final firstKeys = registry.items.map((a) => a.key).toList();

    await tester.pump();
    await tester.pumpAndSettle();

    expect(registry.items.map((a) => a.key).toList(), firstKeys);
  });

  testWidgets('markdown without a registry renders headings unchanged', (
    tester,
  ) async {
    await _pump(tester, const MarkdownTextContent(content: '# Plain heading\n'));

    expect(find.text('Plain heading'), findsOneWidget);
  });

  testWidgets('comments header label resolves through plural(), not tr()', (
    tester,
  ) async {
    // repliesCount is a plural map (zero/one/other) in the locale files.
    // Resolving it with tr() hands that Map to a String sink and throws
    // "_Map<String, dynamic> is not a subtype of type 'String?'".
    late String label;
    await _pump(
      tester,
      Builder(
        builder: (context) {
          label = 'repliesCount'.plural(3);
          return Text(label);
        },
      ),
    );

    expect(label, '3 replies');
    expect(find.text('3 replies'), findsOneWidget);
  });

  testWidgets('comments header label covers the zero and one forms', (
    tester,
  ) async {
    late List<String> labels;
    await _pump(
      tester,
      Builder(
        builder: (context) {
          labels = [
            'repliesCount'.plural(0),
            'repliesCount'.plural(1),
            'repliesCount'.plural(12),
          ];
          return Text(labels.join('|'));
        },
      ),
    );

    expect(labels, ['No reply', '1 reply', '12 replies']);
  });

  testWidgets('article body mode drops the headline it re-renders itself', (
    tester,
  ) async {
    final registry = MarkdownHeadingRegistry();
    await _pump(
      tester,
      PostBody(
        item: _articleBody(),
        isFullPost: true,
        hideTitle: true,
        hideDescription: true,
        headingAnchors: registry,
      ),
    );

    expect(find.text('The Headline'), findsNothing);
    expect(find.text('A short standfirst.'), findsNothing);
    expect(registry.items.map((a) => a.text).toList(), [
      'First Section',
      'Second Section',
    ]);
  });

  testWidgets('article body keeps the headline when not overridden', (
    tester,
  ) async {
    await _pump(tester, PostBody(item: _articleBody(), isFullPost: true));

    expect(find.text('The Headline'), findsOneWidget);
    expect(find.text('A short standfirst.'), findsOneWidget);
  });

  testWidgets('scrolling to a captured anchor moves the article scroll view', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final registry = MarkdownHeadingRegistry();
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await _pump(
      tester,
      SizedBox(
        height: 600,
        child: CustomScrollView(
          controller: controller,
          slivers: [
            SliverToBoxAdapter(
              child: PostBody(
                item: _articleBody(),
                isFullPost: true,
                hideTitle: true,
                hideDescription: true,
                headingAnchors: registry,
              ),
            ),
          ],
        ),
      ),
    );

    expect(controller.position.maxScrollExtent, greaterThan(0));
    expect(controller.offset, 0);

    final secondSection = registry.items[1].key.currentContext;
    expect(secondSection, isNotNull);
    // Jump straight to the anchor: an animated ensureVisible would need frames
    // pumped to complete, which is not what this test is asserting.
    await Scrollable.ensureVisible(secondSection!, alignment: 0.0);
    await tester.pumpAndSettle();

    expect(
      controller.offset,
      greaterThan(0),
      reason: 'the second heading sits below the fold',
    );
  }, timeout: const Timeout(Duration(seconds: 60)));
}
