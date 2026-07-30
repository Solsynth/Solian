import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/config.dart';

// Conditional imports based on platform
import 'notify.windows.dart' as windows_notify;
import 'notify.universal.dart' as universal_notify;
import 'push_provider.dart';

// Platform-specific delegation
Future<void> initializeLocalNotifications(WidgetRef ref) async {
  if (kIsWeb) {
    // No local notifications on web
    return;
  }
  if (Platform.isWindows) {
    return windows_notify.initializeLocalNotifications(ref);
  } else {
    return universal_notify.initializeLocalNotifications(ref);
  }
}

StreamSubscription? setupNotificationListener(
  BuildContext context,
  WidgetRef ref,
) {
  if (kIsWeb) {
    // No notification listener on web
    return null;
  }
  if (Platform.isWindows) {
    return windows_notify.setupNotificationListener(context, ref);
  } else {
    return universal_notify.setupNotificationListener(context, ref);
  }
}

/// Show a local notification (fixed id = 0, replacing previous).
/// Main isolate only (plugin initialised by [initializeLocalNotifications]).
Future<void> showLocalNotificationFromFcm({
  required String title,
  String? body,
  String? payload,
}) async {
  if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    return;
  }
  return universal_notify.showLocalNotificationFromFcm(
    title: title,
    body: body,
    payload: payload,
  );
}

/// Background-isolate variant.  Creates a fresh plugin instance per call.
Future<void> showBackgroundNotificationFromFcm({
  required String title,
  String? body,
  String? payload,
}) async {
  if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    return;
  }
  await universal_notify.ensureFcmNotificationPlugin(
    title: title,
    body: body,
    payload: payload,
  );
}

Future<void> showDebugLocalNotification(WidgetRef ref) async {
  if (kIsWeb) {
    return;
  }
  if (Platform.isWindows) {
    return windows_notify.showDebugLocalNotification(ref);
  } else {
    return universal_notify.showDebugLocalNotification(ref);
  }
}

Future<void> subscribePushNotification(
  Dio apiClient, {
  bool detailedErrors = false,
  BuildContext? context,
}) async {
  if (kIsWeb) {
    // No push notification subscription on web
    return;
  }
  final effectiveContext = context;
  if (effectiveContext == null) {
    throw ArgumentError(
      'BuildContext is required to register push notifications.',
    );
  }

  final prefs = ProviderScope.containerOf(
    effectiveContext,
    listen: false,
  ).read(sharedPreferencesProvider);
  await resolvePushProvider(effectiveContext, prefs);

  if (Platform.isWindows) {
    return windows_notify.subscribePushNotification(
      apiClient,
      detailedErrors: detailedErrors,
    );
  } else {
    return universal_notify.subscribePushNotification(
      apiClient,
      detailedErrors: detailedErrors,
    );
  }
}
