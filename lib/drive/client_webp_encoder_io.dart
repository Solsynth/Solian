import 'dart:typed_data';

import 'package:swipelab_webp/swipelab_webp.dart';

Uint8List? encodeLossyWebP({
  required Uint8List rgba,
  required int width,
  required int height,
  required double quality,
}) {
  return WebPEncoder.encodeRgba(
    rgba: rgba,
    width: width,
    height: height,
    quality: quality,
  );
}
