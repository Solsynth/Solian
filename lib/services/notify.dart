import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Conditional imports based on platform
import 'notify.windows.dart' as windows_notify;
import 'notify.universal.dart' as universal_notify;

// Platform-specific delegation
Future<void> initializeLocalNotifications() async {
  if (Platform.isWindows) {
    return windows_notify.initializeLocalNotifications();
  } else {
    return universal_notify.initializeLocalNotifications();
  }
}

StreamSubscription setupNotificationListener(
  BuildContext context,
  WidgetRef ref,
) {
  if (Platform.isWindows) {
    return windows_notify.setupNotificationListener(context, ref);
  } else {
    return universal_notify.setupNotificationListener(context, ref);
  }
}

Future<void> subscribePushNotification(
  Dio apiClient, {
  bool detailedErrors = false,
}) async {
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
