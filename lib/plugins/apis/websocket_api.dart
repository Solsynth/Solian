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

class PluginWebsocketApi extends PluginApi {
  WebSocketService? _service;
  StreamSubscription<WebSocketPacket>? _packetSub;
  StreamSubscription<WebSocketState>? _statusSub;
  final List<_WsPacketHandler> _handlers = [];

  static const reservedSendTypes = {
    'ping', 'pong', 'error', 'error.dupe',
  };

  @override
  Set<PluginPermission> get requiredPermissions => {
    PluginPermission.websocketSubscribe,
    PluginPermission.websocketSend,
  };

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
  void register(PluginContext context, JsRuntime runtime) {
    final canSub = context.hasPermission(PluginPermission.websocketSubscribe);
    final canSend = context.hasPermission(PluginPermission.websocketSend);
    if (!canSub && !canSend) return;

    var js = 'var ws = {};\n';
    if (canSub) {
      js += r'''
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
''';
    }
    if (canSend) {
      js += r'''
ws.send = function(type, data, endpoint) {
  return sendMessage("api:ws:send", JSON.stringify({
    type: type,
    data: (typeof data === "undefined") ? null : data,
    endpoint: (typeof endpoint === "undefined") ? null : endpoint
  }));
};
''';
    }
    runtime.exec(js);

    if (canSub) {
      runtime.onMessage('api:ws:subscribe', (raw) {
        _handleSubscribe(context, raw);
      });
      runtime.onMessage('api:ws:unsubscribe', (raw) {
        _handleUnsubscribe(context, raw);
      });
      runtime.onMessage('api:ws:is_connected', (raw) {
        return _isConnected() ? 'true' : 'false';
      });
    }
    if (canSend) {
      runtime.onMessage('api:ws:send', (raw) {
        return _handleSend(context, raw) ? 'true' : 'false';
      });
    }
  }

  void _handleSubscribe(PluginContext context, dynamic raw) {
    try {
      final data = context.decode(raw);
      final handler = data['handler']?.toString();
      if (handler == null || handler.isEmpty) return;
      final typeRaw = data['type']?.toString();
      final typeFilter = (typeRaw == null || typeRaw.isEmpty || typeRaw == 'null')
          ? null
          : typeRaw;
      _handlers.removeWhere(
        (h) => h.pluginId == context.pluginId && h.handlerName == handler,
      );
      _handlers.add(_WsPacketHandler(
        pluginId: context.pluginId,
        typeFilter: typeFilter,
        handlerName: handler,
      ));
      _log.info('Plugin ${context.pluginId} subscribed to ws${typeFilter != null ? ' type=$typeFilter' : ''} -> $handler');
    } catch (e) {
      _log.warning('Failed to register ws subscribe: $e');
    }
  }

  void _handleUnsubscribe(PluginContext context, dynamic raw) {
    try {
      final data = context.decode(raw);
      final handler = data['handler']?.toString();
      if (handler == null || handler.isEmpty || handler == 'null') {
        _handlers.removeWhere((h) => h.pluginId == context.pluginId);
      } else {
        _handlers.removeWhere(
          (h) => h.pluginId == context.pluginId && h.handlerName == handler,
        );
      }
    } catch (e) {
      _log.warning('Failed to unsubscribe ws: $e');
    }
  }

  bool _handleSend(PluginContext context, dynamic raw) {
    try {
      final data = context.decode(raw);
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
      if (ok) _log.fine('Plugin sent ws packet: $type');
      return ok;
    } catch (e) {
      _log.warning('Failed to send ws packet: $e');
      return false;
    }
  }

  bool _isConnected() {
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
      if (handler.typeFilter != null && handler.typeFilter != packet.type) continue;
      final instance = manager.plugins[handler.pluginId];
      if (instance == null || instance.state != PluginState.active) continue;
      if (!instance.manifest.permissions.contains(PluginPermission.websocketSubscribe)) continue;
      final runtime = instance.runtime;
      if (runtime == null) continue;
      try {
        runtime.callFunction(handler.handlerName, [payload]);
      } catch (e) {
        _log.warning('ws handler ${handler.handlerName} failed for ${handler.pluginId}: $e');
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
      unauthorized: () => statusName = 'unauthorized',
      error: (message) {
        statusName = 'error';
        errorMessage = message;
      },
    );
    final manager = PluginManager();
    final payload = <String, dynamic>{
      'status': statusName,
      'message': errorMessage,
    };
    for (final instance in manager.plugins.values) {
      if (instance.state != PluginState.active) continue;
      if (!instance.manifest.permissions.contains(PluginPermission.websocketSubscribe)) continue;
      final runtime = instance.runtime;
      if (runtime == null) continue;
      try {
        runtime.callFunction('on_ws_status', [payload]);
      } catch (_) {}
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
