import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'island_desktop_presence.dart';
import 'island_desktop_presence_platform_interface.dart';

class MethodChannelIslandDesktopPresence extends IslandDesktopPresencePlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('island_desktop_presence');

  @visibleForTesting
  final eventChannel = const EventChannel('island_desktop_presence/events');

  @visibleForTesting
  final externalNowPlayingChannel = const EventChannel(
    'island_desktop_presence/external_now_playing',
  );

  Stream<PresenceEvent>? _events;
  Stream<ExternalNowPlayingEvent>? _externalNowPlayingEvents;

  @override
  Stream<PresenceEvent> get events {
    return _events ??= eventChannel
        .receiveBroadcastStream()
        .map(_decodeEvent)
        .distinct(_samePresenceEvent);
  }

  @override
  Stream<ExternalNowPlayingEvent> get externalNowPlayingEvents {
    return _externalNowPlayingEvents ??= externalNowPlayingChannel
        .receiveBroadcastStream()
        .map(_decodeExternalNowPlayingEvent)
        .distinct(_sameExternalNowPlayingEvent);
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

  @override
  Future<void> startExternalNowPlayingMonitoring({
    required Duration pollInterval,
    String? executablePath,
  }) {
    final arguments = <String, Object>{
      'pollIntervalMilliseconds': pollInterval.inMilliseconds,
    };
    if (executablePath != null && executablePath.isNotEmpty) {
      arguments['executablePath'] = executablePath;
    }
    return methodChannel.invokeMethod<void>(
      'startExternalNowPlayingMonitoring',
      arguments,
    );
  }

  @override
  Future<void> stopExternalNowPlayingMonitoring() {
    return methodChannel.invokeMethod<void>('stopExternalNowPlayingMonitoring');
  }

  @override
  Future<void> setAuthToken({String? token, String? serverURL}) {
    return methodChannel.invokeMethod<void>('setAuthToken', <String, Object?>{
      'token': token,
      'serverURL': serverURL,
    });
  }

  @override
  Future<Map<String, dynamic>?> debugNowPlaying({String? executablePath}) async {
    final arguments = <String, Object>{};
    if (executablePath != null && executablePath.isNotEmpty) {
      arguments['executablePath'] = executablePath;
    }
    final result = await methodChannel.invokeMethod<Map<Object?, Object?>>(
      'debugNowPlaying',
      arguments.isNotEmpty ? arguments : null,
    );
    if (result == null) return null;
    return result.map((key, value) => MapEntry(key.toString(), value));
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

  ExternalNowPlayingEvent _decodeExternalNowPlayingEvent(dynamic event) {
    if (event is! Map<Object?, Object?>) {
      throw PlatformException(
        code: 'invalid_now_playing_event',
        message: 'External now playing event payload must be a map.',
      );
    }

    final rawSource = event['source'];
    final rawState = event['state'];
    if (rawSource is! String || rawState is! String) {
      throw PlatformException(
        code: 'invalid_now_playing_event',
        message: 'External now playing event is missing source or state.',
      );
    }

    return ExternalNowPlayingEvent(
      source: _decodeExternalSource(rawSource),
      state: _decodeExternalState(rawState),
      providerKey: event['provider_key'] as String?,
      providerReferenceId: event['provider_reference_id'] as String?,
      sourceAppName: event['source_app_name'] as String?,
      sourceBundleIdentifier: event['source_bundle_identifier'] as String?,
      uniqueIdentifier: event['unique_identifier'] as String?,
      title: event['title'] as String?,
      artist: event['artist'] as String?,
      album: event['album'] as String?,
      playbackRate: _decodeOptionalDouble(event['playback_rate']),
      duration: _decodeOptionalDuration(event['duration_seconds']),
      position: _decodeOptionalDuration(event['position_seconds']),
      titleUrl: event['title_url'] as String?,
      subtitleUrl: event['subtitle_url'] as String?,
      artworkUrl: event['artwork_url'] as String?,
      artworkUrlLarge: event['artwork_url_large'] as String?,
      artworkHash: event['artwork_hash'] as String?,
      catalogId: event['catalog_id'] as String?,
    );
  }

  Duration? _decodeOptionalDuration(Object? rawValue) {
    return switch (rawValue) {
      null => null,
      int value => Duration(milliseconds: (value * 1000)),
      double value => Duration(milliseconds: (value * 1000).round()),
      _ => throw PlatformException(
        code: 'invalid_now_playing_duration',
        message: 'External now playing duration fields must be numeric.',
      ),
    };
  }

  double? _decodeOptionalDouble(Object? rawValue) {
    return switch (rawValue) {
      null => null,
      int value => value.toDouble(),
      double value => value,
      _ => throw PlatformException(
        code: 'invalid_now_playing_number',
        message: 'External now playing numeric fields must be numeric.',
      ),
    };
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

  ExternalNowPlayingSource _decodeExternalSource(String source) {
    return switch (source) {
      'music' => ExternalNowPlayingSource.music,
      'spotify' => ExternalNowPlayingSource.spotify,
      'other' => ExternalNowPlayingSource.other,
      _ => throw PlatformException(
        code: 'invalid_now_playing_source',
        message: 'Unsupported external now playing source: $source',
      ),
    };
  }

  ExternalNowPlayingState _decodeExternalState(String state) {
    return switch (state) {
      'playing' => ExternalNowPlayingState.playing,
      'paused' => ExternalNowPlayingState.paused,
      'stopped' => ExternalNowPlayingState.stopped,
      _ => throw PlatformException(
        code: 'invalid_now_playing_state',
        message: 'Unsupported external now playing state: $state',
      ),
    };
  }

  bool _samePresenceEvent(PresenceEvent previous, PresenceEvent next) {
    return previous.state == next.state && previous.idleTime == next.idleTime;
  }

  bool _sameExternalNowPlayingEvent(
    ExternalNowPlayingEvent previous,
    ExternalNowPlayingEvent next,
  ) {
    return previous == next;
  }
}
