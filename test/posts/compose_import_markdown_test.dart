import 'package:flutter_test/flutter_test.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';

void main() {
  group('ComposeLogic.resolveLocalFilesFromMarkdown', () {
    test('collects inline image and link targets resolved to base directory',
        () {
      const content = '''
# Title

![screenshot](images/shot.png)

Read the [guide](docs/guide.pdf) before continuing.
''';
      expect(
        ComposeLogic.resolveLocalFilesFromMarkdown('/base', content),
        {'/base/images/shot.png', '/base/docs/guide.pdf'},
      );
    });

    test('collects reference-style definition targets', () {
      const content = '''
[logo]: images/logo.png "Logo"
[home]: /abs/landing.html

![logo][logo] and [home]
''';
      expect(
        ComposeLogic.resolveLocalFilesFromMarkdown('/base', content),
        {'/base/images/logo.png', '/abs/landing.html'},
      );
    });

    test('ignores remote URLs, anchors, data URIs and inline refs without defs',
        () {
      const content = '''
![remote](https://example.com/a.png)
[scheme](solian://files/abc123)
[anchor](#section)
[data](data:image/png;base64,AAAA)
![rel][undefined]
''';
      expect(
        ComposeLogic.resolveLocalFilesFromMarkdown('/base', content),
        isEmpty,
      );
    });

    test('keeps absolute paths and normalizes Windows separators', () {
      const content = r'''
![win](images\shot.png)
![abs](/Users/me/photos/one.jpg)
![drive](C:\photos\two.jpg)
''';
      expect(
        ComposeLogic.resolveLocalFilesFromMarkdown('/base', content),
        {
          '/base/images/shot.png',
          '/Users/me/photos/one.jpg',
          '/base/C:/photos/two.jpg',
        },
      );
    });

    test('strips angle brackets and trailing titles', () {
      const content = '''
![a](<images/a.png>)
![b](images/b.png 'A title')
![c](images/c.png "Another title")
''';
      expect(
        ComposeLogic.resolveLocalFilesFromMarkdown('/base', content),
        {
          '/base/images/a.png',
          '/base/images/b.png',
          '/base/images/c.png',
        },
      );
    });

    test('deduplicates repeated targets and returns empty set for none', () {
      expect(
        ComposeLogic.resolveLocalFilesFromMarkdown('/base', 'plain text'),
        isEmpty,
      );
      expect(
        ComposeLogic.resolveLocalFilesFromMarkdown(
          '/base',
          '![x](img/a.png) ![x](img/a.png) [i](img/a.png)',
        ),
        {'/base/img/a.png'},
      );
    });
  });
}
