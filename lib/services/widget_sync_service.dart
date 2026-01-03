import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class WidgetSyncService {
  static const _channel = MethodChannel('dev.solsynth.solian/widget');
  static final _instance = WidgetSyncService._internal();

  factory WidgetSyncService() => _instance;

  WidgetSyncService._internal();

  bool get _isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> syncToWidget() async {
    if (!_isSupported) return;

    try {
      await _channel.invokeMethod('syncToWidget');
    } catch (e) {
      debugPrint('Failed to sync to widget: $e');
    }
  }
}
