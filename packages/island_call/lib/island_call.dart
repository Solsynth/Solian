import 'island_call_platform_interface.dart';

export 'island_call_platform_interface.dart';
export 'invite_sheet.dart';

class IslandCall {
  IslandCall._();
  static final IslandCallPlatform _p = IslandCallPlatform.instance;

  /// Initialize with server credentials. Call once on app startup.
  static Future<void> initialize({required String serverUrl, required String authToken}) =>
      _p.initialize(serverUrl: serverUrl, authToken: authToken);

  /// Join a call room. Triggers native UI presentation.
  static Future<void> joinRoom(String roomId) => _p.joinRoom(roomId);

  /// Leave the current call and dismiss native UI.
  static Future<void> leaveRoom() => _p.leaveRoom();

  static Future<void> toggleMic() => _p.toggleMic();
  static Future<void> toggleCamera() => _p.toggleCamera();
  static Future<void> toggleSpeaker() => _p.toggleSpeaker();
  static Future<void> toggleViewMode() => _p.toggleViewMode();

  /// Show the expanded call view (iOS sheet / macOS window).
  static Future<void> showExpandedView() => _p.showExpandedView();

  /// Dismiss expanded view; floating widget persists on iOS.
  static Future<void> dismissExpandedView() => _p.dismissExpandedView();

  /// Call state changes: isConnected, isReconnecting, duration, etc.
  static Stream<Map<String, dynamic>> get onStateChanged => _p.onStateChanged;

  /// Participant list changes.
  static Stream<List<Map<String, dynamic>>> get onParticipantsChanged => _p.onParticipantsChanged;

  /// Start an outgoing call via CallKit. [handle] identifies the callee/room.
  static Future<void> startCall(String handle) => _p.startCall(handle);

  /// End the current call via CallKit.
  static Future<void> endCall() => _p.endCall();

  /// Report an incoming call to CallKit (for server-triggered notifications).
  static Future<void> reportIncomingCall({required String callerId, required String callerName, required String roomId}) =>
      _p.reportIncomingCall(callerId: callerId, callerName: callerName, roomId: roomId);

  /// Get the VoIP push token (iOS only, null on macOS).
  static Future<String?> getVoipToken() => _p.getVoipToken();

  /// Invite a user to the current call via VoIP push.
  static Future<void> inviteToCall({required String roomId, required String targetAccountId}) =>
      _p.inviteToCall(roomId: roomId, targetAccountId: targetAccountId);

  /// Start a Live Activity for an ongoing call.
  static Future<void> startCallActivity({required String roomId, String? roomName, String? callerName}) =>
      _p.startCallActivity(roomId: roomId, roomName: roomName, callerName: callerName);

  /// Update the Live Activity with current call state.
  static Future<void> updateCallActivity({bool? isMuted, int? participantCount, int? elapsedSeconds}) =>
      _p.updateCallActivity(isMuted: isMuted, participantCount: participantCount, elapsedSeconds: elapsedSeconds);

  /// End the Live Activity when call ends.
  static Future<void> endCallActivity() => _p.endCallActivity();
}
