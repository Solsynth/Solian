import 'package:flutter_test/flutter_test.dart';
import 'package:island/core/services/deeplink_service.dart';
import 'package:island/route.dart';

void main() {
  final router = AppRouter();

  group('isKnownInAppRoutePath', () {
    test('accepts every concrete in-app route', () {
      for (final path in [
        '/',
        '/explore',
        '/chat',
        '/chat/room-1',
        '/chat/room-1/detail',
        '/chat/room-1/search',
        '/chat/search',
        '/realms',
        '/workspaces',
        '/workspaces/studio',
        '/realms/foo',
        '/account/me/leveling',
        '/account/me/meet/7',
        '/account/stickers',
        '/account/stickers/pack-1',
        '/wallet',
        '/wallet/transactions/42',
        '/orders/42',
        '/posts/123',
        '/posts/123?tab=comments',
        '/publishers/name',
        '/accounts/some-name',
        '/calendar/name',
        '/calendar/name/events/42',
        '/settings',
        '/search',
        '/files/abc',
        '/creators/pub/posts',
        '/creators/pub/stickers/pack-1',
      ]) {
        expect(isKnownInAppRoutePath(router, path), isTrue, reason: path);
      }
    });

    test('rejects paths that only match the 404 catch-all', () {
      for (final path in [
        '/nonexistent',
        '/posts/123/extra',
        '/realms/foo/bar',
        '/wallet/transactions',
        '/account/workspaces',
        '/account/me/leveling/extra',
        '/chat/room-1/unknown',
      ]) {
        expect(isKnownInAppRoutePath(router, path), isFalse, reason: path);
      }
    });
  });

  test('solianLinkWebUrl maps custom-scheme links to the web app', () {
    expect(
      solianLinkWebUrl(Uri.parse('solian://posts/123'))?.toString(),
      'https://solian.app/posts/123',
    );
    expect(
      solianLinkWebUrl(
        Uri.parse('solian://posts/123?tab=comments'),
      )?.toString(),
      'https://solian.app/posts/123?tab=comments',
    );
    expect(
      solianLinkWebUrl(Uri.parse('https://solian.app/posts/123'))?.toString(),
      'https://solian.app/posts/123',
    );
    expect(solianLinkWebUrl(Uri.parse('https://example.com/x')), isNull);
    expect(solianLinkWebUrl(Uri.parse('https://api.solian.app/x')), isNull);
  });

  test('solianLinkBrowserUrl avoids Android app-link re-entry', () {
    expect(
      solianLinkBrowserUrl(Uri.parse('solian://posts/123'))?.toString(),
      'https://www.solian.app/posts/123',
    );
    expect(
      solianLinkBrowserUrl(
        Uri.parse('https://solian.app/nonexistent'),
      )?.toString(),
      'https://www.solian.app/nonexistent',
    );
    expect(solianLinkBrowserUrl(Uri.parse('https://example.com/x')), isNull);
  });
}
