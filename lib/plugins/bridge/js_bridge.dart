import 'dart:convert';
import 'package:flutter_js/flutter_js.dart';
import 'package:logging/logging.dart';

final _log = Logger('JsBridge');

/// High-level Dart wrapper around flutter_js's JavascriptRuntime.
///
/// Provides safe, ergonomic APIs for executing JavaScript code,
/// creating isolated runtimes, and converting values via JSON.
class JsRuntime {
  final JavascriptRuntime _runtime;
  final String name;

  JsRuntime._(this._runtime, this.name);

  /// Execute JavaScript source code (statements). Returns true on success.
  bool exec(String source, {String filename = '<string>'}) {
    try {
      final result = _runtime.evaluate(source, sourceUrl: filename);
      if (result.isError) {
        _log.warning('JS error in $name: ${result.stringResult}');
        return false;
      }
      return true;
    } catch (e) {
      _log.warning('JS exec exception in $name: $e');
      return false;
    }
  }

  /// Evaluate a JavaScript expression and return the result as a Dart object.
  /// Returns null on failure.
  Object? eval(String expression) {
    try {
      final result = _runtime.evaluate(expression);
      if (result.isError) {
        _log.warning('JS eval error in $name: ${result.stringResult}');
        return null;
      }
      return _parseResult(result.stringResult);
    } catch (e) {
      _log.warning('JS eval exception in $name: $e');
      return null;
    }
  }

  /// Execute JavaScript code and return success/error info.
  JsExecutionResult execWithOutput(String source, {String filename = '<string>'}) {
    try {
      final result = _runtime.evaluate(source, sourceUrl: filename);
      if (result.isError) {
        return JsExecutionResult(success: false, error: result.stringResult);
      }
      return JsExecutionResult(success: true);
    } catch (e) {
      return JsExecutionResult(success: false, error: e.toString());
    }
  }

  /// Call a named JavaScript function with JSON-serializable arguments.
  /// Returns the parsed result, or null on failure.
  Object? callFunction(String funcName, [List<Object?>? args]) {
    try {
      final argsJson = args != null
          ? args.map((a) => jsonEncode(a)).join(',')
          : '';
      final code = '$funcName($argsJson)';
      final result = _runtime.evaluate(code);
      if (result.isError) {
        _log.warning('JS callFunction error in $name ($funcName): ${result.stringResult}');
        return null;
      }
      return _parseResult(result.stringResult);
    } catch (e) {
      _log.warning('JS callFunction exception in $name ($funcName): $e');
      return null;
    }
  }

  /// Call a named JavaScript function that returns a JSON string.
  /// Parses the JSON result into a Dart Map/List.
  Map<String, dynamic>? callFunctionJson(String funcName, [List<Object?>? args]) {
    final result = callFunction(funcName, args);
    if (result is String) {
      try {
        final decoded = jsonDecode(result);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) {
          return decoded.map((k, v) => MapEntry(k.toString(), v));
        }
      } catch (e) {
        _log.warning('Failed to parse JSON from $funcName: $result');
      }
    }
    if (result is Map<String, dynamic>) return result;
    if (result is Map) {
      return result.map((k, v) => MapEntry(k.toString(), v));
    }
    return null;
  }

  /// Register a Dart handler that JavaScript code can call via sendMessage(channel, args).
  ///
  /// In JS: `sendMessage('channelName', JSON.stringify({key: 'value'}))`
  /// In Dart: the [handler] receives the decoded args.
  void onMessage(String channelName, dynamic Function(dynamic args) handler) {
    _runtime.onMessage(channelName, handler);
  }

  /// Set a global JavaScript variable from a Dart value.
  void setGlobal(String name, Object? value) {
    final json = jsonEncode(value);
    _runtime.evaluate('var $name = $json');
  }

  /// Get a global JavaScript variable as a Dart object.
  Object? getGlobal(String name) {
    try {
      final result = _runtime.evaluate(
        'typeof $name !== "undefined" ? JSON.stringify($name) : "undefined"',
      );
      if (result.isError || result.stringResult == 'undefined') return null;
      return _parseResult(result.stringResult);
    } catch (e) {
      return null;
    }
  }

  /// Format the last error as a Dart string. Returns null if no error.
  String? formatException() {
    // flutter_js doesn't have a separate exception state;
    // errors are returned in JsEvalResult.isError/stringResult
    return null;
  }

  /// Dispose this runtime and free resources.
  void dispose() {
    _runtime.dispose();
  }

  /// Parse a JS result string into a Dart object.
  Object? _parseResult(String raw) {
    if (raw == 'undefined' || raw == 'null') return null;
    if (raw == 'true') return true;
    if (raw == 'false') return false;

    // Try number
    final asInt = int.tryParse(raw);
    if (asInt != null) return asInt;
    final asDouble = double.tryParse(raw);
    if (asDouble != null) return asDouble;

    // Try JSON
    if (raw.startsWith('{') || raw.startsWith('[')) {
      try {
        return jsonDecode(raw);
      } catch (_) {
        // Not valid JSON, return as string
      }
    }

    // Remove surrounding quotes if present
    if (raw.startsWith('"') && raw.endsWith('"') && raw.length >= 2) {
      try {
        return jsonDecode(raw);
      } catch (_) {}
    }

    return raw;
  }
}

/// Result of executing JavaScript code.
class JsExecutionResult {
  final bool success;
  final String? error;

  const JsExecutionResult({required this.success, this.error});
}

/// Singleton that manages all JavaScript runtimes for the plugin system.
class JsBridge {
  JsBridge._();
  static final JsBridge instance = JsBridge._();

  final Map<String, JsRuntime> _runtimes = {};

  /// Create a new isolated JavaScript runtime for a plugin.
  JsRuntime createRuntime(String name) {
    if (_runtimes.containsKey(name)) {
      _log.warning('Runtime $name already exists, disposing old one');
      _runtimes[name]!.dispose();
    }

    final runtime = getJavascriptRuntime();
    final jsRuntime = JsRuntime._(runtime, name);
    _runtimes[name] = jsRuntime;
    _log.info('Created JS runtime: $name');
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
