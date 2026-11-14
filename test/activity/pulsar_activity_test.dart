import 'package:flutter_test/flutter_test.dart';
import 'package:island/activity/pulsar_activity.dart';

void main() {
  test('maps a Pulsar session onto the presence model', () {
    final activity = pulsarActivityFromJson({
      'id': 'session-1',
      'account_id': 'account-1',
      'domain': 'music',
      'manual_id': 'spotify:track-1',
      'title': 'Track',
      'subtitle': 'Artist',
      'caption': 'Album',
      'artwork_url': 'https://cdn.example/cover.jpg',
      'small_image': 'https://cdn.example/icon.png',
      'lease_minutes': 5,
      'lease_expires_at': '2026-11-14T12:05:00Z',
      'started_at': '2026-11-14T12:00:00Z',
      'created_at': '2026-11-14T12:00:00Z',
      'updated_at': '2026-11-14T12:01:00Z',
      'meta': {'progress_ms': 15000},
    });

    expect(activity.id, 'session-1');
    expect(activity.accountId, 'account-1');
    expect(activity.type, 'music');
    expect(activity.manualId, 'spotify:track-1');
    expect(activity.largeImage, 'https://cdn.example/cover.jpg');
    expect(activity.smallImage, 'https://cdn.example/icon.png');
    expect(activity.leaseMinutes, 5);
    expect(activity.leaseExpiresAt, DateTime.utc(2026, 11, 14, 12, 5));
    expect(activity.createdAt, DateTime.utc(2026, 11, 14, 12));
    expect(activity.meta?['progress_ms'], 15000);
  });

  test('normalizes Pulsar domains without a dedicated glyph', () {
    expect(pulsarDomainToType('video'), 'entertainment');
    expect(pulsarDomainToType('anime'), 'entertainment');
    expect(pulsarDomainToType('book'), 'reading');
    expect(pulsarDomainToType('custom'), 'other');
    expect(pulsarDomainToType('gaming'), 'gaming');
  });

  test('converts an RPC activity into a Pulsar now-playing body', () {
    final body = pulsarNowPlayingBody({
      'type': 'music',
      'manual_id': 'rpc:123',
      'title': 'Track',
      'subtitle': 'Artist',
      'large_image': 'https://cdn.example/cover.jpg',
      'small_image': 'https://cdn.example/icon.png',
      'lease_minutes': 5,
      'meta': {'source': 'rpc'},
    });

    expect(body['domain'], 'music');
    expect(body['manual_id'], 'rpc:123');
    expect(body['artwork_url'], 'https://cdn.example/cover.jpg');
    expect(body['large_image'], 'https://cdn.example/cover.jpg');
    expect(body['small_image'], 'https://cdn.example/icon.png');
    expect(body['lease_minutes'], 5);
    expect(body['meta'], {'source': 'rpc'});
  });

  test('groups batch presence by account', () {
    final grouped = pulsarActivitiesByAccount([
      {'id': 'a', 'account_id': 'one', 'domain': 'music', 'title': 'A'},
      {'id': 'b', 'account_id': 'two', 'domain': 'gaming', 'title': 'B'},
      {'id': 'c', 'account_id': 'one', 'domain': 'video', 'title': 'C'},
    ]);

    expect(grouped['one']?.length, 2);
    expect(grouped['two']?.single.type, 'gaming');
  });
}
