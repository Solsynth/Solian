import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
