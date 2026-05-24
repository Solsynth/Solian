import 'island_desktop_presence_platform_interface.dart';

enum PresenceState { active, idle }

enum ExternalNowPlayingSource { music, spotify, other }

enum ExternalNowPlayingState { playing, paused, stopped }

class PresenceEvent {
  const PresenceEvent({required this.state, required this.idleTime});

  final PresenceState state;
  final Duration idleTime;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is PresenceEvent &&
        other.state == state &&
        other.idleTime == idleTime;
  }

  @override
  int get hashCode => Object.hash(state, idleTime);
}

class ExternalNowPlayingEvent {
  const ExternalNowPlayingEvent({
    required this.source,
    required this.state,
    this.sourceAppName,
    this.sourceBundleIdentifier,
    this.uniqueIdentifier,
    this.title,
    this.artist,
    this.album,
    this.duration,
    this.position,
    this.titleUrl,
    this.subtitleUrl,
    this.artworkUrl,
    this.artworkUrlLarge,
    this.artworkHash,
    this.catalogId,
  });

  final ExternalNowPlayingSource source;
  final ExternalNowPlayingState state;
  final String? sourceAppName;
  final String? sourceBundleIdentifier;
  final String? uniqueIdentifier;
  final String? title;
  final String? artist;
  final String? album;
  final Duration? duration;
  final Duration? position;
  final String? titleUrl;
  final String? subtitleUrl;
  final String? artworkUrl;
  final String? artworkUrlLarge;
  final String? artworkHash;
  final String? catalogId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ExternalNowPlayingEvent &&
        other.source == source &&
        other.state == state &&
        other.sourceAppName == sourceAppName &&
        other.sourceBundleIdentifier == sourceBundleIdentifier &&
        other.uniqueIdentifier == uniqueIdentifier &&
        other.title == title &&
        other.artist == artist &&
        other.album == album &&
        other.duration == duration &&
        other.position == position &&
        other.titleUrl == titleUrl &&
        other.subtitleUrl == subtitleUrl &&
        other.artworkUrl == artworkUrl &&
        other.artworkUrlLarge == artworkUrlLarge &&
        other.artworkHash == artworkHash &&
        other.catalogId == catalogId;
  }

  @override
  int get hashCode => Object.hash(
    source,
    state,
    sourceAppName,
    sourceBundleIdentifier,
    uniqueIdentifier,
    title,
    artist,
    album,
    duration,
    position,
    titleUrl,
    subtitleUrl,
    artworkUrl,
    artworkUrlLarge,
    artworkHash,
    catalogId,
  );
}

class IslandDesktopPresence {
  Stream<PresenceEvent> get events {
    return IslandDesktopPresencePlatform.instance.events;
  }

  Stream<ExternalNowPlayingEvent> get externalNowPlayingEvents {
    return IslandDesktopPresencePlatform.instance.externalNowPlayingEvents;
  }

  Future<Duration> getIdleTime() {
    return IslandDesktopPresencePlatform.instance.getIdleTime();
  }

  Future<void> startMonitoring({required Duration idleThreshold}) {
    return IslandDesktopPresencePlatform.instance.startMonitoring(
      idleThreshold: idleThreshold,
    );
  }

  Future<void> stopMonitoring() {
    return IslandDesktopPresencePlatform.instance.stopMonitoring();
  }

  Future<void> startExternalNowPlayingMonitoring({
    Duration pollInterval = const Duration(seconds: 2),
    String? executablePath,
  }) {
    return IslandDesktopPresencePlatform.instance
        .startExternalNowPlayingMonitoring(
          pollInterval: pollInterval,
          executablePath: executablePath,
        );
  }

  Future<void> stopExternalNowPlayingMonitoring() {
    return IslandDesktopPresencePlatform.instance
        .stopExternalNowPlayingMonitoring();
  }

  Future<void> setAuthToken({String? token, String? serverURL}) {
    return IslandDesktopPresencePlatform.instance.setAuthToken(
      token: token,
      serverURL: serverURL,
    );
  }
}
