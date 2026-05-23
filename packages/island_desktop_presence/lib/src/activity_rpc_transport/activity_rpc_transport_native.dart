import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'activity_rpc_transport_model.dart';

const _rpcMethodChannel = MethodChannel('island_desktop_presence');
const _rpcEventChannel = EventChannel('island_desktop_presence/rpc_events');

class MultiPlatformIpcServer extends IpcServer {
  StreamSubscription<dynamic>? _eventSubscription;
  final Map<String, MultiPlatformIpcSocketWrapper> _connections = {};

  @override
  Future<void> start() async {
    _eventSubscription ??= _rpcEventChannel.receiveBroadcastStream().listen(
      _handleNativeEvent,
    );
    await _rpcMethodChannel.invokeMethod<void>('startRpcTransport');
  }

  @override
  Future<void> stop() async {
    await _rpcMethodChannel.invokeMethod<void>('stopRpcTransport');
    await _eventSubscription?.cancel();
    _eventSubscription = null;
    _connections.clear();
    sockets.clear();
  }

  void _handleNativeEvent(dynamic event) {
    if (event is! Map<Object?, Object?>) {
      throw PlatformException(
        code: 'invalid_rpc_event',
        message: 'RPC transport event must be a map.',
      );
    }

    final eventType = event['event'] as String?;
    if (eventType == null) {
      throw PlatformException(
        code: 'invalid_rpc_event',
        message: 'RPC transport event is missing an event type.',
      );
    }

    switch (eventType) {
      case 'connected':
        final connectionId = event['connection_id'] as String?;
        if (connectionId == null) {
          return;
        }
        final socket = MultiPlatformIpcSocketWrapper._(connectionId);
        _connections[connectionId] = socket;
        addSocket(socket);
        break;
      case 'packet':
        final connectionId = event['connection_id'] as String?;
        final packetType = event['packet_type'] as int?;
        final dataJson = event['data_json'] as String?;
        if (connectionId == null || packetType == null || dataJson == null) {
          return;
        }

        final socket = _connections[connectionId];
        if (socket == null) {
          return;
        }

        final decoded = jsonDecode(dataJson);
        if (decoded is! Map<String, dynamic>) {
          return;
        }

        handlePacket?.call(socket, IpcPacket(packetType, decoded), {});
        break;
      case 'closed':
        final connectionId = event['connection_id'] as String?;
        if (connectionId == null) {
          return;
        }
        final socket = _connections.remove(connectionId);
        if (socket == null) {
          return;
        }
        removeSocket(socket);
        onSocketClose?.call(socket);
        break;
      case 'error':
        final message = event['message'] as String?;
        throw PlatformException(
          code: 'rpc_transport_error',
          message: message ?? 'Unknown RPC transport error.',
        );
    }
  }
}

class MultiPlatformIpcSocketWrapper extends IpcSocketWrapper {
  MultiPlatformIpcSocketWrapper._(this.connectionId);

  final String connectionId;

  @override
  void send(Map<String, dynamic> msg) {
    _rpcMethodChannel.invokeMethod<void>('sendRpcPacket', <String, Object?>{
      'connectionId': connectionId,
      'packetType': IpcTypes.frame,
      'dataJson': jsonEncode(msg),
    });
  }

  @override
  void sendPong(dynamic data) {
    final payload = data is Map<String, dynamic> ? data : <String, dynamic>{};
    _rpcMethodChannel.invokeMethod<void>('sendRpcPacket', <String, Object?>{
      'connectionId': connectionId,
      'packetType': IpcTypes.pong,
      'dataJson': jsonEncode(payload),
    });
  }

  @override
  void close() {
    _rpcMethodChannel.invokeMethod<void>(
      'closeRpcConnection',
      <String, Object?>{'connectionId': connectionId},
    );
  }

  @override
  void closeWithCode(int code, [String message = '']) {
    _rpcMethodChannel.invokeMethod<void>('sendRpcPacket', <String, Object?>{
      'connectionId': connectionId,
      'packetType': IpcTypes.close,
      'dataJson': jsonEncode(<String, Object?>{
        'code': code,
        'message': message,
      }),
    });
  }
}
