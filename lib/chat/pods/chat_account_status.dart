import 'dart:async';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:island/core/network.dart';

part 'chat_account_status.g.dart';

/// Represents a device connected to a chat subscription
class SnChatDeviceStatus {
  final String deviceToken;
  final bool isWebSocketConnected;

  SnChatDeviceStatus({
    required this.deviceToken,
    required this.isWebSocketConnected,
  });

  factory SnChatDeviceStatus.fromJson(Map<String, dynamic> json) {
    return SnChatDeviceStatus(
      deviceToken: json['device_token'] as String,
      isWebSocketConnected: json['is_web_socket_connected'] as bool,
    );
  }
}

/// Represents a chat subscription with notification status
class SnChatSubscriptionStatus {
  final String roomId;
  final String memberId;
  final SnChatRoom room;
  final bool isSubscribed;
  final bool pushNotificationsSuppressed;
  final List<SnChatDeviceStatus> devices;

  SnChatSubscriptionStatus({
    required this.roomId,
    required this.memberId,
    required this.room,
    required this.isSubscribed,
    required this.pushNotificationsSuppressed,
    required this.devices,
  });

  factory SnChatSubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SnChatSubscriptionStatus(
      roomId: json['room_id'] as String,
      memberId: json['member_id'] as String,
      room: SnChatRoom.fromJson(json['room'] as Map<String, dynamic>),
      isSubscribed: json['is_subscribed'] as bool,
      pushNotificationsSuppressed:
          json['push_notifications_suppressed'] as bool,
      devices: (json['devices'] as List)
          .map((e) => SnChatDeviceStatus.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Represents the account's chat status including subscription and notification settings
class SnChatAccountStatus {
  final String accountId;
  final bool hasActiveSubscriptions;
  final bool hasAnyWebSocketConnection;
  final bool pushNotificationsMaySendForUnsubscribedRooms;
  final List<SnChatSubscriptionStatus> subscriptions;

  SnChatAccountStatus({
    required this.accountId,
    required this.hasActiveSubscriptions,
    required this.hasAnyWebSocketConnection,
    required this.pushNotificationsMaySendForUnsubscribedRooms,
    required this.subscriptions,
  });

  factory SnChatAccountStatus.fromJson(Map<String, dynamic> json) {
    return SnChatAccountStatus(
      accountId: json['account_id'] as String,
      hasActiveSubscriptions: json['has_active_subscriptions'] as bool,
      hasAnyWebSocketConnection: json['has_any_web_socket_connection'] as bool,
      pushNotificationsMaySendForUnsubscribedRooms:
          json['push_notifications_may_send_for_unsubscribed_rooms'] as bool,
      subscriptions: (json['subscriptions'] as List)
          .map(
            (e) => SnChatSubscriptionStatus.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  /// Get subscription status for a specific room
  SnChatSubscriptionStatus? getSubscriptionForRoom(String roomId) {
    try {
      return subscriptions.firstWhereOrNull((sub) => sub.roomId == roomId);
    } catch (_) {
      return null;
    }
  }

  /// Check if push notifications are suppressed for a specific room
  bool isPushNotificationsSuppressed(String roomId) {
    final subscription = getSubscriptionForRoom(roomId);
    return subscription?.pushNotificationsSuppressed ?? false;
  }
}

@riverpod
class ChatAccountStatus extends _$ChatAccountStatus {
  static const Duration _pollingInterval = Duration(seconds: 75); // 1m 15s
  Timer? _pollingTimer;

  @override
  Future<SnChatAccountStatus?> build() async {
    // Set up polling timer
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      if (state.hasValue) {
        Logger.root.fine('[ChatAccountStatus] Polling for updates');
        _fetchStatus();
      }
    });

    ref.onDispose(() {
      _pollingTimer?.cancel();
    });

    return _fetchStatus();
  }

  Future<SnChatAccountStatus?> _fetchStatus() async {
    try {
      final client = ref.read(apiClientProvider);
      final resp = await client.get('/messager/chat/accounts/me/status');
      return SnChatAccountStatus.fromJson(resp.data as Map<String, dynamic>);
    } catch (e) {
      Logger.root.warning('[ChatAccountStatus] Failed to fetch status: $e');
      // Return null on error - this is optional data
      return null;
    }
  }

  /// Refresh the account status manually
  Future<void> refresh() async {
    state = AsyncValue.loading();
    state = AsyncValue.data(await _fetchStatus());
  }
}
