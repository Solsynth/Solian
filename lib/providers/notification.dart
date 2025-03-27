import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:provider/provider.dart';
import 'package:surface/logger.dart';
import 'package:surface/providers/config.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/providers/websocket.dart';
import 'package:surface/types/notification.dart';
import 'package:tray_manager/tray_manager.dart';

class NotificationProvider extends ChangeNotifier {
  late final SnNetworkProvider _sn;
  late final UserProvider _ua;
  late final WebSocketProvider _ws;
  late final ConfigProvider _cfg;

  final AudioPlayer _notifySoundPlayer = AudioPlayer(playerId: 'notify-sound');

  NotificationProvider(BuildContext context) {
    _sn = context.read<SnNetworkProvider>();
    _ua = context.read<UserProvider>();
    _ws = context.read<WebSocketProvider>();
    _cfg = context.read<ConfigProvider>();
  }

  Future<void> registerPushNotifications() async {
    if (kIsWeb || Platform.isWindows || Platform.isLinux) return;
    if (!_ua.isAuthorized) return;

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    late final String? token;
    late final String provider;
    var deviceUuid = await FlutterUdid.consistentUdid;

    if (deviceUuid.isEmpty) {
      logging.warning(
          '[Push Notification] Unable to active push notifications, couldn\'t get device uuid');
      return;
    } else {
      logging.info('[Push Notification] Device UUID is $deviceUuid');
      logging
          .info('[Push Notification] Registering device push notifications...');
    }

    if (Platform.isIOS || Platform.isMacOS) {
      provider = 'apns';
      token = await FirebaseMessaging.instance.getAPNSToken();
    } else {
      provider = 'fcm';
      token = await FirebaseMessaging.instance.getToken();
    }
    logging.info('[Push Notification] Device Push Token is $token');

    try {
      await _sn.client.post(
        '/cgi/id/notifications/subscription',
        data: {
          'provider': provider,
          'device_token': token,
          'device_id': deviceUuid
        },
      );
    } catch (err) {
      logging.error(
          '[Push Notification] Unable to register push notifications: $err');
    }
  }

  int showingCount = 0;
  int showingTrayCount = 0;
  List<SnNotification> notifications = List.empty(growable: true);

  int? skippableNotifyChannel;
  bool isMuted = false;

  void listen() {
    _ws.pk.stream.listen((event) {
      if (event.method == 'notifications.new') {
        final notification = SnNotification.fromJson(event.payload!);

        final doHaptic = _cfg.prefs.getBool(kAppNotifyWithHaptic) ?? true;
        if (doHaptic) HapticFeedback.mediumImpact();

        // April fool notification sfx
        if (_cfg.prefs.getBool(kAppAprilFoolFeatures) ?? true) {
          final now = DateTime.now();
          if (now.day == 1 && now.month == 4) {
            _notifySoundPlayer.play(
              AssetSource('audio/notify/metal-pipe.mp3'),
              volume: 0.6,
            );
          }
        }

        if (notification.topic == 'messaging.message' &&
            skippableNotifyChannel != null) {
          if (notification.metadata['channel_id'] != null &&
              notification.metadata['channel_id'] == skippableNotifyChannel) {
            return;
          }
        }

        if (showingCount < 0) showingCount = 0;
        showingCount++;
        showingTrayCount++;
        notifications.add(notification);
        Future.delayed(const Duration(seconds: 5), () {
          if (showingCount >= 0) showingCount--;
          notifyListeners();
        });
        notifyListeners();
        updateTray();

        if (!kIsWeb && !isMuted) {
          if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
            LocalNotification notify = LocalNotification(
              title: notification.title,
              subtitle: notification.subtitle,
              body: notification.body,
            );
            notify.onClick = () {
              appWindow.show();
            };
            notify.show();
          }
        }
      }
    });
  }

  void clearTray() {
    showingTrayCount = 0;
    updateTray();
  }

  void updateTray() {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) return;
    if (showingTrayCount == 0) {
      trayManager.setTitle('');
    } else {
      trayManager.setTitle(' $showingTrayCount');
    }
  }

  void clear() {
    showingCount = 0;
    notifications.clear();
    updateTray();
    notifyListeners();
  }
}
