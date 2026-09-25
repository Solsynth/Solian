import 'package:flutter/services.dart';
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

  test('export/import round trip is stable for common markdown', () {
    const samples = [
      '# Title\n\nSome paragraph with **bold** and [a link](https://example.com).',
      '- item one\n- item two\n\n1. numbered\n2. second',
      '> a quote\n\n```dart\nvoid main() {}\n```',
      '`inline code` and **bold** trailing text.',
      'A line starting with # is escaped\n\n> a quote line',
      'Ordered: 1. not a list\n\nPlain **bold** end.',
    ];
    for (final sample in samples) {
      final first = quillDeltaToMarkdown(markdownToQuillDelta(sample));
      final second = quillDeltaToMarkdown(markdownToQuillDelta(first));
      expect(second, first, reason: 'round trip unstable for: $sample');
    }
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
