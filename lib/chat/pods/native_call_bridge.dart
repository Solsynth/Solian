import 'dart:async';
import 'dart:io';

import 'package:callkeep/callkeep.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:island/core/utils/call_kit_utils.dart';

part 'native_call_bridge.g.dart';

const _unset = Object();
const _nativeCallPushTokenKey = 'dev.solsynth.solian.native_call.push_token';

bool get isNativeCallAvailable =>
    !kIsWeb && (Platform.isIOS || Platform.isAndroid);

final FlutterCallkeep _callKeep = FlutterCallkeep();
bool _platformListenersRegistered = false;
Future<void>? _setupFuture;
bool _foregroundSetupComplete = false;

class NativeCallBackgroundBridge {
  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (!isNativeCallAvailable || _initialized) return;
    await _ensureCallKeepSetup(backgroundMode: true);
    _initialized = true;
  }

  static Future<bool> showIncomingCallFromPayload(
    Map<dynamic, dynamic> payload,
  ) async {
    final descriptor = systemCallDescriptorFromPushPayload(payload);
    if (descriptor == null) return false;

    await ensureInitialized();
    await _displayIncomingCall(descriptor);
    if (Platform.isAndroid) {
      await _callKeep.backToForeground();
    }
    return true;
  }
}

Future<void> _ensureCallKeepSetup({required bool backgroundMode}) async {
  if (!isNativeCallAvailable) return;
  if (_setupFuture != null && (backgroundMode || _foregroundSetupComplete)) {
    await _setupFuture;
    return;
  }
  _registerPlatformListeners();
  _setupFuture = _callKeep.setup(
    showAlertDialog: null,
    backgroundMode: backgroundMode,
    options: <String, dynamic>{
      'ios': {'appName': 'Solian'},
      'android': {
        'additionalPermissions': <String>[
          'android.permission.CALL_PHONE',
          'android.permission.READ_PHONE_NUMBERS',
        ],
        'foregroundService': <String, String>{
          'channelId': 'dev.solsynth.solian.calls',
          'channelName': 'Solian Calls',
          'notificationTitle': 'Solian call is active',
          'notificationIcon': 'mipmap/launcher_icon',
        },
      },
    },
  );
  await _setupFuture;
  if (!backgroundMode) {
    _foregroundSetupComplete = true;
  }
}

void _registerPlatformListeners() {
  if (_platformListenersRegistered) return;
  _platformListenersRegistered = true;
  _callKeep.on<CallKeepPushKitToken>((event) {
    unawaited(_persistPushToken(event.token));
  });
}

Future<void> _persistPushToken(String? token) async {
  if (token == null || token.isEmpty) return;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_nativeCallPushTokenKey, token);
}

Future<String?> loadPersistedNativeCallPushToken() async {
  if (!isNativeCallAvailable || !Platform.isIOS) return null;
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_nativeCallPushTokenKey);
}

Future<void> _displayIncomingCall(SystemCallDescriptor descriptor) async {
  await _callKeep.displayIncomingCall(
    uuid: descriptor.callUuid,
    handle: descriptor.handle,
    callerName: descriptor.callerName,
    handleType: descriptor.handle.startsWith('@') ? 'generic' : 'number',
    hasVideo: descriptor.hasVideo,
    additionalData: descriptor.toAdditionalData(),
  );
}

Future<void> _startOutgoingCall(SystemCallDescriptor descriptor) async {
  await _callKeep.startCall(
    uuid: descriptor.callUuid,
    handle: descriptor.handle,
    callerName: descriptor.callerName,
    handleType: descriptor.handle.startsWith('@') ? 'generic' : 'number',
    hasVideo: descriptor.hasVideo,
    additionalData: descriptor.toAdditionalData(),
  );
}

String? _roomIdFromCallData(CallData data) {
  final roomId = data.additionalData?['room_id']?.toString();
  if (roomId != null && roomId.isNotEmpty) return roomId;
  final fallback = data.handle?.toString();
  if (fallback == null || fallback.isEmpty) return null;
  return fallback.startsWith('@') ? null : fallback;
}

String? _callerNameFromCallData(CallData data) {
  final caller = data.name?.toString();
  if (caller != null && caller.isNotEmpty) return caller;
  return data.handle?.toString();
}

String? _callUuidFromCallData(CallData data) {
  final callUuid = data.callUUID?.toString();
  if (callUuid != null && callUuid.isNotEmpty) return callUuid;
  return data.additionalData?['call_uuid']?.toString();
}

/// Thin wrapper that listens to the native event channel and exposes
/// call state to Flutter widgets that need it.
@Riverpod(keepAlive: true)
class NativeCallBridge extends _$NativeCallBridge {
  bool _isInitializing = false;
  bool _listenersRegistered = false;

  @override
  NativeCallState build() {
    return const NativeCallState();
  }

  void _registerListeners() {
    if (_listenersRegistered) return;
    _listenersRegistered = true;

    _callKeep.on<CallKeepDidDisplayIncomingCall>((event) {
      final callData = event.callData;
      state = state.copyWith(
        callUuid: _callUuidFromCallData(callData),
        roomId: _roomIdFromCallData(callData),
        roomName: _callerNameFromCallData(callData),
        isIncomingDisplayed: true,
        source: NativeCallSource.incomingPush,
      );
    });

    _callKeep.on<CallKeepPerformAnswerCallAction>((event) {
      final callData = event.callData;
      final roomId = _roomIdFromCallData(callData);
      final callerName = _callerNameFromCallData(callData);
      final callUuid = _callUuidFromCallData(callData);
      Logger.root.info(
        '[NativeCallBridge] Native answer received: room=$roomId uuid=$callUuid',
      );
      state = state.copyWith(
        callUuid: callUuid,
        roomId: roomId,
        roomName: callerName,
        callKitAcceptedRoomId: roomId,
        isAcceptedPending: true,
        isConnected: false,
        isIncomingDisplayed: false,
      );
      if (Platform.isAndroid) {
        unawaited(_callKeep.backToForeground());
      }
    });

    _callKeep.on<CallKeepDidReceiveStartCallAction>((event) {
      final callData = event.callData;
      state = state.copyWith(
        callUuid: _callUuidFromCallData(callData),
        roomId: _roomIdFromCallData(callData),
        roomName: _callerNameFromCallData(callData),
        callKitAcceptedRoomId: _roomIdFromCallData(callData),
        isAcceptedPending: true,
        isOutgoing: true,
        source: NativeCallSource.outgoingLocal,
      );
    });

    _callKeep.on<CallKeepDidPerformSetMutedCallAction>((event) {
      state = state.copyWith(isMicrophoneEnabled: !(event.muted ?? false));
    });

    _callKeep.on<CallKeepDidToggleHoldAction>((event) {
      state = state.copyWith(isOnHold: event.hold ?? false);
    });

    _callKeep.on<CallKeepPerformRejectCallAction>((_) {
      Logger.root.info('[NativeCallBridge] Native call rejected');
      clearAcceptedCall();
    });

    _callKeep.on<CallKeepPerformEndCallAction>((_) {
      Logger.root.info('[NativeCallBridge] Native call ended');
      clearAcceptedCall();
    });

    _callKeep.on<CallKeepProviderReset>((_) {
      Logger.root.warning('[NativeCallBridge] Native provider reset');
      clearAcceptedCall();
    });

    _callKeep.on<CallKeepPushKitToken>((event) {
      final token = event.token;
      state = state.copyWith(pushToken: token);
      unawaited(_persistPushToken(token));
    });
  }

  Future<void> ensureInitialized() async {
    if (!isNativeCallAvailable || _isInitializing) return;
    _isInitializing = true;
    _registerListeners();
    await _ensureCallKeepSetup(backgroundMode: false);
    state = state.copyWith(pushToken: await loadPersistedNativeCallPushToken());
    Logger.root.info('[NativeCallBridge] Initialized');
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
      await _callKeep.reportConnectingOutgoingCallWithUUID(callUuid);
    }
  }

  Future<void> markFlutterCallConnected() async {
    final callUuid = state.callUuid;
    if (callUuid == null || callUuid.isEmpty) {
      state = state.copyWith(isConnected: true, isAcceptedPending: false);
      return;
    }

    if (Platform.isIOS && state.isOutgoing) {
      await _callKeep.reportConnectedOutgoingCallWithUUID(callUuid);
    } else if (Platform.isAndroid) {
      await _callKeep.setCurrentCallActive(callUuid);
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
      await _callKeep.endCall(activeUuid);
    } else {
      await _callKeep.endAllCalls();
    }
    clearAcceptedCall();
  }

  Future<void> endAllCalls() async {
    await _callKeep.endAllCalls();
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
      callUuid: identical(callUuid, _unset) ? this.callUuid : callUuid as String?,
      isIncomingDisplayed: isIncomingDisplayed ?? this.isIncomingDisplayed,
      isOnHold: isOnHold ?? this.isOnHold,
      isOutgoing: isOutgoing ?? this.isOutgoing,
      source: identical(source, _unset)
          ? this.source
          : source as NativeCallSource?,
      pushToken: identical(pushToken, _unset)
          ? this.pushToken
          : pushToken as String?,
    );
  }
}
