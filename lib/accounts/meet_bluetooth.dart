import 'dart:async';
import 'dart:math';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart' as ble;
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/talker.dart';
import 'package:permission_handler/permission_handler.dart';

const kMeetBluetoothServiceUuid = 'FFF0';
const kSolianManufacturerId = 0xFFFF;
const kSolianManufacturerMarkerHex = '534F4C';

final meetBluetoothServiceProvider = Provider<MeetBluetoothService>((ref) {
  return MeetBluetoothService();
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

class BluetoothHexDiscovery {
  final String payloadHex;
  final String deviceId;
  final String? name;
  final int rssi;

  const BluetoothHexDiscovery({
    required this.payloadHex,
    required this.deviceId,
    required this.name,
    required this.rssi,
  });
}

class MeetBluetoothService {
  final ble.CentralManager _centralManager = ble.CentralManager();
  final ble.PeripheralManager _peripheralManager = ble.PeripheralManager();
  final StreamController<List<BluetoothHexDiscovery>>
  _nearbyDiscoveriesController = StreamController.broadcast();
  final StreamController<bool> _nearbyDiscoveryStateController =
      StreamController<bool>.broadcast();
  StreamSubscription<ble.DiscoveredEventArgs>? _nearbyDiscoveredSub;
  Timer? _nearbyDiscoveryTimer;
  final Map<String, BluetoothHexDiscovery> _nearbyDiscoveries = {};
  String? _activeAdvertisementKey;
  bool _isNearbyDiscovering = false;

  MeetBluetoothService();

  bool get supportsNearbyDiscovery =>
      !kIsWeb &&
      switch (defaultTargetPlatform) {
        TargetPlatform.android ||
        TargetPlatform.iOS ||
        TargetPlatform.macOS ||
        TargetPlatform.linux ||
        TargetPlatform.windows => true,
        _ => false,
      };

  bool get supportsAdvertising =>
      !kIsWeb &&
      switch (defaultTargetPlatform) {
        TargetPlatform.android => true,
        _ => false,
      };

  Future<void> ensureScanReady() async {
    _ensureDiscoverySupported();
    await _requestPermissions(forAdvertise: false);
    await _ensureBluetoothOn();
  }

  Stream<List<BluetoothHexDiscovery>> get nearbyDiscoveriesStream =>
      _nearbyDiscoveriesController.stream;

  Stream<bool> get nearbyDiscoveryStateStream =>
      _nearbyDiscoveryStateController.stream;

  Future<void> ensureAdvertiseReady() async {
    _ensureAdvertisingSupported();
    await _requestPermissions(forAdvertise: true);
    await _ensurePeripheralOn();
  }

  Future<void> startAdvertising(String meetId) async {
    final meetBytes = _uuidToBytes(meetId);
    if (meetBytes == null) {
      throw const FormatException('Meet id must be a UUID.');
    }
    await startAdvertisingHex(
      serviceUuid: '0000${kMeetBluetoothServiceUuid.padLeft(4, '0')}-0000-1000-8000-00805f9b34fb',
      payloadHex: _bytesToHex(meetBytes).toUpperCase(),
    );
  }

  Future<void> startAdvertisingHex({
    required String serviceUuid,
    required String payloadHex,
  }) async {
    await ensureAdvertiseReady();
    final service = ble.UUID.fromString(serviceUuid);
    final payload = _hexToBytes(payloadHex);
    if (payload == null || payload.isEmpty) {
      throw const FormatException('Payload hex is invalid.');
    }
    final advertisementKey = '${serviceUuid.toLowerCase()}|${payloadHex.toUpperCase()}';
    if (_activeAdvertisementKey == advertisementKey) {
      talker.info(
        '[Nearby/BLE] startAdvertising skipped serviceUuid=$serviceUuid payloadHex=$payloadHex because the same advertisement is already active',
      );
      return;
    }

    const useSeparateServiceUuidField = true;
    // Android returns ADVERTISE_FAILED_ALREADY_STARTED (3) if an old
    // advertisement is still active, so always stop before re-arming.
    await stopAdvertising();
    if (defaultTargetPlatform == TargetPlatform.android) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }
    final advertisement = ble.Advertisement(
      serviceUUIDs: [service],
      serviceData: {service: Uint8List.fromList(payload)},
    );
    final payloadLayout = _buildAdvertisementLayout(
      serviceUuid: serviceUuid,
      payloadHex: payloadHex.toUpperCase(),
      includeSeparateServiceUuid: useSeparateServiceUuidField,
    );
    talker.info(
      '[Nearby/BLE] startAdvertising serviceUuid=$serviceUuid serviceUuidBytes=${_bytesToHex(service.value).toUpperCase()} payloadHex=$payloadHex payloadBytes=${payload.length} estimatedBytes=${payloadLayout.totalBytes} separateServiceUuid=$useSeparateServiceUuidField layout=${payloadLayout.summary}',
    );
    try {
      await _peripheralManager.startAdvertising(advertisement);
      _activeAdvertisementKey = advertisementKey;
    } catch (error) {
      _activeAdvertisementKey = null;
      rethrow;
    }
  }

  Future<void> stopAdvertising() async {
    if (!supportsAdvertising) return;
    if (_activeAdvertisementKey == null) return;
    try {
      await _peripheralManager.stopAdvertising();
      talker.info('[Nearby/BLE] stopAdvertising');
    } finally {
      _activeAdvertisementKey = null;
    }
  }

  Future<void> startScan({
    Duration timeout = const Duration(seconds: 12),
  }) async {
    await ensureScanReady();
    if (await FlutterBluePlus.isScanning.first) {
      await FlutterBluePlus.stopScan();
    }
    await FlutterBluePlus.startScan(
      withServices: [Guid(kMeetBluetoothServiceUuid)],
      timeout: timeout,
    );
  }

  Future<void> startScanForService(
    String serviceUuid, {
    Duration timeout = const Duration(seconds: 12),
    bool useServiceFilter = true,
  }) async {
    await ensureScanReady();
    if (await FlutterBluePlus.isScanning.first) {
      await FlutterBluePlus.stopScan();
    }
    talker.info(
      '[Nearby/BLE] startScan serviceUuid=$serviceUuid useServiceFilter=$useServiceFilter timeoutSec=${timeout.inSeconds}',
    );
    if (useServiceFilter) {
      await FlutterBluePlus.startScan(
        withServices: [Guid(serviceUuid)],
        timeout: timeout,
      );
    } else {
      await FlutterBluePlus.startScan(timeout: timeout);
    }
  }

  Future<void> stopScan() async {
    if (!supportsNearbyDiscovery) return;
    if (await FlutterBluePlus.isScanning.first) {
      await FlutterBluePlus.stopScan();
    }
  }

  Future<void> startNearbyDiscoveryForService(
    String serviceUuid, {
    Duration timeout = const Duration(seconds: 12),
    int? expectedLength,
  }) async {
    await ensureNearbyDiscoveryReady();
    await stopNearbyDiscovery();
    _nearbyDiscoveries.clear();

    final targetUuid = ble.UUID.fromString(serviceUuid);
    talker.info(
      '[Nearby/BLE] startNearbyDiscovery serviceUuid=$serviceUuid timeoutSec=${timeout.inSeconds}',
    );

    _nearbyDiscoveredSub = _centralManager.discovered.listen((event) {
      final parsed = _parseNearbyDiscoveryEvent(
        event,
        targetUuid: targetUuid,
        expectedLength: expectedLength,
      );
      if (parsed == null) return;

      final current = _nearbyDiscoveries[parsed.payloadHex];
      if (current == null || parsed.rssi > current.rssi) {
        _nearbyDiscoveries[parsed.payloadHex] = parsed;
        final items = _nearbyDiscoveries.values.toList()
          ..sort((a, b) => b.rssi.compareTo(a.rssi));
        _nearbyDiscoveriesController.add(items);
        talker.info(
          '[Nearby/BLE] parsed ${items.length} discoveries for serviceUuid=$serviceUuid payloads=${items.map((e) => e.payloadHex).join(",")}',
        );
      }
    });

    await _centralManager.startDiscovery(serviceUUIDs: [targetUuid]);
    _isNearbyDiscovering = true;
    _nearbyDiscoveryStateController.add(true);
    _nearbyDiscoveryTimer = Timer(timeout, () {
      unawaited(stopNearbyDiscovery());
    });
  }

  Future<void> stopNearbyDiscovery() async {
    _nearbyDiscoveryTimer?.cancel();
    _nearbyDiscoveryTimer = null;
    await _nearbyDiscoveredSub?.cancel();
    _nearbyDiscoveredSub = null;
    if (_isNearbyDiscovering) {
      await _centralManager.stopDiscovery();
      _isNearbyDiscovering = false;
      _nearbyDiscoveryStateController.add(false);
      talker.info('[Nearby/BLE] stopNearbyDiscovery');
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

  List<BluetoothHexDiscovery> parseHexDiscoveries(
    List<ScanResult> results, {
    required String serviceUuid,
    int? expectedLength,
  }) {
    final byPayload = <String, BluetoothHexDiscovery>{};
    final targetGuid = Guid(serviceUuid);
    final matchingServiceUuids = <String>[];
    final matchingManufacturerRows = <String>[];
    final rawServiceDataRows = <String>[];

    for (final result in results) {
      final advertisedServiceData = result.advertisementData.serviceData.entries
          .map(
            (entry) =>
                '${entry.key.str128.toUpperCase()}:${_bytesToHex(entry.value).toUpperCase()}',
          )
          .toList();
      if (result.advertisementData.serviceUuids.any(
        (entry) => _guidEquals(entry, targetGuid),
      )) {
        matchingServiceUuids.add(
          '${result.device.remoteId.str}@${result.rssi}',
        );
      }
      if (result.advertisementData.manufacturerData.containsKey(
        kSolianManufacturerId,
      )) {
        matchingManufacturerRows.add(
          '${result.device.remoteId.str}@${result.rssi}:${_bytesToHex(result.advertisementData.manufacturerData[kSolianManufacturerId]!).toUpperCase()}',
        );
      }
      if (advertisedServiceData.isNotEmpty) {
        rawServiceDataRows.add(
          '${result.device.remoteId.str}@${result.rssi}:${advertisedServiceData.join("|")}',
        );
      }

      List<int>? rawBytes;
      for (final entry in result.advertisementData.serviceData.entries) {
        if (_guidEquals(entry.key, targetGuid)) {
          rawBytes = entry.value;
          break;
        }
      }

      if (rawBytes == null || rawBytes.isEmpty) continue;
      if (expectedLength != null && rawBytes.length != expectedLength) continue;

      final payloadHex = _bytesToHex(rawBytes).toUpperCase();
      final current = byPayload[payloadHex];
      final name = result.advertisementData.advName.isNotEmpty
          ? result.advertisementData.advName
          : null;

      if (current == null || result.rssi > current.rssi) {
        byPayload[payloadHex] = BluetoothHexDiscovery(
          payloadHex: payloadHex,
          deviceId: result.device.remoteId.str,
          name: name,
          rssi: result.rssi,
        );
      }
    }

    final items = byPayload.values.toList()
      ..sort((a, b) => b.rssi.compareTo(a.rssi));
    if (matchingServiceUuids.isNotEmpty ||
        matchingManufacturerRows.isNotEmpty ||
        rawServiceDataRows.isNotEmpty) {
      talker.info(
        '[Nearby/BLE] rawScan serviceUuid=$serviceUuid matchedServiceUuids=${matchingServiceUuids.join(",")} manufacturer=${matchingManufacturerRows.join(",")} serviceData=${rawServiceDataRows.join(",")}',
      );
    }
    if (items.isNotEmpty) {
      talker.info(
        '[Nearby/BLE] parsed ${items.length} discoveries for serviceUuid=$serviceUuid payloads=${items.map((e) => e.payloadHex).join(",")}',
      );
    }
    return items;
  }

  Future<void> ensureNearbyDiscoveryReady() async {
    _ensureDiscoverySupported();
    await _requestPermissions(forAdvertise: false);
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _centralManager.authorize();
    }

    var state = _centralManager.state;
    if (state == ble.BluetoothLowEnergyState.unknown) {
      state = await _centralManager.stateChanged
          .map((event) => event.state)
          .firstWhere(
            (value) => value != ble.BluetoothLowEnergyState.unknown,
            orElse: () => _centralManager.state,
          );
    }

    if (state == ble.BluetoothLowEnergyState.poweredOn) return;

    if (state == ble.BluetoothLowEnergyState.unauthorized) {
      throw StateError(
        'Bluetooth permission is blocked. Please allow Solian to use Bluetooth.',
      );
    }

    if (state == ble.BluetoothLowEnergyState.unsupported) {
      throw StateError('Bluetooth LE is not supported on this device.');
    }

    if (state == ble.BluetoothLowEnergyState.poweredOff) {
      throw StateError('Bluetooth must be turned on before using Nearby.');
    }

    throw StateError('Bluetooth discovery is not ready yet. Current state: $state');
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
      final current = await Permission.bluetooth.status;
      if (current.isGranted) return;

      final status = await Permission.bluetooth.request();
      if (status.isGranted) return;

      if (status.isPermanentlyDenied || status.isRestricted) {
        throw StateError(
          'Bluetooth permission is blocked on iPhone. Please allow Solian in Settings > Privacy & Security > Bluetooth.',
        );
      }

      throw StateError(
        'Bluetooth permission is required on iPhone to discover nearby Meet sessions.',
      );
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

  Future<void> _ensurePeripheralOn() async {
    if (!supportsAdvertising) {
      throw UnsupportedError(
        'Bluetooth advertising is not supported on this platform.',
      );
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      await _peripheralManager.authorize();
    }

    var state = _peripheralManager.state;
    if (state == ble.BluetoothLowEnergyState.unknown) {
      state = await _peripheralManager.stateChanged
          .map((event) => event.state)
          .firstWhere(
            (value) => value != ble.BluetoothLowEnergyState.unknown,
            orElse: () => _peripheralManager.state,
          );
    }

    if (state == ble.BluetoothLowEnergyState.poweredOn) {
      return;
    }

    if (state == ble.BluetoothLowEnergyState.unauthorized) {
      throw StateError(
        'Bluetooth permission is blocked. Please allow Solian to use Bluetooth.',
      );
    }

    if (state == ble.BluetoothLowEnergyState.unsupported) {
      throw StateError('BLE advertising is not supported on this device.');
    }

    if (state == ble.BluetoothLowEnergyState.poweredOff) {
      throw StateError('Bluetooth must be turned on before using Nearby.');
    }

    throw StateError('Bluetooth advertiser is not ready yet. Current state: $state');
  }

  BluetoothHexDiscovery? _parseNearbyDiscoveryEvent(
    ble.DiscoveredEventArgs event, {
    required ble.UUID targetUuid,
    required int? expectedLength,
  }) {
    final advertisement = event.advertisement;
    final matchingServiceUuids = advertisement.serviceUUIDs
        .where((entry) => _bleUuidEquals(entry, targetUuid))
        .map((entry) => entry.toString().toUpperCase())
        .toList();
    final matchingServiceData = advertisement.serviceData.entries
        .where((entry) => _bleUuidEquals(entry.key, targetUuid))
        .toList();
    final manufacturerRows = advertisement.manufacturerSpecificData
        .map(
          (entry) =>
              '0x${entry.id.toRadixString(16).padLeft(4, '0').toUpperCase()}:${_bytesToHex(entry.data).toUpperCase()}',
        )
        .toList();

    if (matchingServiceUuids.isNotEmpty ||
        matchingServiceData.isNotEmpty ||
        manufacturerRows.isNotEmpty) {
      talker.info(
        '[Nearby/BLE] rawNearbyDiscovery peripheral=${event.peripheral.uuid.toString().toUpperCase()} rssi=${event.rssi} serviceUuids=${matchingServiceUuids.join(",")} serviceData=${matchingServiceData.map((e) => "${e.key.toString().toUpperCase()}:${_bytesToHex(e.value).toUpperCase()}").join(",")} manufacturer=${manufacturerRows.join(",")}',
      );
    }

    if (matchingServiceData.isEmpty) return null;

    final rawBytes = matchingServiceData.first.value;
    if (rawBytes.isEmpty) return null;
    if (expectedLength != null && rawBytes.length != expectedLength) return null;

    return BluetoothHexDiscovery(
      payloadHex: _bytesToHex(rawBytes).toUpperCase(),
      deviceId: event.peripheral.uuid.toString(),
      name: advertisement.name,
      rssi: event.rssi,
    );
  }
}

_AdvertisementLayout _buildAdvertisementLayout({
  required String serviceUuid,
  required String payloadHex,
  required bool includeSeparateServiceUuid,
}) {
  final normalized = serviceUuid.trim().toLowerCase();
  final is16Bit = RegExp(r'^[0-9a-f]{4}$').hasMatch(normalized);
  final uuidBytes = is16Bit ? 2 : 16;
  final sections = <String>[];
  var total = 0;
  if (includeSeparateServiceUuid) {
    final bytes = 1 + 1 + uuidBytes;
    total += bytes;
    sections.add(
      'serviceUUIDs(len=$bytes,type=${is16Bit ? "0x03" : "0x07"},uuid=$normalized)',
    );
  }
  final payloadLength = payloadHex.length ~/ 2;
  final serviceDataBytes = 1 + 1 + uuidBytes + payloadLength;
  total += serviceDataBytes;
  sections.add(
    'serviceData(len=$serviceDataBytes,type=${is16Bit ? "0x16" : "0x21"},uuid=$normalized,payloadHex=${payloadHex.toUpperCase()},payloadBytes=$payloadLength)',
  );
  return _AdvertisementLayout(totalBytes: total, summary: sections.join('; '));
}

class _AdvertisementLayout {
  final int totalBytes;
  final String summary;

  const _AdvertisementLayout({
    required this.totalBytes,
    required this.summary,
  });
}

bool _guidEquals(Guid left, Guid right) {
  return left.str128.toLowerCase() == right.str128.toLowerCase();
}

bool _bleUuidEquals(ble.UUID left, ble.UUID right) {
  return _bytesToHex(left.value) == _bytesToHex(right.value);
}

String _bytesToUuid(List<int> bytes) {
  final hex = _bytesToHex(bytes);
  return [
    hex.substring(0, 8),
    hex.substring(8, 12),
    hex.substring(12, 16),
    hex.substring(16, 20),
    hex.substring(20, 32),
  ].join('-');
}

String _bytesToHex(List<int> bytes) {
  final buffer = StringBuffer();
  for (var i = 0; i < bytes.length; i++) {
    buffer.write(bytes[i].toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}

List<int>? _uuidToBytes(String value) {
  try {
    final uuid = ble.UUID.fromString(value);
    return uuid.value;
  } catch (_) {
    return null;
  }
}

List<int>? _hexToBytes(String value) {
  final hex = value.trim();
  if (hex.isEmpty || hex.length.isOdd) return null;
  final bytes = <int>[];
  for (var i = 0; i < hex.length; i += 2) {
    final part = hex.substring(i, i + 2);
    final parsed = int.tryParse(part, radix: 16);
    if (parsed == null) return null;
    bytes.add(parsed);
  }
  return bytes;
}

int estimateDistancePercent(int rssi) {
  final bounded = max(-100, min(-35, rssi));
  return ((bounded + 100) / 65 * 100).round();
}
