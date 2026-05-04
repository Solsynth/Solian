import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/accounts/widgets/account/friends_overview.dart';
import 'package:island/accounts/widgets/friend_status_toast.dart';
import 'package:island/core/config.dart';
import 'package:island/core/lifecycle.dart';
import 'package:island/core/websocket.dart';
import 'package:logging/logging.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final _log = Logger('FriendStatusListener');

class FriendStatusCache {
  final Map<String, SnAccountStatus> _statusCache = {};
  final Map<String, List<SnPresenceActivity>> _activitiesCache = {};

  SnAccountStatus? getStatus(String accountId) => _statusCache[accountId];
  List<SnPresenceActivity> getActivities(String accountId) =>
      _activitiesCache[accountId] ?? [];

  void updateStatus(String accountId, SnAccountStatus? status) {
    if (status != null) {
      _statusCache[accountId] = status;
    } else {
      _statusCache.remove(accountId);
    }
  }

  void updateActivities(String accountId, List<SnPresenceActivity> activities) {
    _activitiesCache[accountId] = activities;
  }

  void initializeFromFriends(List<SnFriendOverviewItem> friends) {
    for (final friend in friends) {
      _statusCache[friend.account.id] = friend.status;
      _activitiesCache[friend.account.id] = friend.activities;
    }
  }
}

class FriendStatusListener {
  final Ref _ref;
  final FriendStatusCache _cache = FriendStatusCache();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  StreamSubscription<WebSocketPacket>? _wsSubscription;
  bool _initialized = false;

  FriendStatusListener(this._ref) {
    _initialize();
  }

  void _initialize() {
    if (_initialized) return;
    _initialized = true;

    final friendsAsync = _ref.read(friendsOverviewProvider);
    friendsAsync.whenData((friends) {
      _cache.initializeFromFriends(friends);
      _log.info(
        'Initialized friend status cache with ${friends.length} friends',
      );
    });

    _ref.listen<AsyncValue<List<SnFriendOverviewItem>>>(
      friendsOverviewProvider,
      (previous, next) {
        next.whenData((friends) {
          _cache.initializeFromFriends(friends);
        });
      },
    );

    final websocket = _ref.read(websocketProvider);
    _wsSubscription = websocket.dataStream.listen(_handleWebSocketPacket);

    _ref.onDispose(() {
      _wsSubscription?.cancel();
    });
  }

  void _handleWebSocketPacket(WebSocketPacket packet) {
    final data = packet.data;
    if (data == null) return;

    switch (packet.type) {
      case 'account.status.updated':
        _handleStatusUpdate(data);
        break;
      case 'account.presence.activities.updated':
        _handleActivitiesUpdate(data);
        break;
    }
  }

  bool _isAppFocused() {
    final lifecycleState = _ref.read(appLifecycleStateProvider);
    return lifecycleState.maybeWhen(
      data: (state) => state == AppLifecycleState.resumed,
      orElse: () => true,
    );
  }

  String _getEventCaption(FriendStatusChangeType changeType) {
    return switch (changeType) {
      FriendStatusChangeType.online => 'came online',
      FriendStatusChangeType.offline => 'went offline',
      FriendStatusChangeType.busy => 'is now busy',
      FriendStatusChangeType.doNotDisturb => 'is now do not disturb',
      FriendStatusChangeType.activityStarted => 'started an activity',
      FriendStatusChangeType.activityEnded => 'ended an activity',
    };
  }

  Future<void> _showDesktopNotification(
    FriendStatusChangeEvent event,
  ) async {
    final settings = _ref.read(appSettingsProvider);
    if (!settings.friendStatusDesktopNotification) return;

    if (kIsWeb || Platform.isIOS) return;

    final caption = _getEventCaption(event.changeType);

    final androidDetails = AndroidNotificationDetails(
      'friend_status',
      'Friend Status',
      channelDescription: 'Friend online/offline status changes',
      importance: Importance.low,
      priority: Priority.low,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentSound: false,
      presentBanner: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _notificationsPlugin.show(
      id: event.account.id.hashCode,
      title: event.account.nick,
      body: caption,
      notificationDetails: notificationDetails,
    );

    _log.info(
      'Sent desktop notification for ${event.account.name}: $caption',
    );
  }



  void _handleStatusUpdate(Map<String, dynamic> data) {
    final accountId = data['account_id'] as String?;
    if (accountId == null) return;

    final statusJson = data['status'] as Map<String, dynamic>?;
    if (statusJson == null) return;

    final newStatus = SnAccountStatus.fromJson(statusJson);
    final previousStatus = _cache.getStatus(accountId);

    final friendsAsync = _ref.read(friendsOverviewProvider);
    final friendsList = friendsAsync.value;
    if (friendsList == null) return;

    final friendAccount = friendsList.cast<SnFriendOverviewItem?>().firstWhere(
      (f) => f?.account.id == accountId,
      orElse: () => null,
    );

    if (friendAccount == null) {
      _log.fine('Received status update for non-friend account: $accountId');
      return;
    }

    final changeType = _determineStatusChangeType(previousStatus, newStatus);

    if (changeType != null) {
      _log.info(
        'Friend ${friendAccount.account.name} status changed: $changeType',
      );

      _cache.updateStatus(accountId, newStatus);

      final event = FriendStatusChangeEvent(
        account: friendAccount.account,
        status: newStatus,
        activities: _cache.getActivities(accountId),
        changeType: changeType,
      );

      final isAppFocused = _isAppFocused();
      if (isAppFocused) {
        _ref.read(friendStatusToastProvider.notifier).showEvent(event);
      } else {
        _showDesktopNotification(event);
      }
    } else {
      _cache.updateStatus(accountId, newStatus);
    }
  }

  void _handleActivitiesUpdate(Map<String, dynamic> data) {
    final accountId = data['account_id'] as String?;
    if (accountId == null) return;

    final activitiesJson = data['activities'] as List<dynamic>?;
    if (activitiesJson == null) return;

    final newActivities = activitiesJson
        .map(
          (json) => SnPresenceActivity.fromJson(json as Map<String, dynamic>),
        )
        .toList();

    final previousActivities = _cache.getActivities(accountId);

    final friendsAsync = _ref.read(friendsOverviewProvider);
    final friendsList = friendsAsync.value;
    if (friendsList == null) return;

    final friendAccount = friendsList.cast<SnFriendOverviewItem?>().firstWhere(
      (f) => f?.account.id == accountId,
      orElse: () => null,
    );

    if (friendAccount == null) {
      _log.fine('Received status update for non-friend account: $accountId');
      return;
    }

    final changeType = _determineActivityChangeType(
      previousActivities,
      newActivities,
    );

    if (changeType != null) {
      _log.info(
        'Friend ${friendAccount.account.name} activity changed: $changeType',
      );

      _cache.updateActivities(accountId, newActivities);

      final event = FriendStatusChangeEvent(
        account: friendAccount.account,
        status: _cache.getStatus(accountId),
        activities: newActivities,
        changeType: changeType,
      );

      final isAppFocused = _isAppFocused();
      if (isAppFocused) {
        _ref.read(friendStatusToastProvider.notifier).showEvent(event);
      } else {
        _showDesktopNotification(event);
      }
    } else {
      _cache.updateActivities(accountId, newActivities);
    }
  }

  FriendStatusChangeType? _determineStatusChangeType(
    SnAccountStatus? previous,
    SnAccountStatus? current,
  ) {
    if (previous == null && current == null) return null;

    final wasOnline = previous?.isOnline ?? false;
    final isOnline = current?.isOnline ?? false;

    if (!wasOnline && isOnline) {
      return FriendStatusChangeType.online;
    }

    if (wasOnline && !isOnline) {
      return FriendStatusChangeType.offline;
    }

    if (isOnline) {
      final previousType = previous?.type ?? 0;
      final currentType = current?.type ?? 0;

      if (previousType != currentType) {
        return switch (currentType) {
          1 => FriendStatusChangeType.busy,
          2 => FriendStatusChangeType.doNotDisturb,
          _ => FriendStatusChangeType.online,
        };
      }
    }

    return null;
  }

  FriendStatusChangeType? _determineActivityChangeType(
    List<SnPresenceActivity> previous,
    List<SnPresenceActivity> current,
  ) {
    final hadActivities = previous.isNotEmpty;
    final hasActivities = current.isNotEmpty;

    if (!hadActivities && hasActivities) {
      return FriendStatusChangeType.activityStarted;
    }

    if (hadActivities && !hasActivities) {
      return FriendStatusChangeType.activityEnded;
    }

    if (hasActivities && current.isNotEmpty) {
      final previousTitle = previous.firstOrNull?.title;
      final currentTitle = current.firstOrNull?.title;

      if (previousTitle != currentTitle) {
        return FriendStatusChangeType.activityStarted;
      }
    }

    return null;
  }
}

final friendStatusListenerProvider = Provider<FriendStatusListener>((ref) {
  return FriendStatusListener(ref);
});
