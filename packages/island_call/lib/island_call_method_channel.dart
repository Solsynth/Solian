import 'package:flutter/services.dart';

import 'island_call_platform_interface.dart';

class MethodChannelIslandCall extends IslandCallPlatform {
  static const _channel = MethodChannel('island_call');

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
}
