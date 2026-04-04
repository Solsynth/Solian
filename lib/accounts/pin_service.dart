import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

enum LocationPinStatus { active, offline, removed, unknown }

enum LocationPinVisibility { public, private, unlisted }

final pinServiceProvider = Provider<PinService>((ref) {
  return PinService(ref.watch(apiClientProvider));
});

class SnLocationPin {
  final String id;
  final String accountId;
  final String deviceId;
  final LocationPinVisibility visibility;
  final LocationPinStatus status;
  final DateTime? lastHeartbeatAt;
  final DateTime? expiresAt;
  final String? locationName;
  final String? locationAddress;
  final String? locationWkt;
  final bool keepOnDisconnect;
  final Map<String, dynamic> metadata;
  final SnAccount? account;

  const SnLocationPin({
    required this.id,
    required this.accountId,
    required this.deviceId,
    required this.visibility,
    required this.status,
    this.lastHeartbeatAt,
    this.expiresAt,
    this.locationName,
    this.locationAddress,
    this.locationWkt,
    required this.keepOnDisconnect,
    required this.metadata,
    this.account,
  });

  factory SnLocationPin.fromJson(Map<String, dynamic> json) {
    return SnLocationPin(
      id: (json['id'] ?? '').toString(),
      accountId: (json['account_id'] ?? json['accountId'] ?? '').toString(),
      deviceId: (json['device_id'] ?? json['deviceId'] ?? '').toString(),
      visibility: _parseVisibility(json['visibility']),
      status: _parseStatus(json['status']),
      lastHeartbeatAt: _tryParseDate(
        json['last_heartbeat_at'] ?? json['lastHeartbeatAt'],
      ),
      expiresAt: _tryParseDate(json['expires_at'] ?? json['expiresAt']),
      locationName: json['location_name']?.toString(),
      locationAddress: json['location_address']?.toString(),
      locationWkt: json['location_wkt']?.toString(),
      keepOnDisconnect:
          json['keep_on_disconnect'] ?? json['keepOnDisconnect'] ?? false,
      metadata: json['metadata'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['metadata'] as Map<String, dynamic>)
          : const {},
      account: json['account'] is Map<String, dynamic>
          ? SnAccount.fromJson(json['account'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SnLocationPinEvent {
  final String type;
  final DateTime? sentAt;
  final SnLocationPin? pin;

  const SnLocationPinEvent({required this.type, this.sentAt, this.pin});

  factory SnLocationPinEvent.fromJson(Map<String, dynamic> json) {
    return SnLocationPinEvent(
      type: (json['type'] ?? 'snapshot').toString(),
      sentAt: _tryParseDate(json['sent_at'] ?? json['sentAt']),
      pin: json['pin'] is Map<String, dynamic>
          ? SnLocationPin.fromJson(json['pin'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PinService {
  final Dio _client;

  const PinService(this._client);

  Dio _streamClient() {
    final options = _client.options.copyWith(
      receiveTimeout: Duration.zero,
      sendTimeout: Duration.zero,
    );
    final dio = Dio(options);
    dio.interceptors.addAll(_client.interceptors);
    return dio;
  }

  Future<SnLocationPin> createPin({
    LocationPinVisibility visibility = LocationPinVisibility.public,
    String? locationName,
    String? locationAddress,
    String? locationWkt,
    Map<String, dynamic>? metadata,
    bool keepOnDisconnect = false,
  }) async {
    final response = await _client.post(
      '/passport/pins',
      data: {
        'visibility': switch (visibility) {
          LocationPinVisibility.public => 0,
          LocationPinVisibility.private => 1,
          LocationPinVisibility.unlisted => 2,
        },
        if (locationName?.trim().isNotEmpty ?? false)
          'location_name': locationName!.trim(),
        if (locationAddress?.trim().isNotEmpty ?? false)
          'location_address': locationAddress!.trim(),
        if (locationWkt?.trim().isNotEmpty ?? false)
          'location_wkt': locationWkt!.trim(),
        if (metadata != null && metadata.isNotEmpty) 'metadata': metadata,
        'keep_on_disconnect': keepOnDisconnect,
      },
    );
    return SnLocationPin.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<SnLocationPin> updatePinLocation({
    required String pinId,
    String? locationName,
    String? locationAddress,
    String? locationWkt,
  }) async {
    final response = await _client.put(
      '/passport/pins/$pinId/location',
      data: {
        if (locationName?.trim().isNotEmpty ?? false)
          'location_name': locationName!.trim(),
        if (locationAddress?.trim().isNotEmpty ?? false)
          'location_address': locationAddress!.trim(),
        if (locationWkt?.trim().isNotEmpty ?? false)
          'location_wkt': locationWkt!.trim(),
      },
    );
    return SnLocationPin.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<void> removePin(String pinId) async {
    await _client.delete('/passport/pins/$pinId');
  }

  Future<List<SnLocationPin>> listNearbyPins({
    String? locationWkt,
    LocationPinVisibility? visibility,
    int offset = 0,
    int take = 50,
  }) async {
    final response = await _client.get(
      '/passport/pins/nearby',
      queryParameters: {
        if (locationWkt?.isNotEmpty ?? false) 'location_wkt': locationWkt,
        if (visibility != null)
          'visibility': switch (visibility) {
            LocationPinVisibility.public => 0,
            LocationPinVisibility.private => 1,
            LocationPinVisibility.unlisted => 2,
          },
        'offset': offset,
        'take': take,
      },
    );

    final data = response.data;
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) => SnLocationPin.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<SnLocationPin> getPin(String pinId, {String? locationWkt}) async {
    final response = await _client.get(
      '/passport/pins/$pinId',
      queryParameters: {
        if (locationWkt?.isNotEmpty ?? false) 'location_wkt': locationWkt,
      },
    );
    return SnLocationPin.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<void> disconnectPin(
    String pinId, {
    bool keepOnDisconnect = false,
  }) async {
    await _client.post(
      '/passport/pins/$pinId/disconnect',
      data: {'keep_on_disconnect': keepOnDisconnect},
    );
  }

  Future<List<SnLocationPin>> getMyPins() async {
    final response = await _client.get('/passport/pins/me');

    final data = response.data;
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) => SnLocationPin.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Stream<SnLocationPinEvent> streamPin(String pinId) async* {
    final response = await _streamClient().get(
      '/passport/pins/$pinId/stream',
      options: Options(
        responseType: ResponseType.stream,
        receiveTimeout: Duration.zero,
        sendTimeout: Duration.zero,
        headers: {'Accept': 'text/event-stream'},
      ),
    );

    final body = response.data;
    if (body is! ResponseBody) {
      throw StateError('Pin stream did not return a response body.');
    }

    String? eventName;
    final dataLines = <String>[];

    await for (final line
        in body.stream
            .cast<List<int>>()
            .transform(utf8.decoder)
            .transform(const LineSplitter())) {
      if (line.isEmpty) {
        if (dataLines.isNotEmpty) {
          final payload = jsonDecode(dataLines.join('\n'));
          if (payload is Map<String, dynamic>) {
            final json = Map<String, dynamic>.from(payload);
            if ((json['type'] == null || json['type'].toString().isEmpty) &&
                eventName != null) {
              json['type'] = eventName;
            }
            yield SnLocationPinEvent.fromJson(json);
          }
        }
        eventName = null;
        dataLines.clear();
        continue;
      }

      if (line.startsWith('event:')) {
        eventName = line.substring(6).trim();
        continue;
      }
      if (line.startsWith('data:')) {
        dataLines.add(line.substring(5).trim());
      }
    }

    if (dataLines.isNotEmpty) {
      final payload = jsonDecode(dataLines.join('\n'));
      if (payload is Map<String, dynamic>) {
        final json = Map<String, dynamic>.from(payload);
        if ((json['type'] == null || json['type'].toString().isEmpty) &&
            eventName != null) {
          json['type'] = eventName;
        }
        yield SnLocationPinEvent.fromJson(json);
      }
    }
  }
}

DateTime? _tryParseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}

LocationPinStatus _parseStatus(dynamic value) {
  return switch (value) {
    0 || '0' || 'Active' || 'active' => LocationPinStatus.active,
    1 || '1' || 'Offline' || 'offline' => LocationPinStatus.offline,
    2 || '2' || 'Removed' || 'removed' => LocationPinStatus.removed,
    _ => LocationPinStatus.unknown,
  };
}

LocationPinVisibility _parseVisibility(dynamic value) {
  return switch (value) {
    0 || '0' || 'Public' || 'public' => LocationPinVisibility.public,
    1 || '1' || 'Private' || 'private' => LocationPinVisibility.private,
    2 || '2' || 'Unlisted' || 'unlisted' => LocationPinVisibility.unlisted,
    _ => LocationPinVisibility.public,
  };
}
