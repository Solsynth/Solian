import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/services/time.dart';
import 'package:island/shared/widgets/content/video.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:media_kit/media_kit.dart';
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
    Map<String, String>? httpHeaders,
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
    await player.open(Media(uri, httpHeaders: httpHeaders), play: autoplay);
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
    if (!playback.docked || !playback.hasMedia) return const SizedBox.shrink();

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
        child: playback.kind == MediaPlaybackKind.video
            ? _VideoDock(playback: playback, controller: controller)
            : Row(
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

class _VideoDock extends StatelessWidget {
  const _VideoDock({required this.playback, required this.controller});

  final MediaPlaybackState playback;
  final MediaPlaybackController controller;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 160,
    child: Row(
      children: [
        AspectRatio(
          aspectRatio: playback.aspectRatio,
          child: UniversalVideo(
            uri: playback.uri!,
            aspectRatio: playback.aspectRatio,
            externalPlayer: controller.player,
            persistent: false,
          ),
        ),
        Expanded(
          child: Text(
            playback.title.isEmpty ? 'Video' : playback.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ).padding(horizontal: 12),
        ),
        IconButton(
          onPressed: controller.close,
          icon: const Icon(Symbols.close),
        ),
      ],
    ),
  );
}
