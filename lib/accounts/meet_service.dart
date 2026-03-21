import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

enum SnMeetStatus { active, completed, expired, cancelled, unknown }

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
  final DateTime? expiresAt;
  final DateTime? completedAt;
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
    required this.expiresAt,
    required this.completedAt,
    required this.locationName,
    required this.locationAddress,
    required this.locationWkt,
    required this.metadata,
    required this.participants,
  });

  bool get isFinal => switch (status) {
    SnMeetStatus.completed || SnMeetStatus.expired || SnMeetStatus.cancelled =>
      true,
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
      expiresAt: _tryParseDate(json['expires_at'] ?? json['expiresAt']),
      completedAt: _tryParseDate(
        json['completed_at'] ?? json['completedAt'],
      ),
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

  Future<SnMeet> createMeet({
    String? locationName,
    String? locationAddress,
    Map<String, dynamic>? metadata,
    int? expiresInSeconds,
  }) async {
    final response = await _client.post(
      '/passport/meets',
      data: {
        if (locationName?.trim().isNotEmpty ?? false)
          'location_name': locationName!.trim(),
        if (locationAddress?.trim().isNotEmpty ?? false)
          'location_address': locationAddress!.trim(),
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

  Stream<SnMeetEvent> joinMeet(String meetId) async* {
    final response = await _client.post(
      '/passport/meets/$meetId/join',
      options: Options(
        responseType: ResponseType.stream,
        receiveTimeout: null,
        sendTimeout: null,
        headers: {'Accept': 'text/event-stream'},
      ),
    );

    final body = response.data;
    if (body is! ResponseBody) {
      throw StateError('Meet join stream did not return a response body.');
    }

    String? eventName;
    final dataLines = <String>[];

    await for (final line in body.stream
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
