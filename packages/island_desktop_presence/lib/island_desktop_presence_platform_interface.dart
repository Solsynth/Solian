import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'island_desktop_presence.dart';
import 'island_desktop_presence_method_channel.dart';

abstract class IslandDesktopPresencePlatform extends PlatformInterface {
  IslandDesktopPresencePlatform() : super(token: _token);

  static final Object _token = Object();

  static IslandDesktopPresencePlatform _instance =
      MethodChannelIslandDesktopPresence();

  static IslandDesktopPresencePlatform get instance => _instance;

  static set instance(IslandDesktopPresencePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Stream<PresenceEvent> get events {
    throw UnimplementedError('events has not been implemented.');
  }

  Future<Duration> getIdleTime() {
    throw UnimplementedError('getIdleTime() has not been implemented.');
  }

  Future<void> startMonitoring({required Duration idleThreshold}) {
    throw UnimplementedError('startMonitoring() has not been implemented.');
  }

  Future<void> stopMonitoring() {
    throw UnimplementedError('stopMonitoring() has not been implemented.');
  }
}
