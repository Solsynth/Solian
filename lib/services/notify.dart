import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:island/main.dart';
import 'package:island/route.dart';
import 'package:island/models/user.dart';
import 'package:island/pods/websocket.dart';
import 'package:island/widgets/app_notification.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher_string.dart';

StreamSubscription<WebSocketPacket> setupNotificationListener(
  BuildContext context,
  WidgetRef ref,
) {
  final ws = ref.watch(websocketProvider);
  return ws.dataStream.listen((pkt) {
    if (pkt.type == "notifications.new") {
      final notification = SnNotification.fromJson(pkt.data!);
      showTopSnackBar(
        globalOverlay.currentState!,
        NotificationCard(notification: notification),
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
          top:
              (!kIsWeb &&
                      (Platform.isMacOS ||
                          Platform.isWindows ||
                          Platform.isLinux))
                  ? 24
                  // ignore: use_build_context_synchronously
                  : MediaQuery.of(context).padding.top + 8,
          bottom: 16,
        ),
      );
    }
  });
}

Future<void> subscribePushNotification(
  Dio apiClient, {
  bool detailedErrors = false,
}) async {
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
        log("Failed to get firebase cloud messaging push token: $err");
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
    "/notifications/subscription",
    data: {"provider": provider, "device_token": token},
  );
}
