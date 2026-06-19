import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/core/network.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'call.g.dart';
part 'call.freezed.dart';

enum ViewMode { grid, stage }

String formatDuration(Duration duration) {
  String negativeSign = duration.isNegative ? '-' : '';
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
  return "$negativeSign${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}

@freezed
sealed class CallState with _$CallState {
  const factory CallState({
    required bool isConnected,
    @Default(false) bool isReconnecting,
    required bool isMicrophoneEnabled,
    required bool isCameraEnabled,
    required bool isScreenSharing,
    required bool isSpeakerphone,
    @Default(Duration(seconds: 0)) Duration duration,
    DateTime? joinedAt,
    @Default(ViewMode.grid) ViewMode viewMode,
    @Default(0) int participantSyncVersion,
    @Default(0) int reconnectAttempt,
    @Default(false) bool hasJoined,
    String? error,
  }) = _CallState;
}

@freezed
sealed class CallParticipantLive with _$CallParticipantLive {
  const CallParticipantLive._();

  const factory CallParticipantLive({
    required CallParticipant participant,
    required lk.Participant remoteParticipant,
  }) = _CallParticipantLive;

  bool get isSpeaking => remoteParticipant.isSpeaking;
  bool get isMuted =>
      remoteParticipant.isMuted || !remoteParticipant.isMicrophoneEnabled();
  bool get isScreenSharing => remoteParticipant.isScreenShareEnabled();
  bool get isScreenSharingWithAudio =>
      remoteParticipant.isScreenShareAudioEnabled();

  bool get hasVideo => remoteParticipant.hasVideo;
  bool get hasAudio => remoteParticipant.hasAudio;
}

@Riverpod(keepAlive: true)
class CallNotifier extends _$CallNotifier {
  lk.Room? _room;
  lk.LocalParticipant? _localParticipant;
  List<CallParticipantLive> _participants = [];
  final Map<String, CallParticipant> _participantInfoByIdentity = {};
  lk.EventsListener? _roomListener;
  bool _isAdmin = false;

  List<CallParticipantLive> get participants =>
      List.unmodifiable(_participants);
  lk.LocalParticipant? get localParticipant => _localParticipant;

  Map<String, double> participantsVolumes = {};

  Timer? _durationTimer;
  Timer? _reconnectTimer;
  Timer? _connectionHealthTimer;
  Timer? _reconnectGraceTimer;

  lk.Room? get room => _room;
  bool get isAdmin => _isAdmin;

  // Reconnection state
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  static const Duration _baseReconnectDelay = Duration(seconds: 1);
  static const Duration _maxReconnectDelay = Duration(seconds: 30);
  bool _isReconnecting = false;
  bool _shouldAutoReconnect = true;
  bool _isManualDisconnect = false;

  static int get maxReconnectAttempts => _maxReconnectAttempts;

  SnChatRoom? _currentRoom;

  @override
  CallState build() {
    // Subscribe to websocket updates
    return const CallState(
      isConnected: false,
      isReconnecting: false,
      isMicrophoneEnabled: true,
      isCameraEnabled: false,
      isScreenSharing: false,
      isSpeakerphone: true,
      viewMode: ViewMode.grid,
      participantSyncVersion: 0,
    );
  }

  void _bumpParticipantSync() {
    state = state.copyWith(
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
    // Add local participant first if available
    if (_localParticipant != null) {
      final localInfo = _buildParticipant();
      _participants.add(
        CallParticipantLive(
          participant: localInfo,
          remoteParticipant: _localParticipant!,
        ),
      );
    }
    // Add remote participants
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

  /// Builds the CallParticipant object for the local participant.
  /// Optionally, pass [participants] if you want to prioritize info from the latest list.
  CallParticipant _buildParticipant({List<CallParticipant>? participants}) {
    if (_localParticipant == null) {
      throw StateError('No local participant available');
    }
    // Prefer info from the latest participants list if available
    if (participants != null) {
      final idx = participants.indexWhere(
        (p) => p.identity == _localParticipant!.identity,
      );
      if (idx != -1) return participants[idx];
    }

    // Otherwise, use info from the identity map or fallback to minimal
    return _participantInfoByIdentity[_localParticipant!.identity] ??
        CallParticipant(
          identity: _localParticipant!.identity,
          name: _localParticipant!.identity,
          joinedAt: DateTime.now(),
        );
  }

  void _updateLiveParticipants(List<CallParticipant> participants) {
    // Update the info map for lookup
    for (final p in participants) {
      _participantInfoByIdentity[p.identity] = p;
    }
    if (_room == null) {
      // Can't build live objects, just store empty
      _participants = [];
      _bumpParticipantSync();
      return;
    }
    final remoteParticipants = _room!.remoteParticipants;
    final remotes = remoteParticipants.values.toList();
    _participants = [];
    // Add local participant if present in the list
    if (_localParticipant != null) {
      final localInfo = _buildParticipant(participants: participants);
      _participants.add(
        CallParticipantLive(
          participant: localInfo,
          remoteParticipant: _localParticipant!,
        ),
      );
    }
    // Add remote participants
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
          return null; // Already added local
        }
        return remote != null
            ? CallParticipantLive(participant: p, remoteParticipant: remote)
            : null;
      }).whereType<CallParticipantLive>(),
    );
    _bumpParticipantSync();
  }

  String? _roomId;
  String? get roomId => _roomId;

  SnChatRoom? _chatRoom;
  SnChatRoom? get chatRoom => _chatRoom;

  Future<void> joinRoom(SnChatRoom room) async {
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
      await _performConnection(room);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> _performConnection(SnChatRoom room) async {
    // Request microphone permission on macOS before connecting
    if (!kIsWeb && Platform.isMacOS) {
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        throw Exception('Microphone permission is required for calls');
      }
    }

    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get(
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

    // Setup duration timer
    final joinedAt = DateTime.now();
    if (!state.hasJoined || state.joinedAt == null) {
      state = state.copyWith(joinedAt: joinedAt, duration: Duration.zero);
      _durationTimer?.cancel();
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final baseJoinedAt = state.joinedAt;
        if (baseJoinedAt == null) return;
        state = state.copyWith(
          duration: DateTime.now().difference(baseJoinedAt),
        );
      });
    }

    // Connect to LiveKit
    _room = lk.Room();

    await _room!.connect(
      endpoint,
      token,
      connectOptions: lk.ConnectOptions(autoSubscribe: true),
      roomOptions: lk.RoomOptions(adaptiveStream: true, dynacast: true),
      fastConnectOptions: lk.FastConnectOptions(
        microphone: lk.TrackOption(enabled: true),
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

    // Listen for connection updates
    _room!.addListener(_onConnectionStateChange);
    state = state.copyWith(
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

    state = state.copyWith(
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
      state = state.copyWith(isReconnecting: false, reconnectAttempt: 0);
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

    state = state.copyWith(
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
      state = state.copyWith(
        isReconnecting: false,
        reconnectAttempt: _reconnectAttempts,
        error: 'Connection lost. Please rejoin the call.',
      );
      return;
    }

    _isReconnecting = true;
    _reconnectAttempts++;
    state = state.copyWith(
      isConnected: false,
      isReconnecting: true,
      reconnectAttempt: _reconnectAttempts,
      error: null,
    );

    // Exponential backoff with jitter
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
        // Clean up old connection
        if (_room != null) {
          _room!.removeListener(_onConnectionStateChange);
          _isManualDisconnect = true;
          await _room!.disconnect();
          await _room!.dispose();
          _isManualDisconnect = false;
        }
        _room = null;
        _localParticipant = null;

        await _performConnection(_currentRoom!);
        Logger.root.info('[Call] Reconnection successful');
        _reconnectAttempts = 0;
        _isReconnecting = false;
      } catch (e) {
        Logger.root.severe('[Call] Reconnection failed: $e');
        _isReconnecting = false;
        state = state.copyWith(
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
      state = state.copyWith(isMicrophoneEnabled: target);
      if (target) {
        await _localParticipant!.audioTrackPublications.firstOrNull?.unmute(
          stopOnMute: autostop,
        );
      } else {
        await _localParticipant!.audioTrackPublications.firstOrNull?.mute(
          stopOnMute: autostop,
        );
      }
      state = state.copyWith();
    }
  }

  Future<void> toggleCamera() async {
    if (_localParticipant != null) {
      final target = !_localParticipant!.isCameraEnabled();
      state = state.copyWith(isCameraEnabled: target);
      await _localParticipant!.setCameraEnabled(target);
      state = state.copyWith();
    }
  }

  Future<void> toggleScreenShare(BuildContext context) async {
    if (_localParticipant != null) {
      final target = !_localParticipant!.isScreenShareEnabled();
      state = state.copyWith(isScreenSharing: target);

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

      state = state.copyWith();
    }
  }

  Future<void> toggleSpeakerphone() async {
    state = state.copyWith(isSpeakerphone: !state.isSpeakerphone);
    await lk.Hardware.instance.setSpeakerphoneOn(state.isSpeakerphone);
    state = state.copyWith();
  }

  Future<void> disconnect() async {
    _shouldAutoReconnect = false;
    _reconnectGraceTimer?.cancel();
    _reconnectTimer?.cancel();
    if (_room != null) {
      _isManualDisconnect = true;
      await _room!.disconnect();
      state = state.copyWith(
        isConnected: false,
        isReconnecting: false,
        isMicrophoneEnabled: false,
        isCameraEnabled: false,
        isScreenSharing: false,
        reconnectAttempt: 0,
      );
      _isManualDisconnect = false;
      // Disable wakelock when call disconnects
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

    final apiClient = ref.read(apiClientProvider);
    await apiClient.post(
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

    final apiClient = ref.read(apiClientProvider);
    await apiClient.post(
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

    final apiClient = ref.read(apiClientProvider);
    await apiClient.post(
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
    state = state.copyWith(
      viewMode: state.viewMode == ViewMode.grid
          ? ViewMode.stage
          : ViewMode.grid,
    );
  }

  void dispose() {
    _shouldAutoReconnect = false;
    _reconnectTimer?.cancel();
    _connectionHealthTimer?.cancel();
    _reconnectGraceTimer?.cancel();
    _isReconnecting = false;
    _isManualDisconnect = true;

    state = state.copyWith(
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
  }
}
