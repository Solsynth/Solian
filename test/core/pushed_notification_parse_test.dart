import 'package:flutter_test/flutter_test.dart';
import 'package:island/core/notification.dart';

/// Metoer's `notifications.new` payload keeps `title`, `subtitle` and `content`
/// nullable — a silent or image-only notice carries none of them — and
/// `viewed_at` null until the notice is read. Reading the map straight into the
/// SDK model made those pushes throw inside the socket listener, so they never
/// reached the overlay at all. These pin the tolerances that keep them arriving.
void main() {
  test('a fully populated payload keeps every field', () {
    final notification = parsePushedNotification({
      'id': 'n1',
      'topic': 'messages.new',
      'title': 'Hello',
      'subtitle': 'from someone',
      'content': 'body text',
      'created_at': '2026-11-21T03:00:00Z',
      'viewed_at': null,
      'app_id': 'dev.solsynth.solian',
      'account_id': 'a1',
      'meta': {'action_uri': '/chat/1'},
    });

    expect(notification, isNotNull);
    expect(notification!.id, 'n1');
    expect(notification.title, 'Hello');
    expect(notification.subtitle, 'from someone');
    expect(notification.body, 'body text');
    expect(notification.appId, 'dev.solsynth.solian');
    expect(notification.accountId, 'a1');
    expect(notification.viewedAt, isNull);
    expect(notification.meta['action_uri'], '/chat/1');
    expect(notification.createdAt.toUtc(), DateTime.utc(2026, 11, 21, 3));
  });

  test('null text fields become empty strings instead of throwing', () {
    final notification = parsePushedNotification({
      'id': 'n2',
      'topic': 'auth.login',
      'title': null,
      'subtitle': null,
      'content': null,
      'created_at': '2026-11-21T03:00:00Z',
      'viewed_at': null,
      'app_id': null,
      'account_id': 'a1',
      'meta': null,
    });

    expect(notification, isNotNull);
    expect(notification!.title, '');
    expect(notification.subtitle, '');
    expect(notification.body, '');
    expect(notification.appId, isNull);
    expect(notification.meta, isEmpty);
  });

  test('missing timestamps fall back to now, not to an exception', () {
    final before = DateTime.now();
    final notification = parsePushedNotification({
      'id': 'n3',
      'topic': 'relationships.friends.request',
    });

    expect(notification, isNotNull);
    expect(
      notification!.createdAt.isBefore(
        before.subtract(const Duration(seconds: 1)),
      ),
      isFalse,
    );
  });

  test('a payload without an id is rejected rather than shown', () {
    expect(parsePushedNotification({'topic': 'x'}), isNull);
    expect(parsePushedNotification({'id': '', 'topic': 'x'}), isNull);
    expect(parsePushedNotification({'id': 'n4'}), isNull);
  });
}
