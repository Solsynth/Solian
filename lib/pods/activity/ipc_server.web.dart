// Stub implementation for web platform
// This file provides empty implementations to avoid import errors on web

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

class IpcServer {
  Future<void> start() async {}
  Future<void> stop() async {}
  void Function(dynamic, dynamic, dynamic)? handlePacket;
  void addSocket(dynamic socket) {}
  void removeSocket(dynamic socket) {}
  List<dynamic> get sockets => [];
}

class IpcSocketWrapper {
  String clientId = '';
  bool handshook = false;

  void addData(List<int> data) {}
  void send(Map<String, dynamic> msg) {}
  void sendPong(dynamic data) {}
  void close() {}
  void closeWithCode(int code, [String message = '']) {}
  List<dynamic> readPackets() => [];
}

class MultiPlatformIpcServer extends IpcServer {}

class MultiPlatformIpcSocketWrapper extends IpcSocketWrapper {}
