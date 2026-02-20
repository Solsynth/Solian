import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/widgets/embeds/livestream_room.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class LivestreamOverlayState {
  final String? livestreamId;

  const LivestreamOverlayState({this.livestreamId});

  bool get isActive => livestreamId != null && livestreamId!.isNotEmpty;

  LivestreamOverlayState copyWith({String? livestreamId, bool clear = false}) {
    return LivestreamOverlayState(
      livestreamId: clear ? null : (livestreamId ?? this.livestreamId),
    );
  }
}

class LivestreamOverlayController extends Notifier<LivestreamOverlayState> {
  @override
  LivestreamOverlayState build() => const LivestreamOverlayState();

  void show(String livestreamId) {
    state = state.copyWith(livestreamId: livestreamId);
  }

  void hide() {
    state = state.copyWith(clear: true);
  }
}

final livestreamOverlayProvider =
    NotifierProvider<LivestreamOverlayController, LivestreamOverlayState>(
      LivestreamOverlayController.new,
    );

final overlayLivestreamDetailProvider = FutureProvider.family
    .autoDispose<SnLiveStream?, String>((ref, livestreamId) async {
      try {
        final client = ref.watch(apiClientProvider);
        final response = await client.get('/sphere/livestreams/$livestreamId');
        return SnLiveStream.fromJson(Map<String, dynamic>.from(response.data));
      } catch (_) {
        return null;
      }
    });

class LivestreamFloatingOverlay extends HookConsumerWidget {
  const LivestreamFloatingOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlayState = ref.watch(livestreamOverlayProvider);
    final livestreamId = overlayState.livestreamId;
    if (livestreamId == null) return const SizedBox.shrink();

    final roomState = ref.watch(livestreamRoomProvider(livestreamId));
    final roomNotifier = ref.read(
      livestreamRoomProvider(livestreamId).notifier,
    );
    final detailAsync = ref.watch(
      overlayLivestreamDetailProvider(livestreamId),
    );

    useEffect(() {
      if (roomState.room == null && !roomState.isConnecting) {
        roomNotifier.connect(streamer: false);
      }
      return null;
    }, [livestreamId, roomState.room, roomState.isConnecting]);

    String title = 'Livestream';
    String? thumbnailId;
    if (detailAsync.value != null) {
      title = detailAsync.value?.title ?? title;
      thumbnailId = detailAsync.value?.thumbnail?.id;
    }

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 14, bottom: 14),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                context.router.push(
                  LivestreamWatchRoute(livestreamId: livestreamId),
                );
              },
              child: Container(
                width: 220,
                height: 154,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: roomState.videoTrack != null
                          ? lk.VideoTrackRenderer(roomState.videoTrack!)
                          : (thumbnailId != null
                                ? CloudImageWidget(
                                    fileId: thumbnailId,
                                    fit: BoxFit.cover,
                                  )
                                : const ColoredBox(color: Colors.black)),
                    ),
                    const Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: Color(0x22000000)),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: 8,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton.filledTonal(
                            tooltip: 'Open',
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              context.router.push(
                                LivestreamWatchRoute(
                                  livestreamId: livestreamId,
                                ),
                              );
                            },
                            icon: const Icon(Symbols.open_in_new, size: 16),
                          ),
                          const SizedBox(width: 4),
                          IconButton.filledTonal(
                            tooltip: 'Close',
                            visualDensity: VisualDensity.compact,
                            onPressed: () => ref
                                .read(livestreamOverlayProvider.notifier)
                                .hide(),
                            icon: const Icon(Symbols.close, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
