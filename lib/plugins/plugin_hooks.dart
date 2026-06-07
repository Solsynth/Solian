import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:island/plugins/apis/hooks_api.dart';
import 'package:island/plugins/plugin_manager.dart';

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

  /// Run the `before_post_create` hook chain.
  /// Returns the modified payload, or cancelled if a handler returns null.
  HookResult<Map<String, dynamic>> runBeforePostCreate(
    Map<String, dynamic> payload,
  ) {
    return _runHook('before_post_create', payload);
  }

  /// Run the `before_message_send` hook chain.
  /// Returns the modified content string, or cancelled if a handler returns null.
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
  /// If any handler returns null, the chain is cancelled.
  HookResult<Map<String, dynamic>> _runHook(
    String hookName,
    Map<String, dynamic> data,
  ) {
    final manager = PluginManager();
    final hooksApi = manager.getApi<HooksApi>();
    if (hooksApi == null) {
      _log.info('Hook $hookName: no HooksApi registered');
      return HookResult.proceed(data);
    }

    final handlers = hooksApi.handlers
        .where((h) => h.hookName == hookName)
        .toList();

    _log.info('Hook $hookName: found ${handlers.length} handlers');

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
      // Find the plugin's runtime
      final manager = PluginManager();
      final instance = manager.plugins[handler.pluginId];
      final runtime = instance?.runtime;

      if (runtime == null) {
        _log.warning(
          'Hook handler ${handler.handlerName}: no runtime for plugin ${handler.pluginId}',
        );
        return data; // Skip, don't cancel
      }

      // Call the handler function in JS, passing data as JSON.
      // Wrap in JSON.stringify so JS objects come back as parseable JSON
      // instead of "[object Object]".
      final dataJson = jsonEncode(data);
      final resultRaw = runtime.eval(
        'JSON.stringify(${handler.handlerName}($dataJson))',
      );
      Object? result;
      if (resultRaw is String && resultRaw != 'undefined') {
        try {
          result = jsonDecode(resultRaw);
        } catch (_) {
          result = resultRaw;
        }
      } else {
        result = resultRaw;
      }

      if (result == null) {
        _log.warning(
          'Hook handler ${handler.handlerName} returned null '
          '(plugin: ${handler.pluginId})',
        );
        return null; // Cancel
      }

      // Convert result back to Dart Map
      if (result is Map<String, dynamic>) {
        return result;
      }
      if (result is Map) {
        return result.map((k, v) => MapEntry(k.toString(), v));
      }
      if (result is String) {
        try {
          final decoded = jsonDecode(result);
          if (decoded is Map<String, dynamic>) return decoded;
          if (decoded is Map) {
            return decoded.map((k, v) => MapEntry(k.toString(), v));
          }
        } catch (_) {}
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
