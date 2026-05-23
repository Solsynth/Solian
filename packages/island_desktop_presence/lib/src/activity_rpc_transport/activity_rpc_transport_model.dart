import 'dart:convert';
import 'dart:typed_data';

class IpcTypes {
  static const int handshake = 0;
  static const int frame = 1;
  static const int close = 2;
  static const int ping = 3;
  static const int pong = 4;
}

class IpcCloseCodes {
  static const int closeNormal = 1000;
  static const int closeUnsupported = 1003;
  static const int closeAbnormal = 1006;
}

class IpcErrorCodes {
  static const int invalidClientId = 4000;
  static const int invalidOrigin = 4001;
  static const int rateLimited = 4002;
  static const int tokenRevoked = 4003;
  static const int invalidVersion = 4004;
  static const int invalidEncoding = 4005;
}

class IpcPacket {
  final int type;
  final Map<String, dynamic> data;

  IpcPacket(this.type, this.data);
}

abstract class IpcServer {
  final List<IpcSocketWrapper> _sockets = [];

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
    Map<String, Function>,
  )?
  handlePacket;

  void Function(IpcSocketWrapper socket)? onSocketClose;
}

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

      if (_buffer.length < 8 + dataSize) {
        break;
      }

      final dataBytes = _buffer.sublist(8, 8 + dataSize);
      final jsonStr = utf8.decode(dataBytes);
      final jsonData = jsonDecode(jsonStr) as Map<String, dynamic>;

      packets.add(IpcPacket(type, jsonData));
      _buffer.removeRange(0, 8 + dataSize);
    }

    return packets;
  }
}
