import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:island/core/config.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PushNotificationProvider {
  apple,
  fcm,
  unifiedpush;

  int get remoteType => switch (this) {
    PushNotificationProvider.apple => 0,
    PushNotificationProvider.fcm => 1,
    // 2 is for Solar Network Push
    PushNotificationProvider.unifiedpush => 3,
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

bool supportsUnifiedPushOnCurrentPlatform() {
  if (kIsWeb) return false;
  return Platform.isAndroid || Platform.isLinux;
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

  final options = <PushNotificationProvider>[
    if (Platform.isAndroid) PushNotificationProvider.fcm,
    if (supportsUnifiedPushOnCurrentPlatform())
      PushNotificationProvider.unifiedpush,
  ];

  if (options.length == 1) {
    await prefs.setString(
      _pushProviderStorageKey(),
      options.first.storageValue,
    );
    return options.first;
  }

  final choice = await showOverlayDialog<PushNotificationProvider>(
    barrierDismissible: false,
    builder: (context, close) => ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: kDialogMaxWidth),
      child: AlertDialog(
        title: const Icon(Symbols.notifications_active, size: 40),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Push Notifications',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Gap(8),
            Text(
              Platform.isAndroid
                  ? 'Choose how this device should receive push notifications. You can change this later by clearing app data.'
                  : 'This platform can use UnifiedPush for remote notifications.',
            ),
          ],
        ),
        actions: [
          if (Platform.isAndroid)
            TextButton(
              onPressed: () => close(PushNotificationProvider.fcm),
              child: const Text('Use FCM'),
            ),
          TextButton(
            onPressed: () => close(PushNotificationProvider.unifiedpush),
            child: const Text('Use UnifiedPush'),
          ),
        ],
      ),
    ),
  );

  final provider = choice ?? options.first;
  await prefs.setString(_pushProviderStorageKey(), provider.storageValue);
  return provider;
}
