import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';

class UniversalVideo extends StatelessWidget {
  final String uri;
  const UniversalVideo({super.key, required this.uri});

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      viewType: 'native-video',
      onPlatformViewCreated: (int viewId) {
        final element = web.HTMLVideoElement()..src = uri;
        element.controls = true;
        web.document.body!.append(element);
      },
    );
  }
}
