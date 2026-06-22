import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logging/logging.dart';

part 'native_call_bridge.g.dart';

const _unset = Object();

/// Whether native call UI is available (iOS only for CallKit, not web or macOS).
bool get isNativeCallAvailable => !kIsWeb && Platform.isIOS;

class NativeCallBackgroundBridge {
  static const _callKitChannel = MethodChannel('dev.solsynth.solian/callkit');
  static bool _initialized = false;

  static void ensureInitialized() {
    if (!isNativeCallAvailable || _initialized) return;
    _initialized = true;
    _callKitChannel.setMethodCallHandler((call) async {
      Logger.root.info(
        '[NativeCallBackgroundBridge] Received ${call.method} on background isolate',
      );
      return null;
    });
  }
}

/// Thin wrapper that listens to the native event channel and exposes
/// call state to Flutter widgets that need it (e.g., showing "in call" badges).
@Riverpod(keepAlive: true)
class NativeCallBridge extends _$NativeCallBridge {
  StreamSubscription<CallEvent?>? _callKitEventSub;
  static const _callKitChannel = MethodChannel('dev.solsynth.solian/callkit');
  bool _isInitializing = false;

  @override
  NativeCallState build() {
    ref.onDispose(() {
      _callKitEventSub?.cancel();
    });
    return const NativeCallState();
  }

  void startListening() {
    _callKitEventSub?.cancel();

    // Listen for CallKit events via direct method channel (more reliable)
    _callKitChannel.setMethodCallHandler((call) async {
      Logger.root.info(
        '[NativeCallBridge] CallKit method channel: ${call.method}',
      );

      switch (call.method) {
        case 'callAccepted':
          final roomId = call.arguments['roomId'] as String?;
          final callerName = call.arguments['callerName'] as String?;
          Logger.root.info(
            '[NativeCallBridge] CallKit call accepted via channel: $roomId ($callerName)',
          );
          _setAcceptedCall(roomId);
          break;
        case 'callEnded':
          Logger.root.info('[NativeCallBridge] CallKit call ended via channel');
          clearAcceptedCall();
          break;
      }
    });

    // Also listen for CallKit events from flutter_callkit_incoming
    _callKitEventSub = FlutterCallkitIncoming.onEvent.listen(
      (event) {
        if (event == null) return;

        Logger.root.info(
          '[NativeCallBridge] CallKit event: ${event.eventName}',
        );

        switch (event) {
          case CallEventActionCallAccept(:final callKitParams):
            final roomId = _roomIdFromCallKitParams(callKitParams);
            Logger.root.info(
              '[NativeCallBridge] CallKit call accepted: $roomId',
            );
            _setAcceptedCall(roomId);
            break;

          case CallEventActionCallEnded():
            Logger.root.info('[NativeCallBridge] CallKit call ended');
            clearAcceptedCall();
            break;

          case CallEventActionCallToggleMute(:final isMuted):
            Logger.root.info(
              '[NativeCallBridge] CallKit mute changed: $isMuted',
            );
            state = state.copyWith(isMicrophoneEnabled: !isMuted);
            break;

          case CallEventActionCallToggleHold(:final isOnHold):
            Logger.root.info(
              '[NativeCallBridge] CallKit hold toggled: $isOnHold',
            );
            break;

          case CallEventActionCallToggleAudioSession():
            Logger.root.info(
              '[NativeCallBridge] CallKit audio session toggled',
            );
            break;

          case CallEventActionCallDecline():
            Logger.root.info('[NativeCallBridge] CallKit call declined');
            clearAcceptedCall();
            break;

          default:
            Logger.root.fine(
              '[NativeCallBridge] Unhandled CallKit event: ${event.eventName}',
            );
        }
      },
      onError: (e) {
        // ponytail: swallow errors from flutter_callkit_incoming (e.g., null id for audio session)
        Logger.root.warning('[NativeCallBridge] CallKit event error: $e');
      },
    );
  }

  String? _roomIdFromCallKitParams(CallKitParams params) {
    final extraRoomId = params.extra?['room_id'] ?? params.extra?['roomId'];
    if (extraRoomId is String && extraRoomId.isNotEmpty) {
      return extraRoomId;
    }
    if (params.id.isNotEmpty) {
      return params.id;
    }
    final handle = params.handle;
    return handle == null || handle.isEmpty ? null : handle;
  }

  Future<void> _restorePendingAcceptedCall() async {
    try {
      final pending = await _callKitChannel.invokeMapMethod<String, dynamic>(
        'getPendingAcceptedCall',
      );
      final roomId = pending?['roomId'] as String?;
      if (roomId == null || roomId.isEmpty) return;
      Logger.root.info(
        '[NativeCallBridge] Restored pending accepted call: $roomId',
      );
      _setAcceptedCall(roomId);
    } catch (e) {
      Logger.root.warning(
        '[NativeCallBridge] Failed to restore pending accepted call: $e',
      );
    }
  }

  Future<void> clearPendingAcceptedCall() async {
    try {
      await _callKitChannel.invokeMethod('clearPendingAcceptedCall');
    } catch (e) {
      Logger.root.warning(
        '[NativeCallBridge] Failed to clear pending accepted call: $e',
      );
    }
  }

  void markFlutterCallConnected() {
    if (state.callKitAcceptedRoomId == null) return;
    state = state.copyWith(isConnected: true, isAcceptedPending: false);
  }

  void clearAcceptedCall() {
    state = state.copyWith(
      callKitAcceptedRoomId: null,
      isConnected: false,
      isAcceptedPending: false,
    );
  }

  void _setAcceptedCall(String? roomId) {
    state = state.copyWith(
      callKitAcceptedRoomId: roomId,
      isConnected: false,
      isAcceptedPending: roomId != null,
    );
  }

  /// Call this from app startup to start listening to CallKit events.
  Future<void> ensureInitialized() async {
    if (!isNativeCallAvailable || _isInitializing) return;
    _isInitializing = true;
    startListening();
    await _restorePendingAcceptedCall();
    Logger.root.info('[NativeCallBridge] Initialized');
    _isInitializing = false;
  }
}

class NativeCallState {
  final bool isConnected;
  final bool isAcceptedPending;
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
    this.isAcceptedPending = false,
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
    bool? isAcceptedPending,
    bool? isReconnecting,
    bool? isMicrophoneEnabled,
    bool? isCameraEnabled,
    int? participantCount,
    Object? roomId = _unset,
    Object? roomName = _unset,
    Object? callKitAcceptedRoomId = _unset,
    Object? callerAvatarUrl = _unset,
  }) {
    return NativeCallState(
      isConnected: isConnected ?? this.isConnected,
      isAcceptedPending: isAcceptedPending ?? this.isAcceptedPending,
      isReconnecting: isReconnecting ?? this.isReconnecting,
      isMicrophoneEnabled: isMicrophoneEnabled ?? this.isMicrophoneEnabled,
      isCameraEnabled: isCameraEnabled ?? this.isCameraEnabled,
      participantCount: participantCount ?? this.participantCount,
      roomId: identical(roomId, _unset) ? this.roomId : roomId as String?,
      roomName: identical(roomName, _unset)
          ? this.roomName
          : roomName as String?,
      callKitAcceptedRoomId: identical(callKitAcceptedRoomId, _unset)
          ? this.callKitAcceptedRoomId
          : callKitAcceptedRoomId as String?,
      callerAvatarUrl: identical(callerAvatarUrl, _unset)
          ? this.callerAvatarUrl
          : callerAvatarUrl as String?,
    );
  }
}
