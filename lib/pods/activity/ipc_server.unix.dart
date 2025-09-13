import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:path/path.dart' as path;
import 'ipc_server.dart';

class UnixIpcServer extends IpcServer {
  ServerSocket? _ipcServer;

  @override
  Future<void> start() async {
    final ipcPath = await _findAvailableIpcPath();
    _ipcServer = await ServerSocket.bind(
      InternetAddress(ipcPath, type: InternetAddressType.unix),
      0,
    );
    developer.log('IPC listening at $ipcPath', name: kRpcIpcLogPrefix);

    _ipcServer!.listen((Socket socket) {
      _onIpcConnection(socket);
    });
  }

  @override
  Future<void> stop() async {
    for (var socket in sockets) {
      try {
        socket.close();
      } catch (e) {
        developer.log('Error closing IPC socket: $e', name: kRpcIpcLogPrefix);
      }
    }
    sockets.clear();
    await _ipcServer?.close();
  }

  // Handle new IPC connection
  void _onIpcConnection(Socket socket) {
    developer.log('New IPC connection!', name: kRpcIpcLogPrefix);

    final socketWrapper = UnixIpcSocketWrapper(socket);
    addSocket(socketWrapper);

    socket.listen(
      (data) => _onIpcData(socketWrapper, data),
      onError: (e) {
        developer.log('IPC socket error: $e', name: kRpcIpcLogPrefix);
        socket.close();
      },
      onDone: () {
        developer.log('IPC socket closed', name: kRpcIpcLogPrefix);
        removeSocket(socketWrapper);
      },
    );
  }

  // Handle incoming IPC data
  void _onIpcData(UnixIpcSocketWrapper socket, List<int> data) {
    try {
      socket.addData(data);
      final packets = socket.readPackets();
      for (final packet in packets) {
        handlePacket?.call(socket, packet, {});
      }
    } catch (e) {
      developer.log('IPC data error: $e', name: kRpcIpcLogPrefix);
      socket.closeWithCode(IpcCloseCodes.closeUnsupported, e.toString());
    }
  }

  // Handle IPC handshake
  void _onIpcHandshake(
    IpcSocketWrapper socket,
    Map<String, dynamic> params,
    Map<String, Function> handlers,
  ) {
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

  Future<String> _getMacOsSystemTmpDir() async {
    final result = await Process.run('getconf', ['DARWIN_USER_TEMP_DIR']);
    return (result.stdout as String).trim();
  }

  // Find available IPC socket path
  Future<String> _findAvailableIpcPath() async {
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
        final socketPath = path.join(baseDir, 'discord-ipc-$i');
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
}

class UnixIpcSocketWrapper extends IpcSocketWrapper {
  final Socket socket;

  UnixIpcSocketWrapper(this.socket);

  @override
  void send(Map<String, dynamic> msg) {
    developer.log('IPC sending: $msg', name: kRpcIpcLogPrefix);
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
