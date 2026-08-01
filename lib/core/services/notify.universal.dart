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
import 'package:island/core/services/deeplink_service.dart';
import 'package:island/chat/pods/native_call_bridge.dart';
import 'package:island/route.dart';
import 'package:island/core/websocket.dart';
import 'package:logging/logging.dart';

import 'package:url_launcher/url_launcher_string.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

import 'udid.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const _iosCommunicationNotificationChannel = MethodChannel(
  'dev.solsynth.solian/local_communication_notification',
);

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

/// Detects the file type of [file] from its magic bytes and returns an
/// extension that iOS/macOS accept for notification attachments
/// (jpg/png/gif images, mp3/wav/m4a audio, mp4 video). Returns null when
/// the type cannot be determined or is not supported.
String? _detectDarwinAttachmentExtension(File file) {
  final raf = file.openSync();
  try {
    final bytes = raf.readSync(12);
    if (bytes.length < 4) return null;

    // JPEG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'jpg';
    }
    // PNG: 89 50 4E 47
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'png';
    }
    // GIF: GIF8
    if (bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x38) {
      return 'gif';
    }
    // MP3 with ID3 tag
    if (bytes[0] == 0x49 && bytes[1] == 0x44 && bytes[2] == 0x33) {
      return 'mp3';
    }
    // MP3 without ID3 tag: MPEG audio frame sync (FF Ex)
    if (bytes[0] == 0xFF && (bytes[1] & 0xE0) == 0xE0) {
      return 'mp3';
    }

    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46) {
      // RIFF container: WEBP image or WAVE audio
      final formType = String.fromCharCodes(bytes.sublist(8, 12));
      if (formType == 'WAVE') return 'wav';
      return null; // WEBP is not a supported attachment type
    }

    if (bytes.length >= 12 &&
        bytes[4] == 0x66 &&
        bytes[5] == 0x74 &&
        bytes[6] == 0x79 &&
        bytes[7] == 0x70) {
      // ISO BMFF box: MP4 / M4A (HEIC/AVIF images are not supported)
      final brand = String.fromCharCodes(bytes.sublist(8, 12));
      switch (brand) {
        case 'M4A ':
        case 'M4B ':
          return 'm4a';
        case 'mp42':
        case 'isom':
        case 'mp41':
        case 'avc1':
        case 'dash':
          return 'mp4';
        default:
          return null;
      }
    }
    return null;
  } finally {
    raf.closeSync();
  }
}

/// Returns a path for [file] that iOS/macOS recognise as a notification
/// attachment, copying it to a temp location with a proper extension when
/// needed. flutter_cache_manager stores cached files as `<uuid>.file`, which
/// UNNotificationAttachment rejects with "Unrecognized attachment file type".
/// Returns null when the file type is unknown or unsupported.
Future<String?> _pathForDarwinAttachment(File file) async {
  final extension = _detectDarwinAttachmentExtension(file);
  if (extension == null) {
    Logger.root.warning(
      '[Notification] Skipping attachment with unrecognised type: ${file.path}',
    );
    return null;
  }
  if (file.path.toLowerCase().endsWith('.$extension')) return file.path;

  final segments = file.uri.pathSegments;
  var stem = 'attachment';
  if (segments.isNotEmpty) {
    final name = segments.last;
    final dot = name.lastIndexOf('.');
    stem = dot > 0 ? name.substring(0, dot) : name;
  }
  final target = File('${Directory.systemTemp.path}/$stem.$extension');
  await file.copy(target.path);
  return target.path;
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
      final path = await _pathForDarwinAttachment(file);
      if (path == null) return null;
      return DarwinNotificationAttachment(path, identifier: imageId);
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

Future<bool> _showIosCommunicationNotification({
  required SnNotification notification,
  required String threadId,
  required List<DarwinNotificationAttachment> attachments,
  String? senderImagePath,
}) async {
  try {
    return await _iosCommunicationNotificationChannel
            .invokeMethod<bool>('show', {
              'id': notification.id,
              'title': notification.title,
              'body': notification.body,
              'topic': notification.topic,
              'threadId': threadId,
              'payload': notification.meta['action_uri'],
              'meta': notification.meta,
              'attachmentPaths': attachments
                  .map((item) => item.filePath)
                  .toList(),
              'senderImagePath': senderImagePath,
            }) ??
        false;
  } on PlatformException catch (error) {
    Logger.root.warning(
      '[Notification] Failed to show iOS communication notification: $error',
    );
    return false;
  } on MissingPluginException catch (error) {
    Logger.root.warning(
      '[Notification] iOS communication notification bridge is unavailable: $error',
    );
    return false;
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

  // Hold the router
  final router = ref.read(routerProvider);

  void handleNotificationPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    final routePath = actionUriToRoutePath(payload);
    if (routePath != null) {
      // In-app routes — `solian://…`, `https://solian.app/…` or bare `/…`
      router.navigatePath(
        routePath,
        onFailure: (err) {
          Logger.root.warning('[Notification] Unable to open page: $err');
        },
      );
    } else {
      // External URLs
      launchUrlString(payload);
    }
  }

  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      handleNotificationPayload(response.payload);
    },
  );

  // Cold start: when the app was terminated and is launched by tapping a
  // notification, `onDidReceiveNotificationResponse` never fires — read the
  // launch payload explicitly instead.
  final launchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (launchDetails?.didNotificationLaunchApp ?? false) {
    final payload = launchDetails?.notificationResponse?.payload;
    if (payload != null && payload.isNotEmpty) {
      // The router may still be building its initial stack during bootstrap;
      // wait for the navigator to attach before navigating so the route isn't
      // clobbered by the initial route.
      for (var attempt = 0; attempt < 20; attempt++) {
        final navigatorContext = router.navigatorKey.currentContext;
        if (navigatorContext != null && navigatorContext.mounted) {
          handleNotificationPayload(payload);
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }
    }
  }

  // Proactively create the notification channel on Android 8.0+
  await createNotificationChannel();

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

Future<void> createNotificationChannel() async {
  final android = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  if (android == null) return;
  await android.createNotificationChannel(
    const AndroidNotificationChannel(
      'solar_network_notifications',
      'Notifications',
      description: 'Receive notifications from the Solar Network',
      importance: Importance.max,
      playSound: true,
    ),
  );
}

const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'solar_network_notifications',
      'Notifications',
      channelDescription: 'Receive notifications from the Solar Network',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Solar Network Notification',
      icon: 'ic_notification',
      groupKey: 'solar_network_notifications',
      groupAlertBehavior: GroupAlertBehavior.all,
    );

/// Shows a local notification with a fixed id (0), replacing any previous.
/// Safe to call from a background isolate (FCM background handler).
Future<void> ensureFcmNotificationPlugin({
  required String title,
  String? body,
  String? payload,
}) async {
  final plugin = FlutterLocalNotificationsPlugin();
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  await plugin.initialize(
    settings: const InitializationSettings(android: androidSettings),
  );
  await plugin.show(
    id: DateTime.now().millisecondsSinceEpoch,
    title: title,
    body: body,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        'solar_network_notifications',
        'Notifications',
        channelDescription: 'Receive notifications from the Solar Network',
        importance: Importance.max,
        priority: Priority.high,
        icon: 'ic_notification',
        groupKey: 'solar_network_notifications',
        groupAlertBehavior: GroupAlertBehavior.all,
      ),
    ),
    payload: payload,
  );
}

/// Shows a local notification (fixed id = 0). Plugin must already be
/// initialised (main isolate).
Future<void> showLocalNotificationFromFcm({
  required String title,
  String? body,
  String? payload,
}) async {
  if (kIsWeb) return;
  await flutterLocalNotificationsPlugin.show(
    id: DateTime.now().millisecondsSinceEpoch,
    title: title,
    body: body,
    notificationDetails: const NotificationDetails(
      android: androidNotificationDetails,
    ),
    payload: payload,
  );
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
        // When the app is not focused, mirror WebSocket notifications to the
        // system notification center. This includes iOS while its WebSocket is
        // still connected; foreground notifications remain in-app above.
        if (!kIsWeb) {
          Logger.root.info(
            '[Notification] Showing system notification: ${notification.title}',
          );

          final serverUrl = ref.read(serverUrlProvider);
          final threadId = _buildThreadIdentifier(notification);
          final attachments = await _downloadDarwinAttachments(
            serverUrl,
            notification,
          );

          String? senderImagePath;
          if (Platform.isIOS &&
              notification.topic.startsWith('messages.') &&
              notification.meta['pfp'] is String) {
            try {
              final file = await DefaultCacheManager().getSingleFile(
                '$serverUrl/drive/files/${notification.meta['pfp']}',
              );
              senderImagePath = await _pathForDarwinAttachment(file);
            } catch (error) {
              Logger.root.warning(
                '[Notification] Failed to download communication sender image: $error',
              );
            }
          }

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
          final shownAsCommunicationNotification =
              Platform.isIOS && notification.topic.startsWith('messages.')
              ? await _showIosCommunicationNotification(
                  notification: notification,
                  threadId: threadId,
                  attachments: attachments,
                  senderImagePath: senderImagePath,
                )
              : false;
          if (!shownAsCommunicationNotification) {
            await flutterLocalNotificationsPlugin.show(
              id: notification.id.hashCode,
              title: notification.title,
              body: notification.body,
              notificationDetails: notificationDetails,
              payload: notification.meta['action_uri'] as String?,
            );
          }
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
  if (kIsWeb) return;

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
