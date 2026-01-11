import 'dart:async';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:windows_notification/windows_notification.dart' as winty;
import 'package:windows_notification/notification_message.dart';

import 'package:dio/dio.dart';

// Windows notification instance
winty.WindowsNotification? windowsNotification;

AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;

void _onAppLifecycleChanged(AppLifecycleState state) {
  _appLifecycleState = state;
}

Future<void> initializeLocalNotifications() async {
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
          onTap: () {
            if (notification.meta['action_uri'] != null) {
              var uri = notification.meta['action_uri'] as String;
              if (uri.startsWith('/')) {
                // In-app routes
                rootNavigatorKey.currentContext?.push(
                  notification.meta['action_uri'],
                );
              } else {
                // External URLs
                launchUrlString(uri);
              }
            }
          },
          onDismissed: () {},
          dismissType: DismissType.onSwipe,
          displayDuration: const Duration(seconds: 5),
          snackBarPosition: SnackBarPosition.top,
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 28, // Windows specific padding
            bottom: 16,
          ),
        );
      } else {
        // App is in background, show Windows system notification
        talker.info(
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
              talker.error('Failed to download pfp image: $e');
            }
          }

          if (img != null && img.isNotEmpty) {
            try {
              final file = await DefaultCacheManager().getSingleFile(
                '$serverUrl/drive/files/${img.firstOrNull}',
              );
              largeImagePath = file.path;
            } catch (e) {
              talker.error('Failed to download large image: $e');
            }
          }

          // Use Windows notification for Windows platform
          final notificationMessage = NotificationMessage.fromPluginTemplate(
            notification.id, // unique id
            notification.title,
            [
              notification.subtitle,
              notification.content,
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
