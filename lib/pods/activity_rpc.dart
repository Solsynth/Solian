import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/network.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:path/path.dart' as path;
import 'package:win32/win32.dart';
import 'package:ffi/ffi.dart';

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
  Map<String, Function> handlers; // {connection: (socket), message: (socket, data), close: (socket)}
  HttpServer? _httpServer;
  ServerSocket? _ipcServer;
  int? _pipeHandle; // For Windows named pipe
  Timer? _ipcTimer; // Store timer for cancellation
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
    if (Platform.isWindows) return r'\\.\pipe\discord-ipc';

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
      Platform.environment['XDG_RUNTIME_DIR'],
      Platform.environment['TMPDIR'],
      Platform.environment['TMP'],
      Platform.environment['TEMP'],
      '/tmp',
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
          try {
            await File(socketPath).delete();
          } catch (_) {}
          developer.log(
            'IPC socket will be created at: $socketPath',
            name: kRpcIpcLogPrefix,
          );
          return socketPath;
        } catch (e) {
          if (i == 0) {
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

  // Start the server
  Future<void> start() async {
    int port = portRange[0];
    bool wsSuccess = false;

    // Start WebSocket server
    while (port <= portRange[1]) {
      developer.log('Trying port $port', name: kRpcLogPrefix);
      try {
        _httpServer = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
        developer.log('Listening on $port', name: kRpcLogPrefix);

        shelf_io.serveRequests(_httpServer!, (Request request) async {
          developer.log('New request', name: kRpcLogPrefix);
          if (request.headers['upgrade']?.toLowerCase() == 'websocket') {
            final handler = webSocketHandler((WebSocketChannel channel, _) {
              _wsSockets.add(channel);
              _onWsConnection(channel, request);
            });
            return handler(request);
          }
          developer.log(
            'New request disposed due to not websocket',
            name: kRpcLogPrefix,
          );
          return Response.notFound('Not a WebSocket request');
        });
        wsSuccess = true;
        break;
      } catch (e) {
        if (e is SocketException && e.osError?.errorCode == 98) {
          developer.log('$port in use!', name: kRpcLogPrefix);
        } else {
          developer.log('HTTP error: $e', name: kRpcLogPrefix);
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
      if (Platform.isWindows) {
        await _startWindowsIpcServer();
      } else {
        try {
          final ipcPath = await _findAvailableIpcPath();
          _ipcServer = await ServerSocket.bind(
            InternetAddress(ipcPath, type: InternetAddressType.unix),
            0,
          );
          developer.log('IPC listening at $ipcPath', name: kRpcIpcLogPrefix);

          _ipcServer!.listen((Socket socket) {
            _onIpcConnection(socket);
          });
        } catch (e) {
          developer.log('IPC server error: $e', name: kRpcIpcLogPrefix);
        }
      }
    } else {
      developer.log(
        'IPC server disabled on macOS or web in production mode',
        name: kRpcIpcLogPrefix,
      );
    }
  }

  // Start Windows-specific IPC server using Winsock2 named pipe
  Future<void> _startWindowsIpcServer() async {
    final pipeName = r'\\.\pipe\discord-ipc'.toNativeUtf16();
    try {
      _pipeHandle = CreateNamedPipe(
        pipeName,
        PIPE_ACCESS_DUPLEX,
        PIPE_TYPE_MESSAGE | PIPE_READMODE_MESSAGE | PIPE_WAIT,
        PIPE_UNLIMITED_INSTANCES,
        4096, // Output buffer size
        4096, // Input buffer size
        0, // Default timeout
        nullptr, // Security attributes
      );

      if (_pipeHandle == INVALID_HANDLE_VALUE) {
        final error = GetLastError();
        throw Exception('Failed to create named pipe: error code $error');
      }

      developer.log('IPC named pipe created at \\\\.\\pipe\\discord-ipc', name: kRpcIpcLogPrefix);

      // Start listening for connections in a separate isolate
      _listenWindowsIpc();
    } finally {
      free(pipeName);
    }
  }

  // Listen for Windows IPC connections in an isolate
  void _listenWindowsIpc() async {
    final receivePort = ReceivePort();
    await Isolate.spawn(_windowsIpcIsolate, receivePort.sendPort);

    receivePort.listen((message) {
      if (message is int) {
        final socketWrapper = _IpcSocketWrapper(message);
        _ipcSockets.add(socketWrapper);
        developer.log('New IPC connection on named pipe', name: kRpcIpcLogPrefix);
        _handleWindowsIpcData(socketWrapper);
        _startWindowsIpcServer(); // Create new pipe for next connection
      }
    });
  }

  static void _windowsIpcIsolate(SendPort sendPort) {
    while (true) {
      final pipeHandle = CreateNamedPipe(
        r'\\.\pipe\discord-ipc'.toNativeUtf16(),
        PIPE_ACCESS_DUPLEX,
        PIPE_TYPE_MESSAGE | PIPE_READMODE_MESSAGE | PIPE_WAIT,
        PIPE_UNLIMITED_INSTANCES,
        4096,
        4096,
        0,
        nullptr,
      );
      if (pipeHandle == INVALID_HANDLE_VALUE) {
        developer.log('Failed to create named pipe: ${GetLastError()}', name: kRpcIpcLogPrefix);
        break;
      }
      final connected = ConnectNamedPipe(pipeHandle, nullptr);
      if (connected != 0 || GetLastError() == ERROR_PIPE_CONNECTED) {
        sendPort.send(pipeHandle);
      }
      // Avoid tight loop
      sleep(Duration(milliseconds: 100));
    }
  }

  // Handle Windows IPC data
  void _handleWindowsIpcData(_IpcSocketWrapper socket) async {
    final startTime = DateTime.now();
    final buffer = malloc.allocate<Uint8>(4096);
    final bytesRead = malloc.allocate<Uint32>(sizeOf<Uint32>());
    try {
      while (socket.pipeHandle != null) {
        final readStart = DateTime.now();
        final success = ReadFile(
          socket.pipeHandle!,
          buffer.cast(),
          4096,
          bytesRead,
          nullptr,
        );
        final readDuration = DateTime.now().difference(readStart).inMicroseconds;
        developer.log('ReadFile took $readDuration microseconds', name: kRpcIpcLogPrefix);

        if (success == FALSE && GetLastError() != ERROR_MORE_DATA) {
          developer.log('IPC read error: ${GetLastError()}', name: kRpcIpcLogPrefix);
          socket.close();
          break;
        }

        final data = buffer.asTypedList(bytesRead.value);
        socket.addData(data);
        final packets = socket.readPackets();
        for (final packet in packets) {
          _handleIpcPacket(socket, packet);
        }
      }
    } catch (e) {
      developer.log('IPC data error: $e', name: kRpcIpcLogPrefix);
      socket.closeWithCode(IpcCloseCodes.closeUnsupported, e.toString());
    } finally {
      malloc.free(buffer);
      malloc.free(bytesRead);
      final totalDuration = DateTime.now().difference(startTime).inMicroseconds;
      developer.log('handleWindowsIpcData took $totalDuration microseconds', name: kRpcIpcLogPrefix);
    }
  }

  // Stop the server
  Future<void> stop() async {
    // Stop WebSocket server
    for (var socket in _wsSockets) {
      try {
        await socket.sink.close();
      } catch (e) {
        developer.log('Error closing WebSocket: $e', name: kRpcLogPrefix);
      }
    }
    _wsSockets.clear();
    await _httpServer?.close(force: true);

    // Stop IPC server
    for (var socket in _ipcSockets) {
      try {
        socket.close();
      } catch (e) {
        developer.log('Error closing IPC socket: $e', name: kRpcIpcLogPrefix);
      }
    }
    _ipcSockets.clear();
    if (Platform.isWindows && _pipeHandle != null) {
      try {
        CloseHandle(_pipeHandle!);
      } catch (e) {
        developer.log('Error closing named pipe: $e', name: kRpcIpcLogPrefix);
      }
      _pipeHandle = null;
    }
    _ipcTimer?.cancel();
    await _ipcServer?.close();

    developer.log('Servers stopped', name: kRpcLogPrefix);
  }

  // Handle new WebSocket connection
  void _onWsConnection(WebSocketChannel socket, Request request) {
    final uri = request.url;
    final params = uri.queryParameters;
    final ver = int.tryParse(params['v'] ?? '1') ?? 1;
    final encoding = params['encoding'] ?? 'json';
    final clientId = params['client_id'] ?? '';
    final origin = request.headers['origin'] ?? '';

    developer.log(
      'New WS connection! origin: $origin, params: $params',
      name: kRpcLogPrefix,
    );

    if (origin.isNotEmpty &&
        ![
          'https://discord.com',
          'https://ptb.discord.com',
          'https://canary.discord.com',
        ].contains(origin)) {
      developer.log('Disallowed origin: $origin', name: kRpcLogPrefix);
      socket.sink.close();
      return;
    }

    if (encoding != 'json') {
      developer.log(
        'Unsupported encoding requested: $encoding',
        name: kRpcLogPrefix,
      );
      socket.sink.close();
      return;
    }

    if (ver != 1) {
      developer.log('Unsupported version requested: $ver', name: kRpcLogPrefix);
      socket.sink.close();
      return;
    }

    final socketWithMeta = _WsSocketWrapper(socket, clientId, encoding);

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

    handlers['connection']?.call(socketWithMeta);
  }

  // Handle new IPC connection
  void _onIpcConnection(Socket socket) {
    developer.log('New IPC connection!', name: kRpcIpcLogPrefix);

    final socketWrapper = _IpcSocketWrapper.fromSocket(socket);
    _ipcSockets.add(socketWrapper);

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
  Future<void> _onWsMessage(_WsSocketWrapper socket, dynamic data) async {
    if (data is! String) {
      developer.log('Invalid WebSocket message: not a string', name: kRpcLogPrefix);
      return;
    }
    try {
      final jsonData = await compute(jsonDecode, data);
      if (jsonData is! Map<String, dynamic>) {
        developer.log('Invalid WebSocket message: not a JSON object', name: kRpcLogPrefix);
        return;
      }
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

    if (ver != 1) {
      developer.log(
        'IPC unsupported version requested: $ver',
        name: kRpcIpcLogPrefix,
      );
      socket.closeWithCode(IpcErrorCodes.invalidVersion);
      return;
    }

    if (clientId.isEmpty) {
      developer.log('IPC client ID required', name: kRpcIpcLogPrefix);
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
    developer.log('WS sending: $msg', name: kRpcLogPrefix);
    channel.sink.add(jsonEncode(msg));
  }
}

// IPC wrapper
class _IpcSocketWrapper {
  final Socket? socket;
  final int? pipeHandle;
  String clientId = '';
  bool handshook = false;
  final List<int> _buffer = [];

  _IpcSocketWrapper(this.pipeHandle) : socket = null;
  _IpcSocketWrapper.fromSocket(this.socket) : pipeHandle = null;

  void addData(List<int> data) {
    _buffer.addAll(data);
  }

  void send(Map<String, dynamic> msg) {
    developer.log('IPC sending: $msg', name: kRpcIpcLogPrefix);
    final packet = ActivityRpcServer.encodeIpcPacket(IpcTypes.frame, msg);
    if (Platform.isWindows && pipeHandle != null) {
      final buffer = malloc.allocate<Uint8>(packet.length);
      buffer.asTypedList(packet.length).setAll(0, packet);
      final bytesWritten = malloc.allocate<Uint32>(sizeOf<Uint32>());
      try {
        WriteFile(
          pipeHandle!,
          buffer.cast(),
          packet.length,
          bytesWritten,
          nullptr,
        );
      } finally {
        malloc.free(buffer);
        malloc.free(bytesWritten);
      }
    } else {
      socket?.add(packet);
    }
  }

  void sendPong(dynamic data) {
    final packet = ActivityRpcServer.encodeIpcPacket(IpcTypes.pong, data ?? {});
    if (Platform.isWindows && pipeHandle != null) {
      final buffer = malloc.allocate<Uint8>(packet.length);
      buffer.asTypedList(packet.length).setAll(0, packet);
      final bytesWritten = malloc.allocate<Uint32>(sizeOf<Uint32>());
      try {
        WriteFile(
          pipeHandle!,
          buffer.cast(),
          packet.length,
          bytesWritten,
          nullptr,
        );
      } finally {
        malloc.free(buffer);
        malloc.free(bytesWritten);
      }
    } else {
      socket?.add(packet);
    }
  }

  void close() {
    if (Platform.isWindows && pipeHandle != null) {
      CloseHandle(pipeHandle!);
    } else {
      socket?.close();
    }
  }

  void closeWithCode(int code, [String message = '']) {
    final closeData = {'code': code, 'message': message};
    final packet = ActivityRpcServer.encodeIpcPacket(IpcTypes.close, closeData);
    if (Platform.isWindows && pipeHandle != null) {
      final buffer = malloc.allocate<Uint8>(packet.length);
      buffer.asTypedList(packet.length).setAll(0, packet);
      final bytesWritten = malloc.allocate<Uint32>(sizeOf<Uint32>());
      try {
        WriteFile(
          pipeHandle!,
          buffer.cast(),
          packet.length,
          bytesWritten,
          nullptr,
        );
      } finally {
        malloc.free(buffer);
        malloc.free(bytesWritten);
      }
      CloseHandle(pipeHandle!);
    } else {
      socket?.add(packet);
      socket?.close();
    }
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
        notifier.addActivity(
          'Activity: ${data['args']['activity']['details'] ?? 'Unknown'}',
        );
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