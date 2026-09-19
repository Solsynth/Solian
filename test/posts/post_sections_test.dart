import 'package:flutter_test/flutter_test.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

SnPost _post({String? content, int contentType = 0}) {
  return SnPost.fromJson({
    'id': 'post-1',
    'type': 1,
    'content': content,
    'content_type': contentType,
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  });
}

void main() {
  test('scans ATX headings in document order with their levels', () {
    final sections = scanPostSections(
      '# One\n\nbody\n\n## Two\n\nmore\n\n### Three\n',
    );

    expect(sections.map((s) => s.level).toList(), [1, 2, 3]);
    expect(sections.map((s) => s.title).toList(), ['One', 'Two', 'Three']);
  });

  test('skips hash lines inside fenced code blocks', () {
    final sections = scanPostSections(
      '# Real\n\n```\n# fake\n```\n\n~~~\n## also fake\n~~~\n\n## Real two\n',
    );

    expect(sections.map((s) => s.title).toList(), ['Real', 'Real two']);
  });

  test('ignores indented code that looks like a heading', () {
    final sections = scanPostSections('# Real\n\n    # indented code\n');

    expect(sections.map((s) => s.title).toList(), ['Real']);
  });

  test('accepts up to three leading spaces but not four', () {
    expect(scanPostSections('   ## Shifted\n').map((s) => s.title).toList(), [
      'Shifted',
    ]);
    expect(scanPostSections('    ## Indented\n'), isEmpty);
  });

  test('strips inline markdown and closing hashes from titles', () {
    final sections = scanPostSections(
      '## **Bold** with `code` and [a link](https://x.test) ##\n',
    );

    expect(sections.single.title, 'Bold with code and a link');
  });

  test('ignores headings without text', () {
    expect(scanPostSections('##\n'), isEmpty);
  });

  test('reads headings out of html article content', () {
    final markdown = resolvePostMarkdown(
      _post(
        content: '<h1>One</h1><h2>Two</h2><h3>Three</h3><p>body</p>',
        contentType: 1,
      ),
    );

    final sections = scanPostSections(markdown);
    expect(sections.map((s) => s.title).toList(), ['One', 'Two', 'Three']);
    expect(sections.map((s) => s.level).toList(), [1, 2, 3]);
  });

  test('reads setext headings', () {
    final sections = scanPostSections(
      'Title\n=====\n\nbody\n\nSubtitle\n--------\n\nmore\n',
    );

    expect(sections.map((s) => s.level).toList(), [1, 2]);
    expect(sections.map((s) => s.title).toList(), ['Title', 'Subtitle']);
  });

  test('does not treat a rule or list under a blank line as a heading', () {
    expect(scanPostSections('body\n\n---\n\nmore\n'), isEmpty);
    expect(scanPostSections('- item\n---\n'), isEmpty);
    expect(scanPostSections('> quoted\n---\n'), isEmpty);
  });

  group('active section', () {
    test('starts at the first section', () {
      expect(activeSectionIndex([0, 500, 1200], 0), 0);
    });

    test('follows the reader down the article', () {
      expect(activeSectionIndex([0, 500, 1200], 200), 0);
      expect(activeSectionIndex([0, 500, 1200], 600), 1);
      expect(activeSectionIndex([0, 500, 1200], 1200), 2);
      expect(activeSectionIndex([0, 500, 1200], 9999), 2);
    });

    test('keeps the previous section when a heading is not rendered yet', () {
      expect(activeSectionIndex([0, null, 1200], 600), 0);
      expect(activeSectionIndex([0, null, 1200], 1300), 2);
    });

    test('is the first section when there is nothing to track', () {
      expect(activeSectionIndex(const [], 400), 0);
      expect(activeSectionIndex(const [null], 400), 0);
    });

    test('ignores a heading just below the viewport edge', () {
      expect(activeSectionIndex([0, 100], 87), 0);
      expect(activeSectionIndex([0, 100], 90), 1);
    });
  });
}
