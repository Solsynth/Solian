import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/route.dart';

// Shell route keys for nested navigation
final rootNavigatorKey = GlobalKey<NavigatorState>();

bool get _supportsAnalytics =>
    kIsWeb || Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

// Provider for the router
final routerProvider = Provider((ref) {
  return AppRouter();
});
