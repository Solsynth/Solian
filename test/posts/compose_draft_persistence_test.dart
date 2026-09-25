import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/data/database.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Serves scripted responses and records every request that reached the wire.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;
  final List<RequestOptions> requests = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? _,
    Future<void>? _,
  ) {
    requests.add(options);
    return handler(options);
  }
}

ResponseBody _json(Object data, {int status = 200}) => ResponseBody.fromString(
  jsonEncode(data),
  status,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
    'x-total': ['1'],
  },
);

SnPublisher _publisher() => SnPublisher.fromJson({
  'id': 'publisher-1',
  'type': 0,
  'name': 'tester',
  'nick': 'Tester',
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
});

Map<String, dynamic> _postJson({
  required String id,
  required String content,
  required bool drafted,
}) => {
  'id': id,
  'type': 0,
  'content': content,
  'chained_posts': const [],
  'publisher': _publisher().toJson(),
  'drafted_at': drafted ? '2026-01-01T00:00:00Z' : null,
  'published_at': drafted ? null : '2026-01-01T00:00:00Z',
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
};

late WidgetRef capturedRef;
late BuildContext capturedContext;

class _RefCapture extends ConsumerWidget {
  const _RefCapture();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    capturedRef = ref;
    capturedContext = context;
    return const SizedBox.shrink();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  Future<void> pumpHost(WidgetTester tester, HttpClientAdapter adapter) async {
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
                Dio()..httpClientAdapter = adapter,
              ),
            ],
            child: const MaterialApp(home: _RefCapture()),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();
  }

  Future<List<SnPost>> readDrafts(WidgetTester tester) async =>
      await tester.runAsync(database.getAllPostDrafts) ?? const [];

  testWidgets('failed publish persists the draft and keeps it', (tester) async {
    int? draftsWhenRequestStarted;
    final adapter = _ScriptedAdapter((options) async {
      draftsWhenRequestStarted ??= (await database.getAllPostDrafts()).length;
      return _json({'message': 'boom'}, status: 500);
    });
    await pumpHost(tester, adapter);

    final state = ComposeLogic.createState();
    state.currentPublisher.value = _publisher();
    state.contentController.text = 'Draft survives failures';

    await tester.runAsync(
      () => expectLater(
        ComposeLogic.performSubmit(
          capturedRef,
          state,
          capturedContext,
          onSuccess: () {},
        ),
        throwsA(isA<DioException>()),
      ),
    );

    // The draft was already on disk before the failing request went out.
    expect(draftsWhenRequestStarted, greaterThan(0));

    final drafts = await readDrafts(tester);
    expect(drafts.map((d) => d.content), contains('Draft survives failures'));

    // A failure never deletes anything, locally or on the server.
    expect(
      adapter.requests.map((r) => r.method.toUpperCase()),
      isNot(contains('DELETE')),
    );
  });

  testWidgets(
    'failed cloud draft publish keeps the draft with latest content',
    (tester) async {
      await tester.runAsync(
        () => database.addPostDraftFromPost(
          SnPost.fromJson(
            _postJson(id: 'cloud-draft', content: 'old', drafted: true),
          ),
        ),
      );

      final adapter = _ScriptedAdapter((options) async {
        if (options.path.endsWith('/publish')) {
          return _json({'message': 'boom'}, status: 500);
        }
        return _json(
          _postJson(id: 'cloud-draft', content: 'new content', drafted: true),
        );
      });
      await pumpHost(tester, adapter);

      final state = ComposeLogic.createState(cloudDraftId: 'cloud-draft');
      state.currentPublisher.value = _publisher();
      state.contentController.text = 'new content';

      await tester.runAsync(
        () => expectLater(
          ComposeLogic.performSubmit(
            capturedRef,
            state,
            capturedContext,
            onSuccess: () {},
          ),
          throwsA(isA<DioException>()),
        ),
      );

      final draft = (await readDrafts(
        tester,
      )).where((d) => d.id == 'cloud-draft').firstOrNull;
      expect(draft, isNotNull);
      expect(draft!.content, 'new content');
      expect(draft.draftedAt, isNotNull);
      expect(
        adapter.requests.map((r) => r.method.toUpperCase()),
        isNot(contains('DELETE')),
      );
    },
  );

  testWidgets('published post does not resurrect its draft', (tester) async {
    final adapter = _ScriptedAdapter(
      (options) async => _json(
        _postJson(id: 'published-post', content: 'shipped', drafted: false),
      ),
    );
    await pumpHost(tester, adapter);

    final state = ComposeLogic.createState();
    state.currentPublisher.value = _publisher();
    state.contentController.text = 'shipped';

    await tester.runAsync(
      () => expectLater(
        ComposeLogic.performSubmit(
          capturedRef,
          state,
          capturedContext,
          onSuccess: () {
            // What the compose screens do after a successful publish.
            database.deletePostDraft(state.draftId);
            state.contentController.text = '';
            throw StateError('navigation blew up after publishing');
          },
        ),
        throwsA(isA<StateError>()),
      ),
    );

    expect(await readDrafts(tester), isEmpty);
  });
}
