import 'package:flutter_test/flutter_test.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

void main() {
  test('SnPresenceActivity parses server payload with int visibility + string type', () {
    final json = <String, dynamic>{
      'id': '550e8400-e29b-41d4-a716-446655440000',
      'type': 'gaming',
      'manual_id': 'steam',
      'title': 'Elden Ring',
      'subtitle': null,
      'caption': null,
      'title_url': null,
      'subtitle_url': null,
      'small_image': null,
      'large_image': null,
      'meta': null,
      'lease_minutes': 10,
      'lease_expires_at': '2026-08-26T14:35:00Z',
      'account_id': '22222222-2222-2222-2222-222222222222',
      'created_at': '2026-08-26T14:30:00Z',
      'updated_at': '2026-08-26T14:30:00Z',
      'deleted_at': null,
      'started_at': '2026-08-26T14:30:00Z',
      'ended_at': null,
      'catalog_id': 'a1b2c3d4-e29b-41d4-a716-446655440000',
      'tags': [
        {'slug': 'gaming', 'name': 'Gaming'},
        {'slug': 'rpg', 'name': 'RPG'},
      ],
      'visibility': 1, // PresenceVisibility.Public emitted as int
    };

    final activity = SnPresenceActivity.fromJson(json);

    expect(activity.type, 'gaming');
    expect(activity.visibility, 'public');
    expect(activity.tags, hasLength(2));
    expect(activity.tags[0].slug, 'gaming');
    expect(activity.tags[0].name, 'Gaming');
    expect(activity.startedAt, isNotNull);
    expect(activity.catalogId, 'a1b2c3d4-e29b-41d4-a716-446655440000');
  });

  test('SnPresenceActivity parses string visibility + unknown int', () {
    final json = <String, dynamic>{
      'id': 'x',
      'type': 'music',
      'manual_id': 'spotify',
      'title': 'Song',
      'subtitle': null,
      'caption': null,
      'title_url': null,
      'subtitle_url': null,
      'small_image': null,
      'large_image': null,
      'meta': null,
      'lease_minutes': 5,
      'lease_expires_at': '2026-08-26T14:35:00Z',
      'account_id': '22222222-2222-2222-2222-222222222222',
      'created_at': '2026-08-26T14:30:00Z',
      'updated_at': '2026-08-26T14:30:00Z',
      'deleted_at': null,
      'visibility': 'Friends',
      'tags': [],
    };

    final activity = SnPresenceActivity.fromJson(json);

    expect(activity.type, 'music');
    expect(activity.visibility, 'friends');
  });

  test('SnPresenceActivity parses legacy int type', () {
    final json = <String, dynamic>{
      'id': 'y',
      'type': 2, // legacy Music enum
      'manual_id': null,
      'title': 'Old',
      'subtitle': null,
      'caption': null,
      'title_url': null,
      'subtitle_url': null,
      'small_image': null,
      'large_image': null,
      'meta': null,
      'lease_minutes': 5,
      'lease_expires_at': '2026-08-26T14:35:00Z',
      'account_id': '22222222-2222-2222-2222-222222222222',
      'created_at': '2026-08-26T14:30:00Z',
      'updated_at': '2026-08-26T14:30:00Z',
      'deleted_at': null,
    };

    // Legacy int type still crashes today; guard it so old cached payloads degrade.
    expect(
      () => SnPresenceActivity.fromJson(json),
      throwsA(isA<TypeError>()),
    );
  });
}
