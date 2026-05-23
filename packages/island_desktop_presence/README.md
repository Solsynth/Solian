# island_desktop_presence

Desktop presence plugin for Flutter.

This package is responsible for OS-level presence detection only:

- idle time detection
- active/idle transitions

It does not handle:

- WebSocket sync
- account state
- business logic
- server-side aggregation

Current v1 scope:

- macOS: supported
- Windows: supported
- Linux: X11-based idle detection

## API

```dart
enum PresenceState {
  active,
  idle,
}

class PresenceEvent {
  final PresenceState state;
  final Duration idleTime;
}

class IslandDesktopPresence {
  Stream<PresenceEvent> get events;
  Future<Duration> getIdleTime();
  Future<void> startMonitoring({
    required Duration idleThreshold,
  });
  Future<void> stopMonitoring();
}
```

## Basic usage

```dart
import 'dart:async';

import 'package:island_desktop_presence/island_desktop_presence.dart';

final presence = IslandDesktopPresence();
StreamSubscription<PresenceEvent>? subscription;

Future<void> startPresence() async {
  subscription = presence.events.listen((event) {
    switch (event.state) {
      case PresenceState.active:
        print('User is active');
        break;
      case PresenceState.idle:
        print('User is idle for ${event.idleTime.inSeconds}s');
        break;
    }
  });

  await presence.startMonitoring(
    idleThreshold: const Duration(minutes: 5),
  );
}

Future<void> stopPresence() async {
  await subscription?.cancel();
  await presence.stopMonitoring();
}
```

## WebSocket example

Keep transport outside the plugin. The app listens to normalized events and sends
its own packet:

```dart
import 'dart:convert';

import 'package:island/core/websocket.dart';
import 'package:island_desktop_presence/island_desktop_presence.dart';

final presence = IslandDesktopPresence();

await presence.startMonitoring(
  idleThreshold: const Duration(minutes: 5),
);

presence.events.listen((event) {
  final isIdle = event.state == PresenceState.idle;

  websocketNotifier.sendMessage(
    jsonEncode(
      WebSocketPacket(
        endpoint: 'passport',
        type: 'status.idle',
        data: {'is_idle': isIdle},
      ),
    ),
  );
});
```

## Notes

- Native platforms poll idle state every few seconds.
- The native layer keeps a local active/idle state machine and emits only on
  normalized transitions.
- `startMonitoring` emits an initial snapshot when monitoring begins.
