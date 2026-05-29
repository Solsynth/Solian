import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/activity/activity_rpc.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/websocket.dart';
import 'package:island_desktop_presence/island_desktop_presence.dart';
import 'package:logging/logging.dart';

final desktopPresenceProvider = Provider<DesktopPresenceService?>((ref) {
  if (kIsWeb) {
    return null;
  }
  if (!(Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    return null;
  }

  final service = DesktopPresenceService(ref);
  service.start();
  ref.onDispose(service.dispose);
  return service;
});

final desktopNowPlayingProvider = Provider<DesktopNowPlayingService?>((ref) {
  if (kIsWeb || !(Platform.isMacOS || Platform.isWindows)) {
    return null;
  }

  final service = DesktopNowPlayingService(ref);
  service.start();
  ref.onDispose(service.dispose);
  return service;
});

class DesktopPresenceService {
  DesktopPresenceService(this._ref);

  static const Duration _idleThreshold = Duration(minutes: 5);

  final Ref _ref;
  final IslandDesktopPresence _presence = IslandDesktopPresence();

  StreamSubscription<PresenceEvent>? _presenceSubscription;
  StreamSubscription<WebSocketState>? _websocketSubscription;

  bool? _lastObservedIdle;
  bool? _lastSentIdle;
  bool _started = false;

  Future<void> start() async {
    if (_started) {
      return;
    }
    _started = true;

    _presenceSubscription = _presence.events.listen(
      _handlePresenceEvent,
      onError: (Object error, StackTrace stackTrace) {
        Logger.root.severe(
          '[DesktopPresence] Presence event stream failed',
          error,
          stackTrace,
        );
      },
    );

    _websocketSubscription = _ref.read(websocketProvider).statusStream.listen((
      next,
    ) {
      if (next.maybeWhen(connected: () => true, orElse: () => false)) {
        _sendIdleStatus(force: true);
      }
    });

    try {
      await _presence.startMonitoring(idleThreshold: _idleThreshold);
    } catch (error, stackTrace) {
      Logger.root.severe(
        '[DesktopPresence] Failed to start idle monitoring',
        error,
        stackTrace,
      );
    }
  }

  void _handlePresenceEvent(PresenceEvent event) {
    final isIdle = event.state == PresenceState.idle;
    _lastObservedIdle = isIdle;
    _sendIdleStatus();
  }

  void _sendIdleStatus({bool force = false}) {
    final isIdle = _lastObservedIdle;
    if (isIdle == null) {
      return;
    }

    if (!isIdle && _lastSentIdle == null) {
      return;
    }

    final isConnected = _ref
        .read(websocketStateProvider)
        .maybeWhen(connected: () => true, orElse: () => false);
    if (!isConnected) {
      return;
    }

    if (!force && _lastSentIdle == isIdle) {
      return;
    }

    final notifier = _ref.read(websocketStateProvider.notifier);
    Logger.root.info('[DesktopPresence] Sending idle status: $isIdle');
    notifier.sendMessage(
      jsonEncode(
        WebSocketPacket(
          type: 'status.idle',
          data: {'is_idle': isIdle},
          endpoint: 'passport',
        ),
      ),
    );
    _lastSentIdle = isIdle;
  }

  Future<void> dispose() async {
    await _presenceSubscription?.cancel();
    await _websocketSubscription?.cancel();
    _presenceSubscription = null;
    _websocketSubscription = null;
    _started = false;
    _lastObservedIdle = null;
    _lastSentIdle = null;
    try {
      await _presence.stopMonitoring();
    } catch (error, stackTrace) {
      Logger.root.warning(
        '[DesktopPresence] Failed to stop idle monitoring',
        error,
        stackTrace,
      );
    }
  }
}

class DesktopNowPlayingService {
  DesktopNowPlayingService(this._ref);

  static const Duration _pollInterval = Duration(seconds: 2);
  static const Duration _pauseClearDebounce = Duration(minutes: 1);
  static const int _leaseMinutes = 5;
  static const String _manualIdPrefix = 'desktop:now_playing';
  static const String _fixedManualId = 'desktop:now_playing:fixed';

  final Ref _ref;
  final IslandDesktopPresence _presence = IslandDesktopPresence();

  String? _manualId;
  StreamSubscription<ExternalNowPlayingEvent>? _subscription;
  Timer? _renewalTimer;
  Timer? _pauseClearTimer;
  Timer? _tokenSyncTimer;
  Map<String, dynamic>? _currentActivityData;
  String? _currentActivityFingerprint;
  String? _currentActivityManualId;
  bool _started = false;

  Future<void> start() async {
    if (_started) {
      return;
    }
    _started = true;

    _subscription = _presence.externalNowPlayingEvents.listen(
      _handleEvent,
      onError: (Object error, StackTrace stackTrace) {
        Logger.root.severe(
          '[DesktopNowPlaying] Event stream failed',
          error,
          stackTrace,
        );
      },
    );

    try {
      final executablePath = _ref.read(desktopNowPlayingCliPathProvider);
      Logger.root.info('[DesktopNowPlaying] Starting macOS monitoring');
      await _syncAuthToken();
      _startTokenSync();
      await _presence.startExternalNowPlayingMonitoring(
        pollInterval: _pollInterval,
        executablePath: executablePath,
      );
    } catch (error, stackTrace) {
      Logger.root.severe(
        '[DesktopNowPlaying] Failed to start monitoring',
        error,
        stackTrace,
      );
    }
  }

  void _handleEvent(ExternalNowPlayingEvent event) {
    Logger.root.info(
      '[DesktopNowPlaying] source=${event.source.name} '
      'app=${event.sourceAppName ?? ""} '
      'bundle=${event.sourceBundleIdentifier ?? ""} '
      'id=${event.uniqueIdentifier ?? ""} '
      'state=${event.state.name} '
      'playbackRate=${event.playbackRate?.toString() ?? ""} '
      'title=${event.title ?? ""} '
      'artist=${event.artist ?? ""} '
      'album=${event.album ?? ""}',
    );

    unawaited(_syncNowPlayingActivity(event));
  }

  Future<void> _syncNowPlayingActivity(ExternalNowPlayingEvent event) async {
    switch (event.state) {
      case ExternalNowPlayingState.playing:
        _cancelPauseClear();
        break;
      case ExternalNowPlayingState.paused:
        _schedulePauseClear();
        return;
      case ExternalNowPlayingState.stopped:
        _cancelPauseClear();
        await _clearNowPlayingActivity();
        return;
    }

    if (event.state != ExternalNowPlayingState.playing) {
      await _clearNowPlayingActivity();
      return;
    }

    final activityData = _buildActivityData(event);
    if (activityData == null) {
      await _clearNowPlayingActivity();
      return;
    }

    final fingerprint = jsonEncode(activityData);
    if (_currentActivityFingerprint == fingerprint) {
      return;
    }

    final manualId = activityData['manual_id'] as String?;
    if (_currentActivityManualId != null &&
        _currentActivityManualId != manualId) {
      try {
        await _ref
            .read(apiClientProvider)
            .delete(
              '/passport/activities',
              queryParameters: {'manualId': _currentActivityManualId},
            );
      } catch (error, stackTrace) {
        Logger.root.warning(
          '[DesktopNowPlaying] Failed to clear previous now playing activity',
          error,
          stackTrace,
        );
      }
    }

    try {
      await _ref
          .read(apiClientProvider)
          .post('/passport/activities', data: activityData);
      _currentActivityData = activityData;
      _currentActivityFingerprint = fingerprint;
      _currentActivityManualId = manualId;
      _invalidateCurrentUserPresenceActivities();
      _startRenewal();
      Logger.root.info('[DesktopNowPlaying] Published now playing activity');
    } catch (error, stackTrace) {
      Logger.root.warning(
        '[DesktopNowPlaying] Failed to publish now playing activity',
        error,
        stackTrace,
      );
    }
  }

  Map<String, dynamic>? _buildActivityData(ExternalNowPlayingEvent event) {
    final title = event.title;
    if (title == null || title.isEmpty) {
      return null;
    }

    final titleUrl = event.titleUrl;
    final subtitleUrl = event.artist == null || event.artist!.isEmpty
        ? null
        : event.subtitleUrl;
    final artworkReference =
        event.artworkHash ?? event.artworkUrlLarge ?? event.artworkUrl;
    final providerKey = _resolveProviderKey(event);
    final referenceId = _resolveReferenceId(event);
    final queryableTerms = _buildQueryableTerms(
      providerKey: providerKey,
      referenceId: referenceId,
      title: title,
      artist: event.artist,
      album: event.album,
      sourceAppName: event.sourceAppName,
      sourceBundleIdentifier: event.sourceBundleIdentifier,
    );
    final reuseFixedManualId = _ref.read(
      desktopNowPlayingReuseFixedManualIdProvider,
    );

    _manualId = reuseFixedManualId
        ? _fixedManualId
        : event.uniqueIdentifier != null || event.catalogId != null
        ? '$_manualIdPrefix:${event.uniqueIdentifier ?? event.catalogId}'
        : '$_manualIdPrefix:${_hashTitle(title)}';

    return <String, dynamic>{
      'type': 'Music',
      'manual_id': _manualId,
      if (providerKey case final provider?) 'provider': provider,
      if (referenceId case final reference?) 'reference_id': reference,
      if (queryableTerms.isNotEmpty) 'queryable_terms': queryableTerms,
      'title': title,
      'subtitle': event.artist,
      'caption': event.album,
      'title_url': titleUrl,
      'subtitle_url': subtitleUrl,
      'small_image': artworkReference,
      'large_image': artworkReference,
      'meta': <String, dynamic>{
        'source': event.source.name,
        'provider': providerKey,
        'reference_id': referenceId,
        'queryable_terms': queryableTerms,
        'source_app_name': event.sourceAppName,
        'source_bundle_identifier': event.sourceBundleIdentifier,
        'unique_identifier': event.uniqueIdentifier,
        'catalog_id': event.catalogId,
        'title_url': titleUrl,
        'subtitle_url': subtitleUrl,
        'artwork_url': event.artworkUrl,
        'artwork_url_large': event.artworkUrlLarge,
        'artwork_hash': event.artworkHash,
        'playback_rate': event.playbackRate,
        'duration_seconds': event.duration?.inMilliseconds != null
            ? event.duration!.inMilliseconds / 1000.0
            : null,
        'position_seconds': event.position?.inMilliseconds != null
            ? event.position!.inMilliseconds / 1000.0
            : null,
      },
      'lease_minutes': _leaseMinutes,
    };
  }

  String? _resolveProviderKey(ExternalNowPlayingEvent event) {
    final explicit = _normalizeQueryableTerm(event.providerKey);
    if (explicit != null) {
      return explicit;
    }

    return switch (event.source) {
      ExternalNowPlayingSource.music => 'apple_music',
      ExternalNowPlayingSource.spotify => 'spotify',
      ExternalNowPlayingSource.other =>
        _normalizeQueryableTerm(event.sourceBundleIdentifier) ??
            _normalizeQueryableTerm(event.sourceAppName),
    };
  }

  String? _resolveReferenceId(ExternalNowPlayingEvent event) {
    return _normalizeQueryableTerm(
      event.providerReferenceId ?? event.catalogId ?? event.uniqueIdentifier,
    );
  }

  List<String> _buildQueryableTerms({
    required String? providerKey,
    required String? referenceId,
    required String title,
    required String? artist,
    required String? album,
    required String? sourceAppName,
    required String? sourceBundleIdentifier,
  }) {
    final terms = <String?>[
      if (providerKey case final provider?) provider,
      if (referenceId case final reference?) reference,
      _normalizeQueryableTerm(title),
      _normalizeQueryableTerm(artist),
      _normalizeQueryableTerm(album),
      _normalizeQueryableTerm(sourceAppName),
      _normalizeQueryableTerm(sourceBundleIdentifier),
    ];

    return terms.whereType<String>().toSet().toList(growable: false);
  }

  String? _normalizeQueryableTerm(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  Future<void> _syncAuthToken() async {
    try {
      final token = await getValidAuthToken(_ref);
      final serverURL = _ref.read(serverUrlProvider);
      await _presence.setAuthToken(token: token, serverURL: serverURL);
    } catch (error, stackTrace) {
      Logger.root.warning(
        '[DesktopNowPlaying] Failed to sync auth token',
        error,
        stackTrace,
      );
    }
  }

  void _startTokenSync() {
    _tokenSyncTimer?.cancel();
    _tokenSyncTimer = Timer.periodic(
      const Duration(minutes: 4),
      (_) => _syncAuthToken(),
    );
  }

  String _hashTitle(String title) {
    const int prime = 31;
    int hash = 0;
    for (final codeUnit in title.codeUnits) {
      hash = (hash * prime + codeUnit) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  void _startRenewal() {
    _renewalTimer?.cancel();
    final renewalIntervalSeconds = _leaseMinutes * 60 - 30;
    _renewalTimer = Timer.periodic(
      Duration(seconds: renewalIntervalSeconds),
      (_) => _renewActivity(),
    );
  }

  void _schedulePauseClear() {
    if (_currentActivityData == null) {
      return;
    }
    if (_pauseClearTimer?.isActive ?? false) {
      return;
    }

    Logger.root.info(
      '[DesktopNowPlaying] Playback paused; delaying clear for '
      '${_pauseClearDebounce.inSeconds}s',
    );
    _pauseClearTimer = Timer(_pauseClearDebounce, () {
      _pauseClearTimer = null;
      unawaited(_clearNowPlayingActivity());
    });
  }

  void _cancelPauseClear() {
    _pauseClearTimer?.cancel();
    _pauseClearTimer = null;
  }

  Future<void> _renewActivity() async {
    final activityData = _currentActivityData;
    if (activityData == null) {
      return;
    }

    try {
      await _ref
          .read(apiClientProvider)
          .post('/passport/activities', data: activityData);
      Logger.root.info('[DesktopNowPlaying] Renewed now playing activity');
    } catch (error, stackTrace) {
      Logger.root.warning(
        '[DesktopNowPlaying] Failed to renew now playing activity',
        error,
        stackTrace,
      );
    }
  }

  Future<void> _clearNowPlayingActivity() async {
    _cancelPauseClear();
    _renewalTimer?.cancel();
    _renewalTimer = null;
    if (_currentActivityData == null) {
      return;
    }

    try {
      await _ref
          .read(apiClientProvider)
          .delete(
            '/passport/activities',
            queryParameters: {'manualId': _manualId},
          );
      _invalidateCurrentUserPresenceActivities();
      Logger.root.info('[DesktopNowPlaying] Cleared now playing activity');
    } catch (error, stackTrace) {
      Logger.root.warning(
        '[DesktopNowPlaying] Failed to clear now playing activity',
        error,
        stackTrace,
      );
    } finally {
      _currentActivityData = null;
      _currentActivityFingerprint = null;
      _currentActivityManualId = null;
    }
  }

  void _invalidateCurrentUserPresenceActivities() {
    final uname = _ref.read(userInfoProvider).value?.name;
    if (uname == null || uname.isEmpty) {
      return;
    }
    _ref.invalidate(presenceActivitiesProvider(uname));
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    _tokenSyncTimer?.cancel();
    _tokenSyncTimer = null;
    _cancelPauseClear();
    await _clearNowPlayingActivity();
    _started = false;
    try {
      await _presence.stopExternalNowPlayingMonitoring();
    } catch (error, stackTrace) {
      Logger.root.warning(
        '[DesktopNowPlaying] Failed to stop monitoring',
        error,
        stackTrace,
      );
    }
  }
}
