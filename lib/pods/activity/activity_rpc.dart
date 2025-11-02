import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' hide Response;
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/activity.dart';
import 'package:island/pods/network.dart';
import 'package:island/talker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// Conditional imports for IPC server - use web stubs on web platform
import 'ipc_server.dart' if (dart.library.html) 'ipc_server.web.dart';

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
      talker.log('[$kRpcLogPrefix] Trying port $port');
      try {
        _httpServer = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
        talker.log('[$kRpcLogPrefix] Listening on $port');

        shelf_io.serveRequests(_httpServer!, (Request request) async {
          talker.log('[$kRpcLogPrefix] New request');
          if (request.headers['upgrade']?.toLowerCase() == 'websocket') {
            final handler = webSocketHandler((WebSocketChannel channel, _) {
              _wsSockets.add(channel);
              _onWsConnection(channel, request);
            });
            return handler(request);
          }
          talker.log('New request disposed due to not websocket');
          return Response.notFound('Not a WebSocket request');
        });
        wsSuccess = true;
        break;
      } catch (e) {
        if (e is SocketException && e.osError?.errorCode == 98) {
          talker.log('[$kRpcLogPrefix] $port in use!');
        } else {
          talker.log('[$kRpcLogPrefix] HTTP error: $e');
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
    final shouldStartIpc = !Platform.isMacOS && !kIsWeb;
    if (shouldStartIpc) {
      try {
        _ipcServer = MultiPlatformIpcServer();

        // Set up IPC handlers
        _ipcServer!.handlePacket = (socket, packet, _) {
          _handleIpcPacket(socket, packet);
        };

        // Set up IPC close handler
        _ipcServer!.onSocketClose = (socket) {
          handlers['close']?.call(socket);
        };

        await _ipcServer!.start();
      } catch (e) {
        talker.log('[$kRpcLogPrefix] IPC server error: $e');
      }
    } else {
      talker.log('IPC server disabled on macOS or web');
    }
  }

  // Stop the server
  Future<void> stop() async {
    // Stop WebSocket server
    for (var socket in _wsSockets) {
      try {
        await socket.sink.close();
      } catch (e) {
        talker.log('[$kRpcLogPrefix] Error closing WebSocket: $e');
      }
    }
    _wsSockets.clear();
    await _httpServer?.close(force: true);

    // Stop IPC server
    await _ipcServer?.stop();

    talker.log('[$kRpcLogPrefix] Servers stopped');
  }

  // Handle new WebSocket connection
  void _onWsConnection(WebSocketChannel socket, Request request) {
    final uri = request.url;
    final params = uri.queryParameters;
    final ver = int.tryParse(params['v'] ?? '1') ?? 1;
    final encoding = params['encoding'] ?? 'json';
    final clientId = params['client_id'] ?? '';
    final origin = request.headers['origin'] ?? '';

    talker.log('New WS connection! origin: $origin, params: $params');

    if (origin.isNotEmpty &&
        ![
          'https://discord.com',
          'https://ptb.discord.com',
          'https://canary.discord.com',
        ].contains(origin)) {
      talker.log('[$kRpcLogPrefix] Disallowed origin: $origin');
      socket.sink.close();
      return;
    }

    if (encoding != 'json') {
      talker.log('Unsupported encoding requested: $encoding');
      socket.sink.close();
      return;
    }

    if (ver != 1) {
      talker.log('[$kRpcLogPrefix] Unsupported version requested: $ver');
      socket.sink.close();
      return;
    }

    final socketWithMeta = _WsSocketWrapper(socket, clientId, encoding);

    socket.stream.listen(
      (data) => _onWsMessage(socketWithMeta, data),
      onError: (e) {
        talker.log('[$kRpcLogPrefix] WS socket error: $e');
      },
      onDone: () {
        talker.log('[$kRpcLogPrefix] WS socket closed');
        handlers['close']?.call(socketWithMeta);
        _wsSockets.remove(socket);
      },
    );

    handlers['connection']?.call(socketWithMeta);
  }

  // Handle incoming WebSocket message
  Future<void> _onWsMessage(_WsSocketWrapper socket, dynamic data) async {
    if (data is! String) {
      talker.log('Invalid WebSocket message: not a string');
      return;
    }
    try {
      final jsonData = await compute(jsonDecode, data);
      if (jsonData is! Map<String, dynamic>) {
        talker.log('Invalid WebSocket message: not a JSON object');
        return;
      }
      talker.log('[$kRpcLogPrefix] WS message: $jsonData');
      handlers['message']?.call(socket, jsonData);
    } catch (e) {
      talker.log('[$kRpcLogPrefix] WS message parse error: $e');
    }
  }

  // Handle IPC packet
  void _handleIpcPacket(IpcSocketWrapper socket, IpcPacket packet) {
    switch (packet.type) {
      case IpcTypes.ping:
        talker.log('[$kRpcLogPrefix] IPC ping received');
        socket.sendPong(packet.data);
        break;

      case IpcTypes.pong:
        talker.log('[$kRpcLogPrefix] IPC pong received');
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
        talker.log('[$kRpcLogPrefix] IPC frame: ${packet.data}');
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
    talker.log('[$kRpcLogPrefix] IPC handshake: $params');

    final ver = int.tryParse(params['v']?.toString() ?? '1') ?? 1;
    final clientId = params['client_id']?.toString() ?? '';

    if (ver != 1) {
      talker.log('IPC unsupported version requested: $ver');
      socket.closeWithCode(IpcErrorCodes.invalidVersion);
      return;
    }

    if (clientId.isEmpty) {
      talker.log('[$kRpcLogPrefix] IPC client ID required');
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
    talker.log('[$kRpcLogPrefix] WS sending: $msg');
    channel.sink.add(jsonEncode(msg));
  }
}

// State management for server status and activities
class ServerState {
  final String status;
  final List<String> activities;
  final String? currentActivityManualId;
  final Map<String, dynamic>? currentActivityData;

  ServerState({
    required this.status,
    this.activities = const [],
    this.currentActivityManualId,
    this.currentActivityData,
  });

  ServerState copyWith({
    String? status,
    List<String>? activities,
    String? currentActivityManualId,
    Map<String, dynamic>? currentActivityData,
  }) {
    return ServerState(
      status: status ?? this.status,
      activities: activities ?? this.activities,
      currentActivityManualId:
          currentActivityManualId ?? this.currentActivityManualId,
      currentActivityData: currentActivityData ?? this.currentActivityData,
    );
  }
}

class ServerStateNotifier extends StateNotifier<ServerState> {
  final ActivityRpcServer server;
  final Dio apiClient;
  Timer? _renewalTimer;

  ServerStateNotifier(this.apiClient, this.server)
    : super(ServerState(status: 'Server not started'));

  String? get currentActivityManualId => state.currentActivityManualId;

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
          '/pass/activities',
          data: state.currentActivityData,
        );
        talker.log('Activity lease renewed');
      } catch (e) {
        talker.log('Failed to renew activity lease: $e');
      }
    }
  }
}

const kPresenceActivityLease = 5;

// Providers
final rpcServerStateProvider = StateNotifierProvider<
  ServerStateNotifier,
  ServerState
>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final server = ActivityRpcServer({});
  final notifier = ServerStateNotifier(apiClient, server);
  server.updateHandlers({
    'connection': (socket) {
      final clientId =
          socket is _WsSocketWrapper
              ? socket.clientId
              : (socket as IpcSocketWrapper).clientId;
      notifier.updateStatus('Client connected (ID: $clientId)');
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
    },
    'message': (socket, dynamic data) async {
      if (data['cmd'] == 'SET_ACTIVITY') {
        final activity = data['args']['activity'];
        final appId = 'rpc:${socket.clientId}';

        final currentId = notifier.currentActivityManualId;
        if (currentId != null && currentId != appId) {
          talker.info(
            'Skipped the new SET_ACTIVITY command due to there is one existing...',
          );
          return;
        }

        notifier.addActivity('Activity: ${activity['details'] ?? 'Untitled'}');
        // https://discord.com/developers/docs/topics/rpc#setactivity-set-activity-argument-structure
        final type = switch (activity['type']) {
          0 => 1, // Discord Playing -> Playing
          2 => 2, // Discord Music -> Listening
          3 => 2, // Discord Watching -> Listening
          _ => 1, // Discord Competing (or null) -> Playing
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
          final apiClient = ref.watch(apiClientProvider);
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

          await apiClient.post('/pass/activities', data: activityData);
          notifier.setCurrentActivity(appId, activityData);
        } catch (e) {
          talker.log('Failed to set remote activity status: $e');
        }
        socket.send({
          'cmd': 'SET_ACTIVITY',
          'data': data['args']['activity'],
          'evt': null,
          'nonce': data['nonce'],
        });
      }
    },
    'close': (socket) async {
      notifier.updateStatus('Client disconnected');
      final currentId = notifier.currentActivityManualId;
      try {
        final apiClient = ref.watch(apiClientProvider);
        await apiClient.delete(
          '/pass/activities',
          queryParameters: {'manualId': currentId},
        );
        notifier.setCurrentActivity(null, null);
      } catch (e) {
        talker.log('Failed to unset remote activity status: $e');
      }
    },
  });
  return notifier;
});

final rpcServerProvider = Provider<ActivityRpcServer>((ref) {
  final notifier = ref.watch(rpcServerStateProvider.notifier);
  return notifier.server;
});

@riverpod
Future<List<SnPresenceActivity>> presenceActivities(
  Ref ref,
  String uname,
) async {
  ref.keepAlive();
  final timer = Timer.periodic(
    const Duration(minutes: 1),
    (_) => ref.invalidateSelf(),
  );
  ref.onDispose(() => timer.cancel());

  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/pass/activities/$uname');
  final data = response.data as List<dynamic>;
  return data.map((json) => SnPresenceActivity.fromJson(json)).toList();
}
