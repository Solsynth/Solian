import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dart_ipc/dart_ipc.dart';
import 'package:island/talker.dart';
import 'package:path/path.dart' as path;

const String kRpcIpcLogPrefix = 'arRPC.ipc';

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

// IPC Packet structure
class IpcPacket {
  final int type;
  final Map<String, dynamic> data;

  IpcPacket(this.type, this.data);
}

// Abstract base class for IPC server
abstract class IpcServer {
  final List<IpcSocketWrapper> _sockets = [];

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

  Future<void> start();
  Future<void> stop();

  void addSocket(IpcSocketWrapper socket) {
    _sockets.add(socket);
  }

  void removeSocket(IpcSocketWrapper socket) {
    _sockets.remove(socket);
  }

  List<IpcSocketWrapper> get sockets => _sockets;

  void Function(
    IpcSocketWrapper socket,
    IpcPacket packet,
    Map<String, Function> handlers,
  )?
  handlePacket;

  void Function(IpcSocketWrapper socket)? onSocketClose;
}

// Abstract base class for IPC socket wrapper
abstract class IpcSocketWrapper {
  String clientId = '';
  bool handshook = false;
  final List<int> _buffer = [];

  void addData(List<int> data) {
    _buffer.addAll(data);
  }

  void send(Map<String, dynamic> msg);
  void sendPong(dynamic data);
  void close();
  void closeWithCode(int code, [String message = '']);

  List<IpcPacket> readPackets() {
    final packets = <IpcPacket>[];

    while (_buffer.length >= 8) {
      final buffer = Uint8List.fromList(_buffer);
      final byteData = ByteData.view(buffer.buffer);

      final type = byteData.getInt32(0, Endian.little);
      final dataSize = byteData.getInt32(4, Endian.little);

      if (_buffer.length < 8 + dataSize) break;

      final dataBytes = _buffer.sublist(8, 8 + dataSize);
      final jsonStr = utf8.decode(dataBytes);
      final jsonData = jsonDecode(jsonStr);

      packets.add(IpcPacket(type, jsonData));

      _buffer.removeRange(0, 8 + dataSize);
    }

    return packets;
  }
}

// Multiplatform IPC Server implementation using dart_ipc
class MultiPlatformIpcServer extends IpcServer {
  StreamSubscription? _serverSubscription;

  @override
  Future<void> start() async {
    try {
      final ipcPath =
          Platform.isWindows
              ? r'\\.\pipe\discord-ipc-0'
              : await _findAvailableUnixIpcPath();

      final serverSocket = await bind(ipcPath);
      talker.log('IPC listening at $ipcPath');

      _serverSubscription = serverSocket.listen((socket) {
        final socketWrapper = MultiPlatformIpcSocketWrapper(socket);
        addSocket(socketWrapper);
        talker.log('New IPC connection!');
        _handleIpcData(socketWrapper);
      });
    } catch (e) {
      throw Exception('Failed to start IPC server: $e');
    }
  }

  @override
  Future<void> stop() async {
    for (var socket in sockets) {
      try {
        socket.close();
      } catch (e) {
        talker.log('Error closing IPC socket: $e');
      }
    }
    sockets.clear();
    _serverSubscription?.cancel();
  }

  // Handle incoming IPC data
  void _handleIpcData(MultiPlatformIpcSocketWrapper socket) {
    final startTime = DateTime.now();
    socket.socket.listen(
      (data) {
        final readStart = DateTime.now();
        socket.addData(data);
        final readDuration =
            DateTime.now().difference(readStart).inMicroseconds;
        talker.log('Read data took $readDuration microseconds');

        final packets = socket.readPackets();
        for (final packet in packets) {
          handlePacket?.call(socket, packet, {});
        }
      },
      onDone: () {
        talker.log('IPC connection closed');
        removeSocket(socket);
        onSocketClose?.call(socket);
        socket.close();
      },
      onError: (e) {
        talker.log('IPC data error: $e');
        socket.closeWithCode(IpcCloseCodes.closeUnsupported, e.toString());
      },
    );
    final totalDuration = DateTime.now().difference(startTime).inMicroseconds;
    talker.log('_handleIpcData took $totalDuration microseconds');
  }

  Future<String> _getMacOsSystemTmpDir() async {
    final result = await Process.run('getconf', ['DARWIN_USER_TEMP_DIR']);
    return (result.stdout as String).trim();
  }

  // Find available IPC socket path for Unix-like systems
  Future<String> _findAvailableUnixIpcPath() async {
    // Build list of directories to try, with macOS-specific handling
    final baseDirs = <String>[];

    if (Platform.isMacOS) {
      try {
        final macTempDir = await _getMacOsSystemTmpDir();
        if (macTempDir.isNotEmpty) {
          baseDirs.add(macTempDir);
        }
      } catch (e) {
        talker.log('Failed to get macOS system temp dir: $e');
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
        final socketPath = path.join(baseDir, 'discord-ipc-$i');
        try {
          final socket = await bind(socketPath);
          socket.close();
          try {
            await File(socketPath).delete();
          } catch (_) {}
          talker.log('IPC socket will be created at: $socketPath');
          return socketPath;
        } catch (e) {
          if (i == 0) {
            talker.log('IPC path $socketPath not available: $e');
          }
          continue;
        }
      }
    }
    throw Exception(
      'No available IPC socket paths found in any temp directory',
    );
  }
}

// Multiplatform IPC Socket Wrapper
class MultiPlatformIpcSocketWrapper extends IpcSocketWrapper {
  final dynamic socket;

  MultiPlatformIpcSocketWrapper(this.socket);

  @override
  void send(Map<String, dynamic> msg) {
    talker.log('IPC sending: $msg');
    final packet = IpcServer.encodeIpcPacket(IpcTypes.frame, msg);
    socket.add(packet);
  }

  @override
  void sendPong(dynamic data) {
    final packet = IpcServer.encodeIpcPacket(IpcTypes.pong, data ?? {});
    socket.add(packet);
  }

  @override
  void close() {
    socket.close();
  }

  @override
  void closeWithCode(int code, [String message = '']) {
    final closeData = {'code': code, 'message': message};
    final packet = IpcServer.encodeIpcPacket(IpcTypes.close, closeData);
    socket.add(packet);
    socket.close();
  }
}
