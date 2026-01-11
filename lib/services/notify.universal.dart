import 'dart:async';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:island/main.dart';
import 'package:island/pods/config.dart';
import 'package:island/route.dart';
import 'package:island/models/account.dart';
import 'package:island/pods/websocket.dart';
import 'package:island/talker.dart';
import 'package:island/widgets/app_notification.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      final payload = response.payload;
      if (payload != null) {
        if (payload.startsWith('/')) {
          // In-app routes
          rootNavigatorKey.currentContext?.push(payload);
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
        // App is focused, show in-app notification
        talker.info(
          '[Notification] Showing in-app notification: ${notification.title}',
        );
        if (settings.notifyWithHaptic) {
          HapticFeedback.heavyImpact();
        }
        if (settings.soundEffects) {
          final player = AudioPlayer();
          player
              .setAudioSource(
                AudioSource.asset('assets/audio/notification.mp3'),
              )
              .then((_) {
                player.play().then((_) => player.dispose());
              });
        }
        showTopSnackBar(
          globalOverlay.currentState!,
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: NotificationCard(notification: notification),
            ),
          ),
          onDismissed: () {},
          dismissType: DismissType.onSwipe,
          displayDuration: const Duration(seconds: 5),
          snackBarPosition: SnackBarPosition.top,
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top:
                (!kIsWeb &&
                    (Platform.isMacOS ||
                        Platform.isWindows ||
                        Platform.isLinux))
                ? 28
                // ignore: use_build_context_synchronously
                : MediaQuery.of(context).padding.top + 16,
            bottom: 16,
          ),
        );
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
            0,
            notification.title,
            notification.content,
            notificationDetails,
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
        _putTokenToRemote(apiClient, fcmToken, 1);
      })
      .onError((err) {
        talker.error("Failed to get firebase cloud messaging push token: $err");
      });

  if (deviceToken != null) {
    _putTokenToRemote(
      apiClient,
      deviceToken,
      !kIsWeb && (Platform.isIOS || Platform.isMacOS) ? 0 : 1,
    );
  } else if (detailedErrors) {
    throw Exception("Failed to get device token for push notifications.");
  }
}

Future<void> _putTokenToRemote(
  Dio apiClient,
  String token,
  int provider,
) async {
  await apiClient.put(
    "/ring/notifications/subscription",
    data: {"provider": provider, "device_token": token},
  );
}
