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
  if (kIsWeb || !Platform.isMacOS) {
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
  static const int _leaseMinutes = 5;
  static const String _manualIdPrefix = 'desktop:now_playing';
  static const String _fixedManualId = 'desktop:now_playing:fixed';

  final Ref _ref;
  final IslandDesktopPresence _presence = IslandDesktopPresence();

  String? _manualId;
  StreamSubscription<ExternalNowPlayingEvent>? _subscription;
  Timer? _renewalTimer;
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
      'title=${event.title ?? ""} '
      'artist=${event.artist ?? ""} '
      'album=${event.album ?? ""}',
    );

    unawaited(_syncNowPlayingActivity(event));
  }

  Future<void> _syncNowPlayingActivity(ExternalNowPlayingEvent event) async {
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
    if (_currentActivityManualId != null && _currentActivityManualId != manualId) {
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
    final reuseFixedManualId = _ref.read(
      desktopNowPlayingReuseFixedManualIdProvider,
    );

    _manualId = reuseFixedManualId
        ? _fixedManualId
        : event.uniqueIdentifier != null || event.catalogId != null
        ? '$_manualIdPrefix:${event.uniqueIdentifier ?? event.catalogId}'
        : '$_manualIdPrefix:${_hashTitle(title)}';

    return <String, dynamic>{
      'type': 2,
      'manual_id': _manualId,
      'title': title,
      'subtitle': event.artist,
      'caption': event.album,
      'title_url': titleUrl,
      'subtitle_url': subtitleUrl,
      'small_image': artworkReference,
      'large_image': artworkReference,
      'meta': <String, dynamic>{
        'source': event.source.name,
        'source_app_name': event.sourceAppName,
        'source_bundle_identifier': event.sourceBundleIdentifier,
        'unique_identifier': event.uniqueIdentifier,
        'catalog_id': event.catalogId,
        'title_url': titleUrl,
        'subtitle_url': subtitleUrl,
        'artwork_url': event.artworkUrl,
        'artwork_url_large': event.artworkUrlLarge,
        'artwork_hash': event.artworkHash,
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
