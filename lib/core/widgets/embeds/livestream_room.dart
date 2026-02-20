import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' show Helper;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:easy_localization/easy_localization.dart';

class ChatMessage {
  final String sender;
  final String? senderIdentity;
  final String message;
  final bool isMine;
  final DateTime createdAt;

  const ChatMessage({
    required this.sender,
    required this.senderIdentity,
    required this.message,
    required this.isMine,
    required this.createdAt,
  });
}

class LivestreamRoomState {
  final lk.Room? room;
  final lk.VideoTrack? videoTrack;
  final bool isConnecting;
  final String? errorText;
  final int viewerCount;
  final double volume;
  final List<ChatMessage> messages;
  final bool isSendingChat;
  final bool isChatCollapsed;
  final bool? requestedStreamerMode;
  final String? localIdentity;
  final bool isStreamerIdentity;
  final bool isCameraEnabled;
  final bool isMicrophoneEnabled;
  final bool isScreenSharing;
  final List<String> remoteParticipantIdentities;

  const LivestreamRoomState({
    this.room,
    this.videoTrack,
    this.isConnecting = false,
    this.errorText,
    this.viewerCount = 0,
    this.volume = 1.0,
    this.messages = const [],
    this.isSendingChat = false,
    this.isChatCollapsed = false,
    this.requestedStreamerMode,
    this.localIdentity,
    this.isStreamerIdentity = false,
    this.isCameraEnabled = false,
    this.isMicrophoneEnabled = false,
    this.isScreenSharing = false,
    this.remoteParticipantIdentities = const [],
  });

  LivestreamRoomState copyWith({
    lk.Room? room,
    lk.VideoTrack? videoTrack,
    bool? isConnecting,
    String? errorText,
    int? viewerCount,
    double? volume,
    List<ChatMessage>? messages,
    bool? isSendingChat,
    bool? isChatCollapsed,
    bool? requestedStreamerMode,
    String? localIdentity,
    bool? isStreamerIdentity,
    bool? isCameraEnabled,
    bool? isMicrophoneEnabled,
    bool? isScreenSharing,
    List<String>? remoteParticipantIdentities,
    bool clearRoom = false,
    bool clearError = false,
    bool clearVideoTrack = false,
    bool clearRequestedStreamerMode = false,
    bool clearLocalIdentity = false,
  }) {
    return LivestreamRoomState(
      room: clearRoom ? null : (room ?? this.room),
      videoTrack: clearVideoTrack ? null : (videoTrack ?? this.videoTrack),
      isConnecting: isConnecting ?? this.isConnecting,
      errorText: clearError ? null : (errorText ?? this.errorText),
      viewerCount: viewerCount ?? this.viewerCount,
      volume: volume ?? this.volume,
      messages: messages ?? this.messages,
      isSendingChat: isSendingChat ?? this.isSendingChat,
      isChatCollapsed: isChatCollapsed ?? this.isChatCollapsed,
      requestedStreamerMode: clearRequestedStreamerMode
          ? null
          : (requestedStreamerMode ?? this.requestedStreamerMode),
      localIdentity: clearLocalIdentity
          ? null
          : (localIdentity ?? this.localIdentity),
      isStreamerIdentity: isStreamerIdentity ?? this.isStreamerIdentity,
      isCameraEnabled: isCameraEnabled ?? this.isCameraEnabled,
      isMicrophoneEnabled: isMicrophoneEnabled ?? this.isMicrophoneEnabled,
      isScreenSharing: isScreenSharing ?? this.isScreenSharing,
      remoteParticipantIdentities:
          remoteParticipantIdentities ?? this.remoteParticipantIdentities,
    );
  }
}

class LivestreamRoomNotifier extends Notifier<LivestreamRoomState> {
  final String livestreamId;
  lk.Room? _room;
  lk.EventsListener<lk.RoomEvent>? _roomListener;
  final Map<String, lk.RemoteAudioTrack> _subscribedAudioTracks = {};
  final ScrollController _chatScrollController = ScrollController();
  final TextEditingController _chatInputController = TextEditingController();

  LivestreamRoomNotifier(this.livestreamId);

  @override
  LivestreamRoomState build() {
    ref.onDispose(() {
      _roomListener?.dispose();
      _chatInputController.dispose();
      _chatScrollController.dispose();
      _room?.disconnect();
      _room?.dispose();
    });
    return const LivestreamRoomState();
  }

  TextEditingController get chatInputController => _chatInputController;
  ScrollController get chatScrollController => _chatScrollController;

  void appendMessage(ChatMessage message) {
    state = state.copyWith(messages: [...state.messages, message]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _applyVolume(lk.Room room, double volume) {
    for (final participant in room.remoteParticipants.values) {
      for (final publication in participant.audioTrackPublications) {
        final track = publication.track;
        if (track != null) {
          Helper.setVolume(volume, track.mediaStreamTrack);
        }
      }
    }
  }

  lk.VideoTrack? _findVideoTrack(lk.Room room) {
    for (final participant in room.remoteParticipants.values) {
      final publication = participant.trackPublications.values.firstWhereOrNull(
        (pub) =>
            pub.kind == lk.TrackType.VIDEO &&
            pub.track is lk.VideoTrack &&
            !pub.isDisposed,
      );
      if (publication?.track is lk.VideoTrack) {
        return publication!.track as lk.VideoTrack;
      }
    }
    final localPublication = room.localParticipant?.trackPublications.values
        .firstWhereOrNull(
          (pub) =>
              pub.kind == lk.TrackType.VIDEO &&
              pub.track is lk.VideoTrack &&
              !pub.isDisposed,
        );
    if (localPublication?.track is lk.VideoTrack) {
      return localPublication!.track as lk.VideoTrack;
    }
    return null;
  }

  void _syncLocalParticipantState() {
    final local = _room?.localParticipant;
    state = state.copyWith(
      localIdentity: local?.identity,
      isStreamerIdentity: (local?.identity ?? '').startsWith('streamer_'),
      isCameraEnabled: local?.isCameraEnabled() ?? false,
      isMicrophoneEnabled: local?.isMicrophoneEnabled() ?? false,
      isScreenSharing: local?.isScreenShareEnabled() ?? false,
    );
  }

  Future<void> connect({bool streamer = false}) async {
    if (state.isConnecting || _room != null) return;
    state = state.copyWith(
      isConnecting: true,
      clearError: true,
      requestedStreamerMode: streamer,
    );

    try {
      final client = ref.read(apiClientProvider);
      final streamResponse = await client.get(
        '/sphere/livestreams/$livestreamId',
      );
      final stream = SnLiveStream.fromJson(
        Map<String, dynamic>.from(streamResponse.data),
      );

      if (stream.status == SnLiveStreamStatus.ended) {
        state = state.copyWith(
          isConnecting: false,
          errorText: 'thisLivestreamHasEnded'.tr(),
        );
        return;
      }
      if (stream.status != SnLiveStreamStatus.active) {
        state = state.copyWith(
          isConnecting: false,
          errorText: 'thisLivestreamIsNotLiveYet'.tr(),
        );
        return;
      }

      final tokenResponse = await client.get(
        '/sphere/livestreams/$livestreamId/token',
        queryParameters: {'streamer': streamer},
      );
      final tokenData = Map<String, dynamic>.from(tokenResponse.data);
      final token = tokenData['token'] as String;
      final url = tokenData['url'] as String;

      if (token.isEmpty || url.isEmpty) {
        throw Exception('Invalid livestream token response.');
      }

      final room = lk.Room();
      final candidateUrls = {
        if (url.startsWith('wss://'))
          url
        else
          url.replaceFirst('ws://', 'wss://'),
        if (url.startsWith('wss://'))
          url.replaceFirst('wss://', 'ws://')
        else
          url,
      }.toList();

      Object? lastError;
      for (final endpoint in candidateUrls) {
        try {
          await room.connect(
            endpoint,
            token,
            connectOptions: lk.ConnectOptions(autoSubscribe: true),
            roomOptions: lk.RoomOptions(adaptiveStream: true, dynacast: true),
          );
          lastError = null;
          break;
        } catch (err) {
          lastError = err;
        }
      }
      if (lastError != null) throw lastError;

      _room = room;
      state = state.copyWith(messages: [], room: room, isConnecting: false);

      void syncVideoTrack() {
        final videoTrack = _findVideoTrack(room);
        final remoteIdentities = room.remoteParticipants.values
            .map((p) => p.identity)
            .toList(growable: false);
        state = state.copyWith(
          videoTrack: videoTrack,
          viewerCount: room.remoteParticipants.length,
          remoteParticipantIdentities: remoteIdentities,
        );
        _applyVolume(room, state.volume);
        _syncLocalParticipantState();
      }

      syncVideoTrack();

      _roomListener?.dispose();
      _roomListener = room.createListener();
      _roomListener!
        ..on<lk.ParticipantConnectedEvent>((_) => syncVideoTrack())
        ..on<lk.ParticipantDisconnectedEvent>((_) => syncVideoTrack())
        ..on<lk.TrackPublishedEvent>((_) => syncVideoTrack())
        ..on<lk.TrackSubscribedEvent>((e) {
          if (e.track is lk.RemoteAudioTrack) {
            final audioTrack = e.track as lk.RemoteAudioTrack;
            _subscribedAudioTracks[e.publication.sid] = audioTrack;
            Helper.setVolume(state.volume, audioTrack.mediaStreamTrack);
          }
          if (e.track is lk.VideoTrack) {
            state = state.copyWith(videoTrack: e.track as lk.VideoTrack);
          } else {
            syncVideoTrack();
          }
        })
        ..on<lk.TrackUnsubscribedEvent>((e) {
          if (e.track is lk.RemoteAudioTrack) {
            _subscribedAudioTracks.remove(e.publication.sid);
          }
          syncVideoTrack();
        })
        ..on<lk.RoomDisconnectedEvent>((_) {
          state = state.copyWith(
            clearRoom: true,
            clearVideoTrack: true,
            viewerCount: 0,
            messages: [],
            remoteParticipantIdentities: const [],
            clearLocalIdentity: true,
            isStreamerIdentity: false,
            isCameraEnabled: false,
            isMicrophoneEnabled: false,
            isScreenSharing: false,
          );
          _subscribedAudioTracks.clear();
        })
        ..on<lk.DataReceivedEvent>((e) {
          if (e.topic != null && e.topic != 'chat') return;
          final text = utf8.decode(e.data, allowMalformed: true).trim();
          if (text.isEmpty) return;
          final senderIdentity = e.participant?.identity;
          if (senderIdentity != null &&
              senderIdentity == room.localParticipant?.identity) {
            return;
          }
          appendMessage(
            ChatMessage(
              sender: senderIdentity ?? 'Server',
              senderIdentity: senderIdentity,
              message: text,
              isMine: false,
              createdAt: DateTime.now(),
            ),
          );
        });

      room.addListener(syncVideoTrack);
    } catch (e) {
      state = state.copyWith(isConnecting: false, errorText: e.toString());
    }
  }

  Future<void> disconnect() async {
    _roomListener?.dispose();
    _roomListener = null;
    final room = _room;
    _room = null;
    _subscribedAudioTracks.clear();
    _chatInputController.clear();
    state = const LivestreamRoomState().copyWith(
      clearRequestedStreamerMode: true,
      clearLocalIdentity: true,
    );
    if (room != null && !room.isDisposed) {
      await room.disconnect();
      await room.dispose();
    }
  }

  Future<void> sendMessage([String? rawMessage]) async {
    final room = _room;
    final localParticipant = room?.localParticipant;
    final message = (rawMessage ?? _chatInputController.text).trim();
    if (state.isSendingChat) {
      return;
    }
    if (room == null) {
      state = state.copyWith(
        errorText: 'Chat unavailable: room not connected.',
      );
      return;
    }
    if (localParticipant == null) {
      state = state.copyWith(
        errorText: 'Chat unavailable: no local participant in room.',
      );
      return;
    }
    if (message.isEmpty) {
      return;
    }

    state = state.copyWith(isSendingChat: true, clearError: true);
    try {
      await localParticipant.publishData(
        utf8.encode(message),
        reliable: true,
        topic: 'chat',
      );
      appendMessage(
        ChatMessage(
          sender: localParticipant.identity,
          senderIdentity: localParticipant.identity,
          message: message,
          isMine: true,
          createdAt: DateTime.now(),
        ),
      );
      if (rawMessage == null) _chatInputController.clear();
    } catch (e) {
      state = state.copyWith(
        errorText:
            'Failed to send message: $e. If you are connected as viewer, your token may not allow chat publishing.',
      );
    } finally {
      state = state.copyWith(isSendingChat: false);
    }
  }

  void setVolume(double value) {
    state = state.copyWith(volume: value);
    if (_room != null) _applyVolume(_room!, value);
    for (final track in _subscribedAudioTracks.values) {
      Helper.setVolume(value, track.mediaStreamTrack);
    }
  }

  void toggleChatCollapsed() {
    state = state.copyWith(isChatCollapsed: !state.isChatCollapsed);
  }

  void clearRequestedMode() {
    state = state.copyWith(clearRequestedStreamerMode: true);
  }

  void syncLocalParticipantState() {
    _syncLocalParticipantState();
  }
}

final livestreamRoomProvider = NotifierProvider.autoDispose
    .family<LivestreamRoomNotifier, LivestreamRoomState, String>(
      LivestreamRoomNotifier.new,
    );
