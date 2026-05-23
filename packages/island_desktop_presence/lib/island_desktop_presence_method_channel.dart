import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'island_desktop_presence.dart';
import 'island_desktop_presence_platform_interface.dart';

class MethodChannelIslandDesktopPresence extends IslandDesktopPresencePlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('island_desktop_presence');

  @visibleForTesting
  final eventChannel = const EventChannel('island_desktop_presence/events');

  Stream<PresenceEvent>? _events;

  @override
  Stream<PresenceEvent> get events {
    return _events ??= eventChannel
        .receiveBroadcastStream()
        .map(_decodeEvent)
        .distinct(_sameEvent);
  }

  @override
  Future<Duration> getIdleTime() async {
    final milliseconds = await methodChannel.invokeMethod<int>('getIdleTime');
    if (milliseconds == null) {
      throw PlatformException(
        code: 'null_idle_time',
        message: 'Native platform returned a null idle time.',
      );
    }
    return Duration(milliseconds: milliseconds);
  }

  @override
  Future<void> startMonitoring({required Duration idleThreshold}) {
    return methodChannel.invokeMethod<void>('startMonitoring', <String, Object>{
      'idleThresholdMilliseconds': idleThreshold.inMilliseconds,
    });
  }

  @override
  Future<void> stopMonitoring() {
    return methodChannel.invokeMethod<void>('stopMonitoring');
  }

  PresenceEvent _decodeEvent(dynamic event) {
    if (event is! Map<Object?, Object?>) {
      throw PlatformException(
        code: 'invalid_event',
        message: 'Presence event payload must be a map.',
      );
    }

    final rawState = event['state'];
    if (rawState is! String) {
      throw PlatformException(
        code: 'invalid_event_state',
        message: 'Presence event is missing a valid state.',
      );
    }

    final rawIdleSeconds = event['idle_seconds'];
    final idleSeconds = switch (rawIdleSeconds) {
      null => 0,
      int value => value,
      double value => value.round(),
      _ => throw PlatformException(
        code: 'invalid_event_idle_time',
        message: 'Presence event has an invalid idle_seconds value.',
      ),
    };

    return PresenceEvent(
      state: _decodeState(rawState),
      idleTime: Duration(seconds: idleSeconds),
    );
  }

  PresenceState _decodeState(String state) {
    return switch (state) {
      'active' => PresenceState.active,
      'idle' => PresenceState.idle,
      _ => throw PlatformException(
        code: 'invalid_event_state',
        message: 'Unsupported presence state: $state',
      ),
    };
  }

  bool _sameEvent(PresenceEvent previous, PresenceEvent next) {
    return previous.state == next.state && previous.idleTime == next.idleTime;
  }
}
