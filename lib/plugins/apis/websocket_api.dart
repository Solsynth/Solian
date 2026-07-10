import 'dart:async';
import 'dart:convert';

import 'package:island/core/websocket.dart';
import 'package:island_plugin_foundation/island_plugin_foundation.dart';
import 'package:logging/logging.dart';

final _log = Logger('PluginWebsocketApi');

class _WsPacketHandler {
  final String pluginId;
  final String? typeFilter;
  final String handlerName;

  const _WsPacketHandler({
    required this.pluginId,
    required this.typeFilter,
    required this.handlerName,
  });
}

/// Host API: subscribe to and send packets on the app [WebSocketService].
///
/// Island-only — depends on the authenticated Solar Network WebSocket.
///
/// Permissions:
/// - [PluginPermission.websocketSubscribe] — receive packets / status
/// - [PluginPermission.websocketSend] — send packets
///
/// JavaScript surface (`ws` namespace):
/// ```js
/// ws.subscribe(handlerName)           // all packets
/// ws.subscribe(type, handlerName)     // filter by packet type
/// ws.unsubscribe(handlerName?)
/// ws.send(type, data?, endpoint?)
/// ws.is_connected()
/// ```
///
/// Incoming packets invoke the handler with
/// `{ type, data, endpoint, error_message }`.
/// Status changes also fire `on_ws_status` if defined:
/// `{ status: "connected"|"connecting"|"disconnected"|... }`.
class PluginWebsocketApi extends PluginApi {
  WebSocketService? _service;
  StreamSubscription<WebSocketPacket>? _packetSub;
  StreamSubscription<WebSocketState>? _statusSub;
  final List<_WsPacketHandler> _handlers = [];

  /// Reserved packet types plugins may not send.
  static const reservedSendTypes = {
    'ping',
    'pong',
    'error',
    'error.dupe',
  };

  @override
  Set<PluginPermission> get requiredPermissions => {
    PluginPermission.websocketSubscribe,
    PluginPermission.websocketSend,
  };

  /// Bind to the live app WebSocket service (call once after connect setup).
  void attach(WebSocketService service) {
    if (identical(_service, service) && _packetSub != null) return;
    detach();
    _service = service;
    _packetSub = service.dataStream.listen(
      _dispatchPacket,
      onError: (Object e) => _log.warning('WebSocket packet stream error: $e'),
    );
    _statusSub = service.statusStream.listen(
      _dispatchStatus,
      onError: (Object e) => _log.warning('WebSocket status stream error: $e'),
    );
    _log.info('Plugin WebSocket API attached');
  }

  void detach() {
    _packetSub?.cancel();
    _statusSub?.cancel();
    _packetSub = null;
    _statusSub = null;
    _service = null;
  }

  bool get isAttached => _service != null;

  @override
  String jsBindingsFor(Set<PluginPermission> granted) {
    final buf = StringBuffer();
    final canSub = granted.contains(PluginPermission.websocketSubscribe);
    final canSend = granted.contains(PluginPermission.websocketSend);
    if (!canSub && !canSend) return '';

    buf.writeln('var ws = {};');
    if (canSub) {
      buf.writeln(r'''
ws.subscribe = function(typeOrHandler, maybeHandler) {
  var type = null;
  var handler = typeOrHandler;
  if (typeof maybeHandler === "string") {
    type = typeOrHandler;
    handler = maybeHandler;
  }
  sendMessage("api:ws:subscribe", JSON.stringify({type: type, handler: handler}));
};
ws.unsubscribe = function(handler) {
  sendMessage("api:ws:unsubscribe", JSON.stringify({handler: handler || null}));
};
ws.is_connected = function() {
  return sendMessage("api:ws:is_connected", "[]");
};
''');
    }
    if (canSend) {
      buf.writeln(r'''
ws.send = function(type, data, endpoint) {
  return sendMessage("api:ws:send", JSON.stringify({
    type: type,
    data: (typeof data === "undefined") ? null : data,
    endpoint: (typeof endpoint === "undefined") ? null : endpoint
  }));
};
''');
    }
    return buf.toString();
  }

  @override
  void register(JsRuntime runtime) {
    final pluginId = PluginManager.activePluginId;
    final permissions = pluginId == null
        ? const <PluginPermission>{}
        : PluginManager().plugins[pluginId]?.manifest.permissions.toSet() ??
              const <PluginPermission>{};

    if (permissions.contains(PluginPermission.websocketSubscribe)) {
      runtime.onMessage('api:ws:subscribe', (args) {
        _handleSubscribe(args);
      });
      runtime.onMessage('api:ws:unsubscribe', (args) {
        _handleUnsubscribe(args);
      });
      runtime.onMessage('api:ws:is_connected', (args) {
        return _isConnected() ? 'true' : 'false';
      });
    }

    if (permissions.contains(PluginPermission.websocketSend)) {
      runtime.onMessage('api:ws:send', (args) {
        return _handleSend(args) ? 'true' : 'false';
      });
    }
  }

  void _handleSubscribe(dynamic args) {
    try {
      final data = args is String ? jsonDecode(args) : args;
      if (data is! Map) return;
      final handler = data['handler']?.toString();
      if (handler == null || handler.isEmpty) return;
      final typeRaw = data['type']?.toString();
      final typeFilter = (typeRaw == null || typeRaw.isEmpty || typeRaw == 'null')
          ? null
          : typeRaw;
      final pluginId = PluginManager.activePluginId ?? 'unknown';

      // Replace existing subscription with same handler name for this plugin.
      _handlers.removeWhere(
        (h) => h.pluginId == pluginId && h.handlerName == handler,
      );
      _handlers.add(
        _WsPacketHandler(
          pluginId: pluginId,
          typeFilter: typeFilter,
          handlerName: handler,
        ),
      );
      _log.info(
        'Plugin $pluginId subscribed to ws${typeFilter != null ? ' type=$typeFilter' : ''} -> $handler',
      );
    } catch (e) {
      _log.warning('Failed to register ws subscribe: $e');
    }
  }

  void _handleUnsubscribe(dynamic args) {
    try {
      final data = args is String ? jsonDecode(args) : args;
      final pluginId = PluginManager.activePluginId ?? 'unknown';
      final handler = data is Map ? data['handler']?.toString() : null;
      if (handler == null || handler.isEmpty || handler == 'null') {
        _handlers.removeWhere((h) => h.pluginId == pluginId);
      } else {
        _handlers.removeWhere(
          (h) => h.pluginId == pluginId && h.handlerName == handler,
        );
      }
    } catch (e) {
      _log.warning('Failed to unsubscribe ws: $e');
    }
  }

  bool _handleSend(dynamic args) {
    try {
      final data = args is String ? jsonDecode(args) : args;
      if (data is! Map) return false;
      final type = data['type']?.toString();
      if (type == null || type.isEmpty) return false;
      if (reservedSendTypes.contains(type)) {
        _log.warning('Plugin blocked from sending reserved packet type: $type');
        return false;
      }

      final service = _service;
      if (service == null) {
        _log.warning('Cannot send ws packet: service not attached');
        return false;
      }

      Map<String, dynamic>? payload;
      final rawData = data['data'];
      if (rawData is Map) {
        payload = rawData.map((k, v) => MapEntry(k.toString(), v));
      }

      final endpoint = data['endpoint']?.toString();
      final packet = WebSocketPacket(
        type: type,
        data: payload,
        endpoint: (endpoint == null || endpoint.isEmpty || endpoint == 'null')
            ? null
            : endpoint,
      );
      final ok = service.sendMessage(jsonEncode(packet.toJson()));
      if (ok) {
        _log.fine('Plugin sent ws packet: $type');
      }
      return ok;
    } catch (e) {
      _log.warning('Failed to send ws packet: $e');
      return false;
    }
  }

  bool _isConnected() {
    // Heuristic: channel present and not closing is internal; use last
    // status via a side-channel if needed. For now, service attached is not
    // enough — check whether send would work by looking at channel.
    final service = _service;
    if (service == null) return false;
    return service.ws != null;
  }

  void _dispatchPacket(WebSocketPacket packet) {
    if (_handlers.isEmpty) return;

    final manager = PluginManager();
    final payload = <String, dynamic>{
      'type': packet.type,
      'data': packet.data,
      'endpoint': packet.endpoint,
      'error_message': packet.errorMessage,
    };

    for (final handler in List.of(_handlers)) {
      if (handler.typeFilter != null && handler.typeFilter != packet.type) {
        continue;
      }
      final instance = manager.plugins[handler.pluginId];
      if (instance == null || instance.state != PluginState.active) continue;
      if (!instance.manifest.permissions.contains(
        PluginPermission.websocketSubscribe,
      )) {
        continue;
      }
      final runtime = instance.runtime;
      if (runtime == null) continue;

      try {
        runtime.callFunction(handler.handlerName, [payload]);
      } catch (e) {
        _log.warning(
          'ws handler ${handler.handlerName} failed for ${handler.pluginId}: $e',
        );
      }
    }
  }

  void _dispatchStatus(WebSocketState status) {
    late final String statusName;
    String? errorMessage;
    status.when(
      connected: () => statusName = 'connected',
      connecting: () => statusName = 'connecting',
      disconnected: () => statusName = 'disconnected',
      internetChanged: () => statusName = 'internet_changed',
      serverDown: () => statusName = 'server_down',
      duplicateDevice: () => statusName = 'duplicate_device',
      error: (message) {
        statusName = 'error';
        errorMessage = message;
      },
    );

    final manager = PluginManager();
    final payload = <String, dynamic>{
      'status': statusName,
      'message': ?errorMessage,
    };

    for (final instance in manager.plugins.values) {
      if (instance.state != PluginState.active) continue;
      if (!instance.manifest.permissions.contains(
        PluginPermission.websocketSubscribe,
      )) {
        continue;
      }
      final runtime = instance.runtime;
      if (runtime == null) continue;
      try {
        runtime.callFunction('on_ws_status', [payload]);
      } catch (_) {
        // Optional callback — ignore missing/errors
      }
    }
  }

  @override
  void onPluginUnload(String pluginId) {
    _handlers.removeWhere((h) => h.pluginId == pluginId);
  }

  @override
  void reset() {
    _handlers.clear();
    detach();
  }
}
