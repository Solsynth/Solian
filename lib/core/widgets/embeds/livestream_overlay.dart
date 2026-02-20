import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/route.dart';
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
    final router = ref.read(routerProvider);

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

    const overlayWidth = 220.0;
    const overlayHeight = 154.0;
    const edgePadding = 14.0;
    final position = useState<Offset?>(null);
    final controlsVisible = useState(true);
    final autoHideTimer = useRef<Timer?>(null);

    void scheduleAutoHide() {
      autoHideTimer.value?.cancel();
      autoHideTimer.value = Timer(const Duration(seconds: 3), () {
        controlsVisible.value = false;
      });
    }

    useEffect(() {
      scheduleAutoHide();
      return () {
        autoHideTimer.value?.cancel();
      };
    }, [livestreamId]);

    Offset clampOffset(Offset value, Size viewport, EdgeInsets safePadding) {
      final minX = edgePadding;
      final minY = safePadding.top + edgePadding;
      final maxX = (viewport.width - overlayWidth - edgePadding).clamp(
        minX,
        double.infinity,
      );
      final maxY = (viewport.height - overlayHeight - edgePadding).clamp(
        minY,
        double.infinity,
      );
      return Offset(value.dx.clamp(minX, maxX), value.dy.clamp(minY, maxY));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = Size(constraints.maxWidth, constraints.maxHeight);
        final safePadding = MediaQuery.of(context).padding;
        if (position.value == null) {
          final initial = Offset(
            viewport.width - overlayWidth - edgePadding,
            viewport.height - overlayHeight - edgePadding,
          );
          position.value = clampOffset(initial, viewport, safePadding);
        } else {
          position.value = clampOffset(position.value!, viewport, safePadding);
        }

        final current = position.value!;
        return Align(
          alignment: Alignment.topLeft,
          child: Transform.translate(
            offset: current,
            child: GestureDetector(
              onPanUpdate: (details) {
                position.value = clampOffset(
                  position.value! + details.delta,
                  viewport,
                  safePadding,
                );
                if (!controlsVisible.value) {
                  controlsVisible.value = true;
                }
                scheduleAutoHide();
              },
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    controlsVisible.value = !controlsVisible.value;
                    if (controlsVisible.value) {
                      scheduleAutoHide();
                    } else {
                      autoHideTimer.value?.cancel();
                    }
                  },
                  child: Container(
                    width: overlayWidth,
                    height: overlayHeight,
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
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOutCubic,
                          left: 8,
                          right: 8,
                          bottom: controlsVisible.value ? 8 : -24,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 180),
                            opacity: controlsVisible.value ? 1 : 0,
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
                        ),
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOutCubic,
                          top: controlsVisible.value ? 6 : -40,
                          right: 6,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 180),
                            opacity: controlsVisible.value ? 1 : 0,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton.filledTonal(
                                  tooltip: 'Open',
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () {
                                    router.push(
                                      LivestreamWatchRoute(
                                        livestreamId: livestreamId,
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Symbols.open_in_new,
                                    size: 16,
                                  ),
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
