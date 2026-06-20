import 'package:flutter/services.dart';

import 'island_call_platform_interface.dart';

class MethodChannelIslandCall extends IslandCallPlatform {
  static const _channel = MethodChannel('island_call');
  static const _stateChannel = EventChannel('island_call/state');
  static const _participantsChannel = EventChannel('island_call/participants');
  static const _callKitEventsChannel = EventChannel('island_call/callkit_events');

  @override
  Future<void> initialize({required String serverUrl, required String authToken}) {
    return _channel.invokeMethod('initialize', {
      'serverUrl': serverUrl,
      'authToken': authToken,
    });
  }

  @override
  Future<void> joinRoom(String roomId) {
    return _channel.invokeMethod('joinRoom', {'roomId': roomId});
  }

  @override
  Future<void> leaveRoom() => _channel.invokeMethod('leaveRoom');

  @override
  Future<void> toggleMic() => _channel.invokeMethod('toggleMic');

  @override
  Future<void> toggleCamera() => _channel.invokeMethod('toggleCamera');

  @override
  Future<void> toggleSpeaker() => _channel.invokeMethod('toggleSpeaker');

  @override
  Future<void> toggleViewMode() => _channel.invokeMethod('toggleViewMode');

  @override
  Future<void> showExpandedView() => _channel.invokeMethod('showExpandedView');

  @override
  Future<void> dismissExpandedView() => _channel.invokeMethod('dismissExpandedView');

  @override
  Stream<Map<String, dynamic>> get onStateChanged =>
      _stateChannel.receiveBroadcastStream().map((e) => Map<String, dynamic>.from(e as Map));

  @override
  Stream<List<Map<String, dynamic>>> get onParticipantsChanged =>
      _participantsChannel.receiveBroadcastStream().map((e) {
        final list = e as List;
        return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      });

  @override
  Future<void> startCall(String handle, {bool isVideo = false}) =>
      _channel.invokeMethod('startCall', {'handle': handle, 'isVideo': isVideo});

  @override
  Future<void> endCall() => _channel.invokeMethod('endCall');

  @override
  Future<void> reportIncomingCall({required String callerId, required String callerName, required String roomId}) =>
      _channel.invokeMethod('reportIncomingCall', {
        'callerId': callerId,
        'callerName': callerName,
        'roomId': roomId,
      });

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
  Stream<Map<String, dynamic>> get onCallKitEvents =>
      _callKitEventsChannel.receiveBroadcastStream().map((e) => Map<String, dynamic>.from(e as Map));

  @override
  Future<void> fulfillPendingAnswer() => _channel.invokeMethod('fulfillPendingAnswer');

  @override
  Future<void> failPendingAnswer() => _channel.invokeMethod('failPendingAnswer');

  @override
  Future<void> reportRemoteEnded() => _channel.invokeMethod('reportRemoteEnded');

  @override
  Future<void> reportConnectionFailed() => _channel.invokeMethod('reportConnectionFailed');
}
