import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'island_desktop_presence_method_channel.dart';

abstract class IslandDesktopPresencePlatform extends PlatformInterface {
  /// Constructs a IslandDesktopPresencePlatform.
  IslandDesktopPresencePlatform() : super(token: _token);

  static final Object _token = Object();

  static IslandDesktopPresencePlatform _instance = MethodChannelIslandDesktopPresence();

  /// The default instance of [IslandDesktopPresencePlatform] to use.
  ///
  /// Defaults to [MethodChannelIslandDesktopPresence].
  static IslandDesktopPresencePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [IslandDesktopPresencePlatform] when
  /// they register themselves.
  static set instance(IslandDesktopPresencePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
