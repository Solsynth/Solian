import 'activity_rpc_transport_model.dart';

class MultiPlatformIpcServer extends IpcServer {
  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}
}

class MultiPlatformIpcSocketWrapper extends IpcSocketWrapper {
  MultiPlatformIpcSocketWrapper();

  @override
  void close() {}

  @override
  void closeWithCode(int code, [String message = '']) {}

  @override
  void send(Map<String, dynamic> msg) {}

  @override
  void sendPong(dynamic data) {}
}
