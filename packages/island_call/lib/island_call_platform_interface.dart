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

  Future<void> startCallActivity({required String roomId, String? roomName, String? callerName}) {
    throw UnimplementedError();
  }

  Future<void> updateCallActivity({bool? isMuted, int? participantCount, int? elapsedSeconds}) {
    throw UnimplementedError();
  }

  Future<void> endCallActivity() {
    throw UnimplementedError();
  }
}
