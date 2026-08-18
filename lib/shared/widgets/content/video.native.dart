import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/core/media_kit_init.dart';
import 'package:island/shared/widgets/content/media_playback.dart';

/// Sentinel default for [UniversalVideo.controls]: replaced in [build] with
/// the platform's built-in controls. An explicit `null` (i.e.
/// [NoVideoControls]) is preserved, disabling the built-in controls.
// `VideoControlsBuilder` is not exported by media_kit_video on web (only the
// native variant defines it), so use the underlying function type directly.
const Widget Function(VideoState) _unsetControls = _noOpControlsForUnset;

Widget _noOpControlsForUnset(VideoState state) => const SizedBox.shrink();

class UniversalVideo extends ConsumerStatefulWidget {
  final String uri;
  final double aspectRatio;
  final bool autoplay;
  final VoidCallback? onRetry;
  final Player? externalPlayer;
  final bool persistent;
  final Widget Function(VideoState)? controls;
  const UniversalVideo({
    super.key,
    required this.uri,
    this.aspectRatio = 16 / 9,
    this.autoplay = false,
    this.onRetry,
    this.externalPlayer,
    this.persistent = true,
    this.controls = _unsetControls,
  });

  @override
  ConsumerState<UniversalVideo> createState() => UniversalVideoState();
}

class UniversalVideoState extends ConsumerState<UniversalVideo> {
  Player? _ownPlayer;
  VideoController? _videoController;
  String? _errorMessage;
  bool _hasError = false;
  bool _isPlaying = false;
  StreamSubscription<bool>? _playingSubscription;
  StreamSubscription<String>? _errorSubscription;
  Future<void> _playerLifecycle = Future.value();
  bool _isDisposed = false;
  // Riverpod forbids touching `ref` in State.dispose(), so the controller is
  // captured eagerly (lazily, on first use) and reused for dock handoff.
  MediaPlaybackController? _playbackController;

  bool get isPlaying => _isPlaying;

  Player get player => _ownPlayer ?? widget.externalPlayer!;

  @override
  void initState() {
    super.initState();
    if (widget.persistent) {
      _playbackController ??= ref.read(mediaPlaybackProvider.notifier);
      // Deferred: modifying a provider during initState (a widget lifecycle)
      // is forbidden by Riverpod. The inline view is (re)appearing, so hand
      // the media back from the dock/PiP.
      scheduleMicrotask(() {
        if (mounted) _playbackController?.restoreInline(widget.uri);
      });
    }
    _queuePlayerInitialization();
  }

  @override
  void didUpdateWidget(UniversalVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uri != widget.uri) {
      _hasError = false;
      _errorMessage = null;
      _queuePlayerInitialization(replacePlayer: true);
    }
  }

  void _queuePlayerInitialization({bool replacePlayer = false}) {
    _playerLifecycle = _playerLifecycle.then((_) async {
      if (replacePlayer) await _disposePlayer();
      if (!_isDisposed) await _initPlayer();
    });
  }

  Future<void> _initPlayer() async {
    ensureMediaKitInitialized();

    final controller = _playbackController ??= ref.read(
      mediaPlaybackProvider.notifier,
    );
    final usePersistentPlayer =
        widget.externalPlayer == null && widget.persistent;
    final player =
        widget.externalPlayer ??
        (usePersistentPlayer ? controller!.player : Player());
    _ownPlayer = player;
    _videoController = VideoController(player);
    if (mounted && !_isDisposed) setState(() {});

    _playingSubscription = player.stream.playing.listen((playing) {
      if (!mounted || _isDisposed) return;
      setState(() {
        _isPlaying = playing;
        _hasError = false;
        _errorMessage = null;
      });
    });

    _errorSubscription = player.stream.error.listen((error) {
      debugPrint('Video player error: $error');
      if (!mounted || _isDisposed) return;
      setState(() {
        _hasError = true;
        _errorMessage = error;
      });
    });

    if (usePersistentPlayer) {
      // NOTE: No Authorization header is sent to media_kit on purpose. The
      // media endpoint 307-redirects to a pre-signed storage URL, and mpv's
      // HTTP stack forwards custom headers on redirects, which makes the
      // signed URL reject the request (400/403) and playback fails.
      await controller!.open(
        uri: widget.uri,
        title: _titleFromUri(widget.uri),
        kind: MediaPlaybackKind.video,
        autoplay: widget.autoplay,
        aspectRatio: widget.aspectRatio,
      );
    } else if (widget.externalPlayer == null) {
      await player.open(Media(widget.uri), play: widget.autoplay);
    }
  }

  String _titleFromUri(String uri) {
    final segments = Uri.tryParse(uri)?.pathSegments ?? const <String>[];
    return segments.isEmpty ? 'Video' : segments.last;
  }

  Future<void> _disposePlayer() async {
    await _playingSubscription?.cancel();
    await _errorSubscription?.cancel();
    _playingSubscription = null;
    _errorSubscription = null;

    final player = _ownPlayer;
    _ownPlayer = null;
    _videoController = null;

    if (player != null && widget.externalPlayer == null && !widget.persistent) {
      await player.dispose();
    }
  }

  void _handleRetry() {
    widget.onRetry?.call();
    setState(() {
      _hasError = false;
      _errorMessage = null;
    });
    _queuePlayerInitialization(replacePlayer: true);
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Detach the stream listeners now so no late event can reach a defunct
    // element; the queued [_disposePlayer] re-cancels them (idempotent).
    unawaited(_playingSubscription?.cancel());
    unawaited(_errorSubscription?.cancel());
    if (widget.persistent) {
      // Deferred: modifying a provider from dispose is forbidden by Riverpod.
      scheduleMicrotask(() {
        _playbackController?.dockWhenReleased(widget.uri);
      });
    }
    _playerLifecycle = _playerLifecycle.then((_) => _disposePlayer());
    super.dispose();
  }

  Future<void> play() async {
    await player.play();
  }

  Future<void> pause() async {
    await player.pause();
  }

  Future<void> playPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _VideoErrorWidget(
        errorMessage: _errorMessage ?? 'Unknown error',
        onRetry: _handleRetry,
        aspectRatio: widget.aspectRatio,
      );
    }

    if (_videoController == null) {
      return Container(
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    Widget video = Video(
      controller: _videoController!,
      aspectRatio: widget.aspectRatio != 1 ? widget.aspectRatio : null,
      fit: BoxFit.contain,
      controls: identical(widget.controls, _unsetControls)
          ? (isMobile ? MaterialVideoControls : MaterialDesktopVideoControls)
          : widget.controls,
      fill: const Color.fromARGB(0, 0, 0, 0),
      filterQuality: FilterQuality.high,
    );

    if (isMobile) {
      video = MaterialVideoControlsTheme(
        normal: MaterialVideoControlsThemeData(
          visibleOnMount: true,
          controlsHoverDuration: const Duration(hours: 1),
          seekBarPositionColor: primaryColor,
          seekBarColor: primaryColor.withValues(alpha: 0.3),
          seekBarBufferColor: primaryColor.withValues(alpha: 0.5),
          seekBarThumbColor: primaryColor,
          bottomButtonBar: const [
            MaterialPositionIndicator(),
            Spacer(),
            MaterialFullscreenButton(),
          ],
        ),
        fullscreen: MaterialVideoControlsThemeData(
          visibleOnMount: true,
          controlsHoverDuration: const Duration(hours: 1),
          seekBarPositionColor: primaryColor,
          seekBarColor: primaryColor.withValues(alpha: 0.3),
          seekBarBufferColor: primaryColor.withValues(alpha: 0.5),
          seekBarThumbColor: primaryColor,
          bottomButtonBar: const [
            MaterialPositionIndicator(),
            Spacer(),
            MaterialFullscreenButton(),
          ],
        ),
        child: video,
      );
    } else {
      video = MaterialDesktopVideoControlsTheme(
        normal: MaterialDesktopVideoControlsThemeData(
          visibleOnMount: true,
          controlsHoverDuration: const Duration(hours: 1),
          seekBarPositionColor: primaryColor,
          seekBarColor: primaryColor.withValues(alpha: 0.3),
          seekBarBufferColor: primaryColor.withValues(alpha: 0.5),
          seekBarThumbColor: primaryColor,
          bottomButtonBar: const [
            MaterialDesktopSkipPreviousButton(),
            MaterialDesktopPlayOrPauseButton(),
            MaterialDesktopSkipNextButton(),
            MaterialDesktopVolumeButton(),
            MaterialDesktopPositionIndicator(),
            Spacer(),
            MaterialDesktopFullscreenButton(),
          ],
        ),
        fullscreen: MaterialDesktopVideoControlsThemeData(
          visibleOnMount: true,
          controlsHoverDuration: const Duration(hours: 1),
          seekBarPositionColor: primaryColor,
          seekBarColor: primaryColor.withValues(alpha: 0.3),
          seekBarBufferColor: primaryColor.withValues(alpha: 0.5),
          seekBarThumbColor: primaryColor,
          bottomButtonBar: const [
            MaterialDesktopSkipPreviousButton(),
            MaterialDesktopPlayOrPauseButton(),
            MaterialDesktopSkipNextButton(),
            MaterialDesktopVolumeButton(),
            MaterialDesktopPositionIndicator(),
            Spacer(),
            MaterialDesktopFullscreenButton(),
          ],
        ),
        child: video,
      );
    }

    return video;
  }
}

class _VideoErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final double aspectRatio;

  const _VideoErrorWidget({
    required this.errorMessage,
    required this.onRetry,
    required this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red[700]!, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Symbols.error, size: 48, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(
                  'Video Playback Error',
                  style: TextStyle(
                    color: Colors.red[400],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Error Details:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        errorMessage,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Symbols.refresh, size: 18),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: errorMessage));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Symbols.content_copy, size: 18),
                      label: const Text('Copy'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white30),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
