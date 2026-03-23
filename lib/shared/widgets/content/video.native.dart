import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class UniversalVideo extends ConsumerStatefulWidget {
  final String uri;
  final double aspectRatio;
  final bool autoplay;
  const UniversalVideo({
    super.key,
    required this.uri,
    this.aspectRatio = 16 / 9,
    this.autoplay = false,
  });

  @override
  ConsumerState<UniversalVideo> createState() => _UniversalVideoState();
}

class _UniversalVideoState extends ConsumerState<UniversalVideo> {
  Player? _player;
  VideoController? _videoController;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() {
    MediaKit.ensureInitialized();

    _player = Player();
    _videoController = VideoController(_player!);

    _player!.stream.playing.listen((playing) {
      if (mounted && playing) {
        setState(() => _isInitialLoading = false);
      }
    });

    _player!.stream.buffering.listen((buffering) {
      if (mounted && buffering) {
        setState(() => _isInitialLoading = true);
      } else if (mounted && !buffering && _player!.state.playing) {
        setState(() => _isInitialLoading = false);
      }
    });

    _player!.stream.error.listen((error) {
      debugPrint('Video player error: $error');
      if (mounted) {
        setState(() => _isInitialLoading = false);
      }
    });

    _player!.open(Media(widget.uri), play: widget.autoplay);
  }

  @override
  void dispose() {
    super.dispose();
    _player?.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
    );

    if (isMobile) {
      video = MaterialVideoControlsTheme(
        normal: MaterialVideoControlsThemeData(
          visibleOnMount: true,
          controlsHoverDuration: const Duration(hours: 1),
          seekBarPositionColor: primaryColor,
          seekBarColor: primaryColor.withValues(alpha: 0.3),
          seekBarBufferColor: primaryColor.withValues(alpha: 0.5),
          bottomButtonBar: [
            const MaterialPlayOrPauseButton(),
            const MaterialSeekBar(),
            const MaterialSkipNextButton(),
          ],
        ),
        fullscreen: MaterialVideoControlsThemeData(
          visibleOnMount: true,
          controlsHoverDuration: const Duration(hours: 1),
          seekBarPositionColor: primaryColor,
          seekBarColor: primaryColor.withValues(alpha: 0.3),
          seekBarBufferColor: primaryColor.withValues(alpha: 0.5),
          seekBarThumbColor: primaryColor,
          bottomButtonBar: [
            const MaterialPlayOrPauseButton(),
            const MaterialSeekBar(),
            const MaterialSkipNextButton(),
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
          ],
        ),
        child: video,
      );
    }

    return Stack(
      children: [
        video,
        if (_isInitialLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
