import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/media_kit_init.dart';
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
    this.source,
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

  /// Optional tag identifying who opened the media (e.g. `chat:<roomId>`
  /// for chat voice messages), used to tear playback down with its owner.
  final String? source;

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
    String? source,
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
    source: source ?? this.source,
  );
}

final mediaPlaybackProvider =
    NotifierProvider<MediaPlaybackController, MediaPlaybackState>(
      MediaPlaybackController.new,
    );

class MediaPlaybackController extends Notifier<MediaPlaybackState> {
  late final Player player;

  /// True when the current media was opened by a chat room's voice message.
  bool isChatVoiceOf(String roomId) => state.source == 'chat:$roomId';

  @override
  MediaPlaybackState build() {
    ensureMediaKitInitialized();
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
    String? source,
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
      source: source,
    );
    await player.open(Media(uri), play: autoplay);
  }

  /// Only continue playback in the dock/PiP while the parent player is
  /// actively playing; a paused or finished media stays with its origin.
  void dockWhenReleased(String uri) {
    if (state.uri == uri && state.playing) {
      state = state.copyWith(docked: true);
    }
  }

  void restoreInline(String uri) {
    if (state.uri == uri) state = state.copyWith(docked: false);
  }

  Future<void> close() async {
    await player.stop();
    state = const MediaPlaybackState();
  }
}

class MediaPlaybackDock extends ConsumerStatefulWidget {
  const MediaPlaybackDock({super.key});

  @override
  ConsumerState<MediaPlaybackDock> createState() => _MediaPlaybackDockState();
}

class _MediaPlaybackDockState extends ConsumerState<MediaPlaybackDock>
    with SingleTickerProviderStateMixin {
  static const double _dockHeight = 68;
  static const double _verticalInset = 12; // top 4 + bottom 8 padding
  static const Duration _animationDuration = Duration(milliseconds: 320);

  late final AnimationController _slide = AnimationController(
    vsync: this,
    duration: _animationDuration,
  );

  @override
  void dispose() {
    _slide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playback = ref.watch(mediaPlaybackProvider);
    // Video keeps playing in a floating overlay (see [FloatingVideoDock]);
    // only audio stays docked as a bottom bar.
    final visible =
        playback.docked &&
        playback.hasMedia &&
        playback.kind != MediaPlaybackKind.video;
    if (visible) {
      if (!_slide.isCompleted) _slide.forward();
    } else {
      if (!_slide.isDismissed) _slide.reverse();
    }
    if (!visible && _slide.isDismissed) return const SizedBox.shrink();

    final curved = CurvedAnimation(
      parent: _slide,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    // Same exit as [TaskOverlay]: the bar slides down while its slot
    // collapses to zero height, clipped so it never squeezes its layout.
    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) => SizedBox(
        height: curved.value * (_dockHeight + _verticalInset),
        child: ClipRect(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: FractionalTranslation(
                  translation: Offset(0, 1 - curved.value),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: _AudioDockBar(playback: playback),
      ),
    );
  }
}

class _AudioDockBar extends ConsumerWidget {
  const _AudioDockBar({required this.playback});

  final MediaPlaybackState playback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(mediaPlaybackProvider.notifier);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final maxMs = playback.duration.inMilliseconds.toDouble();
    final value = playback.position.inMilliseconds
        .toDouble()
        .clamp(0.0, maxMs)
        .toDouble();
    final buffered = playback.buffered.inMilliseconds
        .toDouble()
        .clamp(0.0, maxMs)
        .toDouble();

    return Material(
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      color: theme.colorScheme.surfaceContainerLow,
      child: SizedBox(
        height: _MediaPlaybackDockState._dockHeight,
        child: Row(
          children: [
            IconButton.filled(
              onPressed: controller.player.playOrPause,
              icon: Icon(
                playback.playing ? Symbols.pause : Symbols.play_arrow,
                fill: 1,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          playback.title.isEmpty ? 'Audio' : playback.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      Text(
                        '${playback.position.formatShortDuration()} / ${playback.duration.formatShortDuration()}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ).padding(horizontal: 8),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      activeTrackColor: primary,
                      inactiveTrackColor: primary.withValues(alpha: 0.22),
                      secondaryActiveTrackColor: primary.withValues(alpha: 0.4),
                      thumbColor: primary,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12,
                      ),
                    ),
                    child: Slider(
                      value: value,
                      secondaryTrackValue: buffered,
                      max: maxMs <= 0 ? 1.0 : maxMs,
                      onChanged: maxMs <= 0
                          ? null
                          : (next) => controller.player.seek(
                              Duration(milliseconds: next.round()),
                            ),
                      padding: EdgeInsets.zero,
                      year2023: true,
                    ),
                  ).padding(left: 16, right: 8),
                ],
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: controller.close,
              icon: const Icon(Symbols.close, fill: 1),
            ),
          ],
        ).padding(horizontal: 12, vertical: 8),
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

class _FloatingVideoDockState extends ConsumerState<FloatingVideoDock>
    with SingleTickerProviderStateMixin {
  static const double _initialWidth = 320;
  static const double _initialMinHeight = 180;
  static const double _initialMaxHeight = 240;
  static const double _minWidth = 200;
  static const double _minHeight = 120;
  static const double _maxWidth = 560;
  static const double _maxHeight = 480;
  static const double _margin = 16;
  static const double _dragBarHeight = 36;
  static const double _edgeHandleSize = 12;
  static const double _cornerHandleSize = 24;
  static const Duration _hideDelay = Duration(seconds: 1);
  static const Duration _appearDuration = Duration(milliseconds: 240);

  late final AnimationController _appear = AnimationController(
    vsync: this,
    duration: _appearDuration,
  );

  /// Top-left corner of the card; lazily initialized to the bottom-right on
  /// the first layout and moved by dragging.
  Offset? _position;

  /// User-resized card size; lazily initialized from the video aspect ratio.
  Size? _cardSize;

  bool _mouseOver = false;
  bool _controlsVisible = true;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    _appear.dispose();
    super.dispose();
  }

  void _showControls() {
    _hideTimer?.cancel();
    if (!_controlsVisible) setState(() => _controlsVisible = true);
    // Restart the hide countdown on every mouse move.
    _scheduleHide();
  }

  /// Toggle control visibility from a tap on the video surface.
  void _toggleControls() {
    if (_controlsVisible) {
      // While paused the controls stay put by design; hiding is a no-op.
      if (!ref.read(mediaPlaybackProvider).playing) return;
      _hideTimer?.cancel();
      setState(() => _controlsVisible = false);
    } else {
      _showControls();
    }
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(_hideDelay, _hideIfIdle);
  }

  void _hideIfIdle() {
    if (!mounted || _mouseOver) return;
    if (!ref.read(mediaPlaybackProvider).playing) return;
    setState(() => _controlsVisible = false);
  }

  void _seekTo(double dx, double width) {
    final playback = ref.read(mediaPlaybackProvider);
    final durationMs = playback.duration.inMilliseconds;
    if (durationMs <= 0 || width <= 0) return;
    final fraction = (dx / width).clamp(0.0, 1.0).toDouble();
    ref
        .read(mediaPlaybackProvider.notifier)
        .player
        .seek(Duration(milliseconds: (durationMs * fraction).round()));
  }

  void _resizeCard(Offset delta) {
    setState(() {
      _cardSize =
          (_cardSize ?? const Size(_initialWidth, _initialMinHeight)) + delta;
    });
  }

  @override
  Widget build(BuildContext context) {
    final playback = ref.watch(mediaPlaybackProvider);
    final visible =
        playback.docked &&
        playback.hasMedia &&
        playback.kind == MediaPlaybackKind.video;
    if (visible) {
      if (!_appear.isCompleted) _appear.forward();
    } else {
      // Reset the auto-hide state for the next appearance.
      _hideTimer?.cancel();
      _controlsVisible = true;
      _mouseOver = false;
      if (!_appear.isDismissed) _appear.reverse();
      if (_appear.isDismissed) return const SizedBox.shrink();
    }

    final size = MediaQuery.sizeOf(context);
    final ratio = playback.aspectRatio <= 0 ? 16 / 9 : playback.aspectRatio;
    final initialHeight = (_initialWidth / ratio)
        .clamp(_initialMinHeight, _initialMaxHeight)
        .toDouble();
    final cardSize = _cardSize ??= Size(_initialWidth, initialHeight);
    final maxCardWidth = math.max(
      _minWidth,
      math.min(_maxWidth, size.width - 2 * _margin),
    );
    final maxCardHeight = math.max(
      _minHeight,
      math.min(_maxHeight, size.height - 2 * _margin),
    );
    final cardWidth = cardSize.width.clamp(_minWidth, maxCardWidth).toDouble();
    final cardHeight = cardSize.height
        .clamp(_minHeight, maxCardHeight)
        .toDouble();
    final maxX = math.max(0.0, size.width - cardWidth - 2 * _margin);
    final maxY = math.max(0.0, size.height - cardHeight - 2 * _margin);
    final position = _position ??= Offset(maxX, maxY);
    final left = position.dx.clamp(0.0, maxX).toDouble();
    final top = position.dy.clamp(0.0, maxY).toDouble();

    final controller = ref.read(mediaPlaybackProvider.notifier);

    final maxMs = playback.duration.inMilliseconds.toDouble();
    final progress = maxMs <= 0
        ? 0.0
        : (playback.position.inMilliseconds / maxMs).clamp(0.0, 1.0).toDouble();

    // Paused always keeps the controls visible; only auto-hide while
    // playing with no mouse activity.
    final controlsVisible = _controlsVisible || !playback.playing;
    if (playback.playing && _controlsVisible && !_mouseOver) {
      if (!(_hideTimer?.isActive ?? false)) _scheduleHide();
    }

    return Positioned(
      left: left,
      top: top,
      child: FadeTransition(
        opacity: _appear,
        child: SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(0, 0.12),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _appear,
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                ),
              ),
          child: MouseRegion(
            onEnter: (_) {
              _mouseOver = true;
              _showControls();
            },
            onHover: (_) => _showControls(),
            onExit: (_) {
              _mouseOver = false;
              _scheduleHide();
            },
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
                      // Tap anywhere on the surface toggles the controls;
                      // mouse hover alone left touch users with no way in.
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _toggleControls,
                        // [MediaPlaybackController.close] resets the shared
                        // state while the exit animation is still running, so
                        // `uri` can be null here; a black surface keeps the
                        // exit animation intact instead of crashing the build
                        // on the null-check below.
                        child: playback.hasMedia
                            ? UniversalVideo(
                                uri: playback.uri!,
                                aspectRatio: playback.aspectRatio,
                                externalPlayer: controller.player,
                                persistent: false,
                                controls: NoVideoControls,
                              )
                            : const ColoredBox(color: Colors.black),
                      ),
                    ),
                    // Thin draggable progress bar; no timestamps. Sits above the
                    // bottom resize edge.
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: _edgeHandleSize + 2,
                      child: IgnorePointer(
                        ignoring: !controlsVisible,
                        child: AnimatedOpacity(
                          opacity: controlsVisible ? 1 : 0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          child: SizedBox(
                            // Generous invisible hit target around the 3px bar.
                            height: 20,
                            child: LayoutBuilder(
                              builder: (context, constraints) =>
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTapDown: (details) => _seekTo(
                                      details.localPosition.dx,
                                      constraints.maxWidth,
                                    ),
                                    onHorizontalDragUpdate: (details) =>
                                        _seekTo(
                                          details.localPosition.dx,
                                          constraints.maxWidth,
                                        ),
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 3,
                                        borderRadius: BorderRadius.circular(2),
                                        backgroundColor: Colors.white24,
                                        valueColor:
                                            const AlwaysStoppedAnimation(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Centered play/pause. Ignored while hidden so taps fall
                    // through to the surface toggle below.
                    Center(
                      child: IgnorePointer(
                        ignoring: !controlsVisible,
                        child: AnimatedOpacity(
                          opacity: controlsVisible ? 1 : 0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          child: IconButton.filled(
                            onPressed: controller.player.playOrPause,
                            icon: Icon(
                              playback.playing
                                  ? Symbols.pause
                                  : Symbols.play_arrow,
                              size: 28,
                              fill: 1,
                              color: Colors.white,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black.withValues(
                                alpha: 0.45,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Draggable top bar (stays draggable even while faded).
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: AnimatedOpacity(
                        opacity: controlsVisible ? 1 : 0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
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
                              height: _dragBarHeight,
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
                                    fill: 1,
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
                                      fill: 1,
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
                    ),
                    // Resize handles: right edge, bottom edge, bottom-right
                    // corner. Always active, like the drag bar.
                    Positioned(
                      right: 0,
                      top: _dragBarHeight,
                      bottom: _cornerHandleSize,
                      width: _edgeHandleSize,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.resizeLeftRight,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onHorizontalDragUpdate: (details) =>
                              _resizeCard(Offset(details.delta.dx, 0)),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: _cornerHandleSize,
                      bottom: 0,
                      height: _edgeHandleSize,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.resizeUpDown,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onVerticalDragUpdate: (details) =>
                              _resizeCard(Offset(0, details.delta.dy)),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      width: _cornerHandleSize,
                      height: _cornerHandleSize,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.resizeUpLeftDownRight,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onPanUpdate: (details) => _resizeCard(details.delta),
                          child: const SizedBox.expand(),
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
  }
}
