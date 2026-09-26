import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';

void main() {
  const idleSettings = IpOverrideSettings(enabled: false, overrides: []);
  const relay = RelayRoute(
    id: 'jp-01',
    host: 'relay-jp.example',
    port: 7443,
    region: 'jp',
  );

  test('leaves the platform transport alone when nothing is configured', () {
    expect(
      createAppHttpOverrides(
        mode: IpOverrideMode.off,
        settings: idleSettings,
        domains: const [],
        serverUrl: 'https://api.solian.app',
      ),
      isNull,
    );
  });

  test('installs a connection factory once a relay is selected', () {
    expect(
      createAppHttpOverrides(
        mode: IpOverrideMode.off,
        settings: idleSettings,
        domains: const [],
        serverUrl: 'https://api.solian.app',
        relay: relay,
      ),
      isA<HttpOverrides>(),
    );
    expect(
      createAppHttpOverrides(
        mode: IpOverrideMode.off,
        settings: idleSettings,
        domains: const [],
        serverUrl: 'https://api.solian.app',
        relay: const RelayRoute(id: 'broken', host: '', port: 0),
      ),
      isNull,
      reason: 'an unusable route must not install anything',
    );
  });
}
