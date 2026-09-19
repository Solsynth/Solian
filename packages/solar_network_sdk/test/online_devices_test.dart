import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:test/test.dart';

void main() {
  group('SnOnlineDevice', () {
    test('fromJson parses online device fields', () {
      final device = SnOnlineDevice.fromJson(const {
        'id': 'auth-client-1',
        'device_id': 'iphone-pro',
        'device_name': 'iPhone 15 Pro',
        'device_label': 'My Phone',
        'platform': 3,
        'last_granted_at': '2026-09-19T12:00:00Z',
      });

      expect(device.id, 'auth-client-1');
      expect(device.deviceId, 'iphone-pro');
      expect(device.deviceName, 'iPhone 15 Pro');
      expect(device.deviceLabel, 'My Phone');
      expect(device.platform, 3);
      expect(device.lastGrantedAt, isNotNull);
      expect(device.displayName, 'My Phone');
    });

    test('fromJson defaults when fields absent', () {
      final device = SnOnlineDevice.fromJson(const {
        'id': 'auth-client-1',
        'device_id': 'macbook',
        'device_name': 'MacBook Pro',
      });

      expect(device.deviceLabel, isNull);
      expect(device.platform, 0);
      expect(device.lastGrantedAt, isNull);
      expect(device.displayName, 'MacBook Pro');
    });
  });

  group('SnAccountStatus online devices', () {
    Map<String, dynamic> statusJson({bool isOnline = true}) => {
          'id': 'status-1',
          'attitude': 0,
          'is_online': isOnline,
          'is_customized': false,
          'type': 0,
          'meta': null,
          'cleared_at': null,
          'account_id': 'acc-1',
          'created_at': '2026-09-19T12:00:00Z',
          'updated_at': '2026-09-19T12:00:00Z',
          'deleted_at': null,
          'online_devices': [
            {
              'id': 'auth-client-1',
              'device_id': 'iphone-pro',
              'device_name': 'iPhone 15 Pro',
              'platform': 3,
              'last_granted_at': '2026-09-19T12:00:00Z',
            },
          ],
        };

    test('fromJson parses online_devices', () {
      final status = SnAccountStatus.fromJson(statusJson());

      expect(status.isOnline, isTrue);
      expect(status.onlineDevices, hasLength(1));
      expect(status.onlineDevices.first.deviceName, 'iPhone 15 Pro');
      expect(status.onlineDevices.first.platform, 3);
    });

    test('fromJson defaults online_devices to empty list', () {
      final status = SnAccountStatus.fromJson(statusJson()..remove('online_devices'));

      expect(status.onlineDevices, isEmpty);
    });

    test('toJson emits online_devices as snake_case', () {
      final status = SnAccountStatus.fromJson(statusJson()).toJson();

      expect(status['online_devices'], isA<List>());
      expect(
        (status['online_devices'] as List).first,
        containsPair('device_name', 'iPhone 15 Pro'),
      );
    });
  });

  group('Device/session online state', () {
    test('SnAuthDeviceWithSession parses is_online', () {
      final device = SnAuthDeviceWithSession.fromJson(const {
        'id': 'auth-client-1',
        'device_id': 'iphone-pro',
        'device_name': 'iPhone 15 Pro',
        'account_id': 'acc-1',
        'platform': 3,
        'sessions': [],
        'is_online': true,
      });

      expect(device.isOnline, isTrue);
    });

    test('SnAuthSession defaults is_online to false', () {
      final session = SnAuthSession.fromJson(const {
        'id': 'session-1',
        'last_granted_at': '2026-09-19T12:00:00Z',
        'type': 1,
        'account_id': 'acc-1',
        'created_at': '2026-09-19T12:00:00Z',
        'updated_at': '2026-09-19T12:00:00Z',
      });

      expect(session.isOnline, isFalse);
    });
  });
}
