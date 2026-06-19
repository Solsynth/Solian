import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'island_call_method_channel.dart';

abstract class IslandCallPlatform extends PlatformInterface {
  IslandCallPlatform() : super(token: _token);
  static final Object _token = Object();
  static IslandCallPlatform _instance = MethodChannelIslandCall();
  static IslandCallPlatform get instance => _instance;
  static set instance(IslandCallPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> initialize({required String serverUrl, required String authToken}) {
    throw UnimplementedError();
  }

  Future<void> joinRoom(String roomId) {
    throw UnimplementedError();
  }

  Future<void> leaveRoom() {
    throw UnimplementedError();
  }

  Future<void> toggleMic() {
    throw UnimplementedError();
  }

  Future<void> toggleCamera() {
    throw UnimplementedError();
  }

  Future<void> toggleSpeaker() {
    throw UnimplementedError();
  }

  Future<void> toggleViewMode() {
    throw UnimplementedError();
  }

  Future<void> showExpandedView() {
    throw UnimplementedError();
  }

  Future<void> dismissExpandedView() {
    throw UnimplementedError();
  }

  Stream<Map<String, dynamic>> get onStateChanged {
    throw UnimplementedError();
  }

  Stream<List<Map<String, dynamic>>> get onParticipantsChanged {
    throw UnimplementedError();
  }
}
