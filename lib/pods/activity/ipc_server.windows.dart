import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'ipc_server.dart';

class WindowsIpcServer extends IpcServer {
  int? _pipeHandle;
  Timer? _ipcTimer;

  @override
  Future<void> start() async {
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

      developer.log(
        'IPC named pipe created at \\\\.\\pipe\\discord-ipc',
        name: kRpcIpcLogPrefix,
      );

      // Start listening for connections in a separate isolate
      _listenWindowsIpc();
    } finally {
      free(pipeName);
    }
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

    if (_pipeHandle != null) {
      try {
        CloseHandle(_pipeHandle!);
      } catch (e) {
        developer.log('Error closing named pipe: $e', name: kRpcIpcLogPrefix);
      }
      _pipeHandle = null;
    }
    _ipcTimer?.cancel();
  }

  // Listen for Windows IPC connections in an isolate
  void _listenWindowsIpc() async {
    final receivePort = ReceivePort();
    await Isolate.spawn(_windowsIpcIsolate, receivePort.sendPort);

    receivePort.listen((message) {
      if (message is int) {
        final socketWrapper = WindowsIpcSocketWrapper(message);
        addSocket(socketWrapper);
        developer.log(
          'New IPC connection on named pipe',
          name: kRpcIpcLogPrefix,
        );
        _handleWindowsIpcData(socketWrapper);
        start(); // Create new pipe for next connection
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
        developer.log(
          'Failed to create named pipe: ${GetLastError()}',
          name: kRpcIpcLogPrefix,
        );
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
  void _handleWindowsIpcData(WindowsIpcSocketWrapper socket) async {
    final startTime = DateTime.now();
    final buffer = malloc.allocate<BYTE>(4096);
    final bytesRead = malloc.allocate<DWORD>(4);
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
        final readDuration =
            DateTime.now().difference(readStart).inMicroseconds;
        developer.log(
          'ReadFile took $readDuration microseconds',
          name: kRpcIpcLogPrefix,
        );

        if (success == FALSE && GetLastError() != ERROR_MORE_DATA) {
          developer.log(
            'IPC read error: ${GetLastError()}',
            name: kRpcIpcLogPrefix,
          );
          socket.close();
          break;
        }

        final data = buffer.asTypedList(0);
        socket.addData(data);
        final packets = socket.readPackets();
        for (final packet in packets) {
          handlePacket?.call(socket, packet, {});
        }
      }
    } catch (e) {
      developer.log('IPC data error: $e', name: kRpcIpcLogPrefix);
      socket.closeWithCode(IpcCloseCodes.closeUnsupported, e.toString());
    } finally {
      malloc.free(buffer);
      malloc.free(bytesRead);
      final totalDuration = DateTime.now().difference(startTime).inMicroseconds;
      developer.log(
        'handleWindowsIpcData took $totalDuration microseconds',
        name: kRpcIpcLogPrefix,
      );
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
}

class WindowsIpcSocketWrapper extends IpcSocketWrapper {
  final int? pipeHandle;

  WindowsIpcSocketWrapper(this.pipeHandle);

  @override
  void send(Map<String, dynamic> msg) {
    developer.log('IPC sending: $msg', name: kRpcIpcLogPrefix);
    final packet = IpcServer.encodeIpcPacket(IpcTypes.frame, msg);
    final buffer = malloc.allocate<BYTE>(packet.length);
    buffer.asTypedList(packet.length).setAll(0, packet);
    final bytesWritten = malloc.allocate<DWORD>(4); // DWORD is 4 bytes
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
  }

  @override
  void sendPong(dynamic data) {
    final packet = IpcServer.encodeIpcPacket(IpcTypes.pong, data ?? {});
    final buffer = malloc.allocate<BYTE>(packet.length);
    buffer.asTypedList(packet.length).setAll(0, packet);
    final bytesWritten = malloc.allocate<DWORD>(4); // DWORD is 4 bytes
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
  }

  @override
  void close() {
    if (pipeHandle != null) {
      CloseHandle(pipeHandle!);
    }
  }

  @override
  void closeWithCode(int code, [String message = '']) {
    final closeData = {'code': code, 'message': message};
    final packet = IpcServer.encodeIpcPacket(IpcTypes.close, closeData);
    final buffer = malloc.allocate<BYTE>(packet.length);
    buffer.asTypedList(packet.length).setAll(0, packet);
    final bytesWritten = malloc.allocate<DWORD>(4); // DWORD is 4 bytes
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
  }
}
