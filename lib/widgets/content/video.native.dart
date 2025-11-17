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

  void _openVideo() async {
    MediaKit.ensureInitialized();

    _player = Player();
    _videoController = VideoController(_player!);

    _player!.open(Media(widget.uri), play: widget.autoplay);
  }

  @override
  void initState() {
    super.initState();
    _openVideo();
  }

  @override
  void dispose() {
    super.dispose();
    _player?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoController == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Video(
      controller: _videoController!,
      aspectRatio: widget.aspectRatio != 1 ? widget.aspectRatio : null,
      fit: BoxFit.contain,
      controls:
          !kIsWeb && (Platform.isAndroid || Platform.isIOS)
              ? MaterialVideoControls
              : MaterialDesktopVideoControls,
    );
  }
}
