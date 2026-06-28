import 'package:flutter/material.dart';

class IslandUIFoundation {
  IslandUIFoundation._();

  static GlobalKey<OverlayState>? _overlayKey;

  static GlobalKey<OverlayState>? get overlayKey => _overlayKey;

  static void configureOverlay(GlobalKey<OverlayState> key) {
    _overlayKey = key;
  }

  static bool Function()? _hapticEnabledCallback;

  static bool get hapticEnabled => _hapticEnabledCallback?.call() ?? false;

  static void configureHaptic(bool Function() callback) {
    _hapticEnabledCallback = callback;
  }
}
