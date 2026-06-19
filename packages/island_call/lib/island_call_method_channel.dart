import 'package:flutter/services.dart';

import 'island_call_platform_interface.dart';

class MethodChannelIslandCall extends IslandCallPlatform {
  static const _channel = MethodChannel('island_call');
  static const _stateChannel = EventChannel('island_call/state');
  static const _participantsChannel = EventChannel('island_call/participants');

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
}
