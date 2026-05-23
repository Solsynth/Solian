import 'package:flutter_test/flutter_test.dart';
import 'package:island_desktop_presence/island_desktop_presence.dart';
import 'package:island_desktop_presence/island_desktop_presence_platform_interface.dart';
import 'package:island_desktop_presence/island_desktop_presence_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockIslandDesktopPresencePlatform
    with MockPlatformInterfaceMixin
    implements IslandDesktopPresencePlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final IslandDesktopPresencePlatform initialPlatform = IslandDesktopPresencePlatform.instance;

  test('$MethodChannelIslandDesktopPresence is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelIslandDesktopPresence>());
  });

  test('getPlatformVersion', () async {
    IslandDesktopPresence islandDesktopPresencePlugin = IslandDesktopPresence();
    MockIslandDesktopPresencePlatform fakePlatform = MockIslandDesktopPresencePlatform();
    IslandDesktopPresencePlatform.instance = fakePlatform;

    expect(await islandDesktopPresencePlugin.getPlatformVersion(), '42');
  });
}
