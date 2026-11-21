import 'package:flutter_test/flutter_test.dart';
import 'package:island/activity/pulsar_activity.dart';
import 'package:island/activity/pulsar_artwork.dart';
import 'package:island/activity/pulsar_models.dart';

const _steamCdn = 'https://cdn.cloudflare.steamstatic.com/steam/apps';

PulsarScrobble _scrobble(Map<String, dynamic> json) =>
    PulsarScrobble.fromJson(json);

void main() {
  group('steam artwork', () {
    test('an imported Steam history row gets its capsule back', () {
      // Shape returned by /pulsar/users/:name/history for a Steam game: no
      // artwork_url at all, the app id lives in the catalog provider key.
      final scrobble = _scrobble({
        'id': 's1',
        'account_id': 'a1',
        'domain': 'gaming',
        'client_name': 'steam',
        'title': 'Thief Simulator',
        'played_at': '2026-10-24T07:19:57Z',
        'catalog_item': {
          'id': 'c1',
          'domain': 'custom',
          'provider': 'steam',
          'provider_key': '704850',
          'title': 'Thief Simulator',
        },
      });

      expect(PulsarArtwork.scrobbleUrls(scrobble), [
        '$_steamCdn/704850/library_600x900.jpg',
        '$_steamCdn/704850/header.jpg',
      ]);
    });

    test('a live Steam session resolves from session metadata', () {
      final activity = pulsarActivityFromJson({
        'id': 'session-1',
        'account_id': 'a1',
        'domain': 'gaming',
        'manual_id': 'steam',
        'title': 'RimWorld',
        'meta': {'game_id': '294100', 'provider': 'steam'},
        'lease_minutes': 5,
        'lease_expires_at': '2026-11-14T12:05:00Z',
        'created_at': '2026-11-14T12:00:00Z',
        'updated_at': '2026-11-14T12:01:00Z',
      });

      expect(
        PulsarArtwork.presenceUrls(activity).first,
        '$_steamCdn/294100/library_600x900.jpg',
      );
    });

    test('a catalogue cover still wins for non-Steam providers', () {
      final scrobble = _scrobble({
        'id': 's2',
        'account_id': 'a1',
        'domain': 'music',
        'client_name': 'spotify',
        'title': 'Track',
        'artwork_url': 'https://cdn.example/cover.jpg',
        'played_at': '2026-10-24T07:19:57Z',
        'catalog_item': {
          'id': 'c2',
          'domain': 'music',
          'provider': 'musicbrainz',
          'title': 'Track',
          'artwork_url': 'https://cdn.example/catalog.jpg',
        },
      });

      expect(
        PulsarArtwork.scrobbleUrls(scrobble).first,
        'https://cdn.example/cover.jpg',
      );
      expect(
        PulsarArtwork.scrobbleUrls(scrobble),
        contains('https://cdn.example/catalog.jpg'),
      );
    });

    test('malformed provider keys never reach the CDN', () {
      expect(PulsarArtwork.steamUrls('not-an-id'), isEmpty);
      expect(PulsarArtwork.steamUrls(''), isEmpty);
      expect(PulsarArtwork.steamUrls('  730  '), [
        '$_steamCdn/730/library_600x900.jpg',
        '$_steamCdn/730/header.jpg',
      ]);
    });
  });

  group('sha256 artwork', () {
    test('resolves against the server presence artwork endpoint', () {
      expect(
        PulsarArtwork.resolve(
          'sha256:abc123',
          serverUrl: 'https://api.solian.app/',
        ),
        ['https://api.solian.app/stargate/presence/artworks/sha256:abc123'],
      );
      expect(PulsarArtwork.resolve('sha256:abc123'), isEmpty);
    });

    test('ignores values that are not addresses', () {
      expect(PulsarArtwork.resolve('discord:mp:123'), isEmpty);
      expect(PulsarArtwork.resolve('/relative/path.jpg'), isEmpty);
      expect(PulsarArtwork.resolve('  '), isEmpty);
      expect(PulsarArtwork.resolve('//cdn.example/a.jpg'), [
        'https://cdn.example/a.jpg',
      ]);
    });
  });
}
