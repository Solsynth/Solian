import 'package:logging/logging.dart';

final _log = Logger('JsBridge');

/// Web stub for JsRuntime — JavaScript execution is not available on web.
///
/// On web, the browser's native JS engine is available via `dart:js_interop`,
/// but the plugin system uses `flutter_js` (which requires `dart:ffi`).
/// This stub provides a no-op implementation so the app compiles and runs,
/// but plugin JS execution will be a no-op.
class JsRuntime {
  final String name;

  JsRuntime._(this.name);

  /// Execute JavaScript source code — no-op on web.
  bool exec(String source, {String filename = '<string>'}) {
    _log.warning('JS exec not available on web ($name)');
    return false;
  }

  /// Evaluate a JavaScript expression — returns null on web.
  Object? eval(String expression) {
    _log.warning('JS eval not available on web ($name)');
    return null;
  }

  /// Execute JavaScript code and return success/error info.
  JsExecutionResult execWithOutput(String source, {String filename = '<string>'}) {
    _log.warning('JS execWithOutput not available on web ($name)');
    return JsExecutionResult(success: false, error: 'JS runtime not available on web');
  }

  /// Call a named JavaScript function — returns null on web.
  Object? callFunction(String funcName, [List<Object?>? args]) {
    _log.warning('JS callFunction not available on web ($name)');
    return null;
  }

  /// Call a named JavaScript function that returns a JSON string.
  Map<String, dynamic>? callFunctionJson(String funcName, [List<Object?>? args]) {
    _log.warning('JS callFunctionJson not available on web ($name)');
    return null;
  }

  /// Register a Dart handler — no-op on web.
  void onMessage(String channelName, dynamic Function(dynamic args) handler) {
    _log.warning('JS onMessage not available on web ($name)');
  }

  /// Set a global JavaScript variable — no-op on web.
  void setGlobal(String name, Object? value) {
    _log.warning('JS setGlobal not available on web ($name)');
  }

  /// Get a global JavaScript variable — returns null on web.
  Object? getGlobal(String name) {
    return null;
  }

  /// Format the last error — returns null on web.
  String? formatException() {
    return null;
  }

  /// Dispose this runtime — no-op on web.
  void dispose() {
    // Nothing to dispose on web
  }
}

/// Result of executing JavaScript code.
class JsExecutionResult {
  final bool success;
  final String? error;

  const JsExecutionResult({required this.success, this.error});
}

/// Singleton that manages all JavaScript runtimes for the plugin system.
///
/// On web, this is a no-op stub since `flutter_js` requires `dart:ffi`.
class JsBridge {
  JsBridge._();
  static final JsBridge instance = JsBridge._();

  final Map<String, JsRuntime> _runtimes = {};

  /// Create a new isolated JavaScript runtime for a plugin.
  JsRuntime createRuntime(String name) {
    if (_runtimes.containsKey(name)) {
      _log.warning('Runtime $name already exists, disposing old one');
      final old = _runtimes.remove(name);
      try {
        old?.dispose();
      } catch (e) {
        _log.warning('Failed to dispose old runtime $name: $e');
      }
    }

    final jsRuntime = JsRuntime._(name);
    _runtimes[name] = jsRuntime;
    _log.info('Created JS runtime (web stub): $name');
    return jsRuntime;
  }

  /// Get an existing runtime by name.
  JsRuntime? getRuntime(String name) => _runtimes[name];

  /// Dispose a runtime by name.
  void disposeRuntime(String name) {
    final runtime = _runtimes.remove(name);
    if (runtime != null) {
      runtime.dispose();
      _log.info('Disposed JS runtime: $name');
    }
  }

  /// Dispose all runtimes.
  void disposeAll() {
    for (final runtime in _runtimes.values) {
      runtime.dispose();
    }
    _runtimes.clear();
    _log.info('All JS runtimes disposed');
  }
}
