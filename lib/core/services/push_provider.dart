import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:island/core/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PushNotificationProvider {
  fcm,
  apple,
  appk;

  int get remoteType => switch (this) {
    PushNotificationProvider.fcm => 0,
    PushNotificationProvider.apple => 1,
    PushNotificationProvider.appk => 4,
  };

  String get storageValue => name;

  static PushNotificationProvider? fromStorage(String? value) {
    for (final provider in PushNotificationProvider.values) {
      if (provider.storageValue == value) return provider;
    }
    return null;
  }
}

String _pushProviderStorageKey() {
  if (kIsWeb) return kAppPushProvider;
  if (Platform.isAndroid) return '${kAppPushProvider}_android';
  if (Platform.isLinux) return '${kAppPushProvider}_linux';
  if (Platform.isWindows) return '${kAppPushProvider}_windows';
  if (Platform.isIOS) return '${kAppPushProvider}_ios';
  if (Platform.isMacOS) return '${kAppPushProvider}_macos';
  return kAppPushProvider;
}

Future<PushNotificationProvider> resolvePushProvider(
  BuildContext context,
  SharedPreferences prefs,
) async {
  if (kIsWeb) return PushNotificationProvider.fcm;
  if (Platform.isIOS || Platform.isMacOS) {
    return PushNotificationProvider.apple;
  }
  if (Platform.isWindows) {
    return PushNotificationProvider.fcm;
  }

  final stored = PushNotificationProvider.fromStorage(
    prefs.getString(_pushProviderStorageKey()),
  );
  if (stored != null) return stored;

  await prefs.setString(
    _pushProviderStorageKey(),
    PushNotificationProvider.fcm.storageValue,
  );
  return PushNotificationProvider.fcm;
}
