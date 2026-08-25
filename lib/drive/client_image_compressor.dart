import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Compresses an already-decoded, already-resized image (any format the
/// platform codec can decode — PNG/JPEG/WebP/HEIF) down to a small
/// derivative using the platform's own native codecs.
///
/// The old path handed raw RGBA pixels to a vendored libwebp FFI fork
/// (`swipelab_webp`) and produced visually corrupt derivatives on some
/// platforms. flutter_image_compress encodes through the OS codecs
/// (Android/iOS/macOS), so the encoder no longer runs in our process.
///
/// WebP output is only supported on Android/iOS; desktop falls back to
/// JPEG (the platform validator throws UnsupportedError for webp on
/// macOS/Linux/Windows).
Future<({Uint8List bytes, String mimeType})?> compressClientImage({
  required Uint8List imageBytes,
  required int quality,
}) async {
  final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  final format = isMobile ? CompressFormat.webp : CompressFormat.jpeg;

  final Uint8List result;
  try {
    result = await FlutterImageCompress.compressWithList(
      imageBytes,
      minWidth: 1920,
      minHeight: 1920,
      quality: quality.clamp(0, 100),
      format: format,
    );
  } catch (_) {
    return null;
  }
  if (result.isEmpty) return null;
  return (
    bytes: result,
    mimeType: isMobile ? 'image/webp' : 'image/jpeg',
  );
}
