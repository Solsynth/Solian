import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:island/core/audio.dart';
import 'package:island/core/config.dart';
import 'package:island/core/notification.dart';
import 'package:island/core/services/push_provider.dart';
import 'package:island/chat/pods/native_call_bridge.dart';
import 'package:island/route.dart';
import 'package:island/core/websocket.dart';
import 'package:logging/logging.dart';

import 'package:url_launcher/url_launcher_string.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

import 'udid.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;

void _onAppLifecycleChanged(AppLifecycleState state) {
  _appLifecycleState = state;
}

String _buildThreadIdentifier(SnNotification notification) {
  final meta = notification.meta;
  if (meta['room_id'] != null) {
    return 'room_${meta['room_id']}';
  } else if (meta['user_id'] != null) {
    return 'user_${meta['user_id']}';
  } else if (notification.topic.isNotEmpty) {
    return 'topic_${notification.topic}';
  }
  return 'type_${notification.topic}';
}

Future<List<DarwinNotificationAttachment>> _downloadDarwinAttachments(
  String serverUrl,
  SnNotification notification,
) async {
  final meta = notification.meta;
  final imageIds = <String>[];

  if (meta['images'] is List && (meta['images'] as List).isNotEmpty) {
    imageIds.addAll((meta['images'] as List).map((e) => e.toString()));
  } else if (meta['image'] is String) {
    imageIds.add(meta['image'] as String);
  } else if (meta['pfp'] is String) {
    imageIds.add(meta['pfp'] as String);
  }

  if (imageIds.isEmpty) return [];

  final futures = imageIds.map((imageId) async {
    try {
      final file = await DefaultCacheManager()
          .getSingleFile('$serverUrl/drive/files/$imageId')
          .timeout(const Duration(seconds: 10));
      return DarwinNotificationAttachment(file.path, identifier: imageId);
    } catch (e) {
      Logger.root.warning(
        'Failed to download notification attachment ($imageId): $e',
      );
      return null;
    }
  });

  final results = await Future.wait(futures);
  return results.whereType<DarwinNotificationAttachment>().toList();
}

int _notificationIdFromString(String id) {
  var hash = 0;
  for (var i = 0; i < id.length; i++) {
    hash = (hash * 31 + id.codeUnitAt(i)) & 0x7FFFFFFF;
  }
  return hash;
}

Future<void> initializeLocalNotifications(WidgetRef ref) async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();

  const DarwinInitializationSettings initializationSettingsMacOS =
      DarwinInitializationSettings();

  const LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(defaultActionName: 'Open notification');

  const WindowsInitializationSettings initializationSettingsWindows =
      WindowsInitializationSettings(
        appName: 'Island',
        appUserModelId: 'dev.solsynth.solian',
        guid: 'dev.solsynth.solian',
      );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    macOS: initializationSettingsMacOS,
    linux: initializationSettingsLinux,
    windows: initializationSettingsWindows,
  );

  // Hold the router
  final router = ref.read(routerProvider);
  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      final payload = response.payload;
      if (payload != null) {
        if (payload.startsWith('/')) {
          // In-app routes
          router.navigatePath(payload);
        } else {
          // External URLs
          launchUrlString(payload);
        }
      }
    },
  );

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

const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'solar_network_notifications',
      'Notifications',
      channelDescription: 'Receive notifications from the Solar Network',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Solar Network Notification',
      icon: 'launcher_icon',
    );

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
        // App is in background, show system notification (only on supported platforms)
        if (!kIsWeb && !Platform.isIOS) {
          Logger.root.info(
            '[Notification] Showing system notification: ${notification.title}',
          );

          final serverUrl = ref.read(serverUrlProvider);
          final threadId = _buildThreadIdentifier(notification);
          final attachments = await _downloadDarwinAttachments(
            serverUrl,
            notification,
          );

          final DarwinNotificationDetails darwinNotificationDetails =
              DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
                sound: notification.topic.startsWith('messages.')
                    ? 'SfxMessage.caf'
                    : 'SfxNotification.caf',
                threadIdentifier: threadId,
                categoryIdentifier: notification.topic.startsWith('messages.')
                    ? 'CHAT_MESSAGE'
                    : null,
                attachments: attachments,
              );
          final NotificationDetails notificationDetails = NotificationDetails(
            android: androidNotificationDetails,
            macOS: darwinNotificationDetails,
          );
          await flutterLocalNotificationsPlugin.show(
            id: _notificationIdFromString(notification.id),
            title: notification.title,
            body: notification.body,
            notificationDetails: notificationDetails,
            payload: notification.meta['action_uri'] as String?,
          );
        } else {
          Logger.root.info(
            '[Notification] Skipping system notification for unsupported platform: ${notification.title}',
          );
        }
      }
    }
  });
}

Future<void> showDebugLocalNotification(WidgetRef ref) async {
  if (kIsWeb || Platform.isIOS) return;

  const darwinNotificationDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  const notificationDetails = NotificationDetails(
    android: androidNotificationDetails,
    macOS: darwinNotificationDetails,
    linux: LinuxNotificationDetails(),
  );

  final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  await flutterLocalNotificationsPlugin.show(
    id: id,
    title: 'Debug Local Notification',
    body: 'This is a locally-triggered notification from Debug Sheet.',
    notificationDetails: notificationDetails,
    payload: '/dashboard',
  );
}

Future<void> subscribePushNotification(
  Dio apiClient, {
  bool detailedErrors = false,
}) async {
  if (Firebase.apps.isEmpty) {
    Logger.root.warning(
      '[Notification] Skipping push subscription because Firebase is unavailable.',
    );
    return;
  }
  if (!kIsWeb && Platform.isLinux) {
    return;
  }
  if (!kIsWeb && Platform.isAndroid) {
    await NativeCallBackgroundBridge.ensureInitialized();
  }
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  final deviceName = await getDeviceName();

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
      .listen((fcmToken) async {
        if (kIsWeb || Platform.isAndroid) {
          await _putTokenToRemote(
            apiClient,
            fcmToken,
            PushNotificationProvider.fcm.remoteType,
            deviceName: deviceName,
          );
          return;
        }
        if (Platform.isIOS) {
          await _registerApnsTokenIfAvailable(
            apiClient,
            deviceName: deviceName,
          );
          await _registerVoipTokenIfAvailable(
            apiClient,
            deviceName: deviceName,
          );
        }
      })
      .onError((err) {
        Logger.root.severe(
          "Failed to get firebase cloud messaging push token",
          err,
        );
      });

  var registered = false;
  if (deviceToken != null && deviceToken.isNotEmpty) {
    registered = true;
    await _putTokenToRemote(
      apiClient,
      deviceToken,
      !kIsWeb && (Platform.isIOS || Platform.isMacOS)
          ? PushNotificationProvider.apple.remoteType
          : PushNotificationProvider.fcm.remoteType,
      deviceName: deviceName,
    );
  }
  if (!kIsWeb && Platform.isIOS) {
    registered =
        await _registerVoipTokenIfAvailable(
          apiClient,
          deviceName: deviceName,
        ) ||
        registered;
  }
  if (!registered && detailedErrors) {
    throw Exception("Failed to get device token for push notifications.");
  }
}

Future<bool> _registerApnsTokenIfAvailable(
  Dio apiClient, {
  required String deviceName,
}) async {
  if (kIsWeb || !Platform.isIOS) return false;
  try {
    String? apnsToken;
    for (var i = 0; i < 10; i++) {
      apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null && apnsToken.isNotEmpty) break;
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
    if (apnsToken == null || apnsToken.isEmpty) {
      return false;
    }
    Logger.root.info(
      '[Notification] Registering APNs token ${apnsToken.substring(0, 8)}…',
    );
    await _putTokenToRemote(
      apiClient,
      apnsToken,
      PushNotificationProvider.apple.remoteType,
      deviceName: deviceName,
    );
    return true;
  } catch (err) {
    Logger.root.warning('[Notification] Failed to register APNs token: $err');
    return false;
  }
}

Future<bool> _registerVoipTokenIfAvailable(
  Dio apiClient, {
  required String deviceName,
}) async {
  if (kIsWeb || !Platform.isIOS) return false;
  try {
    String? voipToken;
    for (var i = 0; i < 10; i++) {
      voipToken = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
      if (voipToken != null && voipToken.isNotEmpty) break;
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
    if (voipToken == null || voipToken.isEmpty) {
      return false;
    }
    Logger.root.info(
      '[Notification] Registering VoIP token ${voipToken.substring(0, 8)}…',
    );
    await _putTokenToRemote(
      apiClient,
      voipToken,
      PushNotificationProvider.appk.remoteType,
      deviceName: deviceName,
    );
    return true;
  } catch (err) {
    Logger.root.warning('[Notification] Failed to register VoIP token: $err');
    return false;
  }
}

Future<void> _putTokenToRemote(
  Dio apiClient,
  String token,
  int type, {
  required String deviceName,
}) async {
  await apiClient.put(
    "/ring/notifications/subscription",
    data: {
      "provider": type,
      "device_token": token,
      "device_name": deviceName,
      "app_id": kNotificationTenantAppId,
    },
  );
}
