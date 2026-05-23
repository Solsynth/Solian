
import 'island_desktop_presence_platform_interface.dart';

class IslandDesktopPresence {
  Future<String?> getPlatformVersion() {
    return IslandDesktopPresencePlatform.instance.getPlatformVersion();
  }
}
