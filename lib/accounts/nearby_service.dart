import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/talker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:uuid/uuid.dart';

const kNearbyDeviceIdKey = 'passport.nearby.device_id';
const kNearbyDefaultServiceUuid = 'FFF0';
const kNearbyDefaultSlotDurationSec = 30;
const kNearbyTokenHexLength = 32;

final nearbyServiceProvider = Provider<NearbyService>((ref) {
  return NearbyService(ref.watch(apiClientProvider));
});

class NearbyPresenceToken {
  final int slot;
  final String token;
  final DateTime? validFrom;
  final DateTime? validTo;

  const NearbyPresenceToken({
    required this.slot,
    required this.token,
    required this.validFrom,
    required this.validTo,
  });

  bool isActiveAt(DateTime instant) {
    final from = validFrom;
    final to = validTo;
    if (from == null || to == null) return false;
    return !instant.isBefore(from) && instant.isBefore(to);
  }

  factory NearbyPresenceToken.fromJson(Map<String, dynamic> json) {
    return NearbyPresenceToken(
      slot: (json['slot'] as num?)?.toInt() ?? 0,
      token: (json['token'] ?? '').toString().toUpperCase(),
      validFrom: _tryParseDate(json['valid_from'] ?? json['validFrom']),
      validTo: _tryParseDate(json['valid_to'] ?? json['validTo']),
    );
  }
}

class NearbyPresenceBundle {
  final String deviceId;
  final String serviceUuid;
  final int slotDurationSec;
  final List<NearbyPresenceToken> tokens;
  final bool discoverable;
  final bool friendOnly;
  final int capabilities;

  const NearbyPresenceBundle({
    required this.deviceId,
    required this.serviceUuid,
    required this.slotDurationSec,
    required this.tokens,
    required this.discoverable,
    required this.friendOnly,
    required this.capabilities,
  });

  NearbyPresenceToken? tokenForNow([DateTime? now]) {
    final instant = now ?? DateTime.now().toUtc();
    for (final token in tokens) {
      if (token.isActiveAt(instant)) return token;
    }
    return tokens.isNotEmpty ? tokens.first : null;
  }

  factory NearbyPresenceBundle.fromJson(
    Map<String, dynamic> json, {
    required String deviceId,
    required bool discoverable,
    required bool friendOnly,
    required int capabilities,
  }) {
    final rawTokens =
        (json['tokens'] as List?)?.whereType<Map<String, dynamic>>() ??
        const [];
    return NearbyPresenceBundle(
      deviceId: deviceId,
      serviceUuid:
          (json['service_uuid'] ??
                  json['serviceUuid'] ??
                  kNearbyDefaultServiceUuid)
              .toString(),
      slotDurationSec:
          (json['slot_duration_sec'] ?? json['slotDurationSec'] as num?)
              ?.toInt() ??
          kNearbyDefaultSlotDurationSec,
      tokens: rawTokens.map(NearbyPresenceToken.fromJson).toList(),
      discoverable: discoverable,
      friendOnly: friendOnly,
      capabilities: capabilities,
    );
  }
}

class NearbyObservation {
  final String token;
  final int slot;
  final int avgRssi;
  final int seenCount;
  final int durationMs;
  final DateTime firstSeenAt;
  final DateTime lastSeenAt;

  const NearbyObservation({
    required this.token,
    required this.slot,
    required this.avgRssi,
    required this.seenCount,
    required this.durationMs,
    required this.firstSeenAt,
    required this.lastSeenAt,
  });

  Map<String, dynamic> toJson() => {
    'token': token,
    'slot': slot,
    'avg_rssi': avgRssi,
    'seen_count': seenCount,
    'duration_ms': durationMs,
    'first_seen_at': firstSeenAt.toUtc().toIso8601String(),
    'last_seen_at': lastSeenAt.toUtc().toIso8601String(),
  };
}

class NearbyPeer {
  final String userId;
  final String displayName;
  final SnCloudFile? avatar;
  final bool isFriend;
  final bool canInvite;
  final String visibility;
  final DateTime? lastSeenAt;

  const NearbyPeer({
    required this.userId,
    required this.displayName,
    required this.avatar,
    required this.isFriend,
    required this.canInvite,
    required this.visibility,
    required this.lastSeenAt,
  });

  factory NearbyPeer.fromJson(Map<String, dynamic> json) {
    return NearbyPeer(
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      displayName: (json['display_name'] ?? json['displayName'] ?? '')
          .toString(),
      avatar: json['avatar'] is Map<String, dynamic>
          ? SnCloudFile.fromJson(json['avatar'] as Map<String, dynamic>)
          : null,
      isFriend: json['is_friend'] == true || json['isFriend'] == true,
      canInvite: json['can_invite'] == true || json['canInvite'] == true,
      visibility: (json['visibility'] ?? 'public').toString(),
      lastSeenAt: _tryParseDate(json['last_seen_at'] ?? json['lastSeenAt']),
    );
  }
}

class NearbyObservationAggregator {
  final Map<String, _NearbyObservationDraft> _drafts = {};

  void ingest({
    required Iterable<String> tokens,
    required int slot,
    required Map<String, int> rssiByToken,
  }) {
    final now = DateTime.now().toUtc();
    for (final token in tokens) {
      final key = '$slot:$token';
      final rssi = rssiByToken[token] ?? -90;
      final draft = _drafts.putIfAbsent(
        key,
        () => _NearbyObservationDraft(
          token: token,
          slot: slot,
          firstSeenAt: now,
          lastSeenAt: now,
          totalRssi: 0,
          seenCount: 0,
        ),
      );
      draft.totalRssi += rssi;
      draft.seenCount += 1;
      draft.lastSeenAt = now;
    }
  }

  List<NearbyObservation> build({
    required int minSeenCount,
    required int minDurationMs,
    required int minAvgRssi,
  }) {
    final now = DateTime.now().toUtc();
    final observations = <NearbyObservation>[];

    _drafts.removeWhere((_, draft) {
      final stale = now.difference(draft.lastSeenAt).inSeconds > 45;
      final durationMs = draft.lastSeenAt
          .difference(draft.firstSeenAt)
          .inMilliseconds;
      final avgRssi = (draft.totalRssi / draft.seenCount).round();
      if (!stale &&
          draft.seenCount >= minSeenCount &&
          durationMs >= minDurationMs &&
          avgRssi >= minAvgRssi) {
        observations.add(
          NearbyObservation(
            token: draft.token,
            slot: draft.slot,
            avgRssi: avgRssi,
            seenCount: draft.seenCount,
            durationMs: durationMs,
            firstSeenAt: draft.firstSeenAt,
            lastSeenAt: draft.lastSeenAt,
          ),
        );
      }
      return stale;
    });

    observations.sort((a, b) => b.lastSeenAt.compareTo(a.lastSeenAt));
    return observations;
  }
}

class NearbyService {
  final Dio _client;

  const NearbyService(this._client);

  Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(kNearbyDeviceIdKey)?.trim();
    if (existing?.isNotEmpty ?? false) return existing!;
    final generated = 'nearby_${const Uuid().v4()}';
    await prefs.setString(kNearbyDeviceIdKey, generated);
    return generated;
  }

  Future<NearbyPresenceBundle> issuePresenceTokens({
    required String deviceId,
    required bool discoverable,
    required bool friendOnly,
    int capabilities = 0,
    int prefetchSlots = 10,
  }) async {
    final response = await _client.post(
      '/passport/nearby/presence-tokens',
      data: {
        'device_id': deviceId,
        'discoverable': discoverable,
        'friend_only': friendOnly,
        'capabilities': capabilities,
        'prefetch_slots': prefetchSlots,
      },
    );

    return NearbyPresenceBundle.fromJson(
      Map<String, dynamic>.from(response.data as Map),
      deviceId: deviceId,
      discoverable: discoverable,
      friendOnly: friendOnly,
      capabilities: capabilities,
    );
  }

  Future<List<NearbyPeer>> resolveObservations(
    List<NearbyObservation> observations,
  ) async {
    if (observations.isEmpty) return const [];

    talker.info(
      '[Nearby] resolve request count=${observations.length} observations=${observations.map((e) => e.toJson()).toList()}',
    );

    final response = await _client.post(
      '/passport/nearby/resolve',
      data: {'observations': observations.map((e) => e.toJson()).toList()},
    );

    final data = Map<String, dynamic>.from(response.data as Map);
    final rawPeers =
        (data['peers'] as List?)?.whereType<Map<String, dynamic>>() ?? const [];
    talker.info('[Nearby] resolve response peers=${rawPeers.length} data=$data');
    return rawPeers.map(NearbyPeer.fromJson).toList();
  }

  int currentSlot(int slotDurationSec, [DateTime? now]) {
    final instant = (now ?? DateTime.now()).toUtc();
    return instant.millisecondsSinceEpoch ~/
        Duration(seconds: slotDurationSec).inMilliseconds;
  }
}

class _NearbyObservationDraft {
  final String token;
  final int slot;
  final DateTime firstSeenAt;
  DateTime lastSeenAt;
  int totalRssi;
  int seenCount;

  _NearbyObservationDraft({
    required this.token,
    required this.slot,
    required this.firstSeenAt,
    required this.lastSeenAt,
    required this.totalRssi,
    required this.seenCount,
  });
}

DateTime? _tryParseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  final text = value.toString();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text)?.toUtc();
}
