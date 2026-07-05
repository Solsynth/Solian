import 'package:flutter/material.dart';

class IslandUIFoundation {
  IslandUIFoundation._();

  static GlobalKey<OverlayState>? _overlayKey;
  static GlobalKey<NavigatorState>? _navigatorKey;

  static GlobalKey<OverlayState>? get overlayKey => _overlayKey;
  static GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;

  static void configureOverlay(GlobalKey<OverlayState> key) {
    _overlayKey = key;
  }

  static void configureNavigator(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  static bool Function()? _hapticEnabledCallback;

  static bool get hapticEnabled => _hapticEnabledCallback?.call() ?? false;

  static void configureHaptic(bool Function() callback) {
    _hapticEnabledCallback = callback;
  }
}
