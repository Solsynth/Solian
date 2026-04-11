import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:logging/logging.dart';
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
  final service = WebSocketService();
  ref.onDispose(() => service.close());
  return service;
});

class WebSocketService {
  Ref? _ref;
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

  int _reconnectCount = 0;
  DateTime? _reconnectWindowStart;
  static const int _maxReconnectsPerMinute = 5;
  static const Duration _baseReconnectDelay = Duration(milliseconds: 500);
  static const Duration _maxReconnectDelay = Duration(seconds: 30);

  bool _isConnecting = false;

  Stream<WebSocketPacket> get dataStream => _streamController.stream;
  Stream<WebSocketState> get statusStream => _statusStreamController.stream;

  Future<void> connect(Ref ref) async {
    if (_isConnecting) {
      Logger.root.fine(
        '[WebSocket] Connection attempt already in progress, skipping',
      );
      return;
    }
    await _connectInternal(ref);
  }

  Future<void> _connectInternal(Ref ref) async {
    _ref = ref;
    _isClosing = false;
    _isConnecting = true;
    final connectionGeneration = ++_connectionGeneration;
    await _disposeActiveChannel(suppressReconnect: true);
    _addStatus(WebSocketState.connecting());

    final baseUrl = ref.read(serverUrlProvider);
    final token = await getValidAuthToken(ref);

    final url = '$baseUrl/ws'.replaceFirst('http', 'ws');

    Logger.root.info('[WebSocket] Trying connecting to $url');
    try {
      if (kIsWeb) {
        final wsUrl = token?.isNotEmpty ?? false ? '$url?tk=$token' : url;
        _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      } else {
        final headers = token?.isNotEmpty ?? false
            ? {'Authorization': 'Bearer $token'}
            : null;
        _channel = IOWebSocketChannel.connect(Uri.parse(url), headers: headers);
      }
      await _channel!.ready;
      _isConnecting = false;
      if (connectionGeneration != _connectionGeneration) {
        await _channel!.sink.close();
        return;
      }
      _reconnectCount = 0;
      _reconnectWindowStart = null;
      _addStatus(WebSocketState.connected());
      _scheduleHeartbeat();
      _channelSubscription = _channel!.stream.listen(
        (data) {
          if (connectionGeneration != _connectionGeneration) return;
          String dataStr;
          try {
            dataStr = data is Uint8List ? utf8.decode(data) : data.toString();
          } catch (e) {
            Logger.root.severe('[WebSocket] Failed to decode data: $e');
            return;
          }
          try {
            final packet = WebSocketPacket.fromJson(jsonDecode(dataStr));
            Logger.root.info('[WebSocket] Received packet: ${packet.type}');

            if (packet.type == 'error.dupe') {
              Logger.root.info(
                '[WebSocket] Duplicate device found: ${packet.errorMessage}',
              );
              _isClosing = true;
              _cancelTimers();
              _addStatus(WebSocketState.duplicateDevice());
              _channel!.sink.close();
              return;
            } else if (packet.type == 'error') {
              Logger.root.info(
                '[WebSocket] Connect error: ${packet.errorMessage}',
              );
              _isClosing = true;
              _cancelTimers();
              _addStatus(WebSocketState.error(packet.errorMessage ?? 'error'));
              _channel!.sink.close();
              return;
            }

            _streamController.sink.add(packet);
            if (packet.type == 'pong' && _heartbeatAt != null) {
              final now = DateTime.now();
              final delay = now.difference(_heartbeatAt!);
              heartbeatDelay = delay;
              Logger.root.info(
                "[WebSocket] Server respond last heartbeat for ${delay.inMilliseconds} ms",
              );
            }
          } catch (e) {
            Logger.root.severe('[WebSocket] Failed to parse packet: $e');
          }
        },
        onDone: () {
          if (connectionGeneration != _connectionGeneration || _isClosing) {
            return;
          }
          Logger.root.info(
            '[WebSocket] Connection closed, attempting to reconnect...',
          );
          _addStatus(WebSocketState.disconnected());
          _scheduleReconnect();
        },
        onError: (error) {
          if (connectionGeneration != _connectionGeneration || _isClosing) {
            return;
          }
          Logger.root.severe(
            '[WebSocket] Error occurred: $error, attempting to reconnect...',
          );
          _addStatus(WebSocketState.error(error.toString()));
          _scheduleReconnect();
        },
      );
    } catch (err) {
      if (connectionGeneration != _connectionGeneration || _isClosing) return;
      Logger.root.severe('[WebSocket] Failed to connect: $err');
      _addStatus(WebSocketState.error(err.toString()));
      _scheduleReconnect();
    }
  }

  void _addStatus(WebSocketState state) {
    if (!_statusStreamController.isClosed) {
      _statusStreamController.sink.add(state);
    }
  }

  void _cancelTimers() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _heartbeatAt = null;
    heartbeatDelay = null;
  }

  void _scheduleReconnect() {
    Logger.root.info('[WebSocket] Scheduling reconnect...');
    if (_isClosing) {
      Logger.root.fine(
        '[WebSocket] Not scheduling reconnect because connection is closing',
      );
      return;
    }

    final ref = _ref;
    if (ref == null) {
      Logger.root.severe(
        '[WebSocket] Cannot schedule reconnect: ref not initialized',
      );
      return;
    }

    final now = DateTime.now();
    if (_reconnectWindowStart == null ||
        now.difference(_reconnectWindowStart!).inMinutes >= 1) {
      _reconnectWindowStart = now;
      _reconnectCount = 0;
    }

    _reconnectCount++;

    if (_reconnectCount > _maxReconnectsPerMinute) {
      Logger.root.severe(
        '[WebSocket] Reconnect limit exceeded: $_maxReconnectsPerMinute reconnections in the last minute. Retrying in 30s.',
      );
      _addStatus(WebSocketState.serverDown());
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(const Duration(seconds: 30), () {
        if (_isClosing) return;
        _reconnectWindowStart = null;
        _reconnectCount = 0;
        _addStatus(WebSocketState.connecting());
        connect(ref);
      });
      return;
    }

    _reconnectTimer?.cancel();
    final backoffMs =
        (_baseReconnectDelay.inMilliseconds * (1 << (_reconnectCount - 1)))
            .clamp(
              _baseReconnectDelay.inMilliseconds,
              _maxReconnectDelay.inMilliseconds,
            );
    final jitter = Random().nextInt(200) - 100;
    final delayMs = (backoffMs + jitter).clamp(
      100,
      _maxReconnectDelay.inMilliseconds,
    );
    _reconnectTimer = Timer(Duration(milliseconds: delayMs), () {
      if (_isClosing) return;
      _addStatus(WebSocketState.connecting());
      connect(ref);
    });
  }

  void manualReconnect() {
    final ref = _ref;
    if (ref == null) {
      Logger.root.severe(
        '[WebSocket] Cannot manual reconnect: ref not initialized',
      );
      return;
    }
    Logger.root.info('[WebSocket] Manual reconnect triggered by user');

    // Cancel any pending reconnect timers
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    Logger.root.fine('[WebSocket] Cancelled pending reconnect timers');

    // Immediately disconnect current connection
    _isClosing = false;
    _reconnectCount = 0;
    _reconnectWindowStart = null;
    Logger.root.fine('[WebSocket] Reset reconnect counters and state');

    // Fire and forget dispose - do NOT wait for it to complete
    // This avoids hanging if socket is in broken state
    Logger.root.fine('[WebSocket] Closing existing WebSocket connection');

    // Increment connection generation first to invalidate any existing connection
    _connectionGeneration++;

    // Dispose without waiting
    _disposeActiveChannel(suppressReconnect: true)
        .timeout(const Duration(milliseconds: 1000))
        .then((_) {
          Logger.root.fine('[WebSocket] Dispose completed normally');
          _addStatus(WebSocketState.disconnected());
          Future.delayed(const Duration(milliseconds: 100), () {
            Logger.root.fine(
              '[WebSocket] Reconnecting after manual trigger...',
            );
            _addStatus(WebSocketState.connecting());
            connect(ref);
          });
        })
        .catchError((err) {
          Logger.root.warning(
            '[WebSocket] Dispose had error (this is normal): $err',
          );
        });
  }

  void _scheduleHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _beatTheHeart();
    });
  }

  void _beatTheHeart() {
    if (_channel == null || _isClosing) return;
    _heartbeatAt = DateTime.now();
    Logger.root.info('[WebSocket] We\'re beating the heart! $_heartbeatAt');
    sendMessage(jsonEncode(WebSocketPacket(type: 'ping', data: null)));
  }

  WebSocketChannel? get ws => _channel;

  bool sendMessage(String message) {
    if (_channel == null || _isClosing) {
      Logger.root.info(
        '[WebSocket] Cannot send message: channel is null or closing',
      );
      return false;
    }
    try {
      _channel!.sink.add(message);
      return true;
    } catch (e) {
      Logger.root.severe('[WebSocket] Failed to send message: $e');
      return false;
    }
  }

  void close() {
    _isClosing = true;
    _cancelTimers();
    _channelSubscription?.cancel();
    _channelSubscription = null;
    _channel?.sink.close();
    _channel = null;
    _streamController.close();
    _statusStreamController.close();
    _isClosing = false;
  }

  Future<void> _disposeActiveChannel({bool suppressReconnect = false}) async {
    _cancelTimers();

    // Cancel stream subscription with timeout
    try {
      await _channelSubscription?.cancel().timeout(
        const Duration(milliseconds: 200),
      );
      Logger.root.fine(
        '[WebSocket] Stream subscription cancelled successfully',
      );
    } catch (e) {
      Logger.root.warning(
        '[WebSocket] Stream subscription cancel timed out, forcing null',
      );
    } finally {
      _channelSubscription = null;
    }

    // Close websocket sink with timeout
    try {
      await _channel?.sink.close().timeout(const Duration(milliseconds: 300));
      Logger.root.fine('[WebSocket] WebSocket sink closed successfully');
    } catch (e) {
      Logger.root.warning(
        '[WebSocket] WebSocket close timed out, forcing null',
      );
    } finally {
      _channel = null;
    }

    _isConnecting = false;
  }
}

final websocketStateProvider =
    NotifierProvider<WebSocketStateNotifier, WebSocketState>(
      WebSocketStateNotifier.new,
    );

class WebSocketStateNotifier extends Notifier<WebSocketState> {
  StreamSubscription<WebSocketState>? _statusSubscription;

  @override
  WebSocketState build() {
    _statusSubscription?.cancel();
    final service = ref.read(websocketProvider);
    _statusSubscription = service.statusStream.listen((event) {
      state = event;
    });

    ref.onDispose(() {
      _statusSubscription?.cancel();
      final service = ref.read(websocketProvider);
      service.close();
    });
    return const WebSocketState.disconnected();
  }

  Future<void> connect() async {
    final service = ref.read(websocketProvider);
    await service.connect(ref);
  }

  void sendMessage(String message) {
    final service = ref.read(websocketProvider);
    service.sendMessage(message);
  }

  void close() {
    final service = ref.read(websocketProvider);
    service.close();
    state = const WebSocketState.disconnected();
  }

  void manualReconnect() {
    final service = ref.read(websocketProvider);
    service.manualReconnect();
  }
}
