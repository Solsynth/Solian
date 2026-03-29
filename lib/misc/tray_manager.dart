import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class TrayService {
  TrayService._();

  static final TrayService _instance = TrayService._();

  static TrayService get instance => _instance;

  bool _checkPlatformAvalability() {
    if (kIsWeb) return false;
    if (Platform.isAndroid || Platform.isIOS) return false;
    return true;
  }

  Future<void> initialize(TrayListener listener) async {
    if (!_checkPlatformAvalability()) return;

    await trayManager.setIcon(
      Platform.isWindows
          ? 'assets/icons/icon.ico'
          : 'assets/icons/icon-tray.png',
      isTemplate: Platform.isMacOS,
    );

    final menu = Menu(
      items: [
        MenuItem(key: 'show_window', label: 'Show Window'),
        MenuItem.separator(),
        MenuItem(key: 'exit_app', label: 'Exit App'),
      ],
    );
    await trayManager.setContextMenu(menu);

    trayManager.addListener(listener);
  }

  Future<void> dispose(TrayListener listener) async {
    if (!_checkPlatformAvalability()) return;

    trayManager.removeListener(listener);
    await trayManager.destroy();
  }

  void handleAction(MenuItem item) {
    switch (item.key) {
      case 'show_window':
        windowManager.show();
        break;
      case 'exit_app':
        windowManager.destroy();
        exit(0);
    }
  }
}
