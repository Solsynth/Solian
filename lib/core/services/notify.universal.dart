import 'dart:async';
import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/audio.dart';
import 'package:island/core/config.dart';
import 'package:island/core/notification.dart';
import 'package:island/core/services/push_provider.dart';
import 'package:island/core/services/unifiedpush_service.dart';
import 'package:island/route.dart';
import 'package:island/core/websocket.dart';
import 'package:island/talker.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;

void _onAppLifecycleChanged(AppLifecycleState state) {
  _appLifecycleState = state;
}

Future<void> initializeLocalNotifications() async {
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

  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      final payload = response.payload;
      if (payload != null) {
        if (payload.startsWith('/')) {
          // In-app routes
          rootNavigatorKey.currentContext?.router.pushPath(payload);
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
        talker.info(
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
          talker.info(
            '[Notification] Showing system notification: ${notification.title}',
          );

          // Use flutter_local_notifications for universal platforms
          const AndroidNotificationDetails androidNotificationDetails =
              AndroidNotificationDetails(
                'channel_id',
                'channel_name',
                channelDescription: 'channel_description',
                importance: Importance.max,
                priority: Priority.high,
                ticker: 'ticker',
              );
          const NotificationDetails notificationDetails = NotificationDetails(
            android: androidNotificationDetails,
          );
          await flutterLocalNotificationsPlugin.show(
            id: 0,
            title: notification.title,
            body: notification.content,
            notificationDetails: notificationDetails,
            payload: notification.meta['action_uri'] as String?,
          );
        } else {
          talker.info(
            '[Notification] Skipping system notification for unsupported platform: ${notification.title}',
          );
        }
      }
    }
  });
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
        talker.error("Failed to get firebase cloud messaging push token: $err");
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

Future<void> subscribeUnifiedPushNotification(
  Dio apiClient, {
  bool detailedErrors = false,
}) async {
  if (kIsWeb || !(Platform.isAndroid || Platform.isLinux)) {
    return;
  }

  try {
    await registerUnifiedPush(apiClient);
  } catch (err) {
    if (detailedErrors) rethrow;
    talker.error('Failed to register UnifiedPush subscription: $err');
  }
}

Future<void> _putTokenToRemote(Dio apiClient, String token, int type) async {
  await apiClient.put(
    "/ring/notifications/subscription",
    data: {"type": type, "device_token": token},
  );
}
