import 'dart:async';

import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:livekit_noise_filter/livekit_noise_filter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/types/chat.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ChatCallProvider extends ChangeNotifier {
  late final SnNetworkProvider _sn;

  ChatCallProvider(BuildContext context) {
    _sn = context.read<SnNetworkProvider>();
  }

  SnChatCall? _current;
  SnChannel? _channel;

  bool _isReady = false;
  bool _isMounted = false;
  bool _isInitialized = false;
  bool _isBusy = false;

  String _lastDuration = '00:00:00';
  Timer? _lastDurationUpdateTimer;

  String? token;
  String? endpoint;

  StreamSubscription? hwSubscription;
  List<MediaDevice> _audioInputs = [];
  List<MediaDevice> _videoInputs = [];

  bool _enableAudio = true;
  bool _enableVideo = false;
  LocalAudioTrack? _audioTrack;
  LocalVideoTrack? _videoTrack;
  MediaDevice? _videoDevice;
  MediaDevice? _audioDevice;

  late Room _room;
  late EventsListener<RoomEvent> _listener;

  List<ParticipantTrack> _participantTracks = [];
  ParticipantTrack? _focusTrack;

  // Getters for private fields
  SnChatCall? get current => _current;
  SnChannel? get channel => _channel;
  bool get isReady => _isReady;
  bool get isMounted => _isMounted;
  bool get isInitialized => _isInitialized;
  bool get isBusy => _isBusy;
  String get lastDuration => _lastDuration;
  List<MediaDevice> get audioInputs => _audioInputs;
  List<MediaDevice> get videoInputs => _videoInputs;
  bool get enableAudio => _enableAudio;
  bool get enableVideo => _enableVideo;
  LocalAudioTrack? get audioTrack => _audioTrack;
  LocalVideoTrack? get videoTrack => _videoTrack;
  MediaDevice? get videoDevice => _videoDevice;
  MediaDevice? get audioDevice => _audioDevice;
  List<ParticipantTrack> get participantTracks => _participantTracks;
  ParticipantTrack? get focusTrack => _focusTrack;
  Room get room => _room;

  void _updateDuration() {
    if (_current == null) {
      _lastDuration = '00:00:00';
    } else {
      Duration duration = DateTime.now().difference(_current!.createdAt);
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      _lastDuration = '${twoDigits(duration.inHours)}:'
          '${twoDigits(duration.inMinutes.remainder(60))}:'
          '${twoDigits(duration.inSeconds.remainder(60))}';
    }
    notifyListeners();
  }

  void enableDurationUpdater() {
    _updateDuration();
    _lastDurationUpdateTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateDuration(),
    );
  }

  void disableDurationUpdater() {
    _lastDurationUpdateTimer?.cancel();
    _lastDurationUpdateTimer = null;
  }

  Future<void> checkPermissions() async {
    if (lkPlatformIs(PlatformType.macOS) || lkPlatformIs(PlatformType.linux)) {
      return;
    }

    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothConnect.request();
  }

  void setCall(SnChatCall call, SnChannel related) {
    _current = call;
    _channel = related;
    notifyListeners();
  }

  Future<(String, String)> getRoomToken() async {
    final resp = await _sn.client.post(
      '/cgi/im/channels/${_channel!.keyPath}/calls/ongoing/token',
    );
    token = resp.data['token'];
    endpoint = 'wss://${resp.data['endpoint']}';
    return (token!, endpoint!);
  }

  void initHardware() {
    if (_isReady) return;

    _isReady = true;
    hwSubscription = Hardware.instance.onDeviceChange.stream.listen(
      _revertDevices,
    );
    Hardware.instance.enumerateDevices().then(_revertDevices);
    notifyListeners();
  }

  void initRoom() {
    initHardware();
    final timeout = const Duration(seconds: 60);
    _room = Room(
      roomOptions: RoomOptions(
        dynacast: true,
        adaptiveStream: true,
        defaultAudioCaptureOptions: AudioCaptureOptions(
          processor: LiveKitNoiseFilter(),
        ),
        defaultAudioPublishOptions: AudioPublishOptions(
          name: 'call_voice',
          stream: 'call_stream',
        ),
        defaultVideoPublishOptions: VideoPublishOptions(
          name: 'call_video',
          stream: 'call_stream',
          simulcast: true,
          backupVideoCodec: BackupVideoCodec(enabled: true),
        ),
        defaultScreenShareCaptureOptions: ScreenShareCaptureOptions(
          useiOSBroadcastExtension: true,
          params: VideoParametersPresets.screenShareH1080FPS30,
        ),
        defaultCameraCaptureOptions: CameraCaptureOptions(
          maxFrameRate: 30,
          params: VideoParametersPresets.h1080_169,
        ),
      ),
      connectOptions: ConnectOptions(
        autoSubscribe: true,
        timeouts: Timeouts(
          connection: timeout,
          debounce: timeout,
          publish: timeout,
          peerConnection: timeout,
          iceRestart: timeout,
        ),
      ),
    );
    _listener = _room.createListener();
    WakelockPlus.enable();
  }

  Future<void> joinRoom(String url, String token) async {
    if (_isMounted) return;

    try {
      await _room.connect(
        url,
        token,
        fastConnectOptions: FastConnectOptions(
          microphone: TrackOption(track: _audioTrack),
          camera: TrackOption(track: _videoTrack),
        ),
      );
    } finally {
      _isMounted = true;
      notifyListeners();
    }
  }

  void setupRoom() {
    if (isInitialized) return;

    sortParticipants();
    _room.addListener(_onRoomDidUpdate);
    WidgetsBindingCompatible.instance?.addPostFrameCallback(
      (_) => autoPublish(),
    );

    if (lkPlatformIsMobile()) {
      Hardware.instance.setSpeakerphoneOn(true);
    }

    _isBusy = false;
    _isInitialized = true;
    notifyListeners();
  }

  void autoPublish() async {
    try {
      if (enableVideo) {
        await _room.localParticipant?.setCameraEnabled(true);
      }
      if (enableAudio) {
        await _room.localParticipant?.setMicrophoneEnabled(true);
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> setEnableAudio(bool value) async {
    _enableAudio = value;
    if (!_enableAudio) {
      await _audioTrack?.stop();
      _audioTrack = null;
    } else {
      await _changeLocalAudioTrack();
    }
    notifyListeners();
  }

  Future<void> setEnableVideo(bool value) async {
    _enableVideo = value;
    if (!_enableVideo) {
      await _videoTrack?.stop();
      _videoTrack = null;
    } else {
      await _changeLocalVideoTrack();
    }
    notifyListeners();
  }

  void setupRoomListeners({
    required Function(DisconnectReason?) onDisconnected,
  }) {
    _listener
      ..on<RoomDisconnectedEvent>((event) async {
        onDisconnected(event.reason);
      })
      ..on<ParticipantEvent>((event) => sortParticipants())
      ..on<LocalTrackPublishedEvent>((_) => sortParticipants())
      ..on<LocalTrackUnpublishedEvent>((_) => sortParticipants())
      ..on<TrackSubscribedEvent>((_) => sortParticipants())
      ..on<TrackUnsubscribedEvent>((_) => sortParticipants())
      ..on<ParticipantNameUpdatedEvent>((event) {
        sortParticipants();
      });
  }

  void sortParticipants() {
    Map<String, ParticipantTrack> mediaTracks = {};
    for (var participant in _room.remoteParticipants.values) {
      mediaTracks[participant.sid] = ParticipantTrack(
        participant: participant,
        videoTrack: null,
        isScreenShare: false,
      );

      for (var t in participant.videoTrackPublications) {
        mediaTracks[participant.sid]?.videoTrack = t.track;
        mediaTracks[participant.sid]?.isScreenShare = t.isScreenShare;
      }
    }

    final newTracks = List<ParticipantTrack>.empty(growable: true);

    final mediaTrackList = mediaTracks.values.toList();
    mediaTrackList.sort((a, b) {
      // Loudest people first
      if (a.participant.isSpeaking && b.participant.isSpeaking) {
        if (a.participant.audioLevel > b.participant.audioLevel) {
          return -1;
        } else {
          return 1;
        }
      }

      // Last spoke first
      final aSpokeAt = a.participant.lastSpokeAt?.millisecondsSinceEpoch ?? 0;
      final bSpokeAt = b.participant.lastSpokeAt?.millisecondsSinceEpoch ?? 0;

      if (aSpokeAt != bSpokeAt) {
        return aSpokeAt > bSpokeAt ? -1 : 1;
      }

      // Has video first
      if (a.participant.hasVideo != b.participant.hasVideo) {
        return a.participant.hasVideo ? -1 : 1;
      }

      // First joined people first
      return a.participant.joinedAt.millisecondsSinceEpoch -
          b.participant.joinedAt.millisecondsSinceEpoch;
    });

    newTracks.addAll(mediaTrackList);

    if (_room.localParticipant != null) {
      ParticipantTrack localTrack = ParticipantTrack(
        participant: _room.localParticipant!,
        videoTrack: null,
        isScreenShare: false,
      );

      final localParticipantTracks =
          _room.localParticipant?.videoTrackPublications;
      if (localParticipantTracks != null) {
        for (var t in localParticipantTracks) {
          localTrack.videoTrack = t.track;
          localTrack.isScreenShare = t.isScreenShare;
        }
      }

      newTracks.add(localTrack);
    }

    _participantTracks = newTracks;

    if (focusTrack != null) {
      final idx = participantTracks
          .indexWhere((x) => x.participant.sid == _focusTrack!.participant.sid);
      if (idx == -1) {
        _focusTrack = null;
      }
    }

    if (focusTrack == null) {
      _focusTrack = participantTracks.firstOrNull;
    } else {
      final idx = participantTracks.indexWhere(
        (x) => _focusTrack!.participant.sid == x.participant.sid,
      );
      if (idx > -1) {
        _focusTrack = participantTracks[idx];
      }
    }

    notifyListeners();
  }

  Future<void> _changeLocalAudioTrack() async {
    if (_audioTrack != null) {
      await _audioTrack!.stop();
      _audioTrack = null;
    }

    if (_audioDevice != null) {
      _audioTrack = await LocalAudioTrack.create(
        AudioCaptureOptions(deviceId: _audioDevice!.deviceId),
      );
      await _audioTrack!.start();
    }
    notifyListeners();
  }

  Future<void> _changeLocalVideoTrack() async {
    if (_videoTrack != null) {
      await _videoTrack!.stop();
      _videoTrack = null;
    }

    if (_videoDevice != null) {
      _videoTrack = await LocalVideoTrack.createCameraTrack(
        CameraCaptureOptions(
          deviceId: _videoDevice!.deviceId,
          params: VideoParametersPresets.h1080_169,
        ),
      );
      await _videoTrack!.start();
    }
    notifyListeners();
  }

  void _revertDevices(List<MediaDevice> devices) {
    _audioInputs = devices.where((d) => d.kind == 'audioinput').toList();
    _videoInputs = devices.where((d) => d.kind == 'videoinput').toList();
    notifyListeners();
  }

  void _onRoomDidUpdate() => sortParticipants();

  Future<void> changeLocalAudioTrack() async {
    if (audioTrack != null) {
      await audioTrack!.stop();
      _audioTrack = null;
    }

    if (audioDevice != null) {
      _audioTrack = await LocalAudioTrack.create(
        AudioCaptureOptions(
          deviceId: audioDevice!.deviceId,
        ),
      );
      await audioTrack!.start();
    }
  }

  Future<void> changeLocalVideoTrack() async {
    if (videoTrack != null) {
      await _videoTrack!.stop();
      _videoTrack = null;
    }

    if (videoDevice != null) {
      _videoTrack = await LocalVideoTrack.createCameraTrack(
        CameraCaptureOptions(
          deviceId: videoDevice!.deviceId,
          params: VideoParametersPresets.h1080_169,
        ),
      );
      await videoTrack!.start();
    }
  }

  void deactivateHardware() {
    hwSubscription?.cancel();
  }

  void disposeRoom() {
    _isBusy = false;
    _isMounted = false;
    _isInitialized = false;
    _current = null;
    _channel = null;
    _room.removeListener(_onRoomDidUpdate);
    _room.disconnect();
    _room.dispose();
    _listener.dispose();
    WakelockPlus.disable();
  }

  void disposeHardware() {
    _isReady = false;
    _audioTrack?.stop();
    _audioTrack = null;
    _videoTrack?.stop();
    _videoTrack = null;
  }

  void setVideoDevice(MediaDevice? value) {
    _videoDevice = value;
    notifyListeners();
  }

  void setAudioDevice(MediaDevice? value) {
    _audioDevice = value;
    notifyListeners();
  }

  void setFocusTrack(ParticipantTrack? value) {
    _focusTrack = value;
    notifyListeners();
  }

  void setIsBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }
}
