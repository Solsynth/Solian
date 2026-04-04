import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

enum SnMeetStatus { active, completed, expired, cancelled, unknown }

enum SnMeetVisibility { public, private, unlisted, unknown }

class SnMeetParticipant {
  final String meetId;
  final String accountId;
  final DateTime? joinedAt;
  final SnAccount? account;

  const SnMeetParticipant({
    required this.meetId,
    required this.accountId,
    this.joinedAt,
    this.account,
  });

  factory SnMeetParticipant.fromJson(Map<String, dynamic> json) {
    return SnMeetParticipant(
      meetId: (json['meet_id'] ?? json['meetId'] ?? '').toString(),
      accountId: (json['account_id'] ?? json['accountId'] ?? '').toString(),
      joinedAt: _tryParseDate(json['joined_at'] ?? json['joinedAt']),
      account: json['account'] is Map<String, dynamic>
          ? SnAccount.fromJson(json['account'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SnMeet {
  final String id;
  final String hostId;
  final SnAccount? host;
  final SnMeetStatus status;
  final SnMeetVisibility visibility;
  final DateTime? expiresAt;
  final DateTime? completedAt;
  final String? notes;
  final SnCloudFile? image;
  final String? locationName;
  final String? locationAddress;
  final String? locationWkt;
  final Map<String, dynamic> metadata;
  final List<SnMeetParticipant> participants;

  const SnMeet({
    required this.id,
    required this.hostId,
    required this.host,
    required this.status,
    required this.visibility,
    required this.expiresAt,
    required this.completedAt,
    required this.notes,
    required this.image,
    required this.locationName,
    required this.locationAddress,
    required this.locationWkt,
    required this.metadata,
    required this.participants,
  });

  bool get isFinal => switch (status) {
    SnMeetStatus.completed ||
    SnMeetStatus.expired ||
    SnMeetStatus.cancelled => true,
    _ => false,
  };

  factory SnMeet.fromJson(Map<String, dynamic> json) {
    final rawParticipants =
        (json['participants'] as List?)?.whereType<Map<String, dynamic>>() ??
        const [];

    return SnMeet(
      id: (json['id'] ?? '').toString(),
      hostId: (json['host_id'] ?? json['hostId'] ?? '').toString(),
      host: json['host'] is Map<String, dynamic>
          ? SnAccount.fromJson(json['host'] as Map<String, dynamic>)
          : null,
      status: _parseMeetStatus(json['status']),
      visibility: _parseMeetVisibility(json['visibility']),
      expiresAt: _tryParseDate(json['expires_at'] ?? json['expiresAt']),
      completedAt: _tryParseDate(json['completed_at'] ?? json['completedAt']),
      notes: json['notes']?.toString(),
      image: json['image'] is Map<String, dynamic>
          ? SnCloudFile.fromJson(json['image'] as Map<String, dynamic>)
          : null,
      locationName: json['location_name']?.toString(),
      locationAddress: json['location_address']?.toString(),
      locationWkt: json['location_wkt']?.toString(),
      metadata: json['metadata'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['metadata'] as Map<String, dynamic>)
          : const {},
      participants: rawParticipants.map(SnMeetParticipant.fromJson).toList(),
    );
  }
}

class SnMeetEvent {
  final String type;
  final DateTime? sentAt;
  final SnMeet meet;

  const SnMeetEvent({
    required this.type,
    required this.sentAt,
    required this.meet,
  });

  factory SnMeetEvent.fromJson(Map<String, dynamic> json) {
    return SnMeetEvent(
      type: (json['type'] ?? 'snapshot').toString(),
      sentAt: _tryParseDate(json['sent_at'] ?? json['sentAt']),
      meet: SnMeet.fromJson(Map<String, dynamic>.from(json['meet'] as Map)),
    );
  }
}

final meetServiceProvider = Provider<MeetService>((ref) {
  return MeetService(ref.watch(apiClientProvider));
});

class MeetService {
  final Dio _client;

  const MeetService(this._client);

  Dio _streamClient() {
    final options = _client.options.copyWith(
      receiveTimeout: Duration.zero,
      sendTimeout: Duration.zero,
    );
    final dio = Dio(options);
    dio.interceptors.addAll(_client.interceptors);
    return dio;
  }

  Future<SnMeet> createMeet({
    SnMeetVisibility visibility = SnMeetVisibility.private,
    String? notes,
    String? imageId,
    String? locationName,
    String? locationAddress,
    String? locationWkt,
    Map<String, dynamic>? metadata,
    int? expiresInSeconds,
  }) async {
    final response = await _client.post(
      '/passport/meets',
      data: {
        'visibility': switch (visibility) {
          SnMeetVisibility.public => 0,
          SnMeetVisibility.private => 1,
          SnMeetVisibility.unlisted => 2,
          SnMeetVisibility.unknown => 1,
        },
        if (notes?.trim().isNotEmpty ?? false) 'notes': notes!.trim(),
        if (imageId?.trim().isNotEmpty ?? false) 'image_id': imageId!.trim(),
        if (locationName?.trim().isNotEmpty ?? false)
          'location_name': locationName!.trim(),
        if (locationAddress?.trim().isNotEmpty ?? false)
          'location_address': locationAddress!.trim(),
        if (locationWkt?.trim().isNotEmpty ?? false)
          'location_wkt': locationWkt!.trim(),
        ...?(metadata != null && metadata.isNotEmpty
            ? {'metadata': metadata}
            : null),
        ...?(expiresInSeconds != null
            ? {'expires_in_seconds': expiresInSeconds}
            : null),
      },
    );
    return SnMeet.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<List<SnMeet>> listMeets({
    SnMeetStatus? status,
    bool hostOnly = false,
    int offset = 0,
    int take = 20,
  }) async {
    final response = await _client.get(
      '/passport/meets',
      queryParameters: {
        if (status != null)
          'status': switch (status) {
            SnMeetStatus.active => 0,
            SnMeetStatus.completed => 1,
            SnMeetStatus.expired => 2,
            SnMeetStatus.cancelled => 3,
            SnMeetStatus.unknown => null,
          },
        'host_only': hostOnly,
        'offset': offset,
        'take': take,
      },
    );

    final data = response.data;
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) => SnMeet.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<SnMeet>> listNearbyMeets({
    required String locationWkt,
    int distanceMeters = 1000,
    SnMeetStatus? status,
    int offset = 0,
    int take = 20,
  }) async {
    final response = await _client.get(
      '/passport/meets/nearby',
      queryParameters: {
        'locationWkt': locationWkt,
        'distanceMeters': distanceMeters,
        if (status != null)
          'status': switch (status) {
            SnMeetStatus.active => 0,
            SnMeetStatus.completed => 1,
            SnMeetStatus.expired => 2,
            SnMeetStatus.cancelled => 3,
            SnMeetStatus.unknown => null,
          },
        'offset': offset,
        'take': take,
      },
    );

    final data = response.data;
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) => SnMeet.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<SnMeet> getMeet(String meetId) async {
    final response = await _client.get('/passport/meets/$meetId');
    return SnMeet.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Stream<SnMeetEvent> joinMeet(String meetId) async* {
    final response = await _streamClient().post(
      '/passport/meets/$meetId/join',
      options: Options(
        responseType: ResponseType.stream,
        receiveTimeout: Duration.zero,
        sendTimeout: Duration.zero,
        headers: {'Accept': 'text/event-stream'},
      ),
    );

    final body = response.data;
    if (body is! ResponseBody) {
      throw StateError('Meet join stream did not return a response body.');
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
            yield SnMeetEvent.fromJson(json);
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
        yield SnMeetEvent.fromJson(json);
      }
    }
  }

  Future<void> completeMeet(String meetId) async {
    await _client.post('/passport/meets/$meetId/complete');
  }

  Future<void> deleteMeet(String meetId) async {
    await _client.delete('/passport/meets/$meetId');
  }

  Future<SnMeet> updateMeetVisibility({
    required String meetId,
    required SnMeetVisibility visibility,
  }) async {
    final response = await _client.patch(
      '/passport/meets/$meetId/visibility',
      data: {
        'visibility': switch (visibility) {
          SnMeetVisibility.public => 0,
          SnMeetVisibility.private => 1,
          SnMeetVisibility.unlisted => 2,
          SnMeetVisibility.unknown => 1,
        },
      },
    );
    return SnMeet.fromJson(Map<String, dynamic>.from(response.data as Map));
  }
}

DateTime? _tryParseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}

SnMeetStatus _parseMeetStatus(dynamic value) {
  return switch (value) {
    0 || '0' || 'Active' || 'active' => SnMeetStatus.active,
    1 || '1' || 'Completed' || 'completed' => SnMeetStatus.completed,
    2 || '2' || 'Expired' || 'expired' => SnMeetStatus.expired,
    3 || '3' || 'Cancelled' || 'cancelled' => SnMeetStatus.cancelled,
    _ => SnMeetStatus.unknown,
  };
}

SnMeetVisibility _parseMeetVisibility(dynamic value) {
  return switch (value) {
    0 || '0' || 'Public' || 'public' => SnMeetVisibility.public,
    1 || '1' || 'Private' || 'private' => SnMeetVisibility.private,
    2 || '2' || 'Unlisted' || 'unlisted' => SnMeetVisibility.unlisted,
    _ => SnMeetVisibility.unknown,
  };
}
