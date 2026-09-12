import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:test/test.dart';

void main() {
  group('SnPost chained fields', () {
    test('fromJson parses chained fields', () {
      final post = SnPost.fromJson(const {
        'id': 'p1',
        'chained_post_id': 'head',
        'chained_post': {'id': 'head'},
        'chained_posts': [
          {'id': 'c1'},
          {'id': 'c2'},
        ],
        'chained_count': 2,
      });

      expect(post.chainedPostId, 'head');
      expect(post.chainedPost?.id, 'head');
      expect(post.chainedPosts.map((e) => e.id), ['c1', 'c2']);
      expect(post.chainedCount, 2);
    });

    test('fromJson defaults when fields absent', () {
      final post = SnPost.fromJson(const {'id': 'p1'});

      expect(post.chainedPostId, isNull);
      expect(post.chainedPost, isNull);
      expect(post.chainedPosts, isEmpty);
      expect(post.chainedCount, 0);
    });

    test('toJson emits snake_case keys', () {
      final post = SnPost(
        id: 'p1',
        chainedPostId: 'head',
        chainedPost: const SnPost(id: 'head'),
        chainedPosts: const [SnPost(id: 'c1')],
        chainedCount: 1,
      );

      final json = post.toJson();
      expect(json['chained_post_id'], 'head');
      expect((json['chained_post'] as Map<String, dynamic>)['id'], 'head');
      expect(
        (json['chained_posts'] as List)
            .map((e) => (e as Map<String, dynamic>)['id']),
        ['c1'],
      );
      expect(json['chained_count'], 1);
    });
  });
}
