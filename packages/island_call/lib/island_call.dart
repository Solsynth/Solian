import 'island_call_platform_interface.dart';

export 'island_call_platform_interface.dart';

class IslandCall {
  IslandCall._();
  static final IslandCallPlatform _p = IslandCallPlatform.instance;

  /// Start a Live Activity for an ongoing call.
  static Future<void> startCallActivity({
    required String roomId,
    String? roomName,
    String? callerName,
  }) => _p.startCallActivity(
    roomId: roomId,
    roomName: roomName,
    callerName: callerName,
  );

  /// Update the Live Activity with current call state.
  static Future<void> updateCallActivity({
    bool? isMuted,
    int? participantCount,
    int? elapsedSeconds,
  }) => _p.updateCallActivity(
    isMuted: isMuted,
    participantCount: participantCount,
    elapsedSeconds: elapsedSeconds,
  );

  /// End the Live Activity when call ends.
  static Future<void> endCallActivity() => _p.endCallActivity();
}
