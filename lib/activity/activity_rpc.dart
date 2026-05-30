import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' hide Response;
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/websocket.dart';
import 'package:island_desktop_presence/activity_rpc_transport.dart';
import 'package:logging/logging.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'activity_rpc.g.dart';

const String kRpcLogPrefix = 'arRPC.websocket';
const String kRpcIpcLogPrefix = 'arRPC.ipc';

// IPC Constants
const String kIpcBasePath = 'discord-ipc';

// IPC Packet Types
class IpcTypes {
  static const int handshake = 0;
  static const int frame = 1;
  static const int close = 2;
  static const int ping = 3;
  static const int pong = 4;
}

// IPC Close Codes
class IpcCloseCodes {
  static const int closeNormal = 1000;
  static const int closeUnsupported = 1003;
  static const int closeAbnormal = 1006;
}

// IPC Error Codes
class IpcErrorCodes {
  static const int invalidClientId = 4000;
  static const int invalidOrigin = 4001;
  static const int rateLimited = 4002;
  static const int tokenRevoked = 4003;
  static const int invalidVersion = 4004;
  static const int invalidEncoding = 4005;
}

// Reference https://github.com/OpenAsar/arrpc/blob/main/src/transports/ipc.js
class ActivityRpcServer {
  static const List<int> portRange = [6463, 6472]; // Ports 6463–6472
  Map<String, Function>
  handlers; // {connection: (socket), message: (socket, data), close: (socket)}
  HttpServer? _httpServer;
  IpcServer? _ipcServer;
  final List<WebSocketChannel> _wsSockets = [];

  ActivityRpcServer(this.handlers);

  void updateHandlers(Map<String, Function> newHandlers) {
    handlers = newHandlers;
  }

  // Start the server
  Future<void> start() async {
    int port = portRange[0];
    bool wsSuccess = false;

    // Start WebSocket server
    while (port <= portRange[1]) {
      Logger.root.info('[$kRpcLogPrefix] Trying port $port');
      try {
        _httpServer = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
        Logger.root.info('[$kRpcLogPrefix] Listening on $port');

        shelf_io.serveRequests(_httpServer!, (Request request) async {
          Logger.root.info('[$kRpcLogPrefix] New request');
          if (request.headers['upgrade']?.toLowerCase() == 'websocket') {
            final handler = webSocketHandler((WebSocketChannel channel, _) {
              _wsSockets.add(channel);
              _onWsConnection(channel, request);
            });
            return handler(request);
          }
          Logger.root.info('New request disposed due to not websocket');
          return Response.notFound('Not a WebSocket request');
        });
        wsSuccess = true;
        break;
      } catch (e) {
        if (e is SocketException && e.osError?.errorCode == 98) {
          Logger.root.info('[$kRpcLogPrefix] $port in use!');
        } else {
          Logger.root.info('[$kRpcLogPrefix] HTTP error: $e');
        }
        port++;
        await Future.delayed(Duration(milliseconds: 100)); // Add delay
      }
    }

    if (!wsSuccess) {
      throw Exception(
        'Failed to bind to any port in range ${portRange[0]}–${portRange[1]}',
      );
    }

    // Start IPC server
    final shouldStartIpc = !kIsWeb;
    if (shouldStartIpc) {
      try {
        _ipcServer = MultiPlatformIpcServer();

        // Set up IPC handlers
        _ipcServer!.handlePacket = (socket, packet, _) {
          _handleIpcPacket(socket, packet);
        };

        // Set up IPC close handler
        if (!kIsWeb) {
          (_ipcServer as dynamic).onSocketClose = (socket) {
            handlers['close']?.call(socket);
          };
        }

        await _ipcServer!.start();
      } catch (e) {
        Logger.root.info('[$kRpcLogPrefix] IPC server error: $e');
      }
    } else {
      Logger.root.info('IPC server disabled on web');
    }
  }

  // Stop the server
  Future<void> stop() async {
    // Stop WebSocket server
    for (var socket in _wsSockets) {
      try {
        await socket.sink.close();
      } catch (e) {
        Logger.root.info('[$kRpcLogPrefix] Error closing WebSocket: $e');
      }
    }
    _wsSockets.clear();
    await _httpServer?.close(force: true);

    // Stop IPC server
    await _ipcServer?.stop();

    Logger.root.info('[$kRpcLogPrefix] Servers stopped');
  }

  // Handle new WebSocket connection
  void _onWsConnection(WebSocketChannel socket, Request request) {
    final uri = request.url;
    final params = uri.queryParameters;
    final ver = int.tryParse(params['v'] ?? '1') ?? 1;
    final encoding = params['encoding'] ?? 'json';
    final clientId = params['client_id'] ?? '';
    final origin = request.headers['origin'] ?? '';

    Logger.root.info('New WS connection! origin: $origin, params: $params');

    if (encoding != 'json') {
      Logger.root.info('Unsupported encoding requested: $encoding');
      socket.sink.close();
      return;
    }

    if (ver != 1) {
      Logger.root.info('[$kRpcLogPrefix] Unsupported version requested: $ver');
      socket.sink.close();
      return;
    }

    final socketWithMeta = _WsSocketWrapper(socket, clientId, encoding);

    socket.stream.listen(
      (data) => _onWsMessage(socketWithMeta, data),
      onError: (e) {
        Logger.root.info('[$kRpcLogPrefix] WS socket error: $e');
      },
      onDone: () {
        Logger.root.info('[$kRpcLogPrefix] WS socket closed');
        handlers['close']?.call(socketWithMeta);
        _wsSockets.remove(socket);
      },
    );

    handlers['connection']?.call(socketWithMeta);
  }

  // Handle incoming WebSocket message
  Future<void> _onWsMessage(_WsSocketWrapper socket, dynamic data) async {
    if (data is! String) {
      Logger.root.info('Invalid WebSocket message: not a string');
      return;
    }
    try {
      final jsonData = await compute(jsonDecode, data);
      if (jsonData is! Map<String, dynamic>) {
        Logger.root.info('Invalid WebSocket message: not a JSON object');
        return;
      }
      Logger.root.info('[$kRpcLogPrefix] WS message: $jsonData');
      handlers['message']?.call(socket, jsonData);
    } catch (e) {
      Logger.root.info('[$kRpcLogPrefix] WS message parse error: $e');
    }
  }

  // Handle IPC packet
  void _handleIpcPacket(IpcSocketWrapper socket, IpcPacket packet) {
    switch (packet.type) {
      case IpcTypes.ping:
        Logger.root.info('[$kRpcLogPrefix] IPC ping received');
        socket.sendPong(packet.data);
        break;

      case IpcTypes.pong:
        Logger.root.info('[$kRpcLogPrefix] IPC pong received');
        break;

      case IpcTypes.handshake:
        if (socket.handshook) {
          throw Exception('Already handshook');
        }
        socket.handshook = true;
        _onIpcHandshake(socket, packet.data);
        break;

      case IpcTypes.frame:
        if (!socket.handshook) {
          throw Exception('Need to handshake first');
        }
        Logger.root.info('[$kRpcLogPrefix] IPC frame: ${packet.data}');
        handlers['message']?.call(socket, packet.data);
        break;

      case IpcTypes.close:
        socket.close();
        break;

      default:
        throw Exception('Invalid packet type: ${packet.type}');
    }
  }

  // Handle IPC handshake
  void _onIpcHandshake(IpcSocketWrapper socket, Map<String, dynamic> params) {
    Logger.root.info('[$kRpcLogPrefix] IPC handshake: $params');

    final ver = int.tryParse(params['v']?.toString() ?? '1') ?? 1;
    final clientId = params['client_id']?.toString() ?? '';

    if (ver != 1) {
      Logger.root.info('IPC unsupported version requested: $ver');
      socket.closeWithCode(IpcErrorCodes.invalidVersion);
      return;
    }

    if (clientId.isEmpty) {
      Logger.root.info('[$kRpcLogPrefix] IPC client ID required');
      socket.closeWithCode(IpcErrorCodes.invalidClientId);
      return;
    }

    socket.clientId = clientId;

    handlers['connection']?.call(socket);
  }
}

// WebSocket wrapper
class _WsSocketWrapper {
  final WebSocketChannel channel;
  final String clientId;
  final String encoding;

  _WsSocketWrapper(this.channel, this.clientId, this.encoding);

  void send(Map<String, dynamic> msg) {
    Logger.root.info('[$kRpcLogPrefix] WS sending: $msg');
    channel.sink.add(jsonEncode(msg));
  }
}

// State management for server status and activities
class ServerState {
  final String status;
  final List<String> activities;
  final String? currentActivityManualId;
  final Map<String, dynamic>? currentActivityData;
  final List<Map<String, dynamic>> recentPackets;

  ServerState({
    required this.status,
    this.activities = const [],
    this.currentActivityManualId,
    this.currentActivityData,
    this.recentPackets = const [],
  });

  ServerState copyWith({
    String? status,
    List<String>? activities,
    String? currentActivityManualId,
    Map<String, dynamic>? currentActivityData,
    List<Map<String, dynamic>>? recentPackets,
  }) {
    return ServerState(
      status: status ?? this.status,
      activities: activities ?? this.activities,
      currentActivityManualId:
          currentActivityManualId ?? this.currentActivityManualId,
      currentActivityData: currentActivityData ?? this.currentActivityData,
      recentPackets: recentPackets ?? this.recentPackets,
    );
  }
}

class ServerStateNotifier extends Notifier<ServerState> {
  late ActivityRpcServer server;
  late Dio apiClient;
  Timer? _renewalTimer;
  static const int _maxRecentPackets = 50;

  @override
  ServerState build() {
    apiClient = ref.watch(apiClientProvider);
    final enabled = ref.watch(desktopRpcServerEnabledProvider);
    server = ActivityRpcServer({});
    _setupHandlers();
    ref.onDispose(() {
      _stopRenewal();
      server.stop();
    });
    if (enabled) {
      _startServer();
    }
    return ServerState(status: enabled ? 'Starting...' : 'Disabled');
  }

  Future<void> _startServer() async {
    if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
      try {
        await server.start();
        state = state.copyWith(status: 'Server running');
      } catch (e) {
        state = state.copyWith(status: 'Server failed: $e');
      }
    } else {
      state = state.copyWith(status: 'Server disabled on mobile/web');
    }
  }

  void _setupHandlers() {
    server.updateHandlers({
      'connection': (socket) {
        final clientId = socket is _WsSocketWrapper
            ? socket.clientId
            : (socket as IpcSocketWrapper).clientId;
        updateStatus('Client connected (ID: $clientId)');
        _addPacket({
          'direction': 'incoming',
          'type': 'connection',
          'client_id': clientId,
          'timestamp': DateTime.now().toIso8601String(),
        });
        socket.send({
          'cmd': 'DISPATCH',
          'data': {
            'v': 1,
            'config': {
              'cdn_host': 'fake.cdn',
              'api_endpoint': '//fake.api',
              'environment': 'dev',
            },
            'user': {
              'id': 'fake_user_id',
              'username': 'FakeUser',
              'discriminator': '0001',
              'avatar': null,
              'bot': false,
            },
          },
          'evt': 'READY',
          'nonce': '12345',
        });
        _addPacket({
          'direction': 'outgoing',
          'type': 'DISPATCH',
          'evt': 'READY',
          'timestamp': DateTime.now().toIso8601String(),
        });
      },
      'message': (socket, dynamic data) async {
        _addPacket({
          'direction': 'incoming',
          'type': data['cmd'] ?? 'unknown',
          if (data['nonce'] != null) 'nonce': data['nonce'],
          if (data['args'] != null) 'args': data['args'],
          'timestamp': DateTime.now().toIso8601String(),
        });

        if (data['cmd'] == 'SET_ACTIVITY') {
          final activity = data['args']['activity'];
          final appId = 'rpc:${socket.clientId}';

          final currentId = currentActivityManualId;
          if (currentId != null && currentId != appId) {
            Logger.root.info(
              'Skipped the new SET_ACTIVITY command due to there is one existing...',
            );
            return;
          }

          addActivity('Activity: ${activity['details'] ?? 'Untitled'}');
          final type = switch (activity['type']) {
            0 => 1,
            2 => 2,
            3 => 2,
            _ => 1,
          };
          final title = activity['name'] ?? activity['assets']?['small_text'];
          final subtitle =
              activity['details'] ?? activity['assets']?['large_text'];
          var imageSmall = activity['assets']?['small_image'];
          var imageLarge = activity['assets']?['large_image'];
          if (imageSmall != null && !imageSmall!.contains(':')) {
            imageSmall = 'discord:$imageSmall';
          }
          if (imageLarge != null && !imageLarge!.contains(':')) {
            imageLarge = 'discord:$imageLarge';
          }
          try {
            final activityData = {
              'type': type,
              'manual_id': appId,
              'title': title,
              'subtitle': subtitle,
              'caption': activity['state'],
              'title_url': activity['assets']?['small_text_url'],
              'subtitle_url': activity['assets']?['large_text_url'],
              'small_image': imageSmall,
              'large_image': imageLarge,
              'meta': activity,
              'lease_minutes': kPresenceActivityLease,
            };

            await apiClient.post('/passport/activities', data: activityData);
            setCurrentActivity(appId, activityData);
          } catch (e) {
            Logger.root.info('Failed to set remote activity status: $e');
          }
          socket.send({
            'cmd': 'SET_ACTIVITY',
            'data': data['args']['activity'],
            'evt': null,
            'nonce': data['nonce'],
          });
          _addPacket({
            'direction': 'outgoing',
            'type': 'SET_ACTIVITY',
            'nonce': data['nonce'],
            'timestamp': DateTime.now().toIso8601String(),
          });
        }
      },
      'close': (socket) async {
        final clientId = socket is _WsSocketWrapper
            ? socket.clientId
            : (socket as IpcSocketWrapper).clientId;
        final appId = 'rpc:$clientId';

        _addPacket({
          'direction': 'internal',
          'type': 'disconnect',
          'client_id': clientId,
          'timestamp': DateTime.now().toIso8601String(),
        });
        updateStatus('Client disconnected');

        final currentId = currentActivityManualId;
        if (currentId != null && currentId == appId) {
          try {
            await apiClient.delete(
              '/passport/activities',
              queryParameters: {'manualId': currentId},
            );
            setCurrentActivity(null, null);
          } catch (e) {
            Logger.root.info('Failed to unset remote activity status: $e');
          }
        }
      },
    });
  }

  String? get currentActivityManualId => state.currentActivityManualId;

  void _addPacket(Map<String, dynamic> packet) {
    final packets = [...state.recentPackets, packet];
    if (packets.length > _maxRecentPackets) {
      packets.removeAt(0);
    }
    state = state.copyWith(recentPackets: packets);
  }

  void clearPackets() {
    state = state.copyWith(recentPackets: []);
  }

  Future<void> toggleServer(bool enabled) async {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(kAppDesktopRpcServerEnabled, enabled);
    ref.invalidate(desktopRpcServerEnabledProvider);
  }

  Future<void> start() async {
    if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
      try {
        await server.start();
        state = state.copyWith(status: 'Server running');
      } catch (e) {
        state = state.copyWith(status: 'Server failed: $e');
      }
    } else {
      Future(() {
        state = state.copyWith(status: 'Server disabled on mobile/web');
      });
    }
  }

  void updateStatus(String status) {
    state = state.copyWith(status: status);
  }

  void addActivity(String activity) {
    state = state.copyWith(activities: [...state.activities, activity]);
  }

  void setCurrentActivity(String? id, Map<String, dynamic>? data) {
    state = state.copyWith(
      currentActivityManualId: id,
      currentActivityData: data,
    );
    if (id != null && data != null) {
      _startRenewal();
    } else {
      _stopRenewal();
    }
  }

  void _startRenewal() {
    _renewalTimer?.cancel();
    const int renewalIntervalSeconds = kPresenceActivityLease * 60 - 30;
    _renewalTimer = Timer.periodic(Duration(seconds: renewalIntervalSeconds), (
      timer,
    ) {
      _renewActivity();
    });
  }

  void _stopRenewal() {
    _renewalTimer?.cancel();
    _renewalTimer = null;
  }

  Future<void> _renewActivity() async {
    if (state.currentActivityData != null) {
      try {
        await apiClient.post(
          '/passport/activities',
          data: state.currentActivityData,
        );
        Logger.root.info('Activity lease renewed');
      } catch (e) {
        Logger.root.info('Failed to renew activity lease: $e');
      }
    }
  }
}

const kPresenceActivityLease = 5;

// Providers
final rpcServerStateProvider =
    NotifierProvider<ServerStateNotifier, ServerState>(ServerStateNotifier.new);

final rpcServerProvider = Provider<ActivityRpcServer>((ref) {
  final notifier = ref.watch(rpcServerStateProvider.notifier);
  return notifier.server;
});

@riverpod
Future<List<SnPresenceActivity>> presenceActivities(
  Ref ref,
  String uname,
) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/passport/activities/$uname');
  final data = response.data as List<dynamic>;
  final activities = data
      .map((json) => SnPresenceActivity.fromJson(json))
      .toList();

  if (activities.isNotEmpty) {
    final accountId = activities.first.accountId;
    final websocket = ref.watch(websocketProvider);
    final subscription = websocket.dataStream.listen((packet) {
      if (packet.type == 'account.presence.activities.updated' &&
          packet.data?['account_id'] == accountId) {
        ref.invalidateSelf();
      }
    });
    ref.onDispose(subscription.cancel);
  }

  return activities;
}
