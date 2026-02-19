import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(livestreamDetailProvider(livestreamId));
    final roomState = useState<lk.Room?>(null);
    final roomListenerState = useState<lk.EventsListener<lk.RoomEvent>?>(null);
    final videoTrackState = useState<lk.VideoTrack?>(null);
    final isConnecting = useState(false);
    final errorText = useState<String?>(null);

    useEffect(() {
      return () async {
        roomListenerState.value?.dispose();
        roomListenerState.value = null;
        final room = roomState.value;
        roomState.value = null;
        videoTrackState.value = null;
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
            if (e.track is lk.VideoTrack) {
              videoTrackState.value = e.track as lk.VideoTrack;
            } else {
              syncVideoTrack();
            }
          })
          ..on<lk.TrackUnsubscribedEvent>((_) {
            syncVideoTrack();
          })
          ..on<lk.RoomDisconnectedEvent>((_) {
            videoTrackState.value = null;
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
      roomListenerState.value?.dispose();
      roomListenerState.value = null;
      final room = roomState.value;
      roomState.value = null;
      videoTrackState.value = null;
      if (room != null && !room.isDisposed) {
        await room.disconnect();
        await room.dispose();
      }
    }

    final room = roomState.value;
    final videoTrack = videoTrackState.value;

    return Card(
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
                                    stream.status == SnLiveStreamStatus.active;
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
                          child: FilledButton.tonalIcon(
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
          ],
        ),
      ),
    );
  }
}
