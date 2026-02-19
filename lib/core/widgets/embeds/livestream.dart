import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' show Helper;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';

final livestreamDetailProvider = FutureProvider.family
    .autoDispose<SnLiveStream, String>((ref, livestreamId) async {
      final client = ref.watch(apiClientProvider);
      final response = await client.get('/sphere/livestreams/$livestreamId');
      return SnLiveStream.fromJson(Map<String, dynamic>.from(response.data));
    });

class LivestreamEmbedWidget extends HookConsumerWidget {
  final String livestreamId;
  final bool isInteractive;
  final EdgeInsets margin;

  const LivestreamEmbedWidget({
    super.key,
    required this.livestreamId,
    this.isInteractive = true,
    this.margin = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  static lk.VideoTrack? _findVideoTrack(lk.Room room) {
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
    // Fallback: include local participant publications if remote tracks
    // are delayed in subscription updates.
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

  static String _roomDiagnostics(lk.Room? room) {
    if (room == null) return 'notConnected'.tr();
    final remoteParticipants = room.remoteParticipants.values.toList();
    final videoPublications = remoteParticipants.fold<int>(
      0,
      (sum, participant) => sum + participant.videoTrackPublications.length,
    );
    final remoteVideoTracks = remoteParticipants.fold<int>(
      0,
      (sum, participant) =>
          sum +
          participant.videoTrackPublications
              .where((pub) => pub.track is lk.VideoTrack)
              .length,
    );
    return 'remoteParticipants: ${remoteParticipants.length}, '
        'videoPublications: $videoPublications, '
        'videoTracks: $remoteVideoTracks';
  }

  static void _applyVolume(lk.Room room, double volume) {
    for (final participant in room.remoteParticipants.values) {
      for (final publication in participant.audioTrackPublications) {
        final track = publication.track;
        if (track != null) {
          Helper.setVolume(volume, track.mediaStreamTrack);
        }
      }
    }
  }

  static void _applyVolumeToSubscribedAudioTracks(
    Map<String, lk.RemoteAudioTrack> audioTracks,
    double volume,
  ) {
    for (final track in audioTracks.values) {
      Helper.setVolume(volume, track.mediaStreamTrack);
    }
  }

  static String? _parseViewerIdentityToAccountId(String? identity) {
    if (identity == null || !identity.startsWith('viewer_')) return null;
    final raw = identity.substring('viewer_'.length).toLowerCase();
    if (!RegExp(r'^[0-9a-f]{32}$').hasMatch(raw)) return null;
    return '${raw.substring(0, 8)}-'
        '${raw.substring(8, 12)}-'
        '${raw.substring(12, 16)}-'
        '${raw.substring(16, 20)}-'
        '${raw.substring(20, 32)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(livestreamDetailProvider(livestreamId));
    final roomState = useState<lk.Room?>(null);
    final roomListenerState = useState<lk.EventsListener<lk.RoomEvent>?>(null);
    final videoTrackState = useState<lk.VideoTrack?>(null);
    final isConnecting = useState(false);
    final errorText = useState<String?>(null);
    final fullScreenOpen = useState(false);
    final idleDisconnectTimer = useRef<Timer?>(null);
    final roomViewerCount = useState<int>(0);
    final volume = useState<double>(1.0);
    final subscribedAudioTracks = useState<Map<String, lk.RemoteAudioTrack>>(
      {},
    );
    final chatMessages = useState<List<_LivestreamChatMessage>>([]);
    final chatInputController = useTextEditingController();
    final chatScrollController = useScrollController();
    final isSendingChat = useState(false);
    final chatCollapsed = useState(true);

    void appendChatMessage(_LivestreamChatMessage message) {
      chatMessages.value = [...chatMessages.value, message];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!chatScrollController.hasClients) return;
        chatScrollController.animateTo(
          chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
        );
      });
    }

    void cancelIdleDisconnect() {
      idleDisconnectTimer.value?.cancel();
      idleDisconnectTimer.value = null;
    }

    useEffect(() {
      return () async {
        cancelIdleDisconnect();
        roomListenerState.value?.dispose();
        roomListenerState.value = null;
        final room = roomState.value;
        roomState.value = null;
        videoTrackState.value = null;
        subscribedAudioTracks.value = {};
        roomViewerCount.value = 0;
        chatMessages.value = [];
        if (room != null && !room.isDisposed) {
          await room.disconnect();
          await room.dispose();
        }
      };
    }, const []);

    Future<void> connect() async {
      if (isConnecting.value || roomState.value != null) return;
      isConnecting.value = true;
      errorText.value = null;

      try {
        final stream = await ref.read(
          livestreamDetailProvider(livestreamId).future,
        );
        if (stream.status == SnLiveStreamStatus.ended) {
          errorText.value = 'thisLivestreamHasEnded'.tr();
          return;
        }
        if (stream.status != SnLiveStreamStatus.active) {
          errorText.value = 'thisLivestreamIsNotLiveYet'.tr();
          return;
        }

        final client = ref.read(apiClientProvider);
        final response = await client.get(
          '/sphere/livestreams/$livestreamId/token',
        );
        final data = Map<String, dynamic>.from(response.data);

        final token = data['token'] as String;
        final url = data['url'] as String;

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
        chatMessages.value = [];

        void syncVideoTrack() {
          videoTrackState.value = _findVideoTrack(room);
          _applyVolume(room, volume.value);
          roomViewerCount.value = room.remoteParticipants.length;
        }

        syncVideoTrack();

        roomListenerState.value?.dispose();
        final roomListener = room.createListener();
        roomListener
          ..on<lk.ParticipantConnectedEvent>((_) {
            syncVideoTrack();
          })
          ..on<lk.TrackPublishedEvent>((_) {
            syncVideoTrack();
          })
          ..on<lk.TrackSubscribedEvent>((e) {
            if (e.track is lk.RemoteAudioTrack) {
              final audioTrack = e.track as lk.RemoteAudioTrack;
              subscribedAudioTracks.value = {
                ...subscribedAudioTracks.value,
                e.publication.sid: audioTrack,
              };
              Helper.setVolume(volume.value, audioTrack.mediaStreamTrack);
            }
            if (e.track is lk.VideoTrack) {
              videoTrackState.value = e.track as lk.VideoTrack;
            } else {
              syncVideoTrack();
            }
          })
          ..on<lk.TrackUnsubscribedEvent>((e) {
            if (e.track is lk.RemoteAudioTrack) {
              final clone = {...subscribedAudioTracks.value};
              clone.remove(e.publication.sid);
              subscribedAudioTracks.value = clone;
            }
            syncVideoTrack();
          })
          ..on<lk.RoomDisconnectedEvent>((_) {
            videoTrackState.value = null;
            subscribedAudioTracks.value = {};
            roomViewerCount.value = 0;
            chatMessages.value = [];
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
            appendChatMessage(
              _LivestreamChatMessage(
                sender: senderIdentity ?? 'Server',
                senderIdentity: senderIdentity,
                message: text,
                isMine: false,
                createdAt: DateTime.now(),
              ),
            );
          });

        room.addListener(syncVideoTrack);
        roomListenerState.value = roomListener;

        roomState.value = room;
      } catch (e) {
        errorText.value = e.toString();
        showErrorAlert(e);
      } finally {
        isConnecting.value = false;
      }
    }

    Future<void> disconnect() async {
      cancelIdleDisconnect();
      roomListenerState.value?.dispose();
      roomListenerState.value = null;
      final room = roomState.value;
      roomState.value = null;
      videoTrackState.value = null;
      subscribedAudioTracks.value = {};
      roomViewerCount.value = 0;
      chatMessages.value = [];
      chatInputController.clear();
      if (room != null && !room.isDisposed) {
        await room.disconnect();
        await room.dispose();
      }
    }

    Future<void> sendChatMessage([String? rawMessage]) async {
      final room = roomState.value;
      final localParticipant = room?.localParticipant;
      final message = (rawMessage ?? chatInputController.text).trim();
      if (room == null ||
          localParticipant == null ||
          message.isEmpty ||
          isSendingChat.value) {
        return;
      }

      isSendingChat.value = true;
      try {
        await localParticipant.publishData(
          utf8.encode(message),
          reliable: true,
          topic: 'chat',
        );
        appendChatMessage(
          _LivestreamChatMessage(
            sender: 'Me',
            senderIdentity: localParticipant.identity,
            message: message,
            isMine: true,
            createdAt: DateTime.now(),
          ),
        );
        if (rawMessage == null) {
          chatInputController.clear();
        }
      } catch (e) {
        errorText.value = 'Failed to send message: $e';
        showErrorAlert(e);
      } finally {
        isSendingChat.value = false;
      }
    }

    void scheduleIdleDisconnect() {
      cancelIdleDisconnect();
      if (roomState.value == null || fullScreenOpen.value) return;
      idleDisconnectTimer.value = Timer(const Duration(seconds: 20), () {
        if (roomState.value != null && !fullScreenOpen.value) {
          disconnect();
        }
      });
    }

    Future<void> showFullscreenViewer() async {
      fullScreenOpen.value = true;
      cancelIdleDisconnect();
      final title =
          detailAsync.asData?.value.title ?? 'untitledLivestream'.tr();
      final thumbnailId = detailAsync.asData?.value.thumbnail?.id;
      await showDialog(
        context: context,
        useSafeArea: false,
        builder: (context) => _LivestreamFullscreenViewer(
          title: title,
          thumbnailId: thumbnailId,
          videoTrackListenable: videoTrackState,
          roomListenable: roomState,
          viewerCountListenable: roomViewerCount,
          volume: volume,
          chatMessagesListenable: chatMessages,
          isSendingChatListenable: isSendingChat,
          onSendChat: (message) => sendChatMessage(message),
          onApplyVolume: (value) {
            final room = roomState.value;
            if (room != null) {
              _applyVolume(room, value);
            }
            _applyVolumeToSubscribedAudioTracks(
              subscribedAudioTracks.value,
              value,
            );
          },
        ),
      );
      fullScreenOpen.value = false;
      if (roomState.value != null) {
        scheduleIdleDisconnect();
      }
    }

    final room = roomState.value;
    final videoTrack = videoTrackState.value;

    return VisibilityDetector(
      key: ValueKey('livestream-$livestreamId'),
      onVisibilityChanged: (info) {
        final visible = info.visibleFraction > 0.05;
        if (visible || fullScreenOpen.value) {
          cancelIdleDisconnect();
        } else {
          scheduleIdleDisconnect();
        }
      },
      child: Card(
        margin: margin,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              detailAsync
                  .when(
                    data: (stream) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stream.title ?? 'untitledLivestream'.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (room != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${roomViewerCount.value} in room',
                            style: Theme.of(context).textTheme.bodySmall,
                          ).opacity(0.8),
                        ],
                        if (stream.description?.isNotEmpty ?? false)
                          Text(
                            stream.description!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ).opacity(0.85),
                      ],
                    ),
                    loading: () => const LinearProgressIndicator(minHeight: 2),
                    error: (_, _) => const Text('livestreamUnavailable').tr(),
                  )
                  .padding(horizontal: 4),
              const SizedBox(height: 10),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: videoTrack != null
                              ? lk.VideoTrackRenderer(videoTrack)
                              : detailAsync.when(
                                  data: (stream) {
                                    final thumbnailId = stream.thumbnail?.id;
                                    return Stack(
                                      children: [
                                        Positioned.fill(
                                          child: thumbnailId != null
                                              ? CloudImageWidget(
                                                  fileId: thumbnailId,
                                                  fit: BoxFit.cover,
                                                )
                                              : const ColoredBox(
                                                  color: Colors.black,
                                                ),
                                        ),
                                        const Positioned.fill(
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: Color(0x66000000),
                                            ),
                                          ),
                                        ),
                                        if (room != null)
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Text(
                                                'Connected. Waiting for video...\n${_roomDiagnostics(room)}',
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                  loading: () => Center(
                                    child: Text(
                                      'loadingStream'.tr(),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                  error: (_, _) => Center(
                                    child: Text(
                                      'livestreamUnavailable'.tr(),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        if (isInteractive && room == null)
                          Positioned.fill(
                            child: Center(
                              child: detailAsync.when(
                                data: (stream) {
                                  final canWatch =
                                      stream.status ==
                                      SnLiveStreamStatus.active;
                                  return FilledButton.icon(
                                    onPressed: isConnecting.value
                                        ? null
                                        : canWatch
                                        ? connect
                                        : null,
                                    icon: isConnecting.value
                                        ? const SizedBox.square(
                                            dimension: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Icon(Symbols.play_arrow),
                                    label: Text('watch'.tr()),
                                  );
                                },
                                loading: () => const SizedBox.shrink(),
                                error: (_, _) => const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        if (isInteractive && room != null)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton.filledTonal(
                                  tooltip: 'fullscreen'.tr(),
                                  onPressed: showFullscreenViewer,
                                  icon: const Icon(Symbols.fullscreen),
                                  iconSize: 18,
                                  visualDensity: VisualDensity.compact,
                                ),
                                const SizedBox(width: 8),
                                FilledButton.tonalIcon(
                                  onPressed: disconnect,
                                  icon: const Icon(Symbols.stop, size: 20),
                                  label: Text('leave'.tr()).padding(right: 4),
                                  style: FilledButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (errorText.value != null) ...[
                const SizedBox(height: 10),
                Text(
                  errorText.value!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              if (room != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Symbols.volume_up, size: 18),
                    Expanded(
                      child: Slider(
                        max: 2,
                        value: volume.value,
                        onChanged: (value) {
                          volume.value = value;
                        },
                        onChangeEnd: (value) {
                          _applyVolume(room, value);
                          _applyVolumeToSubscribedAudioTracks(
                            subscribedAudioTracks.value,
                            value,
                          );
                        },
                        year2023: true,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${(volume.value * 100).toStringAsFixed(0)}%',
                      ),
                    ),
                  ],
                ).padding(vertical: 4, horizontal: 6),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          chatCollapsed.value = !chatCollapsed.value;
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
                          child: Row(
                            children: [
                              const Icon(Symbols.chat_bubble, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'liveChatCount'.tr(
                                  args: ['${chatMessages.value.length}'],
                                ),
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const Spacer(),
                              IconButton(
                                constraints: const BoxConstraints(),
                                visualDensity: VisualDensity.compact,
                                tooltip: chatCollapsed.value
                                    ? 'expand'.tr()
                                    : 'collapse'.tr(),
                                onPressed: () {
                                  chatCollapsed.value = !chatCollapsed.value;
                                },
                                icon: Icon(
                                  chatCollapsed.value
                                      ? Symbols.expand_more
                                      : Symbols.expand_less,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!chatCollapsed.value) ...[
                        SizedBox(
                          height: 220,
                          child: chatMessages.value.isEmpty
                              ? Center(
                                  child: Text(
                                    'noChatMessagesYet'.tr(),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                )
                              : ListView.builder(
                                  controller: chatScrollController,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  itemCount: chatMessages.value.length,
                                  itemBuilder: (context, index) {
                                    return _LivestreamChatBubble(
                                      message: chatMessages.value[index],
                                    );
                                  },
                                ),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: chatInputController,
                                  onSubmitted: (value) =>
                                      sendChatMessage(value),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: 'liveChatMessageHint'.tr(),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filled(
                                tooltip: 'send'.tr(),
                                onPressed: isSendingChat.value
                                    ? null
                                    : sendChatMessage,
                                icon: isSendingChat.value
                                    ? const SizedBox.square(
                                        dimension: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Symbols.send),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LivestreamFullscreenViewer extends StatefulWidget {
  final String title;
  final String? thumbnailId;
  final ValueListenable<lk.VideoTrack?> videoTrackListenable;
  final ValueListenable<lk.Room?> roomListenable;
  final ValueListenable<int> viewerCountListenable;
  final ValueNotifier<double> volume;
  final ValueListenable<List<_LivestreamChatMessage>> chatMessagesListenable;
  final ValueListenable<bool> isSendingChatListenable;
  final Future<void> Function(String message) onSendChat;
  final void Function(double value) onApplyVolume;

  const _LivestreamFullscreenViewer({
    required this.title,
    required this.thumbnailId,
    required this.videoTrackListenable,
    required this.roomListenable,
    required this.viewerCountListenable,
    required this.volume,
    required this.chatMessagesListenable,
    required this.isSendingChatListenable,
    required this.onSendChat,
    required this.onApplyVolume,
  });

  @override
  State<_LivestreamFullscreenViewer> createState() =>
      _LivestreamFullscreenViewerState();
}

class _LivestreamFullscreenViewerState
    extends State<_LivestreamFullscreenViewer> {
  bool _controlsVisible = true;
  bool _chatCollapsed = true;
  Timer? _autoHideTimer;
  final TextEditingController _chatInputController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  void _scheduleAutoHide() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _controlsVisible = false);
    });
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) {
      _scheduleAutoHide();
    } else {
      _autoHideTimer?.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    _scheduleAutoHide();
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _chatInputController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleControls,
          child: Stack(
            children: [
              Positioned.fill(
                child: ValueListenableBuilder<lk.VideoTrack?>(
                  valueListenable: widget.videoTrackListenable,
                  builder: (context, track, _) {
                    if (track != null) {
                      return lk.VideoTrackRenderer(track);
                    }
                    return ValueListenableBuilder<lk.Room?>(
                      valueListenable: widget.roomListenable,
                      builder: (context, room, _) {
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: widget.thumbnailId != null
                                  ? CloudImageWidget(
                                      fileId: widget.thumbnailId!,
                                      fit: BoxFit.contain,
                                    )
                                  : const ColoredBox(color: Colors.black),
                            ),
                            const Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Color(0x66000000),
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                room == null
                                    ? 'disconnected'.tr()
                                    : 'connectedWaitingForVideo'.tr(),
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                right: 20,
                bottom: _controlsVisible ? 72 : 20,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeOutCubic,
                  child: _chatCollapsed
                      ? IconButton.filledTonal(
                          key: const ValueKey('chat-collapsed'),
                          tooltip: 'openChat'.tr(),
                          onPressed: () {
                            setState(() => _chatCollapsed = false);
                          },
                          icon: const Icon(Symbols.chat_bubble),
                        )
                      : Container(
                          key: const ValueKey('chat-expanded'),
                          width: 340,
                          height: 320,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  10,
                                  10,
                                  10,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Symbols.chat_bubble,
                                      size: 18,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child:
                                          ValueListenableBuilder<
                                            List<_LivestreamChatMessage>
                                          >(
                                            valueListenable:
                                                widget.chatMessagesListenable,
                                            builder: (context, messages, _) {
                                              return Text(
                                                'chatCount'.tr(
                                                  args: ['${messages.length}'],
                                                ),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              );
                                            },
                                          ),
                                    ),
                                    IconButton(
                                      tooltip: 'Collapse',
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () {
                                        setState(() => _chatCollapsed = true);
                                      },
                                      icon: const Icon(
                                        Symbols.chevron_right,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1, color: Colors.white24),
                              Expanded(
                                child:
                                    ValueListenableBuilder<
                                      List<_LivestreamChatMessage>
                                    >(
                                      valueListenable:
                                          widget.chatMessagesListenable,
                                      builder: (context, messages, _) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              if (!_chatScrollController
                                                  .hasClients) {
                                                return;
                                              }
                                              _chatScrollController.jumpTo(
                                                _chatScrollController
                                                    .position
                                                    .maxScrollExtent,
                                              );
                                            });
                                        if (messages.isEmpty) {
                                          return const Center(
                                            child: Text(
                                              'noChatMessagesYet',
                                              style: TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                          );
                                        }
                                        return ListView.builder(
                                          controller: _chatScrollController,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 8,
                                          ),
                                          itemCount: messages.length,
                                          itemBuilder: (context, index) {
                                            return _LivestreamChatBubble(
                                              message: messages[index],
                                              dark: true,
                                            );
                                          },
                                        );
                                      },
                                    ),
                              ),
                              const Divider(height: 1, color: Colors.white24),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _chatInputController,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        onSubmitted: (value) async {
                                          final text = value.trim();
                                          if (text.isEmpty) return;
                                          await widget.onSendChat(text);
                                          _chatInputController.clear();
                                        },
                                        decoration: InputDecoration(
                                          isDense: true,
                                          hintText: 'liveChatMessageHint'.tr(),
                                          hintStyle: const TextStyle(
                                            color: Colors.white54,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ValueListenableBuilder<bool>(
                                      valueListenable:
                                          widget.isSendingChatListenable,
                                      builder: (context, isSending, _) {
                                        return IconButton.filled(
                                          tooltip: 'send'.tr(),
                                          onPressed: isSending
                                              ? null
                                              : () async {
                                                  final text =
                                                      _chatInputController.text
                                                          .trim();
                                                  if (text.isEmpty) return;
                                                  await widget.onSendChat(text);
                                                  _chatInputController.clear();
                                                },
                                          icon: isSending
                                              ? const SizedBox.square(
                                                  dimension: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                )
                                              : const Icon(Symbols.send),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                top: _controlsVisible ? 12 : -100,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Symbols.close),
                      iconSize: 18,
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: widget.viewerCountListenable,
                      builder: (context, count, _) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Symbols.group,
                            size: 16,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$count',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                left: 16,
                right: 16,
                bottom: _controlsVisible ? 16 : -120,
                child: ValueListenableBuilder<lk.Room?>(
                  valueListenable: widget.roomListenable,
                  builder: (context, room, _) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Symbols.volume_up,
                            color: Colors.white70,
                            size: 18,
                          ),
                          Expanded(
                            child: ValueListenableBuilder<double>(
                              valueListenable: widget.volume,
                              builder: (context, vol, _) => Slider(
                                max: 2,
                                value: vol,
                                onChanged: room == null
                                    ? null
                                    : (value) {
                                        widget.volume.value = value;
                                      },
                                onChangeEnd: room == null
                                    ? null
                                    : widget.onApplyVolume,
                                year2023: true,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                            ),
                          ),
                          ValueListenableBuilder<double>(
                            valueListenable: widget.volume,
                            builder: (context, vol, _) => Text(
                              '${(vol * 100).round()}%',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LivestreamChatMessage {
  final String sender;
  final String? senderIdentity;
  final String message;
  final bool isMine;
  final DateTime createdAt;

  const _LivestreamChatMessage({
    required this.sender,
    required this.senderIdentity,
    required this.message,
    required this.isMine,
    required this.createdAt,
  });
}

class _LivestreamChatBubble extends HookConsumerWidget {
  final _LivestreamChatMessage message;
  final bool dark;

  const _LivestreamChatBubble({required this.message, this.dark = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountId = LivestreamEmbedWidget._parseViewerIdentityToAccountId(
      message.senderIdentity,
    );
    final meAccountAsync = ref.watch(userInfoProvider);
    final accountAsync = accountId == null
        ? const AsyncData<SnAccount?>(null)
        : ref.watch(accountInfoProvider(accountId));

    var displayName = message.sender;
    SnAccount? account;
    accountAsync.whenData((value) => account = value);
    if (account == null && message.isMine) {
      meAccountAsync.whenData((value) => account = value);
    }
    if (account != null) {
      displayName = account!.nick;
    }
    final timestamp =
        '${message.createdAt.hour.toString().padLeft(2, '0')}:'
        '${message.createdAt.minute.toString().padLeft(2, '0')}';
    final nameColor = dark
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    final textColor = dark
        ? Colors.white70
        : Theme.of(context).colorScheme.onSurface;
    final timeColor = dark
        ? Colors.white54
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (account?.profile.picture != null)
            ProfilePictureWidget(file: account!.profile.picture, radius: 10)
          else
            CircleAvatar(
              radius: 10,
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          const SizedBox(width: 6),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 0,
                  child: account != null
                      ? AccountName(
                          account: account!,
                          style:
                              (Theme.of(context).textTheme.labelSmall ??
                                      const TextStyle())
                                  .copyWith(color: nameColor),
                          hideOverlay: true,
                        )
                      : Text(
                          displayName,
                          style:
                              (Theme.of(context).textTheme.labelSmall ??
                                      const TextStyle())
                                  .copyWith(
                                    color: nameColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MarkdownTextContent(
                    content: message.message,
                    textStyle: TextStyle(color: textColor),
                    linesMargin: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  timestamp,
                  style: TextStyle(color: timeColor, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
