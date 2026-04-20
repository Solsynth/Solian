import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:material_symbols_icons/symbols.dart';

class UniversalVideo extends ConsumerStatefulWidget {
  final String uri;
  final double aspectRatio;
  final bool autoplay;
  final VoidCallback? onRetry;
  final Player? externalPlayer;
  const UniversalVideo({
    super.key,
    required this.uri,
    this.aspectRatio = 16 / 9,
    this.autoplay = false,
    this.onRetry,
    this.externalPlayer,
  });

  @override
  ConsumerState<UniversalVideo> createState() => UniversalVideoState();
}

class UniversalVideoState extends ConsumerState<UniversalVideo> {
  Player? _ownPlayer;
  VideoController? _videoController;
  bool _isInitialLoading = true;
  String? _errorMessage;
  bool _hasError = false;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Player get player => _ownPlayer ?? widget.externalPlayer!;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  @override
  void didUpdateWidget(UniversalVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uri != widget.uri) {
      _hasError = false;
      _errorMessage = null;
      _disposePlayer();
      _initPlayer();
    }
  }

  void _initPlayer() {
    MediaKit.ensureInitialized();

    _ownPlayer = widget.externalPlayer ?? Player();
    _videoController = VideoController(_ownPlayer!);

    _ownPlayer!.stream.playing.listen((playing) {
      if (mounted) {
        setState(() {
          _isPlaying = playing;
          _isInitialLoading = false;
          _hasError = false;
          _errorMessage = null;
        });
      }
    });

    _ownPlayer!.stream.buffering.listen((buffering) {
      if (mounted && buffering) {
        setState(() => _isInitialLoading = true);
      } else if (mounted && !buffering && _ownPlayer!.state.playing) {
        setState(() => _isInitialLoading = false);
      }
    });

    _ownPlayer!.stream.error.listen((error) {
      debugPrint('Video player error: $error');
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
          _hasError = true;
          _errorMessage = error;
        });
      }
    });

    _ownPlayer!.open(Media(widget.uri), play: widget.autoplay);
  }

  void _disposePlayer() {
    if (_ownPlayer != null && widget.externalPlayer == null) {
      _ownPlayer!.dispose();
      _ownPlayer = null;
    }
    _videoController = null;
  }

  void _handleRetry() {
    widget.onRetry?.call();
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _isInitialLoading = true;
    });
    _disposePlayer();
    _initPlayer();
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
      controls: isMobile ? MaterialVideoControls : MaterialDesktopVideoControls,
      fill: Colors.transparent,
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
