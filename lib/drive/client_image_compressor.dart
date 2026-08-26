import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Compresses an already-decoded, already-resized image (any format the
/// platform codec can decode — PNG/JPEG/WebP/HEIF) down to a small
/// derivative using the platform's own native codecs.
///
/// The output format depends on the platform:
/// - Android/iOS produce WebP (`image/webp`).
/// - Desktop (macOS/Linux/Windows) produce JPEG (`image/jpeg`) because
///   flutter_image_compress cannot emit WebP off Android/iOS (the macOS
///   validator returns false for webp and the Swift encoder silently writes
///   JPEG anyway).
///
/// The caller must pass the returned mimeType to the server (prepare's
/// `compression_mime_type`), which presigns and validates the derivative
/// against that exact type.
///
/// The old path handed raw RGBA pixels to a vendored libwebp FFI fork
/// (`swipelab_webp`) and produced visually corrupt derivatives on some
/// platforms. flutter_image_compress encodes through the OS codecs, so the
/// encoder no longer runs in our process.
Future<({Uint8List bytes, String mimeType})?> compressClientImage({
  required Uint8List imageBytes,
  required int quality,
}) async {
  final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  final format = isMobile ? CompressFormat.webp : CompressFormat.jpeg;
  final mimeType = isMobile ? 'image/webp' : 'image/jpeg';

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
  return (bytes: result, mimeType: mimeType);
}
