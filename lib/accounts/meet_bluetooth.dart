import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

const kMeetBluetoothServiceUuid = 'FFF0';

final meetBluetoothServiceProvider = Provider<MeetBluetoothService>((ref) {
  return const MeetBluetoothService();
});

class MeetBluetoothDiscovery {
  final String meetId;
  final String deviceId;
  final String? name;
  final int rssi;

  const MeetBluetoothDiscovery({
    required this.meetId,
    required this.deviceId,
    required this.name,
    required this.rssi,
  });
}

class MeetBluetoothService {
  static const MethodChannel _channel = MethodChannel(
    'dev.solsynth.solian/meet_bluetooth',
  );

  const MeetBluetoothService();

  bool get supportsNearbyDiscovery =>
      kIsWeb ||
      switch (defaultTargetPlatform) {
        TargetPlatform.android ||
        TargetPlatform.iOS ||
        TargetPlatform.macOS ||
        TargetPlatform.linux => true,
        _ => false,
      };

  bool get supportsAdvertising =>
      !kIsWeb &&
      switch (defaultTargetPlatform) {
        TargetPlatform.android ||
        TargetPlatform.iOS ||
        TargetPlatform.macOS => true,
        _ => false,
      };

  Future<void> ensureScanReady() async {
    _ensureDiscoverySupported();
    await _requestPermissions(forAdvertise: false);
    await _ensureBluetoothOn();
  }

  Future<void> ensureAdvertiseReady() async {
    _ensureAdvertisingSupported();
    await _requestPermissions(forAdvertise: true);
    await _ensureBluetoothOn();
  }

  Future<void> startAdvertising(String meetId) async {
    await ensureAdvertiseReady();
    await _channel.invokeMethod('startAdvertising', {'meetId': meetId});
  }

  Future<void> stopAdvertising() async {
    if (!supportsAdvertising) return;
    await _channel.invokeMethod('stopAdvertising');
  }

  Future<void> startScan({Duration timeout = const Duration(seconds: 12)}) async {
    await ensureScanReady();
    if (await FlutterBluePlus.isScanning.first) {
      await FlutterBluePlus.stopScan();
    }
    await FlutterBluePlus.startScan(
      withServices: [Guid(kMeetBluetoothServiceUuid)],
      timeout: timeout,
    );
  }

  Future<void> stopScan() async {
    if (!supportsNearbyDiscovery) return;
    if (await FlutterBluePlus.isScanning.first) {
      await FlutterBluePlus.stopScan();
    }
  }

  List<MeetBluetoothDiscovery> parseDiscoveries(List<ScanResult> results) {
    final byMeetId = <String, MeetBluetoothDiscovery>{};
    final targetGuid = Guid(kMeetBluetoothServiceUuid);

    for (final result in results) {
      List<int>? rawBytes;
      for (final entry in result.advertisementData.serviceData.entries) {
        if (_guidEquals(entry.key, targetGuid)) {
          rawBytes = entry.value;
          break;
        }
      }

      if (rawBytes == null || rawBytes.length != 16) continue;
      final meetId = _bytesToUuid(rawBytes);
      final current = byMeetId[meetId];
      final name = result.advertisementData.advName.isNotEmpty
          ? result.advertisementData.advName
          : null;

      if (current == null || result.rssi > current.rssi) {
        byMeetId[meetId] = MeetBluetoothDiscovery(
          meetId: meetId,
          deviceId: result.device.remoteId.str,
          name: name,
          rssi: result.rssi,
        );
      }
    }

    final items = byMeetId.values.toList()
      ..sort((a, b) => b.rssi.compareTo(a.rssi));
    return items;
  }

  void _ensureDiscoverySupported() {
    if (!supportsNearbyDiscovery) {
      throw UnsupportedError(
        'Nearby Bluetooth meet discovery is not supported on this platform.',
      );
    }
  }

  void _ensureAdvertisingSupported() {
    if (!supportsAdvertising) {
      throw UnsupportedError(
        'Bluetooth meet broadcasting is not supported on this platform.',
      );
    }
  }

  Future<void> _requestPermissions({required bool forAdvertise}) async {
    if (kIsWeb) return;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final permissions = <Permission>[
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        if (forAdvertise) Permission.bluetoothAdvertise,
      ];

      final result = await permissions.request();
      final denied = result.values.any((status) => !status.isGranted);
      if (denied) {
        throw StateError('Bluetooth permission is required to use Meet.');
      }
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final status = await Permission.bluetooth.request();
      if (!status.isGranted) {
        throw StateError('Bluetooth permission is required to use Meet.');
      }
    }
  }

  Future<void> _ensureBluetoothOn() async {
    if (await FlutterBluePlus.isSupported == false) {
      throw StateError('Bluetooth LE is not supported on this device.');
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await FlutterBluePlus.turnOn();
    }

    final initial = await FlutterBluePlus.adapterState.first;
    if (initial == BluetoothAdapterState.unknown &&
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      await Future<void>.delayed(const Duration(seconds: 1));
    }

    final state = await FlutterBluePlus.adapterState
        .where(
          (value) =>
              value != BluetoothAdapterState.unknown &&
              value != BluetoothAdapterState.turningOn,
        )
        .first
        .timeout(const Duration(seconds: 10));

    if (state == BluetoothAdapterState.on) {
      return;
    }

    if (state == BluetoothAdapterState.unauthorized) {
      throw StateError(
        'Bluetooth permission is blocked. Please allow Solian in System Settings > Privacy & Security > Bluetooth.',
      );
    }

    if (state == BluetoothAdapterState.unavailable) {
      throw StateError(
        'Bluetooth hardware is unavailable. On macOS, make sure the app has Bluetooth sandbox access.',
      );
    }

    if (state == BluetoothAdapterState.off) {
      throw StateError('Bluetooth must be turned on before using Meet.');
    }

    throw StateError('Bluetooth is not ready yet. Current state: $state');
  }
}

bool _guidEquals(Guid left, Guid right) {
  return left.str128.toLowerCase() == right.str128.toLowerCase();
}

String _bytesToUuid(List<int> bytes) {
  final buffer = StringBuffer();
  for (var i = 0; i < bytes.length; i++) {
    buffer.write(bytes[i].toRadixString(16).padLeft(2, '0'));
  }

  final hex = buffer.toString();
  return [
    hex.substring(0, 8),
    hex.substring(8, 12),
    hex.substring(12, 16),
    hex.substring(16, 20),
    hex.substring(20, 32),
  ].join('-');
}

int estimateDistancePercent(int rssi) {
  final bounded = max(-100, min(-35, rssi));
  return ((bounded + 100) / 65 * 100).round();
}
