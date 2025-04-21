import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class UniversalImage extends StatelessWidget {
  final String uri;
  final String? blurHash;
  const UniversalImage({super.key, required this.uri, this.blurHash});

  @override
  Widget build(BuildContext context) {
    final params = {'src': uri, 'blur': blurHash};
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: 'native-image',
        layoutDirection: TextDirection.ltr,
        creationParams: params,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    if (Platform.isIOS) {
      // For iOS: Use UiKitView to embed a native iOS image view
      return UiKitView(
        viewType: 'native-image',
        layoutDirection: TextDirection.ltr,
        creationParams: params,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Image.network(uri);
  }
}
