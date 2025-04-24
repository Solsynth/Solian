import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';

class UniversalVideo extends StatelessWidget {
  final String uri;
  final double aspectRatio;
  const UniversalVideo({
    super.key,
    required this.uri,
    required this.aspectRatio,
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
