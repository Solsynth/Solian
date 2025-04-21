import 'dart:io';

import 'package:flutter/material.dart';
import 'package:native_video_player/native_video_player.dart';

class UniversalVideo extends StatefulWidget {
  final String uri;
  const UniversalVideo({super.key, required this.uri});

  @override
  State<UniversalVideo> createState() => _UniversalVideoState();
}

class _UniversalVideoState extends State<UniversalVideo> {
  NativeVideoPlayerController? _controller;
  bool _isPlaying = false;

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null) return;

    if (_isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }

    final isPlaying = await controller.isPlaying();
    setState(() {
      _isPlaying = isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) {
      return Stack(
        children: [
          NativeVideoPlayerView(
            onViewReady: (controller) async {
              _controller = controller;
              await controller.loadVideo(
                VideoSource(path: widget.uri, type: VideoSourceType.network),
              );
            },
          ),
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: _togglePlayback,
              child: Center(
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Image.network(widget.uri);
  }
}
