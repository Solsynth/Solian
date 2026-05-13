import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:island/core/audio.dart';
import 'package:island/core/config.dart';
import 'package:island/core/notification.dart';
import 'package:island/core/services/push_provider.dart';
import 'package:island/core/services/unifiedpush_service.dart';
import 'package:island/route.dart';
import 'package:island/core/websocket.dart';
import 'package:logging/logging.dart';

import 'package:url_launcher/url_launcher_string.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;

void _onAppLifecycleChanged(AppLifecycleState state) {
  _appLifecycleState = state;
}

Future<void> _speakNotification(
  SnNotification notification,
  WidgetRef ref,
  String languageCode,
) async {
  final settings = ref.read(appSettingsProvider);
  if (!settings.enableTts) return;

  final tts = FlutterTts();
  await tts.setVolume(settings.ttsVolume);
  await tts.setSpeechRate(settings.ttsSpeechRate);
  await tts.setPitch(settings.ttsPitch);
  final lang = settings.ttsLanguage.isNotEmpty
      ? settings.ttsLanguage
      : languageCode;
  await tts.setLanguage(lang);
  if (settings.ttsVoice != null && settings.ttsVoice!.isNotEmpty) {
    await tts.setVoice({'name': settings.ttsVoice!, 'locale': lang});
  }
  if (!kIsWeb) {
    await tts.setIosAudioCategory(IosTextToSpeechAudioCategory.ambient, [
      IosTextToSpeechAudioCategoryOptions.allowBluetooth,
      IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
      IosTextToSpeechAudioCategoryOptions.mixWithOthers,
    ], IosTextToSpeechAudioMode.voicePrompt);
  }
  final parts = <String>[];
  if (notification.title.isNotEmpty) parts.add(notification.title);
  if (notification.subtitle.isNotEmpty) parts.add(notification.subtitle);
  if (notification.content.isNotEmpty) parts.add(notification.content);

  if (parts.isNotEmpty) {
    await tts.speak(parts.join('. '));
  }
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

  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      final payload = response.payload;
      if (payload != null) {
        if (payload.startsWith('/')) {
          // In-app routes
          ref.read(routerProvider).pushPath(payload);
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

          // Use flutter_local_notifications for universal platforms
          const AndroidNotificationDetails androidNotificationDetails =
              AndroidNotificationDetails(
                'island_notifications',
                'Notifications',
                channelDescription: 'Receive notifications from Island',
                importance: Importance.max,
                priority: Priority.high,
                ticker: 'Island notification',
                icon: 'launcher_icon',
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
          Logger.root.info(
            '[Notification] Skipping system notification for unsupported platform: ${notification.title}',
          );
        }
        // Speak notification via TTS regardless of platform
        if (!context.mounted) return;
        final locale = Localizations.localeOf(context);
        final languageCode = localeToLanguageCode(locale);
        await _speakNotification(notification, ref, languageCode);
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
    Logger.root.severe('Failed to register UnifiedPush subscription: $err');
  }
}

Future<void> _putTokenToRemote(Dio apiClient, String token, int type) async {
  await apiClient.put(
    "/ring/notifications/subscription",
    data: {"type": type, "device_token": token},
  );
}
