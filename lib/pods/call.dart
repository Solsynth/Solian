import 'dart:async';
import 'dart:developer';
import 'package:island/widgets/chat/call_button.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/pods/network.dart';
import 'package:island/models/chat.dart';

part 'call.g.dart';
part 'call.freezed.dart';

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
    required bool isMicrophoneEnabled,
    required bool isCameraEnabled,
    required bool isScreenSharing,
    @Default(Duration(seconds: 0)) Duration duration,
    String? error,
  }) = _CallState;
}

@freezed
sealed class CallParticipantLive with _$CallParticipantLive {
  const CallParticipantLive._();

  const factory CallParticipantLive({
    required CallParticipant participant,
    required Participant remoteParticipant,
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

@riverpod
class CallNotifier extends _$CallNotifier {
  Room? _room;
  LocalParticipant? _localParticipant;
  List<CallParticipantLive> _participants = [];
  final Map<String, CallParticipant> _participantInfoByIdentity = {};
  EventsListener? _roomListener;

  List<CallParticipantLive> get participants =>
      List.unmodifiable(_participants);
  LocalParticipant? get localParticipant => _localParticipant;

  Timer? _durationTimer;

  Room? get room => _room;

  @override
  CallState build() {
    // Subscribe to websocket updates
    return const CallState(
      isConnected: false,
      isMicrophoneEnabled: true,
      isCameraEnabled: false,
      isScreenSharing: false,
    );
  }

  void _initRoomListeners() {
    if (_room == null) return;
    _roomListener?.dispose();
    _roomListener = _room!.createListener();
    _room!.addListener(_onRoomChange);
    _roomListener!
      ..on<ParticipantConnectedEvent>((e) {
        _refreshLiveParticipants();
      })
      ..on<RoomDisconnectedEvent>((e) {
        _participants = [];
        state = state.copyWith();
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
    state = state.copyWith();
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
      state = state.copyWith();
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
      state = state.copyWith();
    }
    // Add remote participants
    _participants.addAll(
      participants.map((p) {
        RemoteParticipant? remote;
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
    state = state.copyWith();
  }

  String? _roomId;
  String? get roomId => _roomId;

  Future<void> joinRoom(String roomId) async {
    if (_roomId == roomId && _room != null) {
      log('[Call] Call skipped. Already has data');
      return;
    } else if (_room != null) {
      if (!_room!.isDisposed &&
          _room!.connectionState != ConnectionState.disconnected) {
        throw Exception('Call already connected');
      }
    }
    _roomId = roomId;
    if (_room != null) {
      await _room!.disconnect();
      await _room!.dispose();
      _room = null;
      _localParticipant = null;
      _participants = [];
    }
    try {
      final apiClient = ref.read(apiClientProvider);
      final ongoingCall = await ref.read(ongoingCallProvider(roomId).future);
      final response = await apiClient.get(
        '/sphere/chat/realtime/$roomId/join',
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        // Parse join response
        final joinResponse = ChatRealtimeJoinResponse.fromJson(data);
        final participants = joinResponse.participants;
        final String endpoint = joinResponse.endpoint;
        final String token = joinResponse.token;

        // Setup duration timer
        _durationTimer?.cancel();
        _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          state = state.copyWith(
            duration: Duration(
              milliseconds:
                  (DateTime.now().millisecondsSinceEpoch -
                      (ongoingCall?.createdAt.millisecondsSinceEpoch ??
                          DateTime.now().millisecondsSinceEpoch)),
            ),
          );
        });

        // Connect to LiveKit
        _room = Room();

        await _room!.connect(
          endpoint,
          token,
          connectOptions: ConnectOptions(autoSubscribe: true),
          roomOptions: RoomOptions(adaptiveStream: true, dynacast: true),
          fastConnectOptions: FastConnectOptions(
            microphone: TrackOption(enabled: true),
          ),
        );
        _localParticipant = _room!.localParticipant;

        _initRoomListeners();
        _updateLiveParticipants(participants);

        // Listen for connection updates
        _room!.addListener(() {
          state = state.copyWith(
            isConnected: _room!.connectionState == ConnectionState.connected,
            isMicrophoneEnabled: _localParticipant!.isMicrophoneEnabled(),
            isCameraEnabled: _localParticipant!.isCameraEnabled(),
            isScreenSharing: _localParticipant!.isScreenShareEnabled(),
          );
        });
        state = state.copyWith(isConnected: true);
      } else {
        state = state.copyWith(error: 'Failed to join room');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
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

  Future<void> toggleScreenShare() async {
    if (_localParticipant != null) {
      final target = !_localParticipant!.isScreenShareEnabled();
      state = state.copyWith(isScreenSharing: target);
      await _localParticipant!.setScreenShareEnabled(target);
      state = state.copyWith();
    }
  }

  Future<void> disconnect() async {
    if (_room != null) {
      await _room!.disconnect();
      state = state.copyWith(
        isConnected: false,
        isMicrophoneEnabled: false,
        isCameraEnabled: false,
        isScreenSharing: false,
      );
    }
  }

  void dispose() {
    state = state.copyWith(
      error: null,
      isConnected: false,
      isMicrophoneEnabled: false,
      isCameraEnabled: false,
      isScreenSharing: false,
    );
    _roomListener?.dispose();
    _room?.removeListener(_onRoomChange);
    _room?.dispose();
    _durationTimer?.cancel();
    _roomId = null;
  }
}
