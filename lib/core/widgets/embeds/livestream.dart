import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' show Helper;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
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

  static String _statusText(SnLiveStreamStatus status) {
    return switch (status) {
      SnLiveStreamStatus.pending => 'Pending',
      SnLiveStreamStatus.active => 'Live',
      SnLiveStreamStatus.ended => 'Ended',
      SnLiveStreamStatus.error => 'Error',
    };
  }

  static String _roomDiagnostics(lk.Room? room) {
    if (room == null) return 'Not connected';
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
    final volume = useState<double>(1.0);
    final subscribedAudioTracks = useState<Map<String, lk.RemoteAudioTrack>>(
      {},
    );

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
          errorText.value = 'This livestream has ended.';
          return;
        }
        if (stream.status != SnLiveStreamStatus.active) {
          errorText.value = 'This livestream is not live yet.';
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

        void syncVideoTrack() {
          videoTrackState.value = _findVideoTrack(room);
          _applyVolume(room, volume.value);
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
      if (room != null && !room.isDisposed) {
        await room.disconnect();
        await room.dispose();
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
      final title = detailAsync.asData?.value.title ?? 'Livestream';
      await showDialog(
        context: context,
        useSafeArea: false,
        builder: (context) => _LivestreamFullscreenViewer(
          title: title,
          videoTrackListenable: videoTrackState,
          roomListenable: roomState,
          volume: volume,
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
          onLeave: disconnect,
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
              detailAsync.when(
                data: (stream) => Row(
                  children: [
                    const Icon(Symbols.live_tv),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        stream.title ?? 'Livestream',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                loading: () => const LinearProgressIndicator(minHeight: 2),
                error: (_, _) => const Text('Livestream unavailable'),
              ),
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
                              : Center(
                                  child: detailAsync.when(
                                    data: (stream) => Text(
                                      room == null
                                          ? '${_statusText(stream.status)} stream'
                                          : 'Connected. Waiting for video...\n${_roomDiagnostics(room)}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    loading: () => const Text(
                                      'Loading stream...',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    error: (_, _) => const Text(
                                      'Livestream unavailable',
                                      style: TextStyle(color: Colors.white70),
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
                                    label: const Text('Watch'),
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
                                  tooltip: 'Fullscreen',
                                  onPressed: showFullscreenViewer,
                                  icon: const Icon(Symbols.fullscreen),
                                ),
                                const SizedBox(width: 8),
                                FilledButton.tonalIcon(
                                  onPressed: disconnect,
                                  icon: const Icon(Symbols.stop, size: 18),
                                  label: const Text('Leave'),
                                  style: FilledButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
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
                      ),
                    ),
                    SizedBox(
                      width: 44,
                      child: Text('${(volume.value * 100).round()}%'),
                    ),
                  ],
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
  final ValueListenable<lk.VideoTrack?> videoTrackListenable;
  final ValueListenable<lk.Room?> roomListenable;
  final ValueNotifier<double> volume;
  final Future<void> Function() onLeave;
  final void Function(double value) onApplyVolume;

  const _LivestreamFullscreenViewer({
    required this.title,
    required this.videoTrackListenable,
    required this.roomListenable,
    required this.volume,
    required this.onLeave,
    required this.onApplyVolume,
  });

  @override
  State<_LivestreamFullscreenViewer> createState() =>
      _LivestreamFullscreenViewerState();
}

class _LivestreamFullscreenViewerState
    extends State<_LivestreamFullscreenViewer> {
  bool _controlsVisible = true;
  Timer? _autoHideTimer;

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
                        return Center(
                          child: Text(
                            room == null
                                ? 'Disconnected'
                                : 'Connected. Waiting for video...',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        );
                      },
                    );
                  },
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
                    ValueListenableBuilder<lk.Room?>(
                      valueListenable: widget.roomListenable,
                      builder: (context, room, _) {
                        if (room == null) return const SizedBox.shrink();
                        return FilledButton.tonalIcon(
                          onPressed: () async {
                            await widget.onLeave();
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          icon: const Icon(Symbols.stop, size: 18),
                          label: const Text('Leave'),
                        );
                      },
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
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(10),
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
