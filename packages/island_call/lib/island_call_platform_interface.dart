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

  Stream<Map<String, dynamic>> get onCallKitEvents {
    throw UnimplementedError();
  }

  Future<void> fulfillPendingAnswer() {
    throw UnimplementedError();
  }

  Future<void> failPendingAnswer() {
    throw UnimplementedError();
  }

  Future<void> reportRemoteEnded() {
    throw UnimplementedError();
  }

  Future<void> reportConnectionFailed() {
    throw UnimplementedError();
  }
}
