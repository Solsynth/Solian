import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class UniversalVideo extends StatelessWidget {
  final String uri;
  final double? aspectRatio;
  final bool autoplay;
  final Player? externalPlayer;
  final bool persistent;
  final VideoControlsBuilder? controls;
  const UniversalVideo({
    super.key,
    required this.uri,
    this.aspectRatio,
    this.autoplay = false,
    this.externalPlayer,
    this.persistent = true,
    this.controls,
  });

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      tagName: 'video',
      onElementCreated: (element) {
        final video = element as web.HTMLVideoElement;
        video.src = uri;
        video.style.width = '100%';
        video.style.height = '100%';
        video.controls = true;
        video.playsInline = true;
        if (autoplay) {
          video.autoplay = true;
          // Browsers require muted media to autoplay without user gesture.
          video.muted = true;
        }
      },
    );
  }
}
