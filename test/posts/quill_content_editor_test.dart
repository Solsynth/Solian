import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/discovery/discovery_service.dart';
import 'package:island/discovery/models/autocomplete_response.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';
import 'package:island/posts/widgets/compose/quill_content_editor.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:shared_preferences/shared_preferences.dart';

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

class _FakeAutocompleteService extends AutocompleteService {
  _FakeAutocompleteService(this.results) : super(Dio());

  final List<AutocompleteSuggestion> results;
  int calls = 0;

  @override
  Future<List<AutocompleteSuggestion>> getGeneralSuggestions(
    String content,
  ) async {
    calls++;
    return results;
  }
}

AutocompleteSuggestion _stickerSuggestion() {
  return AutocompleteSuggestion(
    type: 'sticker',
    keyword: ':sticker+fire:',
    data: {
      'id': 'sticker-1',
      'slug': 'fire',
      'name': 'Fire',
      'image': {'id': 'img-1'},
      'pack_id': 'pack-1',
      'pack': null,
      'created_at': '2026-01-01T00:00:00Z',
      'updated_at': '2026-01-01T00:00:00Z',
      'deleted_at': null,
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Future<void> pumpEditor(
    WidgetTester tester,
    ComposeState state,
    AutocompleteService service, {
    TargetPlatform platform = TargetPlatform.android,
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
              apiClientProvider.overrideWithValue(
                Dio()..httpClientAdapter = _EmptyResponseAdapter(),
              ),
              autocompleteServiceProvider.overrideWithValue(service),
            ],
            child: Builder(
              builder: (context) => mui.MaterialApp(
                locale: const Locale('en', 'US'),
                supportedLocales: const [Locale('en', 'US')],
                localizationsDelegates: [
                  ...context.localizationDelegates,
                  FlutterQuillLocalizations.delegate,
                ],
                theme: mui.ThemeData(
                  platform: platform,
                  colorScheme: mui.ColorScheme.fromSeed(
                    seedColor: Colors.indigo,
                  ),
                ),
                home: mui.Material(
                  child: SizedBox(
                    width: 420,
                    height: 520,
                    child: SingleChildScrollView(
                      child: QuillContentEditor(state: state),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
  }

  /// Simulates an IME replacing the editor buffer with [text], preserving the
  /// document's trailing newline the way real platform text input does.
  Future<void> imeType(WidgetTester tester, String text) async {
    tester.testTextInput.updateEditingValue(
      TextEditingValue(
        text: '$text\n',
        selection: TextSelection.collapsed(offset: text.length),
      ),
    );
    await tester.pump();
  }
  testWidgets('desktop toolbar follows caret and hides after mouse idle', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      final state = ComposeLogic.createState();
      await pumpEditor(
        tester,
        state,
        _FakeAutocompleteService(const []),
        platform: TargetPlatform.macOS,
      );

      expect(
        find.byKey(const ValueKey('compose-floating-toolbar')),
        findsNothing,
      );
      await tester.tap(find.byType(QuillEditor));
      await tester.pump();
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await tester.pump();
      await mouse.moveTo(tester.getCenter(find.byType(QuillEditor)));
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        find.byKey(const ValueKey('compose-floating-toolbar')),
        findsOneWidget,
      );

      await imeType(tester, 'first line\nsecond line');
      await tester.pumpAndSettle();
      final toolbarBefore = tester.getTopLeft(
        find.byKey(const ValueKey('compose-floating-toolbar')),
      );
      state.contentQuillController.updateSelection(
        const TextSelection.collapsed(offset: 2),
        ChangeSource.local,
      );
      await tester.pumpAndSettle();
      final toolbarAfter = tester.getTopLeft(
        find.byKey(const ValueKey('compose-floating-toolbar')),
      );
      expect(toolbarBefore.dy, isNot(toolbarAfter.dy));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        find.byKey(const ValueKey('compose-floating-toolbar')),
        findsNothing,
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('unmounting with the toolbar open does not throw', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      final state = ComposeLogic.createState();
      await pumpEditor(
        tester,
        state,
        _FakeAutocompleteService(const []),
        platform: TargetPlatform.macOS,
      );
      await tester.tap(find.byType(QuillEditor));
      await tester.pump();
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await tester.pump();
      await mouse.moveTo(tester.getCenter(find.byType(QuillEditor)));
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        find.byKey(const ValueKey('compose-floating-toolbar')),
        findsOneWidget,
      );

      // Tear the whole tree down while the toolbar overlay is still visible.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(tester.takeException(), isNull);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('touch toolbar appears immediately above the soft keyboard', (
    tester,
  ) async {
    final state = ComposeLogic.createState();
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetViewInsets);
    await pumpEditor(
      tester,
      state,
      _FakeAutocompleteService(const []),
      platform: TargetPlatform.iOS,
    );

    await tester.tap(find.byType(QuillEditor));
    await tester.pumpAndSettle();
    final toolbar = find.byKey(const ValueKey('compose-floating-toolbar'));
    expect(toolbar, findsOneWidget);
    final toolbarBox = tester.renderObject<RenderBox>(toolbar);
    final toolbarBottom = toolbarBox.localToGlobal(Offset(0, toolbarBox.size.height)).dy;
    final keyboardTop = tester.view.physicalSize.height /
        tester.view.devicePixelRatio -
        tester.view.viewInsets.bottom / tester.view.devicePixelRatio;
    expect(toolbarBottom, lessThanOrEqualTo(keyboardTop));
  });


  testWidgets('renders initial markdown content', (tester) async {
    final state = ComposeLogic.createState();
    state.contentController.text = 'Hello **bold** world';
    await pumpEditor(tester, state, _FakeAutocompleteService(const []));

    expect(find.text('Hello bold world', findRichText: true), findsOneWidget);
    expect(find.text('postContent'), findsNothing); // placeholder hidden
  });

  testWidgets('external content changes are reflected in the editor', (
    tester,
  ) async {
    final state = ComposeLogic.createState();
    await pumpEditor(tester, state, _FakeAutocompleteService(const []));

    state.contentController.text = 'New **content**';
    await tester.pumpAndSettle();

    expect(find.text('New content', findRichText: true), findsOneWidget);
  });

  testWidgets('typing exports markdown back to the content controller', (
    tester,
  ) async {
    final state = ComposeLogic.createState();
    await pumpEditor(tester, state, _FakeAutocompleteService(const []));

    await tester.tap(find.byType(QuillEditor));
    await tester.pump();
    await imeType(tester, 'Hello world');
    await tester.pumpAndSettle();

    expect(state.contentController.text, contains('Hello world'));
  });

  testWidgets('mention suggestions open and insert on tap', (tester) async {
    final state = ComposeLogic.createState();
    final service = _FakeAutocompleteService([_stickerSuggestion()]);
    await pumpEditor(tester, state, service);

    await tester.tap(find.byType(QuillEditor));
    await tester.pump();
    await imeType(tester, 'look @fire');
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pumpAndSettle();

    expect(service.calls, greaterThan(0));
    expect(find.text('Fire'), findsOneWidget);

    await tester.tap(find.text('Fire'));
    await tester.pumpAndSettle();

    expect(state.contentController.text, contains(':sticker+fire:'));
    expect(state.contentController.text, isNot(contains('@fire')));
    expect(find.text('Fire'), findsNothing); // popup closed
  });
}
