import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/services/time.dart';
import 'package:island/shared/widgets/content/media_playback.dart';

import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class UniversalAudio extends ConsumerStatefulWidget {
  final String uri;
  final String filename;
  final bool autoplay;
  const UniversalAudio({
    super.key,
    required this.uri,
    required this.filename,
    this.autoplay = false,
  });

  @override
  ConsumerState<UniversalAudio> createState() => _UniversalAudioState();
}

class _UniversalAudioState extends ConsumerState<UniversalAudio> {
  bool _sliderWorking = false;
  Duration _sliderPosition = Duration.zero;
  // Riverpod forbids touching `ref` in State.dispose(), so the controller is
  // captured lazily and reused for the dock handoff.
  MediaPlaybackController? _playbackController;

  Future<void> _initPlayer() async {
    // NOTE: No Authorization header is sent to media_kit on purpose. The
    // media endpoint 307-redirects to a pre-signed storage URL, and mpv's
    // HTTP stack forwards custom headers on redirects, which makes the
    // signed URL reject the request (400/403) and playback fails.
    final controller =
        _playbackController ??= ref.read(mediaPlaybackProvider.notifier);
    await controller!.open(
      uri: widget.uri,
      title: widget.filename,
      kind: MediaPlaybackKind.audio,
      autoplay: widget.autoplay,
    );
  }

  @override
  void initState() {
    super.initState();
    _playbackController ??= ref.read(mediaPlaybackProvider.notifier);
    // Deferred: modifying a provider during initState (a widget lifecycle)
    // is forbidden by Riverpod. The inline view is (re)appearing, so hand
    // the media back from the dock.
    scheduleMicrotask(() {
      if (mounted) _playbackController?.restoreInline(widget.uri);
    });
    if (widget.autoplay) _initPlayer();
  }

  @override
  void didUpdateWidget(UniversalAudio oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uri != widget.uri && widget.autoplay) {
      _initPlayer();
    }
  }

  @override
  void dispose() {
    // Deferred: modifying a provider from dispose is forbidden by Riverpod.
    scheduleMicrotask(() {
      _playbackController?.dockWhenReleased(widget.uri);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playback = ref.watch(mediaPlaybackProvider);
    final controller = ref.read(mediaPlaybackProvider.notifier);
    final isActive = playback.uri == widget.uri;
    final position = isActive ? playback.position : Duration.zero;
    final duration = isActive ? playback.duration : Duration.zero;
    final buffered = isActive ? playback.buffered : Duration.zero;
    if (!_sliderWorking) _sliderPosition = position;
    final maximum = duration.inMilliseconds.toDouble();
    final sliderValue = _sliderPosition.inMilliseconds
        .toDouble()
        .clamp(0.0, maximum <= 0 ? 1.0 : maximum)
        .toDouble();

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Row(
        children: [
          IconButton.filled(
            onPressed: () async {
              if (!isActive) {
                await _initPlayer();
                await controller.player.play();
              } else {
                await controller.player.playOrPause();
              }
              if (mounted) setState(() {});
            },
            icon: isActive && playback.playing
                ? const Icon(Symbols.pause, fill: 1, color: Colors.white)
                : const Icon(Symbols.play_arrow, fill: 1, color: Colors.white),
          ),
          const Gap(20),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: (isActive && playback.playing || _sliderWorking)
                      ? SizedBox(
                          width: double.infinity,
                          key: const ValueKey('playing'),
                          child: Text(
                            '${position.formatShortDuration()} / ${duration.formatShortDuration()}',
                          ),
                        )
                      : SizedBox(
                          width: double.infinity,
                          key: const ValueKey('filename'),
                          child: Text(
                            widget.filename.isEmpty ? 'Audio' : widget.filename,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                ),
                Slider(
                  value: sliderValue,
                  secondaryTrackValue: buffered.inMilliseconds
                      .toDouble()
                      .clamp(0.0, maximum <= 0 ? 1.0 : maximum)
                      .toDouble(),
                  max: maximum <= 0 ? 1.0 : maximum,
                  onChangeStart: (_) {
                    _sliderWorking = true;
                  },
                  onChanged: (value) {
                    _sliderPosition = Duration(milliseconds: value.toInt());
                    setState(() {});
                  },
                  onChangeEnd: (value) {
                    _sliderPosition = Duration(milliseconds: value.toInt());
                    _sliderWorking = false;
                    controller.player.seek(_sliderPosition);
                  },
                  year2023: true,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ).padding(horizontal: 24, vertical: 16),
    );
  }
}
