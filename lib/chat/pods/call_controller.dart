import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:island/chat/pods/call.dart';

/// Standalone call controller that does not depend on Riverpod.
/// Accepts a [Dio] client via constructor so sub-windows can use it directly.
class CallController {
  final Dio _apiClient;

  CallController({required Dio apiClient}) : _apiClient = apiClient;

  // --- LiveKit state ---
  lk.Room? _room;
  lk.LocalParticipant? _localParticipant;
  List<CallParticipantLive> _participants = [];
  final Map<String, CallParticipant> _participantInfoByIdentity = {};
  lk.EventsListener? _roomListener;
  bool _isAdmin = false;

  List<CallParticipantLive> get participants =>
      List.unmodifiable(_participants);
  lk.LocalParticipant? get localParticipant => _localParticipant;
  lk.Room? get room => _room;
  bool get isAdmin => _isAdmin;

  Map<String, double> participantsVolumes = {};

  // --- Observable state ---
  final ValueNotifier<CallState> stateNotifier = ValueNotifier(
    const CallState(
      isConnected: false,
      isReconnecting: false,
      isMicrophoneEnabled: true,
      isCameraEnabled: false,
      isScreenSharing: false,
      isSpeakerphone: true,
      viewMode: ViewMode.grid,
      participantSyncVersion: 0,
    ),
  );

  CallState get state => stateNotifier.value;
  set _state(CallState s) => stateNotifier.value = s;

  // --- Timers ---
  Timer? _durationTimer;
  Timer? _reconnectTimer;
  Timer? _connectionHealthTimer;
  Timer? _reconnectGraceTimer;

  // --- Reconnection ---
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  static const Duration _baseReconnectDelay = Duration(seconds: 1);
  static const Duration _maxReconnectDelay = Duration(seconds: 30);
  bool _isReconnecting = false;
  bool _shouldAutoReconnect = true;
  bool _isManualDisconnect = false;

  static int get maxReconnectAttempts => _maxReconnectAttempts;

  String? _roomId;
  String? get roomId => _roomId;

  SnChatRoom? _chatRoom;
  SnChatRoom? get chatRoom => _chatRoom;

  SnChatRoom? _currentRoom;

  void _bumpParticipantSync() {
    _state = state.copyWith(
      participantSyncVersion: state.participantSyncVersion + 1,
    );
  }

  void _initRoomListeners() {
    if (_room == null) return;
    _roomListener?.dispose();
    _roomListener = _room!.createListener();
    _room!.addListener(_onRoomChange);
    _roomListener!
      ..on<lk.ParticipantConnectedEvent>((e) {
        _refreshLiveParticipants();
      })
      ..on<lk.RoomDisconnectedEvent>((e) {
        if (_isManualDisconnect) {
          _participants = [];
          _bumpParticipantSync();
          return;
        }
        Logger.root.warning('[Call] Room disconnected event: ${e.reason}');
        _scheduleReconnect(force: true);
      });
  }

  void _onRoomChange() {
    _refreshLiveParticipants();
  }

  void _refreshLiveParticipants() {
    if (_room == null) return;
    final remoteParticipants = _room!.remoteParticipants;
    _participants = [];
    if (_localParticipant != null) {
      final localInfo = _buildParticipant();
      _participants.add(
        CallParticipantLive(
          participant: localInfo,
          remoteParticipant: _localParticipant!,
        ),
      );
    }
    _participants.addAll(
      remoteParticipants.values.map((remote) {
        final match =
            _participantInfoByIdentity[remote.identity] ??
            CallParticipant(
              identity: remote.identity,
              name: remote.identity,
              joinedAt: DateTime.now(),
            );
        return CallParticipantLive(
          participant: match,
          remoteParticipant: remote,
        );
      }),
    );
    _bumpParticipantSync();
  }

  CallParticipant _buildParticipant({List<CallParticipant>? participants}) {
    if (_localParticipant == null) {
      throw StateError('No local participant available');
    }
    if (participants != null) {
      final idx = participants.indexWhere(
        (p) => p.identity == _localParticipant!.identity,
      );
      if (idx != -1) return participants[idx];
    }
    return _participantInfoByIdentity[_localParticipant!.identity] ??
        CallParticipant(
          identity: _localParticipant!.identity,
          name: _localParticipant!.identity,
          joinedAt: DateTime.now(),
        );
  }

  void _updateLiveParticipants(List<CallParticipant> participants) {
    for (final p in participants) {
      _participantInfoByIdentity[p.identity] = p;
    }
    if (_room == null) {
      _participants = [];
      _bumpParticipantSync();
      return;
    }
    final remoteParticipants = _room!.remoteParticipants;
    final remotes = remoteParticipants.values.toList();
    _participants = [];
    if (_localParticipant != null) {
      final localInfo = _buildParticipant(participants: participants);
      _participants.add(
        CallParticipantLive(
          participant: localInfo,
          remoteParticipant: _localParticipant!,
        ),
      );
    }
    _participants.addAll(
      participants.map((p) {
        lk.RemoteParticipant? remote;
        for (final r in remotes) {
          if (r.identity == p.identity) {
            remote = r;
            break;
          }
        }
        if (_localParticipant != null &&
            p.identity == _localParticipant!.identity) {
          return null;
        }
        return remote != null
            ? CallParticipantLive(participant: p, remoteParticipant: remote)
            : null;
      }).whereType<CallParticipantLive>(),
    );
    _bumpParticipantSync();
  }

  Future<void> joinRoom(SnChatRoom room, {bool cameraEnabled = false}) async {
    var roomId = room.id;
    if (_roomId == roomId &&
        _room != null &&
        _room?.connectionState == lk.ConnectionState.connected) {
      Logger.root.info('[Call] Call skipped. Already has data');
      return;
    } else if (_room != null) {
      if (!_room!.isDisposed &&
          _room!.connectionState != lk.ConnectionState.disconnected) {
        throw Exception('Call already connected');
      }
    }
    _roomId = roomId;
    _chatRoom = room;
    _currentRoom = room;
    _shouldAutoReconnect = true;
    _reconnectAttempts = 0;
    _isReconnecting = false;
    _isManualDisconnect = false;
    _reconnectGraceTimer?.cancel();

    if (_room != null) {
      _isManualDisconnect = true;
      await _room!.disconnect();
      await _room!.dispose();
      _isManualDisconnect = false;
      _room = null;
      _localParticipant = null;
      _participants = [];
    }
    try {
      await _performConnection(room, cameraEnabled: cameraEnabled);
    } catch (e) {
      _state = state.copyWith(error: e.toString());
    }
  }

  Future<void> _performConnection(SnChatRoom room,
      {bool cameraEnabled = false}) async {
    if (!kIsWeb && Platform.isIOS) {
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        throw Exception('Microphone permission is required for calls');
      }
      if (cameraEnabled) {
        final cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) {
          throw Exception('Camera permission is required for calls');
        }
      }
    }

    final response = await _apiClient.get(
      '/messager/chat/realtime/${room.id}/join',
    );

    if (response.statusCode != 200 || response.data == null) {
      throw Exception('Failed to join room');
    }

    final data = response.data;
    final joinResponse = ChatRealtimeJoinResponse.fromJson(data);
    final participants = joinResponse.participants;
    final String endpoint = joinResponse.endpoint;
    final String token = joinResponse.token;
    _isAdmin = joinResponse.isAdmin;

    final joinedAt = DateTime.now();
    if (!state.hasJoined || state.joinedAt == null) {
      _state = state.copyWith(joinedAt: joinedAt, duration: Duration.zero);
      _durationTimer?.cancel();
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final baseJoinedAt = state.joinedAt;
        if (baseJoinedAt == null) return;
        _state = state.copyWith(
          duration: DateTime.now().difference(baseJoinedAt),
        );
      });
    }

    _room = lk.Room();

    await _room!.connect(
      endpoint,
      token,
      connectOptions: lk.ConnectOptions(autoSubscribe: true),
      roomOptions: lk.RoomOptions(adaptiveStream: true, dynacast: true),
      fastConnectOptions: lk.FastConnectOptions(
        microphone: lk.TrackOption(enabled: true),
        camera: lk.TrackOption(enabled: cameraEnabled),
      ),
    );
    _localParticipant = _room!.localParticipant;

    _initRoomListeners();
    _updateLiveParticipants(participants);
    _startConnectionHealthMonitor();
    _reconnectGraceTimer?.cancel();

    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      lk.Hardware.instance.setSpeakerphoneOn(true);
    }

    _room!.addListener(_onConnectionStateChange);
    _state = state.copyWith(
      isConnected: true,
      isReconnecting: false,
      reconnectAttempt: 0,
      hasJoined: true,
      error: null,
    );
    WakelockPlus.enable();
  }

  void _onConnectionStateChange() {
    if (_room == null || _room!.isDisposed) return;

    final connectionState = _room!.connectionState;
    final isNowConnected = connectionState == lk.ConnectionState.connected;
    final isNowReconnecting =
        connectionState == lk.ConnectionState.reconnecting ||
            connectionState == lk.ConnectionState.connecting;

    _state = state.copyWith(
      isConnected: isNowConnected,
      isReconnecting: isNowReconnecting || _isReconnecting,
      isMicrophoneEnabled: _localParticipant?.isMicrophoneEnabled() ?? false,
      isCameraEnabled: _localParticipant?.isCameraEnabled() ?? false,
      isScreenSharing: _localParticipant?.isScreenShareEnabled() ?? false,
    );

    if (isNowConnected) {
      WakelockPlus.enable();
      _reconnectAttempts = 0;
      _isReconnecting = false;
      _reconnectGraceTimer?.cancel();
      _state = state.copyWith(isReconnecting: false, reconnectAttempt: 0);
      return;
    }

    if (isNowReconnecting) {
      _scheduleReconnect();
      return;
    }

    if (connectionState == lk.ConnectionState.disconnected &&
        !_isManualDisconnect) {
      _scheduleReconnect(force: true);
    }
  }

  void _startConnectionHealthMonitor() {
    _connectionHealthTimer?.cancel();
    _connectionHealthTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkConnectionHealth(),
    );
  }

  void _checkConnectionHealth() {
    if (_room == null || _room!.isDisposed) return;

    final connectionState = _room!.connectionState;
    if (connectionState == lk.ConnectionState.connected ||
        connectionState == lk.ConnectionState.reconnecting ||
        connectionState == lk.ConnectionState.connecting) {
      return;
    }

    if (!_isManualDisconnect) {
      Logger.root.warning(
        '[Call] Connection health check failed: $connectionState',
      );
      _scheduleReconnect(force: true);
    }
  }

  void _scheduleReconnect({bool force = false}) {
    if (_isManualDisconnect || !_shouldAutoReconnect || _currentRoom == null) {
      return;
    }

    _state = state.copyWith(
      isConnected: false,
      isReconnecting: true,
      reconnectAttempt: _reconnectAttempts,
      error: null,
    );

    if (!force) {
      if (_reconnectGraceTimer?.isActive ?? false) return;
      _reconnectGraceTimer = Timer(const Duration(seconds: 8), () {
        _attemptReconnect();
      });
      return;
    }

    _reconnectGraceTimer?.cancel();
    _attemptReconnect();
  }

  Future<void> _attemptReconnect() async {
    if (_isReconnecting || !_shouldAutoReconnect || _currentRoom == null) {
      return;
    }
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      Logger.root.severe('[Call] Max reconnection attempts reached');
      _state = state.copyWith(
        isReconnecting: false,
        reconnectAttempt: _reconnectAttempts,
        error: 'Connection lost. Please rejoin the call.',
      );
      return;
    }

    _isReconnecting = true;
    _reconnectAttempts++;
    _state = state.copyWith(
      isConnected: false,
      isReconnecting: true,
      reconnectAttempt: _reconnectAttempts,
      error: null,
    );

    final delay = Duration(
      milliseconds:
          (_baseReconnectDelay.inMilliseconds * (1 << (_reconnectAttempts - 1)))
              .clamp(
                _baseReconnectDelay.inMilliseconds,
                _maxReconnectDelay.inMilliseconds,
              ) +
          (DateTime.now().millisecond % 1000),
    );

    Logger.root.info(
      '[Call] Attempting reconnect $_reconnectAttempts/$_maxReconnectAttempts in ${delay.inSeconds}s',
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () async {
      try {
        if (_room != null) {
          _room!.removeListener(_onConnectionStateChange);
          _isManualDisconnect = true;
          await _room!.disconnect();
          await _room!.dispose();
          _isManualDisconnect = false;
        }
        _room = null;
        _localParticipant = null;

        await _performConnection(_currentRoom!,
            cameraEnabled: state.isCameraEnabled);
        Logger.root.info('[Call] Reconnection successful');
        _reconnectAttempts = 0;
        _isReconnecting = false;
      } catch (e) {
        Logger.root.severe('[Call] Reconnection failed: $e');
        _isReconnecting = false;
        _state = state.copyWith(
          isConnected: false,
          isReconnecting: true,
          reconnectAttempt: _reconnectAttempts,
          error: null,
        );
        _scheduleReconnect(force: true);
      }
    });
  }

  Future<void> toggleMicrophone() async {
    if (_localParticipant != null) {
      const autostop = true;
      final target = !_localParticipant!.isMicrophoneEnabled();
      _state = state.copyWith(isMicrophoneEnabled: target);
      if (target) {
        await _localParticipant!.audioTrackPublications.firstOrNull?.unmute(
          stopOnMute: autostop,
        );
      } else {
        await _localParticipant!.audioTrackPublications.firstOrNull?.mute(
          stopOnMute: autostop,
        );
      }
      _state = state.copyWith();
    }
  }

  Future<void> toggleCamera() async {
    if (_localParticipant != null) {
      final target = !_localParticipant!.isCameraEnabled();
      _state = state.copyWith(isCameraEnabled: target);
      await _localParticipant!.setCameraEnabled(target);
      _state = state.copyWith();
    }
  }

  Future<void> toggleScreenShare(BuildContext context) async {
    if (_localParticipant != null) {
      final target = !_localParticipant!.isScreenShareEnabled();
      _state = state.copyWith(isScreenSharing: target);

      if (target && lk.lkPlatformIsDesktop()) {
        try {
          final source = await showDialog<DesktopCapturerSource>(
            context: context,
            builder: (context) => lk.ScreenSelectDialog(),
          );
          if (source == null) {
            return;
          }
          var track = await lk.LocalVideoTrack.createScreenShareTrack(
            lk.ScreenShareCaptureOptions(
              sourceId: source.id,
              maxFrameRate: 30.0,
              captureScreenAudio: true,
              useiOSBroadcastExtension: true,
            ),
          );
          await _localParticipant!.publishVideoTrack(track);
        } catch (err) {
          showErrorAlert(err);
        }
        return;
      } else {
        await _localParticipant!.setScreenShareEnabled(target);
      }

      _state = state.copyWith();
    }
  }

  Future<void> toggleSpeakerphone() async {
    _state = state.copyWith(isSpeakerphone: !state.isSpeakerphone);
    await lk.Hardware.instance.setSpeakerphoneOn(state.isSpeakerphone);
    _state = state.copyWith();
  }

  Future<void> disconnect() async {
    _shouldAutoReconnect = false;
    _reconnectGraceTimer?.cancel();
    _reconnectTimer?.cancel();
    if (_room != null) {
      _isManualDisconnect = true;
      await _room!.disconnect();
      _state = state.copyWith(
        isConnected: false,
        isReconnecting: false,
        isMicrophoneEnabled: false,
        isCameraEnabled: false,
        isScreenSharing: false,
        reconnectAttempt: 0,
      );
      _isManualDisconnect = false;
      WakelockPlus.disable();
    }
  }

  Future<void> muteParticipantByAccountId(String targetAccountId) async {
    if (_roomId == null || _roomId!.isEmpty) {
      throw StateError('No active room');
    }
    if (!_isAdmin) {
      throw StateError('Only room admins can mute participants');
    }
    await _apiClient.post(
      '/messager/chat/realtime/$_roomId/mute/$targetAccountId',
    );
  }

  Future<void> unmuteParticipantByAccountId(String targetAccountId) async {
    if (_roomId == null || _roomId!.isEmpty) {
      throw StateError('No active room');
    }
    if (!_isAdmin) {
      throw StateError('Only room admins can unmute participants');
    }
    await _apiClient.post(
      '/messager/chat/realtime/$_roomId/unmute/$targetAccountId',
    );
  }

  Future<void> kickParticipantByAccountId(String targetAccountId) async {
    if (_roomId == null || _roomId!.isEmpty) {
      throw StateError('No active room');
    }
    if (!_isAdmin) {
      throw StateError('Only room admins can kick participants');
    }
    await _apiClient.post(
      '/messager/chat/realtime/$_roomId/kick/$targetAccountId',
    );
  }

  void setParticipantVolume(CallParticipantLive live, double volume) {
    if (participantsVolumes[live.remoteParticipant.sid] == null) {
      participantsVolumes[live.remoteParticipant.sid] = 1;
    }
    Helper.setVolume(
      volume,
      live
          .remoteParticipant
          .audioTrackPublications
          .first
          .track!
          .mediaStreamTrack,
    );
    participantsVolumes[live.remoteParticipant.sid] = volume;
  }

  double getParticipantVolume(CallParticipantLive live) {
    return participantsVolumes[live.remoteParticipant.sid] ?? 1;
  }

  void toggleViewMode() {
    _state = state.copyWith(
      viewMode: state.viewMode == ViewMode.grid ? ViewMode.stage : ViewMode.grid,
    );
  }

  bool _disposed = false;
  bool get isDisposed => _disposed;

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _shouldAutoReconnect = false;
    _reconnectTimer?.cancel();
    _connectionHealthTimer?.cancel();
    _reconnectGraceTimer?.cancel();
    _isReconnecting = false;
    _isManualDisconnect = true;

    _state = state.copyWith(
      error: null,
      isConnected: false,
      isReconnecting: false,
      isMicrophoneEnabled: false,
      isCameraEnabled: false,
      isScreenSharing: false,
      reconnectAttempt: 0,
      hasJoined: false,
      joinedAt: null,
      duration: Duration.zero,
    );
    _room?.removeListener(_onConnectionStateChange);
    _roomListener?.dispose();
    _room?.disconnect();
    _room?.dispose();
    _durationTimer?.cancel();
    _roomId = null;
    _currentRoom = null;
    _isAdmin = false;
    _participants = [];
    _participantInfoByIdentity.clear();
    participantsVolumes = {};
    WakelockPlus.disable();
    stateNotifier.dispose();
  }
}
