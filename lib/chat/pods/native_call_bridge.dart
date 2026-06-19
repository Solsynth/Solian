import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island_call/island_call.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logging/logging.dart';

part 'native_call_bridge.g.dart';

/// Whether native call UI is available (iOS/macOS only, not web).
bool get isNativeCallAvailable => !kIsWeb && (Platform.isIOS || Platform.isMacOS);

/// Thin wrapper that listens to the native event channel and exposes
/// call state to Flutter widgets that need it (e.g., showing "in call" badges).
@Riverpod(keepAlive: true)
class NativeCallBridge extends _$NativeCallBridge {
  StreamSubscription<Map<String, dynamic>>? _stateSub;
  StreamSubscription<List<Map<String, dynamic>>>? _participantsSub;

  @override
  NativeCallState build() {
    ref.onDispose(() {
      _stateSub?.cancel();
      _participantsSub?.cancel();
    });
    return const NativeCallState();
  }

  void startListening() {
    _stateSub?.cancel();
    _participantsSub?.cancel();

    _stateSub = IslandCall.onStateChanged.listen((data) {
      state = state.copyWith(
        isConnected: data['isConnected'] as bool? ?? false,
        isReconnecting: data['isReconnecting'] as bool? ?? false,
        isMicrophoneEnabled: data['isMicrophoneEnabled'] as bool? ?? true,
        isCameraEnabled: data['isCameraEnabled'] as bool? ?? false,
        participantCount: data['participantCount'] as int? ?? 0,
        roomId: data['roomId'] as String?,
        roomName: data['roomName'] as String?,
      );
    });

    _participantsSub = IslandCall.onParticipantsChanged.listen((data) {
      state = state.copyWith(participantCount: data.length);
    });
  }

  Future<void> initialize({required String serverUrl, required String authToken}) async {
    if (!isNativeCallAvailable) return;
    try {
      await IslandCall.initialize(serverUrl: serverUrl, authToken: authToken);
      startListening();
      Logger.root.info('[NativeCallBridge] Initialized with server: $serverUrl');
    } catch (e) {
      Logger.root.warning('[NativeCallBridge] Initialize failed: $e');
    }
  }

  /// Call this from app startup to auto-initialize with stored credentials.
  Future<void> ensureInitialized(WidgetRef ref) async {
    if (!isNativeCallAvailable) return;
    if (state.isConnected || state.isReconnecting) return; // already active
    try {
      final serverUrl = ref.read(serverUrlProvider);
      // Use ref.read to get the token directly from the provider
      final tokenPair = ref.read(tokenProvider);
      if (tokenPair != null && tokenPair.token.isNotEmpty) {
        await initialize(serverUrl: serverUrl, authToken: tokenPair.token);
      }
    } catch (e) {
      Logger.root.fine('[NativeCallBridge] Auto-init skipped: $e');
    }
  }

  Future<void> joinRoom(String roomId) async {
    if (!isNativeCallAvailable) return;
    await IslandCall.joinRoom(roomId);
  }

  Future<void> leaveRoom() async {
    if (!isNativeCallAvailable) return;
    await IslandCall.leaveRoom();
  }
}

class NativeCallState {
  final bool isConnected;
  final bool isReconnecting;
  final bool isMicrophoneEnabled;
  final bool isCameraEnabled;
  final int participantCount;
  final String? roomId;
  final String? roomName;

  const NativeCallState({
    this.isConnected = false,
    this.isReconnecting = false,
    this.isMicrophoneEnabled = true,
    this.isCameraEnabled = false,
    this.participantCount = 0,
    this.roomId,
    this.roomName,
  });

  NativeCallState copyWith({
    bool? isConnected,
    bool? isReconnecting,
    bool? isMicrophoneEnabled,
    bool? isCameraEnabled,
    int? participantCount,
    String? roomId,
    String? roomName,
  }) {
    return NativeCallState(
      isConnected: isConnected ?? this.isConnected,
      isReconnecting: isReconnecting ?? this.isReconnecting,
      isMicrophoneEnabled: isMicrophoneEnabled ?? this.isMicrophoneEnabled,
      isCameraEnabled: isCameraEnabled ?? this.isCameraEnabled,
      participantCount: participantCount ?? this.participantCount,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
    );
  }
}
