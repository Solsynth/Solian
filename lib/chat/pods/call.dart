import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/core/network.dart';
import 'package:island/chat/pods/call_controller.dart';

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

/// Riverpod wrapper that delegates all call logic to [CallController].
/// The controller is created lazily on first [joinRoom] call.
@Riverpod(keepAlive: true)
class CallNotifier extends _$CallNotifier {
  CallController? _controller;
  void _syncState() {
    if (_controller != null) state = _controller!.stateNotifier.value;
  }

  CallController get _ctrl {
    if (_controller == null) {
      throw StateError('CallNotifier not initialized — call joinRoom first');
    }
    return _controller!;
  }

  // ponytail: expose controller for sub-windows that need direct access
  CallController? get controller => _controller;

  List<CallParticipantLive> get participants => _ctrl.participants;
  lk.LocalParticipant? get localParticipant => _ctrl.localParticipant;
  lk.Room? get room => _ctrl.room;
  bool get isAdmin => _ctrl.isAdmin;
  String? get roomId => _ctrl.roomId;
  SnChatRoom? get chatRoom => _ctrl.chatRoom;
  Map<String, double> get participantsVolumes => _ctrl.participantsVolumes;

  static int get maxReconnectAttempts => CallController.maxReconnectAttempts;

  @override
  CallState build() {
    ref.onDispose(() {
      _controller?.stateNotifier.removeListener(_syncState);
      _controller?.dispose();
    });
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

  CallController _ensureController() {
    if (_controller != null) return _controller!;
    final apiClient = ref.read(apiClientProvider);
    _controller = CallController(apiClient: apiClient);
    _controller!.stateNotifier.addListener(_syncState);
    return _controller!;
  }

  Future<void> joinRoom(SnChatRoom room, {bool cameraEnabled = false}) async {
    final ctrl = _ensureController();
    await ctrl.joinRoom(room, cameraEnabled: cameraEnabled);
  }

  Future<void> toggleMicrophone() => _ctrl.toggleMicrophone();
  Future<void> toggleCamera() => _ctrl.toggleCamera();
  Future<void> toggleScreenShare(BuildContext context) =>
      _ctrl.toggleScreenShare(context);
  Future<void> toggleSpeakerphone() => _ctrl.toggleSpeakerphone();
  Future<void> disconnect() => _ctrl.disconnect();

  Future<void> muteParticipantByAccountId(String id) =>
      _ctrl.muteParticipantByAccountId(id);
  Future<void> unmuteParticipantByAccountId(String id) =>
      _ctrl.unmuteParticipantByAccountId(id);
  Future<void> kickParticipantByAccountId(String id) =>
      _ctrl.kickParticipantByAccountId(id);

  void setParticipantVolume(CallParticipantLive live, double volume) =>
      _ctrl.setParticipantVolume(live, volume);
  double getParticipantVolume(CallParticipantLive live) =>
      _ctrl.getParticipantVolume(live);

  void toggleViewMode() => _ctrl.toggleViewMode();

  void dispose() {
    // ponytail: controller may already be disposed by ref.onDispose
    if (_controller != null && !_controller!.isDisposed) {
      _controller!.stateNotifier.removeListener(_syncState);
      _controller!.dispose();
    }
    _controller = null;
    state = const CallState(
      isConnected: false,
      isReconnecting: false,
      isMicrophoneEnabled: false,
      isCameraEnabled: false,
      isScreenSharing: false,
      isSpeakerphone: true,
      viewMode: ViewMode.grid,
      participantSyncVersion: 0,
    );
  }
}
