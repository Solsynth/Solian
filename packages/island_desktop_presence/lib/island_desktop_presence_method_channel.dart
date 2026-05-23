import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'island_desktop_presence_platform_interface.dart';

/// An implementation of [IslandDesktopPresencePlatform] that uses method channels.
class MethodChannelIslandDesktopPresence extends IslandDesktopPresencePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('island_desktop_presence');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
