import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' show Helper;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/network.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:easy_localization/easy_localization.dart';

part 'livestream_room.freezed.dart';
part 'livestream_room.g.dart';

enum ChatMessageType { chat, systemAward, systemJoin, systemLeave }

double _parseDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

@freezed
abstract class LivestreamEvent with _$LivestreamEvent {
  const factory LivestreamEvent.chatMessage({
    required String id,
    @JsonKey(name: 'live_stream_id') required String livestreamId,
    @JsonKey(name: 'sender_id') required String senderId,
    required String senderName,
    required String content,
    DateTime? createdAt,
    SnAccount? sender,
  }) = LivestreamEventChatMessage;

  const factory LivestreamEvent.timeout({required int durationMinutes}) =
      LivestreamTimeout;

  const factory LivestreamEvent.streamAwarded({
    @JsonKey(name: 'sender_id') required String senderId,
    required String senderName,
    required double amount,
    String? message,
    @JsonKey(name: 'highlight_seconds') int? highlightSeconds,
  }) = LivestreamStreamAwarded;

  const factory LivestreamEvent.unknown(Map<String, dynamic> raw) =
      LivestreamUnknown;

  factory LivestreamEvent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;

    SnAccount? sender;
    if (json['sender'] != null) {
      try {
        sender = SnAccount.fromJson(json['sender'] as Map<String, dynamic>);
      } catch (_) {}
    }

    return switch (type) {
      'timeout' => LivestreamEvent.timeout(
        durationMinutes: json['duration_minutes'] as int? ?? 0,
      ),
      'stream_awarded' => LivestreamEvent.streamAwarded(
        senderId: json['sender_id'] as String? ?? '',
        senderName: json['sender_name'] as String? ?? 'Someone',
        amount: _parseDouble(json['amount']),
        message: json['message'] as String?,
        highlightSeconds: _parseInt(json['highlight_seconds']),
      ),
      _ when json['content'] != null => LivestreamEvent.chatMessage(
        id: json['id'] as String? ?? '',
        livestreamId: json['live_stream_id'] as String? ?? '',
        senderId: json['sender_id'] as String? ?? '',
        senderName: json['sender_name'] as String? ?? 'Unknown',
        content: json['content'] as String? ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
        sender: sender,
      ),
      _ => LivestreamEvent.unknown(json),
    };
  }
}

@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    @Default('') String id,
    @JsonKey(name: 'sender_id') @Default('') String senderId,
    @JsonKey(name: 'sender_name') @Default('Unknown') String sender,
    @JsonKey(name: 'sender_identity') String? senderIdentity,
    @JsonKey(name: 'content') @Default('') String message,
    @JsonKey(name: 'is_mine') @Default(false) bool isMine,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'message_type')
    @Default(ChatMessageType.chat)
    ChatMessageType messageType,
    Map<String, dynamic>? metadata,
    @JsonKey(name: 'sender') SnAccount? senderAccount,
  }) = _ChatMessage;

  const ChatMessage._();

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  factory ChatMessage.systemAward({
    required String sender,
    required String senderId,
    required double amount,
    String? message,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: '',
      senderId: senderId,
      sender: sender,
      senderIdentity: null,
      message: message ?? '',
      isMine: false,
      createdAt: createdAt ?? DateTime.now(),
      messageType: ChatMessageType.systemAward,
      metadata: {'amount': amount},
    );
  }

  factory ChatMessage.systemJoin({required String participantName}) {
    return ChatMessage(
      id: '',
      senderId: '',
      sender: 'System',
      senderIdentity: null,
      message: '$participantName joined the stream',
      isMine: false,
      createdAt: DateTime.now(),
      messageType: ChatMessageType.systemJoin,
      metadata: {'participant_name': participantName},
    );
  }

  factory ChatMessage.systemLeave({required String participantName}) {
    return ChatMessage(
      id: '',
      senderId: '',
      sender: 'System',
      senderIdentity: null,
      message: '$participantName left the stream',
      isMine: false,
      createdAt: DateTime.now(),
      messageType: ChatMessageType.systemLeave,
      metadata: {'participant_name': participantName},
    );
  }
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
      final isStreamer = tokenData['is_streamer'] as bool? ?? false;
      final identity = tokenData['identity'] as String?;

      if (token.isEmpty || url.isEmpty) {
        throw Exception('Invalid livestream token response.');
      }

      List<ChatMessage> chatHistory = [];
      try {
        final userInfo = ref.read(userInfoProvider).value;
        final chatResponse = await client.get(
          '/sphere/livestreams/$livestreamId/chat',
          queryParameters: {'limit': 50, 'offset': 0},
        );
        final chatData = chatResponse.data as List;
        final localUserId = userInfo?.id;
        for (final msg in chatData) {
          final msgMap = Map<String, dynamic>.from(msg);
          final isMine = msgMap['sender_id'] == localUserId;
          chatHistory.add(
            ChatMessage.fromJson(msgMap).copyWith(isMine: isMine),
          );
        }
        // Sort by created_at to ensure chronological order (oldest first)
        chatHistory.sort((a, b) {
          final aTime = a.createdAt ?? DateTime.now();
          final bTime = b.createdAt ?? DateTime.now();
          return aTime.compareTo(bTime);
        });
      } catch (_) {}

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
      state = state.copyWith(
        messages: chatHistory,
        room: room,
        isConnecting: false,
        isStreamerIdentity: isStreamer,
        localIdentity: identity,
      );

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
        ..on<lk.ParticipantConnectedEvent>((e) {
          syncVideoTrack();
          // Don't show join message for the local participant
          if (e.participant.identity != room.localParticipant?.identity) {
            appendMessage(
              ChatMessage.systemJoin(participantName: e.participant.identity),
            );
          }
        })
        ..on<lk.ParticipantDisconnectedEvent>((e) {
          syncVideoTrack();
          // Don't show leave message for the local participant
          if (e.participant.identity != room.localParticipant?.identity) {
            appendMessage(
              ChatMessage.systemLeave(participantName: e.participant.identity),
            );
          }
        })
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
          final data = utf8.decode(e.data, allowMalformed: true).trim();
          if (data.isEmpty) return;

          try {
            final payload = jsonDecode(data) as Map<String, dynamic>;
            final event = LivestreamEvent.fromJson(payload);

            event.when(
              chatMessage:
                  (
                    id,
                    livestreamId,
                    senderId,
                    senderName,
                    content,
                    createdAt,
                    sender,
                  ) {
                    final localUserId = ref.read(userInfoProvider).value?.id;
                    if (senderId == localUserId) {
                      return;
                    }
                    appendMessage(
                      ChatMessage(
                        id: id,
                        senderId: senderId,
                        sender: senderName,
                        message: content,
                        isMine: false,
                        createdAt: createdAt ?? DateTime.now(),
                        senderAccount: sender,
                      ),
                    );
                  },
              timeout: (durationMinutes) {
                state = state.copyWith(
                  errorText: 'You have been muted for $durationMinutes minutes',
                );
              },
              streamAwarded:
                  (senderId, senderName, amount, message, highlightSeconds) {
                    // Add superchat to messages for display
                    if (highlightSeconds != null && highlightSeconds > 0) {
                      final superchat = ChatMessage.systemAward(
                        sender: senderName,
                        senderId: senderId,
                        amount: amount,
                        message: message,
                      );
                      appendMessage(superchat);
                    }
                  },
              unknown: (raw) {
                debugPrint('[Livestream WS] Unknown event: $raw');
              },
            );
          } catch (err) {
            debugPrint('[Livestream WS] Error parsing event: $err');
            final text = data;
            if (text.isEmpty) return;
            final senderIdentity = e.participant?.identity;
            if (senderIdentity != null &&
                senderIdentity == room.localParticipant?.identity) {
              return;
            }
            appendMessage(
              ChatMessage(
                id: '',
                senderId: '',
                sender: senderIdentity ?? 'Server',
                senderIdentity: senderIdentity,
                message: text,
                isMine: false,
                createdAt: DateTime.now(),
              ),
            );
          }
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
    final client = ref.read(apiClientProvider);
    final message = (rawMessage ?? _chatInputController.text).trim();
    if (state.isSendingChat) {
      return;
    }
    if (message.isEmpty) {
      return;
    }

    state = state.copyWith(isSendingChat: true, clearError: true);
    try {
      final response = await client.post(
        '/sphere/livestreams/$livestreamId/chat',
        data: {'content': message},
      );
      final responseData = Map<String, dynamic>.from(response.data);
      appendMessage(ChatMessage.fromJson(responseData).copyWith(isMine: true));
      if (rawMessage == null) _chatInputController.clear();
    } catch (e) {
      state = state.copyWith(errorText: 'Failed to send message: $e');
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
