/// Web-safe stand-in for the tray API.
///
/// `package:tray_manager` is desktop-only: its legacy API is built on
/// `package:nativeapi`, which imports `dart:ffi` and cannot be compiled for
/// the web at all. This facade mirrors the surface the app uses
/// ([TrayService], [TrayListener], [MenuItem], [trayManager]) as no-ops so
/// web builds compile; tray behavior is desktop-only anyway.
library;

/// No-op mirror of `tray_manager`'s [MenuItem]. Only used as a type on web.
class MenuItem {}

/// No-op mirror of `tray_manager`'s [TrayListener] interface.
abstract mixin class TrayListener {
  void onTrayIconMouseDown() {}

  void onTrayIconMouseUp() {}

  void onTrayIconRightMouseDown() {}

  void onTrayIconRightMouseUp() {}

  void onTrayMenuItemClick(MenuItem menuItem) {}
}

/// No-op stand-in for the `trayManager` global.
final trayManager = _StubTrayManager();

class _StubTrayManager {
  Future<void> popUpContextMenu() async {}
}

/// Desktop-only tray integration. On web every method is a no-op; the real
/// `tray_manager` package cannot be imported (it requires `dart:ffi`).
class TrayService {
  TrayService._();

  static final TrayService _instance = TrayService._();

  static TrayService get instance => _instance;

  Future<void> initialize(TrayListener listener) async {}

  Future<void> dispose(TrayListener listener) async {}

  void handleAction(MenuItem item) {}
}
