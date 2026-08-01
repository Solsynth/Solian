import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/services/time.dart';
import 'package:island/shared/widgets/content/video.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:styled_widget/styled_widget.dart';

enum MediaPlaybackKind { audio, video }

class MediaPlaybackState {
  const MediaPlaybackState({
    this.uri,
    this.title = '',
    this.kind = MediaPlaybackKind.audio,
    this.aspectRatio = 16 / 9,
    this.docked = false,
    this.playing = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.buffered = Duration.zero,
  });

  final String? uri;
  final String title;
  final MediaPlaybackKind kind;
  final double aspectRatio;
  final bool docked;
  final bool playing;
  final Duration position;
  final Duration duration;
  final Duration buffered;

  bool get hasMedia => uri != null;

  MediaPlaybackState copyWith({
    String? uri,
    String? title,
    MediaPlaybackKind? kind,
    double? aspectRatio,
    bool? docked,
    bool? playing,
    Duration? position,
    Duration? duration,
    Duration? buffered,
  }) => MediaPlaybackState(
    uri: uri ?? this.uri,
    title: title ?? this.title,
    kind: kind ?? this.kind,
    aspectRatio: aspectRatio ?? this.aspectRatio,
    docked: docked ?? this.docked,
    playing: playing ?? this.playing,
    position: position ?? this.position,
    duration: duration ?? this.duration,
    buffered: buffered ?? this.buffered,
  );
}

final mediaPlaybackProvider =
    NotifierProvider<MediaPlaybackController, MediaPlaybackState>(
      MediaPlaybackController.new,
    );

class MediaPlaybackController extends Notifier<MediaPlaybackState> {
  late final Player player;

  @override
  MediaPlaybackState build() {
    MediaKit.ensureInitialized();
    player = Player(
      configuration: const PlayerConfiguration(bufferSize: 8 * 1024 * 1024),
    );
    player.stream.playing.listen(
      (value) => state = state.copyWith(playing: value),
    );
    player.stream.position.listen(
      (value) => state = state.copyWith(position: value),
    );
    player.stream.duration.listen(
      (value) => state = state.copyWith(duration: value),
    );
    player.stream.buffer.listen(
      (value) => state = state.copyWith(buffered: value),
    );
    ref.onDispose(player.dispose);
    return const MediaPlaybackState();
  }

  Future<void> open({
    required String uri,
    required String title,
    required MediaPlaybackKind kind,
    required bool autoplay,
    double aspectRatio = 16 / 9,
  }) async {
    if (state.uri == uri) {
      state = state.copyWith(docked: false);
      if (autoplay) await player.play();
      return;
    }

    state = MediaPlaybackState(
      uri: uri,
      title: title,
      kind: kind,
      aspectRatio: aspectRatio,
    );
    await player.open(Media(uri), play: autoplay);
  }

  void dockWhenReleased(String uri) {
    if (state.uri == uri) state = state.copyWith(docked: true);
  }

  void restoreInline(String uri) {
    if (state.uri == uri) state = state.copyWith(docked: false);
  }

  Future<void> close() async {
    await player.stop();
    state = const MediaPlaybackState();
  }
}

class MediaPlaybackDock extends ConsumerWidget {
  const MediaPlaybackDock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(mediaPlaybackProvider);
    // Video keeps playing in a floating overlay (see [FloatingVideoDock]);
    // only audio stays docked as a bottom bar.
    if (!playback.docked ||
        !playback.hasMedia ||
        playback.kind == MediaPlaybackKind.video) {
      return const SizedBox.shrink();
    }

    final controller = ref.read(mediaPlaybackProvider.notifier);
    final max = playback.duration.inMilliseconds.toDouble();
    final value = playback.position.inMilliseconds
        .toDouble()
        .clamp(0.0, max)
        .toDouble();
    final buffered = playback.buffered.inMilliseconds
        .toDouble()
        .clamp(0.0, max)
        .toDouble();

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              onPressed: controller.player.playOrPause,
              icon: Icon(
                playback.playing ? Symbols.pause : Symbols.play_arrow,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playback.title.isEmpty ? 'Audio' : playback.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Slider(
                    value: value,
                    secondaryTrackValue: buffered,
                    max: max <= 0 ? 1.0 : max,
                    onChanged: max <= 0
                        ? null
                        : (next) => controller.player.seek(
                            Duration(milliseconds: next.round()),
                          ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            Text(
              '${playback.position.formatShortDuration()} / ${playback.duration.formatShortDuration()}',
              style: Theme.of(context).textTheme.labelSmall,
            ).padding(horizontal: 8),
            IconButton(
              onPressed: controller.close,
              icon: const Icon(Symbols.close),
            ),
          ],
        ).padding(horizontal: 8, vertical: 6),
      ),
    );
  }
}

/// Floating picture-in-picture video shown while a released video keeps
/// playing in the shared player. Draggable from its top bar.
class FloatingVideoDock extends ConsumerStatefulWidget {
  const FloatingVideoDock({super.key});

  @override
  ConsumerState<FloatingVideoDock> createState() => _FloatingVideoDockState();
}

class _FloatingVideoDockState extends ConsumerState<FloatingVideoDock> {
  static const double _cardWidth = 320;
  static const double _cardMinHeight = 180;
  static const double _cardMaxHeight = 240;
  static const double _margin = 16;

  /// Top-left corner of the card; lazily initialized to the bottom-right on
  /// the first layout and moved by dragging.
  Offset? _position;

  @override
  Widget build(BuildContext context) {
    final playback = ref.watch(mediaPlaybackProvider);
    if (!playback.docked ||
        !playback.hasMedia ||
        playback.kind != MediaPlaybackKind.video) {
      return const SizedBox.shrink();
    }

    final size = MediaQuery.sizeOf(context);
    final cardWidth = (size.width - 2 * _margin)
        .clamp(200.0, _cardWidth)
        .toDouble();
    final ratio = playback.aspectRatio <= 0 ? 16 / 9 : playback.aspectRatio;
    final cardHeight = (cardWidth / ratio)
        .clamp(_cardMinHeight, _cardMaxHeight)
        .toDouble();
    final maxX = math.max(0.0, size.width - cardWidth - 2 * _margin);
    final maxY = math.max(0.0, size.height - cardHeight - 2 * _margin);
    final position = _position ??= Offset(maxX, maxY);
    final left = position.dx.clamp(0.0, maxX).toDouble();
    final top = position.dy.clamp(0.0, maxY).toDouble();

    final controller = ref.read(mediaPlaybackProvider.notifier);

    return Positioned(
      left: left,
      top: top,
      child: Material(
        elevation: 12,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        color: Colors.black,
        child: SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: Stack(
            children: [
              Positioned.fill(
                child: UniversalVideo(
                  uri: playback.uri!,
                  aspectRatio: playback.aspectRatio,
                  externalPlayer: controller.player,
                  persistent: false,
                  controls: NoVideoControls,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 4,
                    right: 12,
                    top: 24,
                    bottom: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: controller.player.playOrPause,
                        icon: Icon(
                          playback.playing
                              ? Symbols.pause
                              : Symbols.play_arrow,
                          color: Colors.white,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      Text(
                        '${playback.position.formatShortDuration()} / ${playback.duration.formatShortDuration()}',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: MouseRegion(
                  cursor: SystemMouseCursors.move,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (details) {
                      setState(() {
                        _position = position + details.delta;
                      });
                    },
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.only(left: 8, right: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.55),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Symbols.drag_indicator,
                            size: 16,
                            color: Colors.white54,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              playback.title.isEmpty
                                  ? 'Video'
                                  : playback.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: controller.close,
                            icon: const Icon(
                              Symbols.close,
                              size: 16,
                              color: Colors.white70,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
