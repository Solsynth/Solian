import 'dart:ffi';
import 'package:pocketpy/pocketpy.dart';
import 'package:pocketpy/pocketpy_bindings_generated.dart';
import 'package:logging/logging.dart';
import 'package:island/plugin/bridge/py_bridge.dart';
import 'package:island/plugin/apis/hooks_api.dart';
import 'package:island/plugin/plugin_manager.dart';

final _log = Logger('PluginHooks');

/// Result of running a plugin hook chain.
class HookResult<T> {
  final bool cancelled;
  final T? data;
  final String? cancelledBy;

  const HookResult._({required this.cancelled, this.data, this.cancelledBy});

  factory HookResult.proceed(T data) =>
      HookResult._(cancelled: false, data: data);

  factory HookResult.cancel(String pluginId) =>
      HookResult._(cancelled: true, cancelledBy: pluginId);
}

/// Runs plugin hook chains, passing data through each handler sequentially.
///
/// Usage from app code:
/// ```dart
/// final result = PluginHooks.instance.runBeforePostCreate(payload);
/// if (result.cancelled) {
///   showError('Post blocked by plugin: ${result.cancelledBy}');
///   return;
/// }
/// final modifiedPayload = result.data!;
/// // continue with modifiedPayload...
/// ```
class PluginHooks {
  static final PluginHooks _instance = PluginHooks._();
  factory PluginHooks() => _instance;
  PluginHooks._();

  final PyBridge _py = PyBridge.instance;

  /// Run the `before_post_create` hook chain.
  /// Returns the modified payload, or cancelled if a handler returns None.
  HookResult<Map<String, dynamic>> runBeforePostCreate(
    Map<String, dynamic> payload,
  ) {
    return _runHook('before_post_create', payload);
  }

  /// Run the `before_message_send` hook chain.
  /// Returns the modified content string, or cancelled if a handler returns None.
  HookResult<String> runBeforeMessageSend(String content) {
    final result = _runHook('before_message_send', {'content': content});
    if (result.cancelled) {
      return HookResult.cancel(result.cancelledBy!);
    }
    final map = result.data!;
    return HookResult.proceed(map['content']?.toString() ?? content);
  }

  /// Run the `before_post_display` hook chain.
  HookResult<Map<String, dynamic>> runBeforePostDisplay(
    Map<String, dynamic> postData,
  ) {
    return _runHook('before_post_display', postData);
  }

  /// Run the `before_message_display` hook chain.
  HookResult<Map<String, dynamic>> runBeforeMessageDisplay(
    Map<String, dynamic> messageData,
  ) {
    return _runHook('before_message_display', messageData);
  }

  /// Run a named hook chain with a Map payload.
  /// Each handler receives the data, can modify it, and returns the result.
  /// If any handler returns None, the chain is cancelled.
  HookResult<Map<String, dynamic>> _runHook(
    String hookName,
    Map<String, dynamic> data,
  ) {
    final manager = PluginManager();
    final hooksApi = manager.getApi<HooksApi>();
    if (hooksApi == null) {
      return HookResult.proceed(data);
    }

    final handlers = hooksApi.handlers
        .where((h) => h.hookName == hookName)
        .toList();

    if (handlers.isEmpty) {
      return HookResult.proceed(data);
    }

    Map<String, dynamic> current = Map<String, dynamic>.from(data);

    for (final handler in handlers) {
      final result = _callHandler(handler, current);
      if (result == null) {
        _log.info(
          'Hook $hookName cancelled by plugin ${handler.pluginId} '
          '(handler: ${handler.handlerName})',
        );
        return HookResult.cancel(handler.pluginId);
      }
      current = result;
    }

    return HookResult.proceed(current);
  }

  /// Call a single hook handler with data. Returns modified data or null to cancel.
  Map<String, dynamic>? _callHandler(
    PluginHookHandler handler,
    Map<String, dynamic> data,
  ) {
    try {
      // Find the handler function in the plugin's module, not __main__
      Pointer<py_TValue>? funcRef;

      if (handler.module != null) {
        final nameId = _py.name(handler.handlerName);
        final itemRef = pocket.py_getdict(handler.module!, nameId);
        if (itemRef != nullptr) {
          funcRef = itemRef;
        }
      }

      // Fallback: try global scope
      funcRef ??= _py.getGlobal(handler.handlerName);

      if (funcRef == null) {
        _log.warning(
          'Hook handler ${handler.handlerName} not found '
          '(plugin: ${handler.pluginId})',
        );
        return data; // Skip, don't cancel
      }

      // Check if it's callable
      final type = pocket.py_typeof(funcRef);
      if (type != py_PredefinedType.tp_function &&
          type != py_PredefinedType.tp_nativefunc) {
        _log.warning(
          'Hook handler ${handler.handlerName} is not callable '
          '(plugin: ${handler.pluginId})',
        );
        return data;
      }

      // Convert data to Python dict and put in register _0
      final dataOut = _py.reg(0);
      _py.fromDart(dataOut, data);

      // Call the handler with 1 argument
      final ok = pocket.py_call(funcRef, 1, dataOut);
      if (!ok) {
        _log.warning(
          'Hook handler ${handler.handlerName} raised an exception: '
          '${_py.formatException() ?? "unknown"}',
        );
        return data; // Skip on error, don't cancel
      }

      // Get return value
      final retval = pocket.py_retval();
      final returnType = pocket.py_typeof(retval);

      // None means cancel
      if (returnType == py_PredefinedType.tp_NoneType) {
        return null;
      }

      // Convert result back to Dart Map
      final result = _py.toDart(retval);
      if (result is Map<String, dynamic>) {
        return result;
      }
      if (result is Map) {
        return result.map((k, v) => MapEntry(k.toString(), v));
      }

      _log.warning(
        'Hook handler ${handler.handlerName} returned unexpected type: '
        '${result.runtimeType}',
      );
      return data; // Skip, don't cancel
    } catch (e) {
      _log.severe(
        'Hook handler ${handler.handlerName} threw: $e '
        '(plugin: ${handler.pluginId})',
      );
      return data; // Skip on error
    }
  }
}
