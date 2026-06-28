import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/audio.dart';
import 'package:island/core/config.dart';
import 'package:island/core/notification.dart';
import 'package:island/core/services/push_provider.dart';
import 'package:island/core/websocket.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:logging/logging.dart';
import 'package:windows_notification/windows_notification.dart' as winty;
import 'package:windows_notification/notification_message.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

import 'udid.dart';

// Windows notification instance
winty.WindowsNotification? windowsNotification;

AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;

void _onAppLifecycleChanged(AppLifecycleState state) {
  _appLifecycleState = state;
}

Future<void> initializeLocalNotifications(WidgetRef _) async {
  // Initialize Windows notification for Windows platform
  windowsNotification = winty.WindowsNotification(applicationId: "Solian");

  WidgetsBinding.instance.addObserver(
    LifecycleEventHandler(onAppLifecycleChanged: _onAppLifecycleChanged),
  );
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final void Function(AppLifecycleState) onAppLifecycleChanged;

  LifecycleEventHandler({required this.onAppLifecycleChanged});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    onAppLifecycleChanged(state);
  }
}

StreamSubscription<WebSocketPacket> setupNotificationListener(
  BuildContext context,
  WidgetRef ref,
) {
  final settings = ref.watch(appSettingsProvider);
  final ws = ref.watch(websocketProvider);
  return ws.dataStream.listen((pkt) async {
    if (pkt.type == "notifications.new") {
      final notification = SnNotification.fromJson(pkt.data!);
      if (_appLifecycleState == AppLifecycleState.resumed) {
        Logger.root.info(
          '[Notification] Showing in-app notification: ${notification.title}',
        );
        if (settings.notifyWithHaptic) {
          HapticFeedback.heavyImpact();
        }
        playNotificationSfx(ref);
        ref.read(notificationStateProvider.notifier).add(notification);
      } else {
        // App is in background, show Windows system notification
        Logger.root.info(
          '[Notification] Showing Windows system notification: ${notification.title}',
        );

        if (windowsNotification != null) {
          final serverUrl = ref.read(serverUrlProvider);
          final pfp = notification.meta['pfp'] as String?;
          final img = notification.meta['images'] as List<dynamic>?;
          final actionUrl = notification.meta['action_uri'] as String?;

          // Download and cache images
          String? imagePath;
          String? largeImagePath;

          if (pfp != null) {
            try {
              final file = await DefaultCacheManager().getSingleFile(
                '$serverUrl/drive/files/$pfp',
              );
              imagePath = file.path;
            } catch (e) {
              Logger.root.severe('Failed to download pfp image: $e');
            }
          }

          if (img != null && img.isNotEmpty) {
            try {
              final file = await DefaultCacheManager().getSingleFile(
                '$serverUrl/drive/files/${img.firstOrNull}',
              );
              largeImagePath = file.path;
            } catch (e) {
              Logger.root.severe('Failed to download large image: $e');
            }
          }

          // Use Windows notification for Windows platform
          final notificationMessage = NotificationMessage.fromPluginTemplate(
            notification.id, // unique id
            notification.title,
            [
              notification.subtitle,
              notification.body,
            ].where((e) => e.isNotEmpty).join('\n'),
            group: notification.topic,
            image: imagePath,
            largeImage: largeImagePath,
            launch: actionUrl != null ? 'solian://$actionUrl' : null,
          );
          await windowsNotification!.showNotificationPluginTemplate(
            notificationMessage,
          );
        }
      }
    }
  });
}

Future<void> showDebugLocalNotification(WidgetRef _) async {
  if (windowsNotification == null) return;

  final id = DateTime.now().millisecondsSinceEpoch.toString();
  final notificationMessage = NotificationMessage.fromPluginTemplate(
    id,
    'Debug Local Notification',
    'This is a locally-triggered notification from Debug Sheet.',
    group: 'debug',
    launch: 'solian:///dashboard',
  );
  await windowsNotification!.showNotificationPluginTemplate(
    notificationMessage,
  );
}

Future<void> subscribePushNotification(
  Dio apiClient, {
  bool detailedErrors = false,
}) async {
  if (!kIsWeb && Platform.isLinux) {
    return;
  }
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  String? deviceToken;
  if (kIsWeb) {
    deviceToken = await FirebaseMessaging.instance.getToken(
      vapidKey:
          "BFN2mkqyeI6oi4d2PAV4pfNyG3Jy0FBEblmmPrjmP0r5lHOPrxrcqLIWhM21R_cicF-j4Xhtr1kyDyDgJYRPLgU",
    );
  } else if (Platform.isAndroid) {
    deviceToken = await FirebaseMessaging.instance.getToken();
  } else if (Platform.isIOS) {
    deviceToken = await FirebaseMessaging.instance.getAPNSToken();
  }

  FirebaseMessaging.instance.onTokenRefresh
      .listen((fcmToken) {
        _putTokenToRemote(
          apiClient,
          fcmToken,
          PushNotificationProvider.fcm.remoteType,
        );
      })
      .onError((err) {
        Logger.root.severe(
          "Failed to get firebase cloud messaging push token",
          err,
        );
      });

  if (deviceToken != null) {
    _putTokenToRemote(
      apiClient,
      deviceToken,
      !kIsWeb && (Platform.isIOS || Platform.isMacOS)
          ? PushNotificationProvider.apple.remoteType
          : PushNotificationProvider.fcm.remoteType,
    );
  } else if (detailedErrors) {
    throw Exception("Failed to get device token for push notifications.");
  }
}

Future<void> _putTokenToRemote(Dio apiClient, String token, int type) async {
  await apiClient.put(
    "/ring/notifications/subscription",
    data: {
      "provider": type,
      "device_token": token,
      "device_name": await getDeviceName(),
      "app_id": kNotificationTenantAppId,
    },
  );
}
