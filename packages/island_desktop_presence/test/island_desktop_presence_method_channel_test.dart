import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_desktop_presence/island_desktop_presence.dart';
import 'package:island_desktop_presence/island_desktop_presence_method_channel.dart';

class _MockPresenceStreamHandler implements MockStreamHandler {
  _MockPresenceStreamHandler(this.events);

  final List<Object?> events;

  @override
  Future<void> onCancel(Object? arguments) async {}

  @override
  Future<void> onListen(
    Object? arguments,
    MockStreamHandlerEventSink eventsSink,
  ) async {
    for (final event in events) {
      eventsSink.success(event);
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelIslandDesktopPresence();
  const methodChannel = MethodChannel('island_desktop_presence');
  const eventChannel = EventChannel('island_desktop_presence/events');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  final methodCalls = <MethodCall>[];

  setUp(() {
    methodCalls.clear();
    messenger.setMockMethodCallHandler(methodChannel, (methodCall) async {
      methodCalls.add(methodCall);
      switch (methodCall.method) {
        case 'getIdleTime':
          return 42000;
        case 'startMonitoring':
        case 'stopMonitoring':
          return null;
        default:
          throw PlatformException(code: 'unimplemented');
      }
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(methodChannel, null);
    messenger.setMockStreamHandler(eventChannel, null);
  });

  test('getIdleTime decodes milliseconds', () async {
    expect(await platform.getIdleTime(), const Duration(seconds: 42));
  });

  test('startMonitoring forwards threshold in milliseconds', () async {
    await platform.startMonitoring(idleThreshold: const Duration(minutes: 5));

    expect(methodCalls, hasLength(1));
    expect(methodCalls.single.method, 'startMonitoring');
    expect(methodCalls.single.arguments, <String, Object>{
      'idleThresholdMilliseconds': 300000,
    });
  });

  test('stopMonitoring invokes native method', () async {
    await platform.stopMonitoring();

    expect(methodCalls, hasLength(1));
    expect(methodCalls.single.method, 'stopMonitoring');
  });

  test('events decode payloads and suppress duplicate events', () async {
    messenger.setMockStreamHandler(
      eventChannel,
      _MockPresenceStreamHandler(<Object?>[
        <String, Object>{'state': 'active', 'idle_seconds': 0},
        <String, Object>{'state': 'active', 'idle_seconds': 0},
        <String, Object>{'state': 'idle', 'idle_seconds': 342},
      ]),
    );

    final events = <PresenceEvent>[];
    final subscription = platform.events.listen(events.add);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await subscription.cancel();

    expect(events, <PresenceEvent>[
      const PresenceEvent(state: PresenceState.active, idleTime: Duration.zero),
      const PresenceEvent(
        state: PresenceState.idle,
        idleTime: Duration(seconds: 342),
      ),
    ]);
  });
}
