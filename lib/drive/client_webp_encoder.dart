import 'dart:typed_data';

import 'client_webp_encoder_stub.dart'
    if (dart.library.io) 'client_webp_encoder_io.dart' as platform;

Uint8List? encodeLossyWebP({
  required Uint8List rgba,
  required int width,
  required int height,
  required double quality,
}) {
  return platform.encodeLossyWebP(
    rgba: rgba,
    width: width,
    height: height,
    quality: quality,
  );
}
