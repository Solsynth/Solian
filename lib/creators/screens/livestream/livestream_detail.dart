import 'dart:async';
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' show Helper;
import 'package:gap/gap.dart';
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

final creatorLivestreamDetailProvider = FutureProvider.family
    .autoDispose<SnLiveStream, String>((ref, livestreamId) async {
      final client = ref.watch(apiClientProvider);
      final response = await client.get('/sphere/livestreams/$livestreamId');
      return SnLiveStream.fromJson(Map<String, dynamic>.from(response.data));
    });

@RoutePage()
class CreatorLivestreamDetailScreen extends HookConsumerWidget {
  final String livestreamId;

  const CreatorLivestreamDetailScreen({super.key, required this.livestreamId});

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

  static String? _parseViewerIdentityToAccountId(String? identity) {
    if (identity == null) return null;
    final idx = identity.indexOf('_');
    if (idx <= 0 || idx + 1 >= identity.length) return null;
    final raw = identity.substring(idx + 1).toLowerCase();
    if (!RegExp(r'^[0-9a-f]{32}$').hasMatch(raw)) return null;
    return '${raw.substring(0, 8)}-'
        '${raw.substring(8, 12)}-'
        '${raw.substring(12, 16)}-'
        '${raw.substring(16, 20)}-'
        '${raw.substring(20, 32)}';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(
      creatorLivestreamDetailProvider(livestreamId),
    );
    final roomState = useState<lk.Room?>(null);
    final roomListenerState = useState<lk.EventsListener<lk.RoomEvent>?>(null);
    final videoTrackState = useState<lk.VideoTrack?>(null);
    final subscribedAudioTracks = useState<Map<String, lk.RemoteAudioTrack>>(
      {},
    );

    final localIdentity = useState<String?>(null);
    final isStreamerIdentity = useState(false);
    final isCameraEnabled = useState(false);
    final isMicrophoneEnabled = useState(false);
    final isScreenSharing = useState(false);
    final roomViewerCount = useState(0);
    final volume = useState(1.0);

    final isConnecting = useState(false);
    final errorText = useState<String?>(null);
    final controlsVisible = useState(true);

    final chatMessages = useState<List<_LivestreamChatMessage>>([]);
    final chatInputController = useTextEditingController();
    final chatScrollController = useScrollController();
    final chatCollapsed = useState(false);
    final isSendingChat = useState(false);

    void appendChat(_LivestreamChatMessage item) {
      chatMessages.value = [...chatMessages.value, item];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!chatScrollController.hasClients) return;
        chatScrollController.jumpTo(
          chatScrollController.position.maxScrollExtent,
        );
      });
    }

    Future<void> disconnect() async {
      roomListenerState.value?.dispose();
      roomListenerState.value = null;
      final room = roomState.value;
      roomState.value = null;
      videoTrackState.value = null;
      subscribedAudioTracks.value = {};
      localIdentity.value = null;
      isStreamerIdentity.value = false;
      isCameraEnabled.value = false;
      isMicrophoneEnabled.value = false;
      isScreenSharing.value = false;
      roomViewerCount.value = 0;
      if (room != null && !room.isDisposed) {
        await room.disconnect();
        await room.dispose();
      }
    }

    Future<void> connect() async {
      if (roomState.value != null || isConnecting.value) return;
      isConnecting.value = true;
      errorText.value = null;

      try {
        final stream = await ref.read(
          creatorLivestreamDetailProvider(livestreamId).future,
        );
        if (stream.status == SnLiveStreamStatus.ended) {
          errorText.value = 'This livestream has ended.';
          return;
        }

        final client = ref.read(apiClientProvider);
        final response = await client.get(
          '/sphere/livestreams/$livestreamId/token',
          queryParameters: {'streamer': true},
        );
        final data = Map<String, dynamic>.from(response.data);

        final token = data['token'] as String? ?? '';
        final url = data['url'] as String? ?? '';
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

        void syncRoomState() {
          videoTrackState.value = _findVideoTrack(room);
          _applyVolume(room, volume.value);
          final local = room.localParticipant;
          localIdentity.value = local?.identity;
          isStreamerIdentity.value = (local?.identity ?? '').startsWith(
            'streamer_',
          );
          isCameraEnabled.value = local?.isCameraEnabled() ?? false;
          isMicrophoneEnabled.value = local?.isMicrophoneEnabled() ?? false;
          isScreenSharing.value = local?.isScreenShareEnabled() ?? false;
          roomViewerCount.value = room.remoteParticipants.length;
        }

        syncRoomState();
        roomListenerState.value?.dispose();
        final listener = room.createListener();
        listener
          ..on<lk.ParticipantConnectedEvent>((_) => syncRoomState())
          ..on<lk.ParticipantDisconnectedEvent>((_) => syncRoomState())
          ..on<lk.TrackPublishedEvent>((_) => syncRoomState())
          ..on<lk.TrackSubscribedEvent>((e) {
            if (e.track is lk.RemoteAudioTrack) {
              final audioTrack = e.track as lk.RemoteAudioTrack;
              subscribedAudioTracks.value = {
                ...subscribedAudioTracks.value,
                e.publication.sid: audioTrack,
              };
              Helper.setVolume(volume.value, audioTrack.mediaStreamTrack);
            }
            syncRoomState();
          })
          ..on<lk.TrackUnsubscribedEvent>((e) {
            if (e.track is lk.RemoteAudioTrack) {
              final clone = {...subscribedAudioTracks.value};
              clone.remove(e.publication.sid);
              subscribedAudioTracks.value = clone;
            }
            syncRoomState();
          })
          ..on<lk.RoomDisconnectedEvent>((_) {
            videoTrackState.value = null;
          })
          ..on<lk.DataReceivedEvent>((e) {
            if (e.topic != null && e.topic != 'chat') return;
            final text = utf8.decode(e.data, allowMalformed: true).trim();
            if (text.isEmpty) return;
            appendChat(
              _LivestreamChatMessage(
                sender: e.participant?.identity ?? 'Server',
                senderIdentity: e.participant?.identity,
                message: text,
                isMine:
                    e.participant?.identity == room.localParticipant?.identity,
                createdAt: DateTime.now(),
              ),
            );
          });

        room.addListener(syncRoomState);
        roomListenerState.value = listener;
        roomState.value = room;
      } catch (e) {
        errorText.value = e.toString();
        showErrorAlert(e);
      } finally {
        isConnecting.value = false;
      }
    }

    Future<void> sendChat([String? raw]) async {
      final room = roomState.value;
      final local = room?.localParticipant;
      final text = (raw ?? chatInputController.text).trim();
      if (room == null ||
          local == null ||
          text.isEmpty ||
          isSendingChat.value) {
        return;
      }
      isSendingChat.value = true;
      try {
        await local.publishData(
          utf8.encode(text),
          reliable: true,
          topic: 'chat',
        );
        appendChat(
          _LivestreamChatMessage(
            sender: local.identity,
            senderIdentity: local.identity,
            message: text,
            isMine: true,
            createdAt: DateTime.now(),
          ),
        );
        if (raw == null) {
          chatInputController.clear();
        }
      } catch (e) {
        errorText.value = 'Failed to send message: $e';
      } finally {
        isSendingChat.value = false;
      }
    }

    Future<void> toggleCamera() async {
      if (!isStreamerIdentity.value) return;
      final local = roomState.value?.localParticipant;
      if (local == null) return;
      final target = !local.isCameraEnabled();
      await local.setCameraEnabled(target);
      isCameraEnabled.value = target;
    }

    Future<void> toggleMic() async {
      if (!isStreamerIdentity.value) return;
      final local = roomState.value?.localParticipant;
      if (local == null) return;
      final target = !local.isMicrophoneEnabled();
      await local.setMicrophoneEnabled(target);
      isMicrophoneEnabled.value = target;
    }

    Future<void> toggleScreenShare() async {
      if (!isStreamerIdentity.value) return;
      final local = roomState.value?.localParticipant;
      if (local == null) return;
      final target = !local.isScreenShareEnabled();

      try {
        if (target && lk.lkPlatformIsDesktop()) {
          final source = await showDialog(
            context: context,
            builder: (context) => lk.ScreenSelectDialog(),
          );
          if (source == null) return;
          final track = await lk.LocalVideoTrack.createScreenShareTrack(
            lk.ScreenShareCaptureOptions(
              sourceId: source.id,
              maxFrameRate: 30.0,
              captureScreenAudio: true,
              useiOSBroadcastExtension: true,
            ),
          );
          await local.publishVideoTrack(track);
        } else {
          await local.setScreenShareEnabled(target);
        }
        isScreenSharing.value = local.isScreenShareEnabled();
      } catch (e) {
        showErrorAlert(e);
      }
    }

    useEffect(() {
      unawaited(connect());
      return () {
        unawaited(disconnect());
      };
    }, const []);

    final room = roomState.value;
    final videoTrack = videoTrackState.value;
    final stream = detailAsync.asData?.value;
    final viewerCountText = '${roomViewerCount.value} in room';
    final modeText = localIdentity.value?.startsWith('streamer_') == true
        ? 'Studio mode'
        : localIdentity.value?.startsWith('viewer_') == true
        ? 'Viewer mode (Ingress connected)'
        : 'Unknown mode';
    final subtitleText = '$modeText • $viewerCountText';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => controlsVisible.value = !controlsVisible.value,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: videoTrack != null
                          ? lk.VideoTrackRenderer(videoTrack)
                          : (stream?.thumbnail?.id != null
                                ? CloudImageWidget(
                                    fileId: stream!.thumbnail!.id,
                                    fit: BoxFit.contain,
                                  )
                                : const ColoredBox(color: Colors.black)),
                    ),
                    if (videoTrack == null)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.42),
                          alignment: Alignment.center,
                          child: Text(
                            room == null
                                ? 'Connecting...'
                                : 'Waiting for video...',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      top: controlsVisible.value ? 0 : -96,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.64),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => context.router.maybePop(),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stream?.title ?? 'Livestream Studio',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    subtitleText,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (room == null && !isConnecting.value)
                              IconButton.filledTonal(
                                onPressed: connect,
                                icon: const Icon(Symbols.refresh),
                              ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      bottom: controlsVisible.value ? 8 : -140,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.64),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isStreamerIdentity.value) ...[
                                _CircleControlButton(
                                  icon: isMicrophoneEnabled.value
                                      ? Symbols.mic
                                      : Symbols.mic_off,
                                  active: isMicrophoneEnabled.value,
                                  onTap: toggleMic,
                                ),
                                const Gap(10),
                                _CircleControlButton(
                                  icon: isCameraEnabled.value
                                      ? Symbols.videocam
                                      : Symbols.videocam_off,
                                  active: isCameraEnabled.value,
                                  onTap: toggleCamera,
                                ),
                                const Gap(10),
                                _CircleControlButton(
                                  icon: isScreenSharing.value
                                      ? Symbols.stop_screen_share
                                      : Symbols.screen_share,
                                  active: isScreenSharing.value,
                                  onTap: toggleScreenShare,
                                ),
                                const Gap(10),
                              ],
                              _CircleControlButton(
                                icon: Symbols.logout,
                                active: false,
                                isDanger: true,
                                onTap: () async {
                                  await disconnect();
                                  if (context.mounted) {
                                    context.router.maybePop();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.3),
                  ),
                ),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => chatCollapsed.value = !chatCollapsed.value,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                      child: Row(
                        children: [
                          const Icon(Symbols.chat_bubble, size: 18),
                          const Gap(8),
                          Text('Live Chat (${chatMessages.value.length})'),
                          const Spacer(),
                          const Icon(Symbols.volume_up, size: 16),
                          SizedBox(
                            width: 120,
                            child: Slider(
                              max: 2,
                              value: volume.value,
                              onChanged: (value) {
                                volume.value = value;
                              },
                              onChangeEnd: (value) {
                                final room = roomState.value;
                                if (room != null) {
                                  _applyVolume(room, value);
                                }
                                _applyVolumeToSubscribedAudioTracks(
                                  subscribedAudioTracks.value,
                                  value,
                                );
                              },
                              year2023: true,
                              padding: EdgeInsets.symmetric(horizontal: 4),
                            ),
                          ),
                          Icon(
                            chatCollapsed.value
                                ? Symbols.expand_more
                                : Symbols.expand_less,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!chatCollapsed.value) ...[
                    SizedBox(
                      height: 220,
                      child: chatMessages.value.isEmpty
                          ? const Center(child: Text('No chat messages yet'))
                          : ListView.builder(
                              controller: chatScrollController,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              itemCount: chatMessages.value.length,
                              itemBuilder: (context, index) {
                                return _LivestreamChatRow(
                                  message: chatMessages.value[index],
                                );
                              },
                            ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: chatInputController,
                              onSubmitted: (value) => sendChat(value),
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'liveChatMessageHint'.tr(),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const Gap(8),
                          IconButton.filled(
                            onPressed: isSendingChat.value ? null : sendChat,
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
                  if (errorText.value != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                      child: Text(
                        errorText.value!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleControlButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final bool isDanger;
  final VoidCallback onTap;

  const _CircleControlButton({
    required this.icon,
    required this.active,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: isDanger
            ? Colors.red
            : active
            ? Theme.of(context).colorScheme.primary
            : Colors.white24,
      ),
      icon: Icon(icon),
      color: Colors.white,
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

class _LivestreamChatRow extends HookConsumerWidget {
  final _LivestreamChatMessage message;

  const _LivestreamChatRow({required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountId =
        CreatorLivestreamDetailScreen._parseViewerIdentityToAccountId(
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
          const Gap(6),
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
                                  .copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                          hideOverlay: true,
                        )
                      : Text(
                          displayName,
                          style:
                              (Theme.of(context).textTheme.labelSmall ??
                                      const TextStyle())
                                  .copyWith(fontWeight: FontWeight.w600),
                        ),
                ),
                const Gap(8),
                Expanded(
                  child: MarkdownTextContent(
                    content: message.message,
                    textStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    linesMargin: EdgeInsets.zero,
                  ),
                ),
                const Gap(8),
                Text(
                  timestamp,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
