import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/core/config.dart';
import 'package:island/discovery/models/autocomplete_response.dart';
import 'package:island/posts/widgets/compose/block_mention_autocomplete.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';

AutocompleteSuggestion _user(String nick) => AutocompleteSuggestion(
  type: 'user',
  keyword: '@$nick',
  data: {
    'id': 'id-$nick',
    'name': nick,
    'nick': nick,
    'language': 'en-US',
    'is_superuser': false,
    'automated_id': null,
    'profile': {
      'id': 'profile-$nick',
      'bio': '',
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
  },
);

/// A real [SolarBlockEditor] plus the autocomplete wired to it, exactly as
/// the composer does it.
class _Host extends StatefulWidget {
  const _Host({super.key, required this.controller, required this.theme});

  final SolarEditorController controller;
  final _Harness theme;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  BlockMentionAutocomplete? autocomplete;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    autocomplete ??= BlockMentionAutocomplete(
      context,
      widget.controller.editorState,
      onFetchSuggestions: (query) async {
        widget.theme.queries.add(query);
        return widget.theme.suggestions;
      },
      isEnabled: () => widget.theme.enabled,
    );
  }

  @override
  void dispose() {
    autocomplete?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SolarBlockEditor(
    controller: widget.controller,
    onKeyEvent: (event) => autocomplete?.handleKey(event),
  );
}

class _Harness {
  final List<String> queries = [];
  List<AutocompleteSuggestion> suggestions = const [];
  bool enabled = true;
  BlockMentionAutocomplete? autocomplete;

  /// Replaces the first block's text and puts the caret at [caretOffset]
  /// (defaults to the end).
  void type(EditorState state, String text, {int? caretOffset}) {
    final node = state.document.root.children.first;
    node.updateAttributes({'delta': (Delta()..insert(text)).toJson()});
    state.selection = Selection.collapsed(
      Position(path: node.path, offset: caretOffset ?? text.length),
    );
  }
}

Future<_Harness> _pump(WidgetTester tester, String seed) async {
  final controller = SolarEditorController(initialMarkdown: seed);
  addTearDown(controller.dispose);
  final harness = _Harness();
  final key = GlobalKey<_HostState>();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [serverUrlProvider.overrideWithValue('https://solar.test')],
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 400,
            child: _Host(key: key, controller: controller, theme: harness),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  harness.autocomplete = key.currentState!.autocomplete;
  return harness;
}

SolarEditorController? _controllerOf(WidgetTester tester) {
  final host = tester.widget<_Host>(find.byType(_Host));
  return host.controller;
}

void main() {
  testWidgets('an @query fetches after the debounce and opens a popup', (
    tester,
  ) async {
    final harness = await _pump(tester, 'hello ');
    harness.suggestions = [_user('alice')];
    final state = _controllerOf(tester)!.editorState;
    harness.type(state, 'hello @ali');
    harness.autocomplete!.onTransaction();

    // Nothing is requested until the debounce elapses.
    await tester.pump(const Duration(milliseconds: 300));
    expect(harness.queries, isEmpty);

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(harness.queries, ['@ali']);
    expect(find.text('alice'), findsOneWidget);
  });

  testWidgets('a query containing whitespace never opens the popup', (
    tester,
  ) async {
    final harness = await _pump(tester, 'hello ');
    harness.suggestions = [_user('alice')];
    harness.type(_controllerOf(tester)!.editorState, 'hello @ali there');
    harness.autocomplete!.onTransaction();

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(harness.queries, isEmpty);
    expect(find.text('alice'), findsNothing);
  });

  testWidgets('a disabled composer never opens the popup', (tester) async {
    final harness = await _pump(tester, 'hello ');
    harness.enabled = false;
    harness.suggestions = [_user('alice')];
    harness.type(_controllerOf(tester)!.editorState, 'hello @ali');
    harness.autocomplete!.onTransaction();

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(harness.queries, isEmpty);
    expect(find.text('alice'), findsNothing);
  });

  testWidgets('enter replaces the whole token with the keyword', (
    tester,
  ) async {
    final harness = await _pump(tester, 'hello ');
    harness.suggestions = [_user('alice')];
    final state = _controllerOf(tester)!.editorState;
    harness.type(state, 'hello @ali there', caretOffset: 'hello @ali'.length);
    harness.autocomplete!.onTransaction();

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(find.text('alice'), findsOneWidget);

    final result = harness.autocomplete!.handleKey(
      const KeyDownEvent(
        timeStamp: Duration.zero,
        physicalKey: PhysicalKeyboardKey.enter,
        logicalKey: LogicalKeyboardKey.enter,
        character: '\n',
      ),
    );
    expect(result, KeyEventResult.handled);
    await tester.pumpAndSettle();

    // `@ali` became `@alice`; the trailing word survives untouched.
    final text = state.document.root.children.first.delta!.toPlainText();
    expect(text, 'hello @alice there');
  });

  testWidgets('keys fall through to the editor when no popup is open', (
    tester,
  ) async {
    final harness = await _pump(tester, 'hello ');
    harness.type(_controllerOf(tester)!.editorState, 'hello @ali');
    expect(
      harness.autocomplete!.handleKey(
        const KeyDownEvent(
          timeStamp: Duration.zero,
          physicalKey: PhysicalKeyboardKey.arrowDown,
          logicalKey: LogicalKeyboardKey.arrowDown,
          character: null,
        ),
      ),
      isNull,
    );
  });
}
