import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:window_manager/window_manager.dart';

/// Persists the live desktop window geometry through [AppSettingsNotifier]
/// (which writes `kAppWindowPosition`, `kAppWindowSize` and
/// `kAppWindowMaximized` into shared preferences), so the next launch
/// restores the same window layout.
///
/// Reads the live window state rather than the notifier's cached copy, so a
/// caller can flush the freshest geometry right before the process exits
/// without waiting for a resize event to have propagated.
Future<void> saveWindowStateNow(WidgetRef ref) async {
  final bounds = await windowManager.getBounds();
  final maximized = await windowManager.isMaximized();
  final notifier = ref.read(appSettingsProvider.notifier);
  if (maximized) {
    notifier.setWindowMaximized(true);
  } else {
    notifier.setWindowBounds(bounds);
  }
}

/// Listens for native window geometry events during the session and persists
/// the window state as it changes, so the last layout survives app restarts
/// and force-kills. Works around lifecycle-only saves that run too late on
/// desktop: the plugins emit `resized`/`moved` while the interaction is
/// happening (Windows `WM_EXITSIZEMOVE`, macOS `windowDidEndLiveResize`,
/// Linux GTK `configure-event`), which does not rely on a teardown signal.
///
/// Resize and move bursts during a live drag are debounced so the state is
/// written once the drag settles. Maximized is tracked as a flag because
/// maximizing changes the frame without a size event here, and the frame size
/// reported while maximized is not meaningful to persist.
class WindowStateListener with WindowListener {
  WindowStateListener(this._ref);

  final WidgetRef _ref;

  Timer? _saveTimer;

  /// Starts listening and records the current geometry as a baseline.
  Future<void> start() async {
    windowManager.addListener(this);
    await saveWindowStateNow(_ref);
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 200), () {
      _saveTimer = null;
      unawaited(saveWindowStateNow(_ref).catchError((_) {}));
    });
  }

  @override
  void onWindowResized() => _scheduleSave();

  @override
  void onWindowMoved() => _scheduleSave();

  @override
  void onWindowMaximize() => _scheduleSave();

  @override
  void onWindowUnmaximize() => _scheduleSave();

  @override
  void onWindowClose() {
    // A final best-effort flush when the window is closed through the native
    // path. The tray "Exit App" action bypasses this (it posts WM_QUIT
    // directly); that path is covered by the close hook's explicit flush.
    _saveTimer?.cancel();
    unawaited(saveWindowStateNow(_ref).catchError((_) {}));
  }
}

/// Installs a fire-and-forget listener that flushes the window geometry when
/// the app is about to terminate through the native close path. The retained
/// [WidgetRef] lives for the whole app process (the plugin keeps the listener
/// alive anyway), so no removal is needed in normal operation.
class WindowStateCloseHook {
  WindowStateCloseHook(this._ref);

  final WidgetRef _ref;

  static _NativeWindowCloseListener? _listener;

  void install() {
    if (_listener == null) {
      _listener = _NativeWindowCloseListener(() => saveWindowStateNow(_ref));
      windowManager.addListener(_listener!);
    }
  }

  /// Removes the hook; used by tests to reset module state between cases.
  static void remove() {
    if (_listener != null) {
      windowManager.removeListener(_listener!);
      _listener = null;
    }
  }
}

class _NativeWindowCloseListener with WindowListener {
  _NativeWindowCloseListener(this._onClose);

  final Future<void> Function() _onClose;

  @override
  void onWindowClose() {
    unawaited(_onClose().catchError((_) {}));
  }
}
