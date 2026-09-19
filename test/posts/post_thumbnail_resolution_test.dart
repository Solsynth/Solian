import 'package:flutter_test/flutter_test.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

SnPost _post({Object? thumbnail, List<Map<String, dynamic>> attachments = const []}) {
  return SnPost.fromJson({
    'id': 'post-1',
    'type': 1,
    'content': 'body',
    'attachments': attachments,
    'meta': {'thumbnail': ?thumbnail},
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  });
}

Map<String, dynamic> _file(String id) => {
  'id': id,
  'name': 'cover.png',
  'mime_type': 'image/png',
};

void main() {
  test('resolves a thumbnail stored as an attachment id', () {
    final post = _post(thumbnail: 'file-1', attachments: [_file('file-1')]);

    expect(resolvePostThumbnail(post)?.id, 'file-1');
  });

  test('resolves a thumbnail stored as an embedded file reference', () {
    // The API also hands back the expanded reference; casting it straight to
    // String crashed the article layout.
    final post = _post(
      thumbnail: _file('file-1'),
      attachments: [_file('file-1')],
    );

    expect(resolvePostThumbnail(post)?.id, 'file-1');
  });

  test('falls back to the embedded reference when it is not an attachment', () {
    final post = _post(
      thumbnail: {..._file('file-9'), 'url': 'https://cdn.test/file-9'},
      attachments: [_file('file-1')],
    );

    final resolved = resolvePostThumbnail(post);
    expect(resolved?.id, 'file-9');
    expect(resolved?.storageUrl, 'https://cdn.test/file-9');
  });

  test('ignores a reference without an id', () {
    final post = _post(
      thumbnail: {'name': 'cover.png'},
      attachments: [_file('file-1')],
    );

    expect(resolvePostThumbnail(post), isNull);
  });

  test('ignores a thumbnail of an unexpected type', () {
    final post = _post(thumbnail: 42, attachments: [_file('file-1')]);

    expect(resolvePostThumbnail(post), isNull);
  });

  test('returns null when the post has no thumbnail', () {
    expect(resolvePostThumbnail(_post()), isNull);
  });
}
