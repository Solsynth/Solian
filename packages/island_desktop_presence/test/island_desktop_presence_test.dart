import 'package:flutter_test/flutter_test.dart';
import 'package:island_desktop_presence/island_desktop_presence.dart';
import 'package:island_desktop_presence/island_desktop_presence_method_channel.dart';
import 'package:island_desktop_presence/island_desktop_presence_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockIslandDesktopPresencePlatform
    with MockPlatformInterfaceMixin
    implements IslandDesktopPresencePlatform {
  @override
  Stream<PresenceEvent> get events => Stream<PresenceEvent>.value(
    const PresenceEvent(state: PresenceState.active, idleTime: Duration.zero),
  );

  @override
  Future<Duration> getIdleTime() =>
      Future<Duration>.value(const Duration(seconds: 42));

  @override
  Future<void> startMonitoring({required Duration idleThreshold}) async {}

  @override
  Future<void> stopMonitoring() async {}
}

void main() {
  final initialPlatform = IslandDesktopPresencePlatform.instance;

  test('$MethodChannelIslandDesktopPresence is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelIslandDesktopPresence>());
  });

  test('delegates getIdleTime', () async {
    final plugin = IslandDesktopPresence();
    IslandDesktopPresencePlatform.instance =
        MockIslandDesktopPresencePlatform();

    expect(await plugin.getIdleTime(), const Duration(seconds: 42));
  });

  test('delegates event stream', () async {
    final plugin = IslandDesktopPresence();
    IslandDesktopPresencePlatform.instance =
        MockIslandDesktopPresencePlatform();

    await expectLater(
      plugin.events,
      emits(
        isA<PresenceEvent>()
            .having((event) => event.state, 'state', PresenceState.active)
            .having((event) => event.idleTime, 'idleTime', Duration.zero),
      ),
    );
  });
}
