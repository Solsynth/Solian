import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';

class UniversalImage extends StatelessWidget {
  final String uri;
  const UniversalImage({super.key, required this.uri});

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      viewType: 'native-image',
      onPlatformViewCreated: (int viewId) {
        final element = web.HTMLImageElement()..src = uri;
        web.document.body!.append(element);
      },
    );
  }
}
