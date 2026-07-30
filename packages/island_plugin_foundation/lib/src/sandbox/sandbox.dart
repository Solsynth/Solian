import 'dart:async';
import 'dart:convert';
import 'package:island_plugin_foundation/src/bridge/js_bridge.dart';
import 'package:logging/logging.dart';

final _log = Logger('Sandbox');

class Sandbox {
  final JsRuntime runtime;
  final String pluginId;
  final List<Map<String, String>> _consoleBuffer = [];
  Timer? _pendingTimer;

  Sandbox._({required this.runtime, required this.pluginId});

  List<Map<String, String>> get consoleOutput => List.unmodifiable(_consoleBuffer);

  static Sandbox create(JsRuntime runtime, String pluginId) {
    final sandbox = Sandbox._(runtime: runtime, pluginId: pluginId);
    sandbox._injectPolyfills();
    return sandbox;
  }

  void _injectPolyfills() {
    runtime.exec('''
var __consoleBuffer = [];
function __consoleLog(level, args) {
  var msg = Array.prototype.slice.call(args).join(" ");
  __consoleBuffer.push({level: level, message: msg});
  try { sendMessage("__sandbox:console", JSON.stringify({level: level, message: msg})); } catch(e) {}
}
var console = {
  log: function() { __consoleLog("log", arguments); },
  warn: function() { __consoleLog("warn", arguments); },
  error: function() { __consoleLog("error", arguments); },
  info: function() { __consoleLog("info", arguments); },
};
''');

    runtime.onMessage('__sandbox:console', (raw) {
      try {
        final data = raw is String ? jsonDecode(raw) : (raw is Map ? raw : {});
        _consoleBuffer.add({
          'level': data['level']?.toString() ?? 'log',
          'message': data['message']?.toString() ?? '',
        });
        _log.fine('[sandbox:$pluginId] console.${data['level']}: ${data['message']}');
      } catch (_) {}
    });
  }

  bool exec(String source, {String filename = '<string>'}) {
    return runtime.exec(source, filename: filename);
  }

  Object? callFunction(String funcName, [List<Object?>? args]) {
    return runtime.callFunction(funcName, args);
  }

  void dispose() {
    _pendingTimer?.cancel();
    _consoleBuffer.clear();
  }
}
