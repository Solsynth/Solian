import 'dart:async';
import 'dart:convert';
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
const _nativeCallDescriptorStoreKey =
    'dev.solsynth.solian.native_call.descriptors';

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
    null,
    <String, dynamic>{
      'ios': {'appName': 'Solian'},
      'android': {
        'additionalPermissions': <String>[
          'android.permission.CALL_PHONE',
          'android.permission.READ_PHONE_NUMBERS',
        ],
        'alertTitle': 'Permissions required',
        'alertDescription':
            'This application needs to access your phone accounts',
        'cancelButton': 'Cancel',
        'okButton': 'OK',
        'foregroundService': <String, String>{
          'channelId': 'dev.solsynth.solian.calls',
          'channelName': 'Solian Calls',
          'notificationTitle': 'Solian call is active',
          'notificationIcon': 'mipmap/launcher_icon',
        },
      },
    },
    backgroundMode: backgroundMode,
  );
  await _setupFuture;
  if (!backgroundMode) {
    _foregroundSetupComplete = true;
  }
}

void _registerPlatformListeners() {
  if (_platformListenersRegistered) return;
  _platformListenersRegistered = true;
  _callKeep.on(CallKeepPushKitToken(), (event) {
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

Future<Map<String, dynamic>> _loadDescriptorStore() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_nativeCallDescriptorStoreKey);
  if (raw == null || raw.isEmpty) return <String, dynamic>{};
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
  } catch (_) {}
  return <String, dynamic>{};
}

Future<void> _storeDescriptor(SystemCallDescriptor descriptor) async {
  final prefs = await SharedPreferences.getInstance();
  final store = await _loadDescriptorStore();
  store[descriptor.callUuid] = <String, dynamic>{
    'callUuid': descriptor.callUuid,
    'roomId': descriptor.roomId,
    'callerName': descriptor.callerName,
    'handle': descriptor.handle,
    'hasVideo': descriptor.hasVideo,
    'source': descriptor.source.name,
    'metadata': descriptor.metadata,
  };
  await prefs.setString(_nativeCallDescriptorStoreKey, jsonEncode(store));
}

NativeCallSource _sourceFromName(String? value) {
  for (final source in NativeCallSource.values) {
    if (source.name == value) return source;
  }
  return NativeCallSource.incomingForeground;
}

Future<SystemCallDescriptor?> _lookupDescriptor(String? callUuid) async {
  if (callUuid == null || callUuid.isEmpty) return null;
  final store = await _loadDescriptorStore();
  final raw = store[callUuid];
  if (raw is! Map) return null;

  final data = raw.map((key, value) => MapEntry(key.toString(), value));
  final metadataRaw = data['metadata'];
  final metadata = metadataRaw is Map
      ? metadataRaw.map((key, value) => MapEntry(key.toString(), value))
      : const <String, dynamic>{};
  final roomId = data['roomId']?.toString();
  final callerName = data['callerName']?.toString();
  final handle = data['handle']?.toString();
  if (roomId == null || callerName == null || handle == null) return null;

  return SystemCallDescriptor(
    callUuid: callUuid,
    roomId: roomId,
    callerName: callerName,
    handle: handle,
    hasVideo: data['hasVideo'] == true,
    source: _sourceFromName(data['source']?.toString()),
    metadata: metadata,
  );
}

Future<void> _removeDescriptor(String? callUuid) async {
  if (callUuid == null || callUuid.isEmpty) return;
  final prefs = await SharedPreferences.getInstance();
  final store = await _loadDescriptorStore();
  store.remove(callUuid);
  await prefs.setString(_nativeCallDescriptorStoreKey, jsonEncode(store));
}

Future<void> _displayIncomingCall(SystemCallDescriptor descriptor) async {
  await _storeDescriptor(descriptor);
  await _callKeep.displayIncomingCall(
    descriptor.callUuid,
    descriptor.handle,
    localizedCallerName: descriptor.callerName,
    handleType: descriptor.handle.startsWith('@') ? 'generic' : 'number',
    hasVideo: descriptor.hasVideo,
  );
}

Future<void> _startOutgoingCall(SystemCallDescriptor descriptor) async {
  await _storeDescriptor(descriptor);
  await _callKeep.startCall(
    descriptor.callUuid,
    descriptor.handle,
    descriptor.callerName,
    handleType: descriptor.handle.startsWith('@') ? 'generic' : 'number',
    hasVideo: descriptor.hasVideo,
  );
}

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

    _callKeep.on(CallKeepDidDisplayIncomingCall(), (event) async {
      SystemCallDescriptor? descriptor;
      final payload = event.payload;
      if (payload != null) {
        descriptor = systemCallDescriptorFromPushPayload(payload);
      }
      descriptor ??= await _lookupDescriptor(event.callUUID);
      if (descriptor == null) return;
      await _storeDescriptor(descriptor);

      state = state.copyWith(
        callUuid: descriptor.callUuid,
        roomId: descriptor.roomId,
        roomName: descriptor.callerName,
        isIncomingDisplayed: true,
        source: event.fromPushKit == true
            ? NativeCallSource.incomingPush
            : NativeCallSource.incomingForeground,
      );
    });

    _callKeep.on(CallKeepPerformAnswerCallAction(), (event) async {
      final callUuid = event.callUUID;
      final descriptor = await _lookupDescriptor(callUuid);
      final roomId = descriptor?.roomId;
      final callerName = descriptor?.callerName;
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

    _callKeep.on(CallKeepDidReceiveStartCallAction(), (event) async {
      final descriptor = await _lookupDescriptor(event.callUUID);
      final roomId = descriptor?.roomId ?? event.handle;
      final roomName = descriptor?.callerName ?? event.name;
      state = state.copyWith(
        callUuid: event.callUUID,
        roomId: roomId,
        roomName: roomName,
        callKitAcceptedRoomId: roomId,
        isAcceptedPending: true,
        isOutgoing: true,
        source: NativeCallSource.outgoingLocal,
      );
    });

    _callKeep.on(CallKeepDidPerformSetMutedCallAction(), (event) {
      state = state.copyWith(isMicrophoneEnabled: !(event.muted ?? false));
    });

    _callKeep.on(CallKeepDidToggleHoldAction(), (event) {
      state = state.copyWith(isOnHold: event.hold ?? false);
    });

    _callKeep.on(CallKeepPerformEndCallAction(), (event) {
      Logger.root.info('[NativeCallBridge] Native call ended');
      unawaited(_removeDescriptor(event.callUUID ?? state.callUuid));
      clearAcceptedCall();
    });

    _callKeep.on(CallKeepProviderReset(), (_) {
      Logger.root.warning('[NativeCallBridge] Native provider reset');
      clearAcceptedCall();
    });

    _callKeep.on(CallKeepPushKitToken(), (event) {
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
      await _removeDescriptor(activeUuid);
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
