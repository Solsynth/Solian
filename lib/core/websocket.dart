import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:island/talker.dart';

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
  StreamSubscription? _channelSubscription;
  final StreamController<WebSocketPacket> _streamController =
      StreamController<WebSocketPacket>.broadcast();
  final StreamController<WebSocketState> _statusStreamController =
      StreamController<WebSocketState>.broadcast();
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  int _connectionGeneration = 0;
  bool _isClosing = false;

  DateTime? _heartbeatAt;
  Duration? heartbeatDelay;

  // Reconnection tracking
  int _reconnectCount = 0;
  DateTime? _reconnectWindowStart;
  static const int _maxReconnectsPerMinute = 5;
  static const Duration _baseReconnectDelay = Duration(milliseconds: 500);
  static const Duration _maxReconnectDelay = Duration(seconds: 30);

  Stream<WebSocketPacket> get dataStream => _streamController.stream;
  Stream<WebSocketState> get statusStream => _statusStreamController.stream;

  Future<void> connect(Ref ref) async {
    _ref = ref;
    _isClosing = false;
    final connectionGeneration = ++_connectionGeneration;
    await _disposeActiveChannel();
    _statusStreamController.sink.add(WebSocketState.connecting());

    final baseUrl = ref.read(serverUrlProvider);
    final token = await getValidAuthToken(ref);

    final url = '$baseUrl/ws'.replaceFirst('http', 'ws');

    talker.info('[WebSocket] Trying connecting to $url');
    try {
      if (kIsWeb) {
        final wsUrl = token?.isNotEmpty ?? false ? '$url?tk=$token' : url;
        _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      } else {
        final headers = token?.isNotEmpty ?? false
            ? {'Authorization': 'Bearer ${token!}'}
            : null;
        _channel = IOWebSocketChannel.connect(Uri.parse(url), headers: headers);
      }
      await _channel!.ready;
      if (connectionGeneration != _connectionGeneration) {
        await _channel!.sink.close();
        return;
      }
      _reconnectCount = 0;
      _reconnectWindowStart = null;
      _statusStreamController.sink.add(WebSocketState.connected());
      _scheduleHeartbeat();
      _channelSubscription = _channel!.stream.listen(
        (data) {
          if (connectionGeneration != _connectionGeneration) return;
          final dataStr = data is Uint8List
              ? utf8.decode(data)
              : data.toString();
          final packet = WebSocketPacket.fromJson(jsonDecode(dataStr));
          talker.info('[WebSocket] Received packet: ${packet.type}');
          if (packet.type == 'error.dupe') {
            talker.info(
              '[WebSocket] Duplicate device found: ${packet.errorMessage}',
            );
            _statusStreamController.sink.add(WebSocketState.duplicateDevice());
            _channel!.sink.close();
            return;
          } else if (packet.type == 'error') {
            talker.info('[WebSocket] Connect error: ${packet.errorMessage}');
            _statusStreamController.sink.add(
              WebSocketState.error(packet.errorMessage ?? 'error'),
            );
            _channel!.sink.close();
          }
          _streamController.sink.add(packet);
          if (packet.type == 'pong' && _heartbeatAt != null) {
            var now = DateTime.now();
            heartbeatDelay = now.difference(_heartbeatAt!);
            talker.info(
              "[WebSocket] Server respond last heartbeat for ${heartbeatDelay!.inMilliseconds} ms",
            );
          }
        },
        onDone: () {
          if (connectionGeneration != _connectionGeneration || _isClosing) {
            return;
          }
          talker.info(
            '[WebSocket] Connection closed, attempting to reconnect...',
          );
          _statusStreamController.sink.add(WebSocketState.disconnected());
          _scheduleReconnect();
        },
        onError: (error) {
          if (connectionGeneration != _connectionGeneration || _isClosing) {
            return;
          }
          talker.error(
            '[WebSocket] Error occurred: $error, attempting to reconnect...',
          );
          _statusStreamController.sink.add(
            WebSocketState.error(error.toString()),
          );
          _scheduleReconnect();
        },
      );
    } catch (err) {
      if (connectionGeneration != _connectionGeneration || _isClosing) return;
      talker.error('[WebSocket] Failed to connect: $err');
      _statusStreamController.sink.add(WebSocketState.error(err.toString()));
      if (err is WebSocketChannelException &&
          (err.message?.contains('handshake') ?? false)) {
        connect(ref);
      } else {
        _scheduleReconnect();
      }
    }
  }

  void _scheduleReconnect() {
    talker.info('[WebSocket] Scheduling reconnect...');
    if (_isClosing) {
      talker.debug(
        '[WebSocket] Not scheduling reconnect because connection is closing',
      );
      return;
    }

    // Check if we've exceeded the reconnect limit
    final now = DateTime.now();
    if (_reconnectWindowStart == null ||
        now.difference(_reconnectWindowStart!).inMinutes >= 1) {
      // Reset window if it's been more than 1 minute since the window started
      _reconnectWindowStart = now;
      _reconnectCount = 0;
    }

    _reconnectCount++;

    if (_reconnectCount > _maxReconnectsPerMinute) {
      talker.error(
        '[WebSocket] Reconnect limit exceeded: $_maxReconnectsPerMinute reconnections in the last minute. Retrying in 30s.',
      );
      _statusStreamController.sink.add(WebSocketState.serverDown());
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(const Duration(seconds: 30), () {
        _reconnectWindowStart = null;
        _reconnectCount = 0;
        _statusStreamController.sink.add(WebSocketState.connecting());
        connect(_ref);
      });
      return;
    }

    _reconnectTimer?.cancel();
    // Exponential backoff: 500ms, 1s, 2s, 4s, ... capped at 30s
    final backoffMs =
        (_baseReconnectDelay.inMilliseconds * (1 << (_reconnectCount - 1)))
            .clamp(
              _baseReconnectDelay.inMilliseconds,
              _maxReconnectDelay.inMilliseconds,
            );
    _reconnectTimer = Timer(Duration(milliseconds: backoffMs), () {
      _statusStreamController.sink.add(WebSocketState.connecting());
      connect(_ref);
    });
  }

  void manualReconnect() {
    _statusStreamController.sink.add(WebSocketState.connecting());
    talker.info('[WebSocket] Manual reconnect triggered by user');
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
    talker.info('[WebSocket] We\'re beating the heart! $_heartbeatAt');
    sendMessage(jsonEncode(WebSocketPacket(type: 'ping', data: null)));
  }

  WebSocketChannel? get ws => _channel;

  void sendMessage(String message) {
    _channel?.sink.add(message);
  }

  void close() {
    _isClosing = true;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _heartbeatAt = null;
    heartbeatDelay = null;
    _channelSubscription?.cancel();
    _channelSubscription = null;
    _channel?.sink.close();
    _channel = null;
  }

  Future<void> _disposeActiveChannel() async {
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _heartbeatAt = null;
    heartbeatDelay = null;
    await _channelSubscription?.cancel();
    _channelSubscription = null;
    await _channel?.sink.close();
    _channel = null;
  }
}

final websocketStateProvider =
    NotifierProvider<WebSocketStateNotifier, WebSocketState>(
      WebSocketStateNotifier.new,
    );

class WebSocketStateNotifier extends Notifier<WebSocketState> {
  Timer? _reconnectTimer;
  StreamSubscription<WebSocketState>? _statusSubscription;

  @override
  WebSocketState build() {
    _statusSubscription?.cancel();
    final service = ref.read(websocketProvider);
    _statusSubscription = service.statusStream.listen((event) {
      state = event;
    });

    ref.onDispose(() {
      _reconnectTimer?.cancel();
      _statusSubscription?.cancel();
    });
    return const WebSocketState.disconnected();
  }

  Future<void> connect() async {
    state = const WebSocketState.connecting();
    try {
      final service = ref.read(websocketProvider);
      await service.connect(ref);
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

  void manualReconnect() {
    final service = ref.read(websocketProvider);
    service.manualReconnect();
  }
}
