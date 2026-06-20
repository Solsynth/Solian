import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

import 'island_call_platform_interface.dart';

export 'island_call_platform_interface.dart';
export 'invite_sheet.dart';

class IslandCall {
  IslandCall._();
  static final IslandCallPlatform _p = IslandCallPlatform.instance;

  /// Initialize with server credentials. Call once on app startup.
  static Future<void> initialize({required String serverUrl, required String authToken}) =>
      _p.initialize(serverUrl: serverUrl, authToken: authToken);

  /// Start an outgoing call via CallKit. [handle] identifies the callee/room.
  static Future<void> startCall(String handle, {bool isVideo = false}) => _p.startCall(handle, isVideo: isVideo);

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

  /// Set the call as connected (fulfills the pending answer action).
  static Future<void> setCallConnected() => _p.setCallConnected();

  /// Listen to CallKit events from the package.
  static Stream<CallEvent?> get onCallKitEvent => FlutterCallkitIncoming.onEvent;
}
