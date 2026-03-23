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
  final bool showFullscreen;
  const UniversalVideo({
    super.key,
    required this.uri,
    this.aspectRatio = 16 / 9,
    this.autoplay = false,
    this.showFullscreen = true,
  });

  @override
  ConsumerState<UniversalVideo> createState() => _UniversalVideoState();
}

class _UniversalVideoState extends ConsumerState<UniversalVideo> {
  Player? _player;
  VideoController? _videoController;
  bool _isLoading = true;

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
        setState(() => _isLoading = false);
      }
    });

    _player!.stream.buffering.listen((buffering) {
      if (mounted) {
        setState(() => _isLoading = buffering);
      }
    });

    _player!.stream.error.listen((error) {
      debugPrint('Video player error: $error');
      if (mounted) {
        setState(() => _isLoading = false);
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
          seekBarPositionColor: primaryColor,
          seekBarColor: primaryColor.withValues(alpha: 0.3),
          seekBarBufferColor: primaryColor.withValues(alpha: 0.5),
          bottomButtonBar: [
            const MaterialPlayOrPauseButton(),
            const MaterialSeekBar(),
            const MaterialSkipNextButton(),
            if (widget.showFullscreen) const MaterialFullscreenButton(),
          ],
        ),
        fullscreen: MaterialVideoControlsThemeData(
          seekBarPositionColor: primaryColor,
          seekBarColor: primaryColor.withValues(alpha: 0.3),
          seekBarBufferColor: primaryColor.withValues(alpha: 0.5),
          bottomButtonBar: [
            const MaterialPlayOrPauseButton(),
            const MaterialSeekBar(),
            const MaterialSkipNextButton(),
            if (widget.showFullscreen) const MaterialFullscreenButton(),
          ],
        ),
        child: video,
      );
    } else {
      video = MaterialDesktopVideoControlsTheme(
        normal: MaterialDesktopVideoControlsThemeData(
          seekBarPositionColor: primaryColor,
          seekBarColor: primaryColor.withValues(alpha: 0.3),
        ),
        fullscreen: MaterialDesktopVideoControlsThemeData(
          seekBarPositionColor: primaryColor,
          seekBarColor: primaryColor.withValues(alpha: 0.3),
        ),
        child: video,
      );
    }

    return Stack(
      children: [
        video,
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
