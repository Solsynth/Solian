import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

class UniversalVideo extends StatelessWidget {
  final String uri;
  final double? aspectRatio;
  final bool autoplay;
  final Player? externalPlayer;
  final bool persistent;
  const UniversalVideo({
    super.key,
    required this.uri,
    this.aspectRatio,
    this.autoplay = false,
    this.externalPlayer,
    this.persistent = true,
  });

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      tagName: 'video',
      onElementCreated: (element) {
        element as web.HTMLVideoElement;
        element.src = uri;
        element.style.width = '100%';
        element.style.height = '100%';
        element.controls = true;
      },
    );
  }
}
