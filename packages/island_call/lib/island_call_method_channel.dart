import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

import 'island_call_platform_interface.dart';

class MethodChannelIslandCall extends IslandCallPlatform {
  static const _channel = MethodChannel('island_call');

  @override
  Future<void> initialize({required String serverUrl, required String authToken}) {
    return _channel.invokeMethod('initialize', {
      'serverUrl': serverUrl,
      'authToken': authToken,
    });
  }

  @override
  Future<void> startCall(String handle, {bool isVideo = false}) async {
    final params = CallKitParams(
      id: handle,
      nameCaller: 'Solian',
      appName: 'Solian',
      handle: handle,
      type: isVideo ? 1 : 0,
      extra: {'roomId': handle},
    );
    await FlutterCallkitIncoming.startCall(params);
  }

  @override
  Future<void> endCall() async {
    // Get current call ID from the state
    await FlutterCallkitIncoming.endAllCalls();
  }

  @override
  Future<void> reportIncomingCall({required String callerId, required String callerName, required String roomId}) async {
    final params = CallKitParams(
      id: roomId,
      nameCaller: callerName,
      appName: 'Solian',
      handle: roomId,
      type: 0,
      extra: {'callerId': callerId, 'roomId': roomId},
    );
    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  @override
  Future<String?> getVoipToken() async {
    final result = await _channel.invokeMethod('getVoipToken');
    return result as String?;
  }

  @override
  Future<void> inviteToCall({required String roomId, required String targetAccountId}) =>
      _channel.invokeMethod('inviteToCall', {
        'roomId': roomId,
        'targetAccountId': targetAccountId,
      });

  @override
  Future<void> startCallActivity({required String roomId, String? roomName, String? callerName}) =>
      _channel.invokeMethod('startCallActivity', {
        'roomId': roomId,
        'roomName': roomName ?? 'Voice Call',
        'callerName': callerName ?? 'Solian',
      });

  @override
  Future<void> updateCallActivity({bool? isMuted, int? participantCount, int? elapsedSeconds}) =>
      _channel.invokeMethod('updateCallActivity', {
        'isMuted': isMuted ?? false,
        'participantCount': participantCount ?? 1,
        'elapsedSeconds': elapsedSeconds ?? 0,
      });

  @override
  Future<void> endCallActivity() => _channel.invokeMethod('endCallActivity');

  @override
  Future<void> setCallConnected() async {
    await FlutterCallkitIncoming.setCallConnected('');
  }
}
