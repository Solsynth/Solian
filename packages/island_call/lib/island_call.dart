import 'island_call_platform_interface.dart';

export 'island_call_platform_interface.dart';

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
}
