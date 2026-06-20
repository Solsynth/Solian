import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logging/logging.dart';

part 'native_call_bridge.g.dart';

/// Whether native call UI is available (iOS only for CallKit, not web or macOS).
bool get isNativeCallAvailable => !kIsWeb && Platform.isIOS;

/// Thin wrapper that listens to the native event channel and exposes
/// call state to Flutter widgets that need it (e.g., showing "in call" badges).
@Riverpod(keepAlive: true)
class NativeCallBridge extends _$NativeCallBridge {
  StreamSubscription<CallEvent?>? _callKitEventSub;

  @override
  NativeCallState build() {
    ref.onDispose(() {
      _callKitEventSub?.cancel();
    });
    return const NativeCallState();
  }

  void startListening() {
    _callKitEventSub?.cancel();

    // Listen for CallKit events from flutter_callkit_incoming
    _callKitEventSub = FlutterCallkitIncoming.onEvent.listen((event) {
      if (event == null) return;

      Logger.root.info('[NativeCallBridge] CallKit event: ${event.eventName}');

      switch (event) {
        case CallEventActionCallAccept(:final callKitParams):
          final roomId = callKitParams.handle;
          Logger.root.info('[NativeCallBridge] CallKit call accepted: $roomId');
          state = state.copyWith(
            callKitAcceptedRoomId: roomId,
            isConnected: true,
          );
          break;

        case CallEventActionCallEnded():
          Logger.root.info('[NativeCallBridge] CallKit call ended');
          state = state.copyWith(
            callKitAcceptedRoomId: null,
            isConnected: false,
          );
          break;

        case CallEventActionCallToggleMute(:final isMuted):
          Logger.root.info('[NativeCallBridge] CallKit mute changed: $isMuted');
          state = state.copyWith(isMicrophoneEnabled: !isMuted);
          break;

        case CallEventActionCallToggleHold(:final isOnHold):
          Logger.root.info(
            '[NativeCallBridge] CallKit hold toggled: $isOnHold',
          );
          break;

        case CallEventActionCallToggleAudioSession(:final isActive):
          Logger.root.info(
            '[NativeCallBridge] CallKit audio session: $isActive',
          );
          break;

        case CallEventActionCallDecline():
          Logger.root.info('[NativeCallBridge] CallKit call declined');
          state = state.copyWith(
            callKitAcceptedRoomId: null,
            isConnected: false,
          );
          break;

        default:
          Logger.root.fine(
            '[NativeCallBridge] Unhandled CallKit event: ${event.eventName}',
          );
      }
    });
  }

  /// Call this from app startup to start listening to CallKit events.
  void ensureInitialized() {
    if (!isNativeCallAvailable) return;
    startListening();
    Logger.root.info('[NativeCallBridge] Initialized');
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
  final String? callKitAcceptedRoomId;
  final String? callerAvatarUrl;

  const NativeCallState({
    this.isConnected = false,
    this.isReconnecting = false,
    this.isMicrophoneEnabled = true,
    this.isCameraEnabled = false,
    this.participantCount = 0,
    this.roomId,
    this.roomName,
    this.callKitAcceptedRoomId,
    this.callerAvatarUrl,
  });

  NativeCallState copyWith({
    bool? isConnected,
    bool? isReconnecting,
    bool? isMicrophoneEnabled,
    bool? isCameraEnabled,
    int? participantCount,
    String? roomId,
    String? roomName,
    String? callKitAcceptedRoomId,
    String? callerAvatarUrl,
  }) {
    return NativeCallState(
      isConnected: isConnected ?? this.isConnected,
      isReconnecting: isReconnecting ?? this.isReconnecting,
      isMicrophoneEnabled: isMicrophoneEnabled ?? this.isMicrophoneEnabled,
      isCameraEnabled: isCameraEnabled ?? this.isCameraEnabled,
      participantCount: participantCount ?? this.participantCount,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      callKitAcceptedRoomId:
          callKitAcceptedRoomId ?? this.callKitAcceptedRoomId,
      callerAvatarUrl: callerAvatarUrl ?? this.callerAvatarUrl,
    );
  }
}
