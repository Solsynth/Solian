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
  const externalNowPlayingChannel = EventChannel(
    'island_desktop_presence/external_now_playing',
  );
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
        case 'startExternalNowPlayingMonitoring':
        case 'stopExternalNowPlayingMonitoring':
          return null;
        default:
          throw PlatformException(code: 'unimplemented');
      }
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(methodChannel, null);
    messenger.setMockStreamHandler(eventChannel, null);
    messenger.setMockStreamHandler(externalNowPlayingChannel, null);
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

  test('startExternalNowPlayingMonitoring forwards poll interval', () async {
    await platform.startExternalNowPlayingMonitoring(
      pollInterval: const Duration(seconds: 2),
      executablePath: '/opt/homebrew/bin/nowplaying-cli',
    );

    expect(methodCalls, hasLength(1));
    expect(methodCalls.single.method, 'startExternalNowPlayingMonitoring');
    expect(methodCalls.single.arguments, <String, Object>{
      'pollIntervalMilliseconds': 2000,
      'executablePath': '/opt/homebrew/bin/nowplaying-cli',
      'disableAppleMusicIntegration': false,
    });
  });

  test('stopExternalNowPlayingMonitoring invokes native method', () async {
    await platform.stopExternalNowPlayingMonitoring();

    expect(methodCalls, hasLength(1));
    expect(methodCalls.single.method, 'stopExternalNowPlayingMonitoring');
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

  test(
    'external now playing events decode payloads and suppress duplicates',
    () async {
      messenger.setMockStreamHandler(
        externalNowPlayingChannel,
        _MockPresenceStreamHandler(<Object?>[
          <String, Object>{
            'source': 'music',
            'state': 'playing',
            'provider_key': 'apple_music',
            'provider_reference_id': '6766820661',
            'source_bundle_identifier': 'com.apple.Music',
            'unique_identifier': '6766820661',
            'title': 'Track',
            'artist': 'Artist',
            'album': 'Album',
            'playback_rate': 1.0,
            'duration_seconds': 180.0,
            'position_seconds': 12.5,
            'title_url': 'https://music.apple.com/us/song/track/6766820661',
            'subtitle_url': 'https://music.apple.com/us/artist/artist/1234',
            'artwork_url': 'https://island.test/artwork-small.jpg',
            'artwork_url_large': 'https://island.test/artwork-large.jpg',
            'artwork_hash': 'sha256:abc123',
            'catalog_id': '6766820661',
          },
          <String, Object>{
            'source': 'music',
            'state': 'playing',
            'provider_key': 'apple_music',
            'provider_reference_id': '6766820661',
            'source_bundle_identifier': 'com.apple.Music',
            'unique_identifier': '6766820661',
            'title': 'Track',
            'artist': 'Artist',
            'album': 'Album',
            'playback_rate': 1.0,
            'duration_seconds': 180.0,
            'position_seconds': 12.5,
            'title_url': 'https://music.apple.com/us/song/track/6766820661',
            'subtitle_url': 'https://music.apple.com/us/artist/artist/1234',
            'artwork_url': 'https://island.test/artwork-small.jpg',
            'artwork_url_large': 'https://island.test/artwork-large.jpg',
            'artwork_hash': 'sha256:abc123',
            'catalog_id': '6766820661',
          },
          <String, Object>{
            'source': 'music',
            'state': 'paused',
            'provider_key': 'apple_music',
            'provider_reference_id': '6766820661',
            'source_bundle_identifier': 'com.apple.Music',
            'unique_identifier': '6766820661',
            'title': 'Track',
            'artist': 'Artist',
            'playback_rate': 0.0,
            'title_url': 'https://music.apple.com/us/song/track/6766820661',
            'subtitle_url': 'https://music.apple.com/us/artist/artist/1234',
            'artwork_url': 'https://island.test/artwork-small.jpg',
            'artwork_url_large': 'https://island.test/artwork-large.jpg',
            'artwork_hash': 'sha256:def456',
            'catalog_id': '6766820661',
          },
        ]),
      );

      final events = <ExternalNowPlayingEvent>[];
      final subscription = platform.externalNowPlayingEvents.listen(events.add);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await subscription.cancel();

      expect(events, <ExternalNowPlayingEvent>[
        const ExternalNowPlayingEvent(
          source: ExternalNowPlayingSource.music,
          state: ExternalNowPlayingState.playing,
          providerKey: 'apple_music',
          providerReferenceId: '6766820661',
          sourceBundleIdentifier: 'com.apple.Music',
          uniqueIdentifier: '6766820661',
          title: 'Track',
          artist: 'Artist',
          album: 'Album',
          playbackRate: 1.0,
          duration: Duration(seconds: 180),
          position: Duration(milliseconds: 12500),
          titleUrl: 'https://music.apple.com/us/song/track/6766820661',
          subtitleUrl: 'https://music.apple.com/us/artist/artist/1234',
          artworkUrl: 'https://island.test/artwork-small.jpg',
          artworkUrlLarge: 'https://island.test/artwork-large.jpg',
          artworkHash: 'sha256:abc123',
          catalogId: '6766820661',
        ),
        const ExternalNowPlayingEvent(
          source: ExternalNowPlayingSource.music,
          state: ExternalNowPlayingState.paused,
          providerKey: 'apple_music',
          providerReferenceId: '6766820661',
          sourceBundleIdentifier: 'com.apple.Music',
          uniqueIdentifier: '6766820661',
          title: 'Track',
          artist: 'Artist',
          playbackRate: 0.0,
          titleUrl: 'https://music.apple.com/us/song/track/6766820661',
          subtitleUrl: 'https://music.apple.com/us/artist/artist/1234',
          artworkUrl: 'https://island.test/artwork-small.jpg',
          artworkUrlLarge: 'https://island.test/artwork-large.jpg',
          artworkHash: 'sha256:def456',
          catalogId: '6766820661',
        ),
      ]);
    },
  );
}
