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

  Future<void> startCall(String handle, {bool isVideo = false}) {
    throw UnimplementedError();
  }

  Future<void> endCall() {
    throw UnimplementedError();
  }

  Future<void> reportIncomingCall({required String callerId, required String callerName, required String roomId}) {
    throw UnimplementedError();
  }

  Future<String?> getVoipToken() {
    throw UnimplementedError();
  }

  Future<void> inviteToCall({required String roomId, required String targetAccountId}) {
    throw UnimplementedError();
  }

  Future<void> startCallActivity({required String roomId, String? roomName, String? callerName}) {
    throw UnimplementedError();
  }

  Future<void> updateCallActivity({bool? isMuted, int? participantCount, int? elapsedSeconds}) {
    throw UnimplementedError();
  }

  Future<void> endCallActivity() {
    throw UnimplementedError();
  }

  Future<void> setCallConnected() {
    throw UnimplementedError();
  }
}
