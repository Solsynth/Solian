import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'websocket.freezed.dart';
part 'websocket.g.dart';

@freezed
sealed class WebSocketState with _$WebSocketState {
  const factory WebSocketState.connected() = _Connected;
  const factory WebSocketState.connecting() = _Connecting;
  const factory WebSocketState.disconnected() = _Disconnected;
  const factory WebSocketState.serverDown() = _ServerDown;
  const factory WebSocketState.duplicateDevice() = _DuplicateDevice;
  const factory WebSocketState.error(String message) = _Error;
}

@freezed
sealed class WebSocketPacket with _$WebSocketPacket {
  const factory WebSocketPacket({
    required String type,
    required Map<String, dynamic>? data,
    String? endpoint,
    String? errorMessage,
  }) = _WebSocketPacket;

  factory WebSocketPacket.fromJson(Map<String, dynamic> json) =>
      _$WebSocketPacketFromJson(json);
}

final websocketProvider = Provider<WebSocketService>((ref) {
  return WebSocketService();
});

class WebSocketService {
  late Ref _ref;
  WebSocketChannel? _channel;
  final StreamController<WebSocketPacket> _streamController =
      StreamController<WebSocketPacket>.broadcast();
  final StreamController<WebSocketState> _statusStreamController =
      StreamController<WebSocketState>.broadcast();
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;

  DateTime? _heartbeatAt;
  Duration? heartbeatDelay;

  Stream<WebSocketPacket> get dataStream => _streamController.stream;
  Stream<WebSocketState> get statusStream => _statusStreamController.stream;

  Future<void> connect(Ref ref) async {
    _ref = ref;
    _statusStreamController.sink.add(WebSocketState.connecting());

    final baseUrl = ref.watch(serverUrlProvider);
    final token = await getToken(ref.watch(tokenProvider));

    final url = '$baseUrl/ws'.replaceFirst('http', 'ws');

    log('[WebSocket] Trying connecting to $url');
    try {
      if (kIsWeb) {
        _channel = WebSocketChannel.connect(Uri.parse('$url?tk=$token'));
      } else {
        _channel = IOWebSocketChannel.connect(
          Uri.parse(url),
          headers: {'Authorization': 'AtField $token'},
        );
      }
      await _channel!.ready;
      _statusStreamController.sink.add(WebSocketState.connected());
      _scheduleHeartbeat();
      _channel!.stream.listen(
        (data) {
          final dataStr =
              data is Uint8List ? utf8.decode(data) : data.toString();
          final packet = WebSocketPacket.fromJson(jsonDecode(dataStr));
          if (packet.type == 'error.dupe') {
            _statusStreamController.sink.add(WebSocketState.duplicateDevice());
            _channel!.sink.close();
            return;
          }
          _streamController.sink.add(packet);
          log(
            "[WebSocket] Received packet: ${packet.type} ${packet.errorMessage}",
          );
          if (packet.type == 'pong' && _heartbeatAt != null) {
            var now = DateTime.now();
            heartbeatDelay = now.difference(_heartbeatAt!);
            log(
              "[WebSocket] Server respond last heartbeat for ${heartbeatDelay!.inMilliseconds} ms",
            );
          }
        },
        onDone: () {
          log('[WebSocket] Connection closed, attempting to reconnect...');
          _scheduleReconnect();
          _statusStreamController.sink.add(WebSocketState.disconnected());
        },
        onError: (error) {
          log('[WebSocket] Error occurred: $error, attempting to reconnect...');
          _scheduleReconnect();
          _statusStreamController.sink.add(
            WebSocketState.error(error.toString()),
          );
        },
      );
    } catch (err) {
      log('[WebSocket] Failed to connect: $err');
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(milliseconds: 500), () {
      _statusStreamController.sink.add(WebSocketState.connecting());
      connect(_ref);
    });
  }

  void _scheduleHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _beatTheHeart();
    });
  }

  void _beatTheHeart() {
    _heartbeatAt = DateTime.now();
    log('[WebSocket] We\'re beating the heart! $_heartbeatAt');
    sendMessage(jsonEncode(WebSocketPacket(type: 'ping', data: null)));
  }

  WebSocketChannel? get ws => _channel;

  void sendMessage(String message) {
    _channel!.sink.add(message);
  }

  void close() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
  }
}

final websocketStateProvider =
    StateNotifierProvider<WebSocketStateNotifier, WebSocketState>(
      (ref) => WebSocketStateNotifier(ref),
    );

class WebSocketStateNotifier extends StateNotifier<WebSocketState> {
  final Ref ref;
  Timer? _reconnectTimer;

  WebSocketStateNotifier(this.ref) : super(const WebSocketState.disconnected());

  Future<void> connect() async {
    state = const WebSocketState.connecting();
    try {
      final service = ref.read(websocketProvider);
      await service.connect(ref);
      state = const WebSocketState.connected();
      service.statusStream.listen((event) {
        if (mounted) state = event;
      });
    } catch (err) {
      state = WebSocketState.error('Failed to connect: $err');
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(milliseconds: 500), () {
      connect();
    });
  }

  void sendMessage(String message) {
    final service = ref.read(websocketProvider);
    service.sendMessage(message);
  }

  void close() {
    final service = ref.read(websocketProvider);
    service.close();
    _reconnectTimer?.cancel();
    state = const WebSocketState.disconnected();
  }
}
