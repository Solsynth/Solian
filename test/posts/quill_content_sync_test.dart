import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
// ignore: experimental_member_use
import 'package:flutter_quill/internal.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';
import 'package:island/posts/widgets/compose/compose_state_utils.dart';
import 'package:island/posts/widgets/compose/quill_markdown.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

SnPost _post(String id, String content) {
  return SnPost.fromJson({
    'id': id,
    'type': 0,
    'content': content,
    'chained_posts': const [],
    'publisher': {
      'id': 'publisher-1',
      'type': 0,
      'name': 'P',
      'nick': 'p',
      'created_at': '2026-01-01T00:00:00Z',
      'updated_at': '2026-01-01T00:00:00Z',
    },
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  });
}

void main() {
  test('custom sticker/realm syntax survives the markdown round trip', () {
    const markdown = 'Hi @alice, check :realm+tech: and :sticker+fire:!';
    final exported = quillDeltaToMarkdown(markdownToQuillDelta(markdown));
    expect(exported, contains(':realm+tech:'));
    expect(exported, contains(':sticker+fire:'));
    expect(exported, contains('@alice'));
    expect(exported, isNot(contains(r'\:')));
  });

  test('highlight and spoiler syntax survives the markdown round trip', () {
    const markdown = 'plain ==marked== and =!secret!= text @alice';
    final exported = quillDeltaToMarkdown(markdownToQuillDelta(markdown));
    expect(exported, contains('==marked=='));
    expect(exported, contains('=!secret!='));
    expect(exported, contains('@alice'));
  });

  test('export/import round trip is stable for common markdown', () {
    const samples = [
      '# Title\n\nSome paragraph with **bold** and [a link](https://example.com).',
      '- item one\n- item two\n\n1. numbered\n2. second',
      '> a quote\n\n```dart\nvoid main() {}\n```',
      '`inline code` and **bold** trailing text.',
      'A line starting with # is escaped\n\n> a quote line',
      'Ordered: 1. not a list\n\nPlain **bold** end.',
      'first line\nsecond line\n\nsecond paragraph\nthird line',
      'para with soft break\ncontinued here\n\nnext paragraph',
    ];
    for (final sample in samples) {
      final first = quillDeltaToMarkdown(markdownToQuillDelta(sample));
      final second = quillDeltaToMarkdown(markdownToQuillDelta(first));
      expect(second, first, reason: 'round trip unstable for: $sample');
    }
  });

  test('a lone newline is a soft break, a blank line starts a paragraph', () {
    final softBreak = quillDeltaToMarkdown(
      Delta()
        ..insert('line1\n')
        ..insert('line2\n'),
    );
    expect(softBreak, 'line1\nline2\n');

    final paragraph = quillDeltaToMarkdown(
      Delta()
        ..insert('line1\n')
        ..insert('\n')
        ..insert('line2\n'),
    );
    expect(paragraph, 'line1\n\nline2\n');

    // Importing keeps the two apart: a blank line becomes an empty line.
    expect(
      Document.fromDelta(
        markdownToQuillDelta('line1\nline2\n'),
      ).root.children.length,
      2,
    );
    expect(
      Document.fromDelta(
        markdownToQuillDelta('line1\n\nline2\n'),
      ).root.children.length,
      3,
    );
  });

  test('pasting markdown inserts it as parsed content', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const clipboard = '# Title\n\n- one\n- two';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.getData') return {'text': clipboard};
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    final state = ComposeLogic.createState();
    // ignore: experimental_member_use
    expect(await state.contentQuillController.clipboardPaste(), isTrue);

    // Parsed into a heading and a list rather than literal `#`/`-` text.
    expect(state.contentController.text, contains('# Title'));
    expect(state.contentController.text, contains('- one'));
    final document = state.contentQuillController.document;
    expect(document.toPlainText(), isNot(contains('#')));
    expect(
      document.root.children.first.style.attributes.keys,
      contains(Attribute.header.key),
    );
  });

  test('pasting prose keeps the default plain text handling', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const clipboard = 'just a normal sentence';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.getData') return {'text': clipboard};
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
    // No rich clipboard formats available, so the default plain text path runs.
    // ignore: experimental_member_use
    ClipboardServiceProvider.setInstance(_PlainClipboardService());
    // ignore: experimental_member_use
    addTearDown(ClipboardServiceProvider.setInstanceToDefault);

    final state = ComposeLogic.createState();
    // ignore: experimental_member_use
    expect(await state.contentQuillController.clipboardPaste(), isTrue);
    expect(state.contentController.text, contains('just a normal sentence'));
  });

test('pasting inline markdown keeps the rest of the line', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const clipboard = '**bold**';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.getData') return {'text': clipboard};
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    final state = ComposeLogic.createState();
    state.contentQuillController.replaceText(
      0,
      0,
      'before after',
      const TextSelection.collapsed(offset: 12),
    );
    // Caret between "before " and "after".
    state.contentQuillController.updateSelection(
      const TextSelection.collapsed(offset: 7),
      ChangeSource.local,
    );
    // ignore: experimental_member_use
    expect(await state.contentQuillController.clipboardPaste(), isTrue);

    // The sentence stays on one line, with the pasted word in between.
    expect(state.contentController.text.trim(), 'before **bold**after');
    expect(state.contentQuillController.document.root.children.length, 1);
  });

  test('initial markdown content is imported into the quill document', () {
    final state = ComposeLogic.createState(
      originalPost: _post('post-1', 'Hello **bold** world'),
    );
    expect(
      state.contentQuillController.document.toPlainText(),
      contains('Hello bold world'),
    );
  });

  test('editor edits export markdown to the content controller', () {
    final state = ComposeLogic.createState();
    state.contentQuillController.replaceText(
      0,
      0,
      'Hello',
      const TextSelection.collapsed(offset: 5),
    );
    expect(state.contentController.text, contains('Hello'));
  });

  test('insertContent places text at the caret and keeps it unescaped', () {
    final state = ComposeLogic.createState();
    state.contentQuillController.replaceText(
      0,
      0,
      'Hello ',
      const TextSelection.collapsed(offset: 6),
    );
    state.insertContent(':sticker+fire:');
    expect(state.contentController.text, contains('Hello :sticker+fire:'));
    expect(state.contentController.text, isNot(contains(r'\:')));
  });

  test('insertImage round trips as a markdown image embed', () {
    final state = ComposeLogic.createState();
    state.insertImage('solian://files/abc123');
    expect(state.contentController.text, contains('solian://files/abc123'));
    expect(state.contentController.text, startsWith('!['));
  });

  test('external content changes are re-imported into the document', () {
    final state = ComposeLogic.createState();
    state.contentController.text = '# T\n\nSome **bold** text';
    expect(
      state.contentQuillController.document.toPlainText(),
      contains('Some bold text'),
    );
  });

  test('resetForm clears the document', () {
    final state = ComposeLogic.createState();
    state.contentController.text = 'Some content';
    expect(state.contentController.text, isNotEmpty);

    ComposeStateUtils.resetForm(state);
    expect(state.contentController.text.trim(), isEmpty);
    expect(state.contentQuillController.document.toPlainText().trim(), isEmpty);
  });
}

// ignore: experimental_member_use
class _PlainClipboardService implements ClipboardService {
  @override
  Future<bool> get hasClipboardContent async => false;

  @override
  Future<String?> getHtmlText() async => null;

  @override
  Future<String?> getHtmlFile() async => null;

  @override
  Future<String?> getMarkdownFile() async => null;

  @override
  Future<Uint8List?> getImageFile() async => null;

  @override
  Future<Uint8List?> getGifFile() async => null;

  @override
  Future<void> copyImage(Uint8List imageBytes) async {}
}
