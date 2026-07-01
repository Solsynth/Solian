import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:island/core/utils/call_kit_utils.dart';

part 'native_call_bridge.g.dart';

const _unset = Object();

bool get isNativeCallAvailable =>
    !kIsWeb && (Platform.isIOS || Platform.isAndroid);

class NativeCallBackgroundBridge {
  static bool _initialized = false;

  /// No-op on iOS: flutter_callkit_incoming handles VoIP pushes natively
  /// through PKPushRegistry and renders CallKit directly.
  static Future<void> ensureInitialized() async {
    if (!isNativeCallAvailable || _initialized) return;
    _initialized = true;
  }

  /// iOS path is handled natively; this is reached only for Android FCM data
  /// messages where a full Flutter isolate is running.
  static Future<bool> showIncomingCallFromPayload(
    Map<dynamic, dynamic> payload,
  ) async {
    if (Platform.isIOS) return false;
    if (!isNativeCallAvailable) return false;

    final descriptor = systemCallDescriptorFromPushPayload(payload);
    if (descriptor == null) return false;

    await _displayIncomingCall(descriptor);
    return true;
  }
}

Future<void> _displayIncomingCall(SystemCallDescriptor descriptor) async {
  final params = CallKitParams(
    id: descriptor.callUuid,
    nameCaller: descriptor.callerName,
    handle: descriptor.handle,
    type: descriptor.hasVideo ? 1 : 0,
    ios: const IOSParams(
      ringtonePath: 'SfxCall.wav',
      configureAudioSession: false, // LiveKit owns AVAudioSession
    ),
    extra: <String, dynamic>{
      'room_id': descriptor.roomId,
      ...descriptor.metadata,
    },
  );
  await FlutterCallkitIncoming.showCallkitIncoming(params);
}

Future<SystemCallDescriptor> _startOutgoingCall(SystemCallDescriptor descriptor) async {
  final params = CallKitParams(
    id: descriptor.callUuid,
    nameCaller: descriptor.callerName,
    handle: descriptor.handle,
    type: descriptor.hasVideo ? 1 : 0,
    ios: const IOSParams(
      ringtonePath: 'SfxCall.wav',
      configureAudioSession: false,
    ),
    extra: <String, dynamic>{
      'room_id': descriptor.roomId,
      ...descriptor.metadata,
    },
  );
  await FlutterCallkitIncoming.startCall(params);
  return descriptor;
}

@Riverpod(keepAlive: true)
class NativeCallBridge extends _$NativeCallBridge {
  bool _listenersRegistered = false;
  bool _isInitializing = false;

  @override
  NativeCallState build() {
    return const NativeCallState();
  }

  void _registerListeners() {
    if (_listenersRegistered) return;
    _listenersRegistered = true;

    FlutterCallkitIncoming.onEvent.listen(
      _onCallEvent,
      onError: (e, st) {
        Logger.root.warning('[NativeCallBridge] event stream error', e, st);
      },
      onDone: () {
        Logger.root.warning('[NativeCallBridge] event stream closed');
      },
    );
  }

  Future<void> _onCallEvent(CallEvent? event) async {
    if (event == null) return;
    Logger.root.info('[NativeCallBridge] event=${event.eventName}');

    switch (event) {
      case CallEventActionCallIncoming():
        _onIncoming(event.callKitParams);
      case CallEventActionCallStart():
        _onStart(event.callKitParams);
      case CallEventActionCallAccept():
        await _onAccept(event.callKitParams.id);
      case CallEventActionCallDecline():
        await _onDecline(event.callKitParams.id);
      case CallEventActionCallEnded():
        await _onEnded(event.callKitParams.id);
      case CallEventActionCallTimeout():
        await _onTimeout(event.id);
      case CallEventActionCallToggleHold():
        state = state.copyWith(isOnHold: event.isOnHold);
      case CallEventActionCallToggleMute():
        state = state.copyWith(isMicrophoneEnabled: !event.isMuted);
      case CallEventActionCallCallback():
        break;
      case CallEventActionCallConnected():
        state = state.copyWith(isConnected: true, isAcceptedPending: false);
      default:
        Logger.root.warning('[NativeCallBridge] unhandled event: $event');
    }
  }

  void _onIncoming(CallKitParams params) {
    final extra = params.extra ?? const <String, dynamic>{};
    final roomId = extra['room_id']?.toString();
    final rawName = (params.nameCaller ?? '').trim();
    final callerName = rawName.isEmpty ? 'Voice Call' : rawName;
    state = state.copyWith(
      callUuid: params.id,
      roomId: roomId,
      roomName: callerName,
      isIncomingDisplayed: true,
      source: NativeCallSource.incomingPush,
    );
    Logger.root.info(
      '[NativeCallBridge] Incoming displayed: uuid=${params.id} room=$roomId caller=$callerName',
    );
  }

  void _onStart(CallKitParams params) {
    final extra = params.extra ?? const <String, dynamic>{};
    final roomId = extra['room_id']?.toString();
    final rawName = (params.nameCaller ?? '').trim();
    final roomName = rawName.isEmpty ? (roomId ?? 'Voice Call') : rawName;
    state = state.copyWith(
      callUuid: params.id,
      roomId: roomId,
      roomName: roomName,
      callKitAcceptedRoomId: roomId,
      isAcceptedPending: true,
      isOutgoing: true,
      source: NativeCallSource.outgoingLocal,
    );
  }

  Future<void> _onAccept(String uuid) async {
    if (uuid.isEmpty) return;
    final descriptor = await _lookupDescriptor(uuid);
    if (descriptor == null) {
      Logger.root.warning(
        '[NativeCallBridge] Native answer: no descriptor for uuid=$uuid',
      );
    }
    state = state.copyWith(
      callUuid: uuid,
      roomId: descriptor?.roomId,
      roomName: descriptor?.callerName,
      callKitAcceptedRoomId: descriptor?.roomId,
      isAcceptedPending: descriptor != null,
      isConnected: false,
      isIncomingDisplayed: false,
    );
    Logger.root.info(
      '[NativeCallBridge] Native answer: room=${state.callKitAcceptedRoomId} uuid=$uuid',
    );
  }

  Future<void> _onDecline(String uuid) async {
    state = state.copyWith(isIncomingDisplayed: false);
    Logger.root.info('[NativeCallBridge] Native decline: uuid=$uuid');
  }

  Future<void> _onEnded(String uuid) async {
    Logger.root.info('[NativeCallBridge] Native call ended: uuid=$uuid');
    clearAcceptedCall();
  }

  Future<void> _onTimeout(String id) async {
    Logger.root.warning('[NativeCallBridge] Call timed out: id=$id');
    state = state.copyWith(isIncomingDisplayed: false);
  }

  /// Look up the call descriptor that was stored via showIncomingCall /
  /// startOutgoingCall. On iOS, the descriptor lives only in Dart since the
  /// plugin keeps its own descriptor map natively.
  Future<SystemCallDescriptor?> _lookupDescriptor(String? callUuid) async {
    if (callUuid == null || callUuid.isEmpty) return null;
    final active = await FlutterCallkitIncoming.activeCalls();
    for (final params in active) {
      if (params.id == callUuid) {
        final extra = params.extra ?? const <String, dynamic>{};
        final roomId = extra['room_id']?.toString();
        final rawName = (params.nameCaller ?? '').trim();
        final callerName = rawName.isEmpty ? 'Voice Call' : rawName;
        final handle = params.handle ?? roomId ?? 'unknown';
        if (roomId == null) continue;
        return createSystemCallDescriptor(
          roomId: roomId,
          callerName: callerName,
          handle: handle,
          hasVideo: (params.type ?? 0) > 0,
          source: NativeCallSource.incomingPush,
          callUuid: params.id,
          metadata: Map<String, dynamic>.from(extra),
        );
      }
    }
    return null;
  }

  Future<void> ensureInitialized() async {
    if (!isNativeCallAvailable || _isInitializing) return;
    _isInitializing = true;
    _registerListeners();
    try {
      final token = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
      state = state.copyWith(pushToken: token);
      Logger.root.info('[NativeCallBridge] Initialized token=${token != null ? "${token.substring(0, 8)}…" : "none"}');
    } catch (e) {
      Logger.root.warning('[NativeCallBridge] Failed to get VoIP token: $e');
    }
    _isInitializing = false;
  }

  Future<SystemCallDescriptor> startOutgoingCall({
    required String roomId,
    required String callerName,
    bool hasVideo = false,
    String? handle,
  }) async {
    await ensureInitialized();
    final descriptor = createSystemCallDescriptor(
      roomId: roomId,
      callerName: callerName,
      handle: handle ?? roomId,
      hasVideo: hasVideo,
      source: NativeCallSource.outgoingLocal,
    );
    await _startOutgoingCall(descriptor);
    state = state.copyWith(
      callUuid: descriptor.callUuid,
      roomId: roomId,
      roomName: callerName,
      callKitAcceptedRoomId: roomId,
      isAcceptedPending: true,
      isOutgoing: true,
      source: NativeCallSource.outgoingLocal,
    );
    return descriptor;
  }

  Future<SystemCallDescriptor> showIncomingCall({
    required String roomId,
    required String callerName,
    String? handle,
    bool hasVideo = false,
    NativeCallSource source = NativeCallSource.incomingForeground,
  }) async {
    await ensureInitialized();
    final descriptor = createSystemCallDescriptor(
      roomId: roomId,
      callerName: callerName,
      handle: handle ?? roomId,
      hasVideo: hasVideo,
      source: source,
    );
    await _displayIncomingCall(descriptor);
    state = state.copyWith(
      callUuid: descriptor.callUuid,
      roomId: descriptor.roomId,
      roomName: descriptor.callerName,
      isIncomingDisplayed: true,
      source: source,
    );
    return descriptor;
  }

  Future<void> markOutgoingConnecting() async {
    final callUuid = state.callUuid;
    if (callUuid == null || callUuid.isEmpty) return;
    if (Platform.isIOS) {
      // The plugin doesn't expose a 1:1 equivalent of callkeep's
      // reportConnectingOutgoingCallWithUUID; startCall already shows the
      // CallKit UI. We rely on setCallConnected when WebRTC signals media.
    }
  }

  Future<void> markFlutterCallConnected() async {
    final callUuid = state.callUuid;
    if (callUuid == null || callUuid.isEmpty) {
      state = state.copyWith(isConnected: true, isAcceptedPending: false);
      return;
    }

    try {
      await FlutterCallkitIncoming.setCallConnected(callUuid);
    } catch (e) {
      Logger.root.warning('[NativeCallBridge] setCallConnected failed: $e');
    }

    state = state.copyWith(
      isConnected: true,
      isAcceptedPending: false,
      isIncomingDisplayed: false,
    );
  }

  Future<void> endCall({String? callUuid}) async {
    final activeUuid = callUuid ?? state.callUuid;
    if (activeUuid != null && activeUuid.isNotEmpty) {
      await FlutterCallkitIncoming.endCall(activeUuid);
    } else {
      await FlutterCallkitIncoming.endAllCalls();
    }
    clearAcceptedCall();
  }

  Future<void> endAllCalls() async {
    await FlutterCallkitIncoming.endAllCalls();
    clearAcceptedCall();
  }

  Future<void> clearPendingAcceptedCall() async {
    state = state.copyWith(isAcceptedPending: false);
  }

  String? currentRoomId() => state.callKitAcceptedRoomId ?? state.roomId;

  void clearAcceptedCall() {
    state = state.copyWith(
      callUuid: null,
      roomId: null,
      roomName: null,
      callKitAcceptedRoomId: null,
      isConnected: false,
      isAcceptedPending: false,
      isIncomingDisplayed: false,
      isOnHold: false,
      isOutgoing: false,
      isAudioSessionActive: false,
      source: null,
    );
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
  final String? callUuid;
  final bool isIncomingDisplayed;
  final bool isOnHold;
  final bool isOutgoing;
  final bool isAudioSessionActive;
  final NativeCallSource? source;
  final String? pushToken;

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
    this.callUuid,
    this.isIncomingDisplayed = false,
    this.isOnHold = false,
    this.isOutgoing = false,
    this.isAudioSessionActive = false,
    this.source,
    this.pushToken,
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
    Object? callUuid = _unset,
    bool? isIncomingDisplayed,
    bool? isOnHold,
    bool? isOutgoing,
    bool? isAudioSessionActive,
    Object? source = _unset,
    Object? pushToken = _unset,
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
      callUuid: identical(callUuid, _unset)
          ? this.callUuid
          : callUuid as String?,
      isIncomingDisplayed: isIncomingDisplayed ?? this.isIncomingDisplayed,
      isOnHold: isOnHold ?? this.isOnHold,
      isOutgoing: isOutgoing ?? this.isOutgoing,
      isAudioSessionActive: isAudioSessionActive ?? this.isAudioSessionActive,
      source: identical(source, _unset)
          ? this.source
          : source as NativeCallSource?,
      pushToken: identical(pushToken, _unset) ? this.pushToken : pushToken as String?,
    );
  }
}
