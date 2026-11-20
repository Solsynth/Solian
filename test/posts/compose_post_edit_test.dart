import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/screens/me/account_settings.dart';
import 'package:island/core/config.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/creators/screens/publishers_form.dart';
import 'package:island/data/database.dart';
import 'package:island/posts/screens/compose_post.dart';
import 'package:island/posts/screens/post_detail.dart';
import 'package:island/posts/widgets/compose/block_content_editor.dart';
import 'package:island/posts/widgets/compose/compose_card.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';
import 'package:island/posts/widgets/compose/compose_state_utils.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Answers every request with an empty list so nothing touches the network.
class _EmptyResponseAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? _,
    Future<void>? _,
  ) async => ResponseBody.fromString(
    jsonEncode(const []),
    200,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
      'x-total': ['0'],
    },
  );
}

SnPublisher _publisher() => SnPublisher.fromJson({
  'id': 'publisher',
  'type': 0,
  'name': 'publisher',
  'nick': 'P',
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
});

SnPost _post({
  required String content,
  String id = 'post',
  bool truncated = false,
}) => SnPost.fromJson({
  'id': id,
  'type': 0,
  'content': content,
  'is_truncated': truncated,
  'chained_posts': const [],
  'publisher': _publisher().toJson(),
  'published_at': '2026-01-01T00:00:00Z',
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
});

/// Mounts the fields exactly as the composer does, with [current] swappable
/// the way a composer swaps its state when a post arrives.
class _EditorHost extends HookWidget {
  final ValueNotifier<ComposeState?> current;

  const _EditorHost({required this.current});

  @override
  Widget build(BuildContext context) {
    final state = useValueListenable(current);
    if (state == null) return const SizedBox(height: 48);
    ComposeStateUtils.useEditorBootstrap(state);
    return BlockContentEditor(state: state, enabled: true);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final publisher = _publisher();
  late AppDatabase database;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    database = AppDatabase.web();
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    Future<SnPost?> Function()? fullPost,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.runAsync(() async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en', 'US')],
          path: 'assets/i18n',
          saveLocale: false,
          child: ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
              databaseProvider.overrideWithValue(database),
              apiClientProvider.overrideWithValue(
                Dio()..httpClientAdapter = _EmptyResponseAdapter(),
              ),
              publishersManagedProvider.overrideWith(
                (ref) async => <SnPublisher>[publisher],
              ),
              publishingSettingsProvider.overrideWith(
                (ref) async => SnPublishingSettings(
                  id: 'settings',
                  accountId: 'account',
                  defaultPostingPublisherId: publisher.id,
                  createdAt: DateTime.utc(2026, 1, 1),
                ),
              ),
              if (fullPost != null)
                postProvider('post').overrideWith((ref) => fullPost()),
            ],
            child: Builder(
              builder: (context) => mui.MaterialApp(
                locale: const Locale('en', 'US'),
                supportedLocales: const [Locale('en', 'US')],
                localizationsDelegates: [...context.localizationDelegates],
                theme: mui.ThemeData(
                  colorScheme: mui.ColorScheme.fromSeed(
                    seedColor: Colors.indigo,
                  ),
                ),
                home: mui.Material(
                  child: SizedBox(height: 800, child: child),
                ),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    // Bounded pumps, never pumpAndSettle: the composer's spinner animates
    // forever, so settling would burn pumpAndSettle's ten-minute timeout.
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 30));
    }
  }

  Future<void> frames(WidgetTester tester, {int count = 10}) async {
    for (var i = 0; i < count; i++) {
      await tester.pump(const Duration(milliseconds: 30));
    }
  }

  String editorText(WidgetTester tester) {
    final editor = tester.widget<SolarBlockEditor>(
      find.byType(SolarBlockEditor),
    );
    return editor.controller.editorState.document.root.children
        .map((node) => node.delta?.toPlainText() ?? '')
        .join('\n');
  }

  testWidgets('an editor booted after the field mounted still renders', (
    tester,
  ) async {
    final current = ValueNotifier<ComposeState?>(null);
    await pump(tester, _EditorHost(current: current));
    await frames(tester);

    // Before any state exists the field is a placeholder.
    expect(find.byType(SolarBlockEditor), findsNothing);

    // This is the edit composer's shape: the state (and its editor) only
    // exists once the post being edited arrived.
    final state = ComposeLogic.createState(
      originalPost: _post(content: 'body'),
    );
    addTearDown(() => ComposeLogic.dispose(state));
    current.value = state;
    await frames(tester);

    expect(find.byType(SolarBlockEditor), findsOneWidget);
    expect(editorText(tester), 'body');
  });

  testWidgets('swapping the composer state boots the new state s editor', (
    tester,
  ) async {
    final first = ComposeLogic.createState(originalPost: _post(content: 'old'));
    addTearDown(() => ComposeLogic.dispose(first));
    final current = ValueNotifier<ComposeState?>(first);
    await pump(tester, _EditorHost(current: current));
    await frames(tester);
    expect(editorText(tester), 'old');

    // Replacing the state used to leave the field without an editor: the
    // bootstrap effect was keyed `[]`, so it never ran again and the new
    // state's controller stayed null forever.
    final second = ComposeLogic.createState(
      originalPost: _post(content: 'new'),
    );
    addTearDown(() => ComposeLogic.dispose(second));
    current.value = second;
    await frames(tester);

    expect(find.byType(SolarBlockEditor), findsOneWidget);
    expect(
      tester.widget<SolarBlockEditor>(find.byType(SolarBlockEditor)).controller,
      same(second.solarEditorController),
    );
    expect(editorText(tester), 'new');
  });

  testWidgets('editing a server post waits for its full copy', (tester) async {
    final fullPost = Completer<SnPost?>();
    await pump(
      tester,
      PostComposePane(
        originalPost: _post(content: 'intro only', truncated: true),
        chrome: PostComposeChrome.pane,
        onFinished: (_) {},
      ),
      fullPost: () => fullPost.future,
    );
    await frames(tester);

    // While the post is still in flight the composer never exists, so its
    // editor is never seeded from the abridged body — and, because no form
    // was built, none of the composer's timers are running either.
    expect(find.byType(PostComposeForm), findsNothing);
    expect(find.byType(SolarBlockEditor), findsNothing);
    // The pane builds material_ui's spinner, not flutter/material's.
    expect(find.byType(mui.CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('a failed fetch of a post offers retry, not an editor', (
    tester,
  ) async {
    var attempts = 0;
    await pump(
      tester,
      PostComposePane(
        originalPost: _post(content: 'complete body'),
        chrome: PostComposeChrome.pane,
        onFinished: (_) {},
      ),
      fullPost: () async {
        attempts++;
        throw Exception('offline');
      },
    );
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await frames(tester);

    expect(find.byType(SolarBlockEditor), findsNothing);
    expect(find.text('Failed to load post'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await frames(tester);
    expect(attempts, greaterThan(1));
  });
}
