import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/network.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:path/path.dart' as path;

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

class ActivityRpcServer {
  static const List<int> portRange = [6463, 6472]; // Ports 6463–6472
  Map<String, Function>
  handlers; // {connection: (socket), message: (socket, data), close: (socket)}
  HttpServer? _httpServer;
  ServerSocket? _ipcServer;
  final List<WebSocketChannel> _wsSockets = [];
  final List<_IpcSocketWrapper> _ipcSockets = [];

  ActivityRpcServer(this.handlers);

  void updateHandlers(Map<String, Function> newHandlers) {
    handlers = newHandlers;
  }

  // Encode IPC packet
  static Uint8List encodeIpcPacket(int type, Map<String, dynamic> data) {
    final jsonData = jsonEncode(data);
    final dataBytes = utf8.encode(jsonData);
    final dataSize = dataBytes.length;

    final buffer = ByteData(8 + dataSize);
    buffer.setInt32(0, type, Endian.little);
    buffer.setInt32(4, dataSize, Endian.little);
    buffer.buffer.asUint8List().setRange(8, 8 + dataSize, dataBytes);

    return buffer.buffer.asUint8List();
  }

  Future<String> _getMacOsSystemTmpDir() async {
    final result = await Process.run('getconf', ['DARWIN_USER_TEMP_DIR']);
    return (result.stdout as String).trim();
  }

  // Find available IPC socket path
  Future<String> _findAvailableIpcPath() async {
    if (Platform.isWindows) {
      // Use TCP sockets on Windows for IPC (simpler and more compatible)
      return _findAvailableTcpPort();
    }

    // Build list of directories to try, with macOS-specific handling
    final baseDirs = <String>[];

    if (Platform.isMacOS) {
      try {
        final macTempDir = await _getMacOsSystemTmpDir();
        if (macTempDir.isNotEmpty) {
          baseDirs.add(macTempDir);
        }
      } catch (e) {
        developer.log(
          'Failed to get macOS system temp dir: $e',
          name: kRpcIpcLogPrefix,
        );
      }
    }

    // Add other standard directories
    final otherDirs = [
      Platform.environment['XDG_RUNTIME_DIR'], // User runtime directory
      Platform.environment['TMPDIR'], // App container temp (fallback)
      Platform.environment['TMP'],
      Platform.environment['TEMP'],
      '/tmp', // System temp directory - most compatible
    ];

    baseDirs.addAll(
      otherDirs.where((dir) => dir != null && dir.isNotEmpty).cast<String>(),
    );

    for (final baseDir in baseDirs) {
      for (int i = 0; i < 10; i++) {
        final socketPath = path.join(baseDir, '$kIpcBasePath-$i');
        try {
          final socket = await ServerSocket.bind(
            InternetAddress(socketPath, type: InternetAddressType.unix),
            0,
          );
          socket.close();
          // Clean up the test socket
          try {
            await File(socketPath).delete();
          } catch (_) {}
          developer.log(
            'IPC socket will be created at: $socketPath',
            name: kRpcIpcLogPrefix,
          );
          return socketPath;
        } catch (e) {
          // Path not available, try next
          if (i == 0) {
            // Log only for the first attempt per directory
            developer.log(
              'IPC path $socketPath not available: $e',
              name: kRpcIpcLogPrefix,
            );
          }
          continue;
        }
      }
    }
    throw Exception(
      'No available IPC socket paths found in any temp directory',
    );
  }

  // Find available TCP port for Windows IPC
  Future<String> _findAvailableTcpPort() async {
    // Use ports in the range 6463-6472 (same as WebSocket server)
    for (int port = 6463; port <= 6472; port++) {
      try {
        final socket = await ServerSocket.bind(
          InternetAddress.loopbackIPv4,
          port,
        );
        socket.close();
        developer.log(
          'IPC TCP socket will be created on port: $port',
          name: kRpcIpcLogPrefix,
        );
        return port.toString(); // Return as string to match existing interface
      } catch (e) {
        // Port not available, try next
        if (port == 6463) {
          developer.log(
            'IPC TCP port $port not available: $e',
            name: kRpcIpcLogPrefix,
          );
        }
        continue;
      }
    }
    throw Exception('No available IPC TCP ports found');
  }

  // Start the WebSocket server
  Future<void> start() async {
    int port = portRange[0];
    bool wsSuccess = false;

    // Start WebSocket server
    while (port <= portRange[1]) {
      developer.log('trying port $port', name: kRpcLogPrefix);
      try {
        // Start HTTP server
        _httpServer = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
        developer.log('listening on $port', name: kRpcLogPrefix);

        // Handle WebSocket upgrades
        shelf_io.serveRequests(_httpServer!, (Request request) async {
          developer.log('new request', name: kRpcLogPrefix);
          if (request.headers['upgrade']?.toLowerCase() == 'websocket') {
            final handler = webSocketHandler((WebSocketChannel channel, _) {
              _wsSockets.add(channel);
              _onWsConnection(channel, request);
            });
            return handler(request);
          }
          developer.log(
            'new request disposed due to not websocket',
            name: kRpcLogPrefix,
          );
          return Response.notFound('Not a WebSocket request');
        });
        wsSuccess = true;
        break;
      } catch (e) {
        if (e is SocketException && e.osError?.errorCode == 98) {
          // EADDRINUSE
          developer.log('$port in use!', name: kRpcLogPrefix);
        } else {
          developer.log('http error: $e', name: kRpcLogPrefix);
        }
        port++;
      }
    }

    if (!wsSuccess) {
      throw Exception(
        'Failed to bind to any port in range ${portRange[0]}–${portRange[1]}',
      );
    }

    // Start IPC server (skip on macOS due to sandboxing)
    final shouldStartIpc = !Platform.isMacOS;
    if (shouldStartIpc) {
      try {
        if (Platform.isWindows) {
          // Use TCP socket on Windows
          final ipcPortStr = await _findAvailableIpcPath();
          final ipcPort = int.parse(ipcPortStr);
          _ipcServer = await ServerSocket.bind(
            InternetAddress.loopbackIPv4,
            ipcPort,
          );
          developer.log(
            'IPC listening on TCP port $ipcPort',
            name: kRpcIpcLogPrefix,
          );
        } else {
          // Use Unix socket on other platforms
          final ipcPath = await _findAvailableIpcPath();
          _ipcServer = await ServerSocket.bind(
            InternetAddress(ipcPath, type: InternetAddressType.unix),
            0,
          );
          developer.log('IPC listening at $ipcPath', name: kRpcIpcLogPrefix);
        }

        _ipcServer!.listen((Socket socket) {
          _onIpcConnection(socket);
        });
      } catch (e) {
        developer.log('IPC server error: $e', name: kRpcIpcLogPrefix);
        // Continue without IPC if it fails
      }
    } else {
      developer.log(
        'IPC server disabled on macOS due to sandboxing',
        name: kRpcIpcLogPrefix,
      );
    }
  }

  // Stop the server
  Future<void> stop() async {
    // Stop WebSocket server
    for (var socket in _wsSockets) {
      await socket.sink.close();
    }
    _wsSockets.clear();
    await _httpServer?.close();

    // Stop IPC server
    for (var socket in _ipcSockets) {
      socket.close();
    }
    _ipcSockets.clear();
    await _ipcServer?.close();

    developer.log('servers stopped', name: kRpcLogPrefix);
  }

  // Handle new WebSocket connection
  void _onWsConnection(WebSocketChannel socket, Request request) {
    // Parse query parameters
    final uri = request.url;
    final params = uri.queryParameters;
    final ver = int.tryParse(params['v'] ?? '1') ?? 1;
    final encoding = params['encoding'] ?? 'json';
    final clientId = params['client_id'] ?? '';
    final origin = request.headers['origin'] ?? '';

    developer.log(
      'new WS connection! origin: $origin, params: $params',
      name: kRpcLogPrefix,
    );

    // Validate origin
    if (origin.isNotEmpty &&
        ![
          'https://discord.com',
          'https://ptb.discord.com',
          'https://canary.discord.com',
        ].contains(origin)) {
      developer.log('disallowed origin: $origin', name: kRpcLogPrefix);
      socket.sink.close();
      return;
    }

    // Validate encoding
    if (encoding != 'json') {
      developer.log(
        'unsupported encoding requested: $encoding',
        name: kRpcLogPrefix,
      );
      socket.sink.close();
      return;
    }

    // Validate version
    if (ver != 1) {
      developer.log('unsupported version requested: $ver', name: kRpcLogPrefix);
      socket.sink.close();
      return;
    }

    // Store client info on socket
    final socketWithMeta = _WsSocketWrapper(socket, clientId, encoding);

    // Set up event listeners
    socket.stream.listen(
      (data) => _onWsMessage(socketWithMeta, data),
      onError: (e) {
        developer.log('WS socket error: $e', name: kRpcLogPrefix);
      },
      onDone: () {
        developer.log('WS socket closed', name: kRpcLogPrefix);
        handlers['close']?.call(socketWithMeta);
        _wsSockets.remove(socket);
      },
    );

    // Notify handler of new connection
    handlers['connection']?.call(socketWithMeta);
  }

  // Handle new IPC connection
  void _onIpcConnection(Socket socket) {
    developer.log('new IPC connection!', name: kRpcIpcLogPrefix);

    final socketWrapper = _IpcSocketWrapper(socket);
    _ipcSockets.add(socketWrapper);

    // Set up event listeners
    socket.listen(
      (data) => _onIpcData(socketWrapper, data),
      onError: (e) {
        developer.log('IPC socket error: $e', name: kRpcIpcLogPrefix);
        socket.close();
      },
      onDone: () {
        developer.log('IPC socket closed', name: kRpcIpcLogPrefix);
        handlers['close']?.call(socketWrapper);
        _ipcSockets.remove(socketWrapper);
      },
    );
  }

  // Handle incoming WebSocket message
  void _onWsMessage(_WsSocketWrapper socket, dynamic data) {
    try {
      final jsonData = jsonDecode(data as String);
      developer.log('WS message: $jsonData', name: kRpcLogPrefix);
      handlers['message']?.call(socket, jsonData);
    } catch (e) {
      developer.log('WS message parse error: $e', name: kRpcLogPrefix);
    }
  }

  // Handle incoming IPC data
  void _onIpcData(_IpcSocketWrapper socket, List<int> data) {
    try {
      socket.addData(data);
      final packets = socket.readPackets();
      for (final packet in packets) {
        _handleIpcPacket(socket, packet);
      }
    } catch (e) {
      developer.log('IPC data error: $e', name: kRpcIpcLogPrefix);
      socket.closeWithCode(IpcCloseCodes.closeUnsupported, e.toString());
    }
  }

  // Handle IPC packet
  void _handleIpcPacket(_IpcSocketWrapper socket, _IpcPacket packet) {
    switch (packet.type) {
      case IpcTypes.ping:
        developer.log('IPC ping received', name: kRpcIpcLogPrefix);
        socket.sendPong(packet.data);
        break;

      case IpcTypes.pong:
        developer.log('IPC pong received', name: kRpcIpcLogPrefix);
        // Handle pong if needed
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
        developer.log('IPC frame: ${packet.data}', name: kRpcIpcLogPrefix);
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
  void _onIpcHandshake(_IpcSocketWrapper socket, Map<String, dynamic> params) {
    developer.log('IPC handshake: $params', name: kRpcIpcLogPrefix);

    final ver = int.tryParse(params['v']?.toString() ?? '1') ?? 1;
    final clientId = params['client_id']?.toString() ?? '';

    // Validate version
    if (ver != 1) {
      developer.log(
        'IPC unsupported version requested: $ver',
        name: kRpcIpcLogPrefix,
      );
      socket.closeWithCode(IpcErrorCodes.invalidVersion);
      return;
    }

    // Validate client ID
    if (clientId.isEmpty) {
      developer.log('IPC client ID required', name: kRpcIpcLogPrefix);
      socket.closeWithCode(IpcErrorCodes.invalidClientId);
      return;
    }

    socket.clientId = clientId;

    // Notify handler of new connection
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
    developer.log('WS sending: $msg', name: kRpcLogPrefix);
    channel.sink.add(jsonEncode(msg));
  }
}

// IPC wrapper
class _IpcSocketWrapper {
  final Socket socket;
  String clientId = '';
  bool handshook = false;
  final List<int> _buffer = [];

  _IpcSocketWrapper(this.socket);

  void addData(List<int> data) {
    _buffer.addAll(data);
  }

  void send(Map<String, dynamic> msg) {
    developer.log('IPC sending: $msg', name: kRpcIpcLogPrefix);
    final packet = ActivityRpcServer.encodeIpcPacket(IpcTypes.frame, msg);
    socket.add(packet);
  }

  void sendPong(dynamic data) {
    final packet = ActivityRpcServer.encodeIpcPacket(IpcTypes.pong, data ?? {});
    socket.add(packet);
  }

  void close() {
    socket.close();
  }

  void closeWithCode(int code, [String message = '']) {
    final closeData = {'code': code, 'message': message};
    final packet = ActivityRpcServer.encodeIpcPacket(IpcTypes.close, closeData);
    socket.add(packet);
    socket.close();
  }

  List<_IpcPacket> readPackets() {
    final packets = <_IpcPacket>[];

    while (_buffer.length >= 8) {
      final buffer = Uint8List.fromList(_buffer);
      final byteData = ByteData.view(buffer.buffer);

      final type = byteData.getInt32(0, Endian.little);
      final dataSize = byteData.getInt32(4, Endian.little);

      if (_buffer.length < 8 + dataSize) break;

      final dataBytes = _buffer.sublist(8, 8 + dataSize);
      final jsonStr = utf8.decode(dataBytes);
      final jsonData = jsonDecode(jsonStr);

      packets.add(_IpcPacket(type, jsonData));

      _buffer.removeRange(0, 8 + dataSize);
    }

    return packets;
  }
}

// IPC Packet structure
class _IpcPacket {
  final int type;
  final Map<String, dynamic> data;

  _IpcPacket(this.type, this.data);
}

// State management for server status and activities
class ServerState {
  final String status;
  final List<String> activities;

  ServerState({required this.status, this.activities = const []});

  ServerState copyWith({String? status, List<String>? activities}) {
    return ServerState(
      status: status ?? this.status,
      activities: activities ?? this.activities,
    );
  }
}

class ServerStateNotifier extends StateNotifier<ServerState> {
  final ActivityRpcServer server;

  ServerStateNotifier(this.server)
    : super(ServerState(status: 'Server not started'));

  Future<void> start() async {
    // Only start server on desktop platforms
    if (!Platform.isAndroid && !Platform.isIOS && !kIsWeb) {
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

  void updateStatus(String status) {
    state = state.copyWith(status: status);
  }

  void addActivity(String activity) {
    state = state.copyWith(activities: [...state.activities, activity]);
  }
}

// Providers
final rpcServerStateProvider =
    StateNotifierProvider<ServerStateNotifier, ServerState>((ref) {
      final server = ActivityRpcServer({});
      final notifier = ServerStateNotifier(server);
      server.updateHandlers({
        'connection': (socket) {
          final clientId =
              socket is _WsSocketWrapper
                  ? socket.clientId
                  : (socket as _IpcSocketWrapper).clientId;
          notifier.updateStatus('Client connected (ID: $clientId)');
          // Send READY event
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
            'nonce': '12345', // Should be dynamic
          });
        },
        'message': (socket, dynamic data) async {
          if (data['cmd'] == 'SET_ACTIVITY') {
            notifier.addActivity(
              'Activity: ${data['args']['activity']['details'] ?? 'Unknown'}',
            );
            // Call setRemoteActivityStatus
            final label = data['args']['activity']['details'] ?? 'Unknown';
            final appId = socket.clientId;
            try {
              await setRemoteActivityStatus(ref, label, appId);
            } catch (e) {
              developer.log(
                'Failed to set remote activity status: $e',
                name: kRpcLogPrefix,
              );
            }
            // Echo back success
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
          final appId = socket.clientId;
          try {
            await unsetRemoteActivityStatus(ref, appId);
          } catch (e) {
            developer.log(
              'Failed to unset remote activity status: $e',
              name: kRpcLogPrefix,
            );
          }
        },
      });
      return notifier;
    });

final rpcServerProvider = Provider<ActivityRpcServer>((ref) {
  final notifier = ref.watch(rpcServerStateProvider.notifier);
  return notifier.server;
});

Future<void> setRemoteActivityStatus(
  Ref ref,
  String label,
  String appId,
) async {
  final apiClient = ref.read(apiClientProvider);
  await apiClient.post(
    '/id/accounts/me/statuses',
    data: {
      'is_invisible': false,
      'is_not_disturb': false,
      'is_automated': true,
      'label': label,
      'app_identifier': appId,
    },
  );
}

Future<void> unsetRemoteActivityStatus(Ref ref, String appId) async {
  final apiClient = ref.read(apiClientProvider);
  await apiClient.delete(
    '/id/accounts/me/statuses',
    queryParameters: {'app': appId},
  );
}
